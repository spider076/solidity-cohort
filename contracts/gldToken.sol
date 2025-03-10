// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDTOKEN is ERC20 {
    address public owner;
    mapping(address => bool) internal freezedAccounts;
    bool public transfersPause;

    constructor() ERC20("Gotcha", "GLD") {
        owner = msg.sender;
        _mint(msg.sender, 1000 * 10 ** decimals()); // Adjust for decimals
    }

    // Use constant for decimals to save gas
    uint8 public constant DECIMALS = 2;

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Authorized");
        _;
    }

    modifier isAccNotFreezed(address account) {
        require(!freezedAccounts[account], "Account is frozen");
        _;
    }

    // Mint tokens (restricted to owner)
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    // Burn tokens (anyone can burn their own tokens)
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // Freeze an account (restricted to owner)
    function freeze(address account) external onlyOwner {
        freezedAccounts[account] = true;
    }

    // Unfreeze an account (restricted to owner)
    function unfreeze(address account) external onlyOwner {
        freezedAccounts[account] = false;
    }

    // Pause transfers (restricted to owner)
    function pause() external onlyOwner {
        transfersPause = true;
    }

    // Unpause transfers (restricted to owner)
    function unpause() external onlyOwner {
        transfersPause = false;
    }

    // Transfer ownership (restricted to owner)
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    // Override transfer to include pause check
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(!transfersPause, "Transfers paused");
        return super.transfer(recipient, amount);
    }

    // Override transferFrom to include freeze and pause checks
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override isAccNotFreezed(sender) returns (bool) {
        require(!transfersPause, "Transfers paused");
        return super.transferFrom(sender, recipient, amount);
    }
}