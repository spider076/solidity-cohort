// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    function transfer(address recipent, uint256 amount) external;
}

contract Token is IERC20 {
    event Transfer(address recipent, uint256 amount);

    function transfer(address _recipent, uint256 _amount) external {
        emit Transfer(_recipent, _amount);
    }
}

contract AbiEncode {
    function tokenContractTransferEncode(address _tokenAddr, bytes memory _data)
        public
        returns (bool)
    {
        (bool ok, ) = _tokenAddr.call(_data);
        return ok;
    }

    function tokenContractTransferInshort(
        address _tokenAddr,
        address _recipent,
        uint256 _amount
    ) public returns (bytes memory) {
        bytes memory data = abi.encodeCall(
            IERC20.transfer,
            (_recipent, _amount)
        );
        (bool ok, bytes memory result) = _tokenAddr.call(data);
        require(ok, "Transaction Failed !");
        return result;
    }

    function abiEncodeWithSignature(address _recipent, uint256 _amount)
        public
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSignature(
                "transfer(address, uint256)",
                _recipent,
                _amount
            );
    }

    function abiEncodeWithSelector(address _recipent, uint256 _amount)
        public
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                IERC20.transfer.selector,
                _recipent,
                _amount
            );
    }

    function abiEncodeCall(address _recipent, uint256 _amount)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(IERC20.transfer, (_recipent, _amount));
    }
}
