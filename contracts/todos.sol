// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Todos {
    uint256 taskCount;
    uint256 taskId;

    event LogMessage(string message);

    struct Task {
        uint256 id;
        string content;
        bool completed;
    }

    mapping(uint256 => Task) public tasks;

    constructor() {
        tasks[taskId] = Task(taskId, "Initial Task", false);

        taskId++;
    }

    function createTask(string memory _content) public {
        tasks[taskId] = Task(taskId, _content, false);

        taskId++;

        emit LogMessage("TaskCreated");
    }

    function toggleTaskCompleted(uint256 _id) public {
        tasks[_id].completed = true;

        emit LogMessage("TaskCompleted");
    }

    function getTask(uint256 _id) public view returns (Task memory) {
        return tasks[_id];
    }

    function getTaskCount() public view returns (uint256) {
        return taskId - 1;
    }
}
