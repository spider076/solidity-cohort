// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts@1.3.0/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts@1.3.0/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts@1.3.0/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

interface IOpinex {
    function updateQuestion(bytes calldata data) external;
}

contract OpinexConsumer is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;
    address public opinexContract; // Opinex contract address

    event Response(bytes32 indexed requestId, bytes response, bytes err);
    // event RequestSent(bytes32 indexed requestId);

    constructor(address router, address _opinexContract)
        FunctionsClient(router)
        ConfirmedOwner(msg.sender)
    {
        opinexContract = _opinexContract;
    }

    function sendRequest(
        string memory source,
        uint64 subscriptionId,
        uint32 gasLimit,
        bytes32 donID
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        emit RequestSent(s_lastRequestId);
        return s_lastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert("UnexpectedRequestID");
        }

        s_lastResponse = response;
        s_lastError = err;

        if (response.length > 0 && opinexContract != address(0)) {
            IOpinex(opinexContract).updateQuestion(response);
        }

        emit Response(requestId, response, err);
    }

    function setOpinexContract(address _opinexContract) external onlyOwner {
        opinexContract = _opinexContract;
    }
}
