// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Wallet {
    address public owner;
    string public status;

    constructor() {
        owner = msg.sender;
    }

    struct Transaction {
        address sender;
        address receiver;
        uint256 timestamp;
        uint256 amount;
    }

    Transaction[] public transactionHistory;

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function topUpBalance() public payable {
        require(
            msg.value >= 1000000000000000000,
            "You need to topup with atleast one eth !"
        );

        transactionHistory.push(
            Transaction(msg.sender, address(this), block.timestamp, msg.value)
        );
    }

    function payViaContract(address payable _to, uint256 _amount)
        public
        payable
        isSuspiciosUser(msg.sender)
    {
        require(address(this).balance > _amount, "Insufficient Balance !");
        require(_to != address(0), "Address format incorrect !");

        _to.transfer(_amount);

        transactionHistory.push(
            Transaction(msg.sender, _to, block.timestamp, _amount)
        );
    }

    function payViaMsgValue(address payable _to)
        public
        payable
        isSuspiciosUser(msg.sender)
    {
        require(address(this).balance > msg.value, "Insufficient balance");

        _to.transfer(msg.value);

        transactionHistory.push(
            Transaction(msg.sender, _to, block.timestamp, msg.value)
        );
    }

    function receiveFromUser() external payable {
        require(msg.value >= 0, "Eth cannot be zero !");

        payable(owner).transfer(msg.value);

        transactionHistory.push(
            Transaction(msg.sender, owner, block.timestamp, msg.value)
        );
    }

    function getOwnerBalance()
        public
        view
        isSuspiciosUser(msg.sender)
        returns (uint256)
    {
        return owner.balance;
    }

    modifier isSuspiciosUser(address _user) {
        require(suspiciosUsers[_user] < 5, "User is reported multiple times!");
        _;
    }

    function suspiciosUser(address _user) internal {
        suspiciosUsers[_user] += 1;
    }

    mapping(address => uint256) private suspiciosUsers;

    receive() external payable {
        status = "received function triggered !";

        transactionHistory.push(
            Transaction(msg.sender, address(this), block.timestamp, msg.value)
        );
    }

    fallback() external payable {
        status = "unknown error occured !";
        payable(msg.sender).transfer(msg.value);

        suspiciosUser(msg.sender);
    }
}
