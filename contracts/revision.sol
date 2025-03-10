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
        // uint256 result = A(a).getter();
        (bool result, bytes memory data) = a.staticcall(abi.encodeWithSignature("getter()"));
        // staticcall : you use staticcall when there is no storage state required to change.

        require(result, "read failed !");

        uint value = abi.decode(data, (uint));

        return value;
    }

    function getterUsingDirectMethod() public view returns(uint256) {
        return A(a).getter(); // this is how you can access the getter function if you have the interface or the contract onsite
    }

    function pay(uint256 _x) public payable {
        (bool result, ) = a.call{value: msg.value, gas : 50000}(
            abi.encodeWithSignature("pay(uint256)", _x)
        );

        require(result, "transaction failed ");
    }
}


// delegate call example

contract delegateContract {
    uint public value;

    function setter(uint _x) public {
        value = _x;
    }
}

contract callerContract {
    uint public value;

    function setter(uint _x, address _delegateAddr) public {
        bytes memory data = abi.encodeWithSignature("setter(uint256)", _x);

       (bool success,) = _delegateAddr.delegatecall(data);

       require(success, "transaction failed !");
    }
}