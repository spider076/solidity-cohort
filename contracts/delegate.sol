// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Library {
    uint256 public balance;

    function deposit(uint256 _amount) external {
        balance += _amount;
    }

    function withdraw(uint256 _amount) external {
        balance -= _amount;
    }
}

contract Main {
    uint256 public balance;

    function deposit(address _library, uint256 _amount) external {
        bytes memory data = abi.encodeWithSignature(
            "deposit(uint256)",
            _amount
        );

        (bool ok, ) = _library.delegatecall(data);
        require(ok, "transaction failed");
    }

    function withdraw(address _library, uint256 _amount) external {
        bytes memory data = abi.encodeWithSignature(
            "withdraw(uint256)",
            _amount
        );

        (bool ok, ) = _library.delegatecall(data);
        require(ok, "transaction failed");
    }
}
