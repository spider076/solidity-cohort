// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

contract visibility {
    function publicFunc() public pure returns (string memory) {       
        return "PUBLIC";
    }

    function privateFunc() private pure returns (string memory) {
        return "PRIVATE";
    }

    function externalFunc() external pure returns (string memory) {   
        return "EXTERNAL";
    }

    function internalFunc() internal pure returns (string memory) {
        return "INTERNAL";
    }
}

contract other {
    visibility v = new visibility();
    
    string public output = v.externalFunc();
}
