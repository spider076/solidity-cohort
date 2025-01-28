// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Book {
    string public name;
    string author;
    uint256 price;

    function setDetails(
        string calldata _name,
        string calldata _author,
        uint256 _price
    ) public {
        name = _name;
        author = _author;
        price = _price;
    }

    function getDetails()
        public
        view
        returns (
            string memory,
            string memory,
            uint256
        )
    {
        return (name, author, price);
    }
}

contract Book1 {
    Book b1 = new Book();

    function getAdr() public view returns (Book) {
        return b1;
    }

    function detailsSetter(
        string calldata _name,
        string calldata _author,
        uint256 _price
    ) public {
        b1.setDetails(_name, _author, _price);
    }

    function getterDetails()
        public
        view
        returns (
            string memory,
            string memory,
            uint256
        )
    {
        return b1.getDetails();
    }
}

// Inheritence Example

contract Car {
    uint256 public wheels = 4;
    uint256 public doors = 4;
    string public brandName = "CTE";
    uint256 public headlights = 2;
    bool public safetyBag = true;
}

contract SuperCar is Car {
    uint256 public speed = 400;
    uint256 public modelNumber = 121;
    string public modelName = "Texxo";
}

// Abstraction Example
// An abstract contract in Solidity:

// Acts as a blueprint for other contracts.
// Cannot be deployed on its own; you must create a child contract that implements its functionality.
// Contains at least one function without implementation, called an abstract function.
// Think of it like a design plan that defines what must exist, but not how it works.

abstract contract Animal {
    bool public isAnimal = false;

    constructor(bool _isAnimal) {
        isAnimal = _isAnimal;
    }

    function makeSound() public virtual returns (string memory);
}

contract dog is Animal {
    constructor() Animal(true) {}

    function makeSound() public pure override returns (string memory) {
        return "WOOF !";
    }
}

contract human is Animal {
    constructor() Animal(false) {}

    function makeSound() public pure override returns (string memory) {
        return "Hushh !";
    }
}

// interface example

interface IGreet {
    function greet() external pure returns (string memory);
}

contract Greeter is IGreet {
    function greet() public pure returns (string memory) {
        return "HOLA !";
    }
}

contract sayHola {
    function getHola(address _greeterAdr) public pure returns (string memory) {
        return IGreet(_greeterAdr).greet();
    }
}
