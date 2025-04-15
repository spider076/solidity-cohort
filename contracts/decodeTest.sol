// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "hardhat/console.sol";

contract DecodeTest {
    struct Question {
        string topic;
        string question;
        string[3] options;
        uint256 timestamp;
        bool isActive;
        uint256 totalPool;
        bool resolved;
        string winningOption;
    }

    Question[] public questions;

    constructor() {}

    event NewQuestion(
        uint256 indexed questionId,
        string topic,
        string question,
        string[] options
    );

    function updateQuestion(bytes calldata data) public {
        questions[0] = Question({
            topic: "Topic",
            question: "What is the capital of France?",
            options: ["Paris", "London", "Rome"],
            timestamp: block.timestamp + 604800, // 1 week
            isActive: true,
            totalPool: 35279 * 10**18, // 35279 tokens
            resolved: false,
            winningOption: "Rome"
        });

        (
            string memory topic,
            string memory question,
            string[] memory options
        ) = abi.decode(data, (string, string, string[]));

        require(bytes(topic).length > 0, "Empty topic");
        require(bytes(question).length > 0, "Empty question");
        require(options.length >= 2, "Need at least 2 options");

        questions.push(
            Question({
                topic: topic,
                question: question,
                options: ["1", "2", "3"],
                timestamp: block.timestamp,
                isActive: true,
                totalPool: 0,
                resolved: false,
                winningOption: ""
            })
        );

        emit NewQuestion(questions.length - 1, topic, question, options);
    }

    function decodeMe(bytes memory data) public pure {
        string memory jsonString = abi.decode(data, (string));

        console.log("RESULT : ",jsonString);
    }
}
