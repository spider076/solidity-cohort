// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract twitter {
    // variables
    uint tweetId = 1;
    uint messageId = 1;
    
    struct Tweet {
        uint tweetId;
        address author; 
        string content;
        uint timestamp;
    } 

    struct Message {
        uint messageId;
        string content;
        address sender;
        address receiver;
        uint timestamp; 
    }

    mapping(uint => Tweet) public tweets;
    mapping(address => uint[]) public tweetsOf;
    mapping(address => Message[]) public conversations;
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => address[]) public following;


    function _tweet(address _from, string memory _content) internal {
        tweets[tweetId] = Tweet(tweetId, _from, _content, block.timestamp);

        tweetId++;
    }

    function _sendMessage(address _from, address _to, string memory _content) internal {
        conversations[_from].push(Message(messageId, _content, _to, _from, block.timestamp));

        messageId++;
    }
    
    function tweet(string memory _content) public {
        _tweet(msg.sender, _content); 
    }

    function sendMessage(string memory _content, address _to) public {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessage(address _from, address _to, string memory _content) public {
        require(operators[_from][msg.sender], "You are not authorized to perform this action");

        _sendMessage(msg.sender, _to, _content);
    }

    function follow(address _followed) public {
        following[msg.sender].push(_followed);
    }

    function allow(address _operator) public {
        operators[msg.sender][_operator] = true;
    }

    function disallow(address _operator) public {
        operators[msg.sender][_operator] = false;
    }

    function getLatestTweets(uint count) public view returns(Tweet[] memory) {
        require(count <= tweetId -1, "Not Enough Tweets present!");

        Tweet[] memory latestTweets = new Tweet[](count);

        for (uint256 i = 0; i < count; i++) {
            latestTweets[i] = tweets[i + 1];
        }

        return latestTweets;
    }

    function getLatestTweetsOf(address user, uint count) public view returns (Tweet[] memory) {
        require(count <= tweetsOf[user].length, "Not enough tweets created !");

        Tweet[] memory latestUserTweets = new Tweet[](tweetsOf[user].length);

        for (uint256 i = 0; i < count; i++) {
            latestUserTweets[i] = tweets[tweetsOf[user][i+1]];
        }

        return latestUserTweets;
    }
}
