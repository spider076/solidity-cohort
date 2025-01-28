// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract demo {
    uint public taskCount = 1;
    event TaskCreated();
    event TaskCompleted();

    struct Task {
        uint id;
        string content;
        bool completed;
    }

    mapping(uint => Task) public tasks;

    constructor() {
        tasks[taskCount] = Task(taskCount, "Initial Task", true);
        taskCount++;
    }

    function createTask(string memory _content) public {
        tasks[taskCount] = Task(taskCount, _content, false);
        taskCount++;

        emit TaskCreated();
    }

    function toggleTaskCompleted(uint _id) public {
        tasks[_id].completed = !tasks[_id].completed;    
        emit TaskCompleted();
    }

    function getTask(uint _id) public view  returns(Task memory) {
        Task memory t = tasks[_id];
        require(bytes(t.content).length > 0, "the task is empty");
        return t;
    }

    function getTaskCount() public view returns(uint) {
        return taskCount;
    }

}

