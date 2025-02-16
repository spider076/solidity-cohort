// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract walletDemo {
    address public owner;
    event Status(string message);

    constructor() {
        owner = msg.sender;
    }

    function paytouser(address payable _to, uint256 _amount) public payable {
        require(address(this).balance > _amount, "insufficient balance");
        require(_to != address(0), "invalid address");

        _to.transfer(_amount);
        emit Status("money sent to the damn user !");
    }

    function transferToContract() external payable {}

    function paytoowner() external payable {
        require(msg.value >= 1000000000, "sfsxfsd");

        payable(owner).transfer(msg.value);
    }

    function paytoOther(address other) external payable {
        require(msg.value >= 1000000000, "requires more eth to send !");

        payable(other).transfer(msg.value);
    }

    // fallback() external payable {
    //     emit Status("something went wrong !");
    // }

    receive() external payable {
        emit Status("money recieved in the contract !");
    }
}
