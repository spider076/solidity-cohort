//  SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Storage {
    string public str = "hello";

    function storageex() public {
        string storage ex = str;
    }
}
