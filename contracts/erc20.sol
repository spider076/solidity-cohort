// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract erc20 is IERC20 {
    uint256 supply = 1000;
    address public founder;
    uint decimal = 0;

    mapping(address => uint256) balanceOfUser;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        founder = msg.sender;
        balanceOfUser[msg.sender] = supply; // initially all the tokens are with the founder
    }

    function totalSupply() external view returns (uint256) {
        return supply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balanceOfUser[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid address !");
        require(
            balanceOfUser[msg.sender] > value,
            "You dont have enough tokens to transfer !"
        );

        balanceOfUser[msg.sender] -= value;
        balanceOfUser[to] += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        require(owner != address(0), "Invalid address !");
        require(spender != address(0), "Invalid address !");

        return allowed[owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "Invalid address !");
        require(
            balanceOfUser[msg.sender] > value,
            "You dont have enough tokens to transfer !"
        );

        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        require(from != address(0), "Invalid address !");
        require(to != address(0), "Invalid address !");
        require(
            allowed[from][to] > value,
            "You dont have enough tokens to transfer !"
        );
        allowed[from][to] -= value;

        balanceOfUser[from] -= value;
        balanceOfUser[to] += value;

        emit Transfer(from, to, value);

        return true;
    }
}
