// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDTOKEN is ERC20 {
    address public owner;

    constructor() ERC20("Gotcha", "GLD") {
        owner = msg.sender;
        _mint(msg.sender, 10000000000000000000000);
    }

    mapping(address => bool) internal freezedAccounts;
    bool public transfersPause;

    // function decimals() public pure override returns (uint8) {
    //     return 0;
    // }

    modifier _isAccFreezed(address account) {
        require(!freezedAccounts[account], "The Account is freezed");
        _;
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "Not Authorized");
        _;
    }

    function mint(address account, uint256 amount) public _onlyOwner {
        _mint(account, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function freeze(address account) public _onlyOwner {
        freezedAccounts[account] = true;
    }

    function unfreeze(address account) public _onlyOwner {
        freezedAccounts[account] = false;
    }

    function pause() public _onlyOwner {
        transfersPause = true;
    }

    function unpause() public _onlyOwner {
        transfersPause = false;
    }

    function transferOwnership(address newOwner) public _onlyOwner {
        owner = newOwner;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(!transfersPause, "Token transfers are paused");
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override _isAccFreezed(sender) returns (bool) {
        require(!transfersPause, "Token transfers are paused");
        return super.transferFrom(sender, recipient, amount);
    }
}
