// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EToken is ERC20 {
    constructor(
        uint256 initalSupply,
        string memory token,
        string memory symbol
    ) ERC20(token, symbol) {
        _mint(msg.sender, initalSupply);
    }

    function decimals() public pure override returns (uint8) {
        return 1;
    }
}
