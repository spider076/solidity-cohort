// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

contract A {
    uint256 value;
    uint256 x;

    function setter(uint256 _x) public {
        x = _x;
    }

    function getter() public view returns (uint256) {
        return x;
    }

    function pay(uint256 _x) public payable {
        x = _x;
        value = msg.value;
    }
}

contract B {
    address a;

    constructor(address _a_contractAddr) {
        a = _a_contractAddr;
    }

    function setter(uint256 _x) public {
        (bool result, ) = a.call(abi.encodeWithSignature("setter(uint256)", _x));
        require(result, "transaction failed !");
    }

    function getter() public view returns (uint256) {
        uint256 result = A(a).getter();

        return result;
    }

    function pay(uint256 _x) public payable {
        (bool result, ) = a.call{value: msg.value}(
            abi.encodeWithSignature("setter(uint256)", _x)
        );

        require(result, "transaction failed ");
    }
}
