// SPDX-License-Identifier: GPL-3.1

pragma solidity ^0.8.2;

contract basics {
    // int256 private val = 10;
    // bool public user = false;

    // constructor(int256 _valuee) {
    //     val = _valuee;
    //     user = true;
    // }

    // modifier userVerify(bool _user) {
    //     require(_user, "user must be logged in !");
    //     _;
    // }

    // function logOut() public {
    //     user = false;
    // }

    // function changeVal() public userVerify(user) {
    //     for (int256 i = 0; i <= 10; i++) {
    //         val++;
    //     }
    // }

    // function showVal() public view userVerify(user) returns (int256) {
    //     return val;
    // }

    // function conditionals(int256 _a)
    //     public
    //     view
    //     userVerify(user)
    //     returns (int256)
    // {
    //     if (_a < 0) {
    //         return -1;
    //     } else {
    //         return 1;
    //     }
    // }

    // function requireCheck(int256 _a) public userVerify(user) {
    //     val = 69;

    //     require(_a > 0, "a is not greater than 0");
    //     val = _a; // changed
    // }

    // event Debug(string message);

    // function checkInput(int256 input) public returns (string memory) {
    //     require(input <= 255 && input >= 0, "Not Within Range");
    //     return "Within Range";
    // }

    // // struct ka example

    // struct Student {
    //     string name;
    //     uint age;
    //     uint rollNo;
    // }

    // Student[] public structExample;

    // function insertStruct(string memory name, uint age, uint rollNo) public {
    //     structExample.push(Student(name, age, rollNo));
    // }

    // // maps ka example

    // mapping(uint => string) public userMap;

    // function insertMap(uint _key,string memory _value) external{
    //     userMap[_key] = _value;
    // }

    // // nested maps example

    // //      studentId       subName   grade
    // mapping(uint => mapping(string => uint)) public studentGrades;

    // function addStudentsGrades(uint _studentId, string memory _subjectName, uint _grade) external {
    //     studentGrades[_studentId][_subjectName] = _grade;
    // }

    // teswts

    //  function reverseArray(uint[] memory _values, uint _length) public pure returns (uint[] memory) {
    //     require(_values.length == _length, "Array length mismatch");

    //     uint[] memory reversed = new uint[](_length);
    //     for (uint i = 0; i < _length; i++) {
    //         reversed[i] = _values[_length - 1 - i];
    //     }

    //     return reversed;
    // }
    struct USER {
        uint id;
        string name;
    }

    uint256 private userId = 1;

    USER[] public users;

    function insert(string memory name) public {
        users.push(USER(userId, name));

        userId++;
    } 

    function read(uint id) public view returns(bool) {
        for(uint i=0;i<users.length;i++) {
            if(users[i].id == id) {
                return true;
            }
        }

        revert("User does not exist!");
    }

    function find(uint id) public view returns(string memory, uint) {
        for(uint i=0;i<users.length;i++) {
            if(users[i].id == id) {
                return (users[i].name, users[i].id);
            }
        }

        revert("there is no user with the specified id");
    }

    // struct USER{
    //     uint id;
    //     string name;
    // }

    // mapping(uint => USER) public users;
    // uint public count = 1;

    // function insert(uint _id, string memory _name) public {
    //     users[_id] = USER(count, _name);
    //     count++;
    // }

    // function read(uint id) public view returns(USER memory) {
    //     return users[id];
    // }

    // function find(uint id) public view returns(string memory) {
    //     require(id <= count, "User does not exist!");

    //     return "User exists!";
    // }
}
