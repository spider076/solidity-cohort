// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Opinex {
    address public owner;
    // address public functionsConsumer; // Chainlink Functions Consumer contract

    struct Question {
        string topic;
        string question;
        string[] options;
        uint256 timestamp;
        bool isActive;
        uint256 totalPool;
        bool resolved;
        string winningOption;
    }

    Question[] public questions;
    mapping(uint256 => mapping(address => uint256)) public bets; // questionId => user => amount
    mapping(uint256 => mapping(address => string)) public userChoices; // questionId => user => option
    mapping(uint256 => mapping(string => uint256)) public optionStakes; // questionId => option => total

    uint256 public constant PENALTY_PERCENT = 10; // 10% penalty for early withdrawal
    uint256 public constant HOUR = 3600; // 1 hour in seconds

    event NewQuestion(
        uint256 indexed questionId,
        string topic,
        string question,
        string[] options
    );
    event BetPlaced(
        uint256 indexed questionId,
        address indexed user,
        string option,
        uint256 amount
    );
    event Withdrawn(
        uint256 indexed questionId,
        address indexed user,
        uint256 amount
    );
    event QuestionResolved(
        uint256 indexed questionId,
        string winningOption,
        uint256 totalPool
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // modifier onlyFunctionsConsumer() {
    //     require(msg.sender == functionsConsumer, "Not Functions Consumer");
    //     _;
    // }

    constructor() {
        owner = msg.sender;
        // functionsConsumer = _functionsConsumer;
    }

    function updateQuestion(bytes calldata data)
        external
    {
        // Decode JSON string as an array
        string memory jsonString = abi.decode(data, (string));
        (
            string memory topic,
            string memory question,
            string[] memory options
        ) = abi.decode(bytes(jsonString), (string, string, string[]));

        require(bytes(topic).length > 0, "Empty topic");
        require(bytes(question).length > 0, "Empty question");
        require(options.length >= 2, "Need at least 2 options");

        if (questions.length > 0 && questions[questions.length - 1].isActive) {
            _resolveQuestion(questions.length - 1);
        }

        questions.push(
            Question({
                topic: topic,
                question: question,
                options: options,
                timestamp: block.timestamp,
                isActive: true,
                totalPool: 0,
                resolved: false,
                winningOption: ""
            })
        );

        emit NewQuestion(questions.length - 1, topic, question, options);
    }

    function placeBet(uint256 questionId, string calldata option)
        external
        payable
    {
        Question storage q = questions[questionId];
        require(q.isActive, "Question not active");
        require(msg.value > 0, "Bet must be > 0");
        require(block.timestamp < q.timestamp + HOUR, "Betting period ended");

        bool isValidOption = false;
        for (uint256 i = 0; i < q.options.length; i++) {
            if (
                keccak256(abi.encodePacked(q.options[i])) ==
                keccak256(abi.encodePacked(option))
            ) {
                isValidOption = true;
                break;
            }
        }
        require(isValidOption, "Invalid option");

        bets[questionId][msg.sender] += msg.value;
        userChoices[questionId][msg.sender] = option;
        optionStakes[questionId][option] += msg.value;
        q.totalPool += msg.value;

        emit BetPlaced(questionId, msg.sender, option, msg.value);
    }

    function withdraw(uint256 questionId) external {
        Question storage q = questions[questionId];
        require(q.isActive, "Question not active");
        require(bets[questionId][msg.sender] > 0, "No bet placed");

        string memory userOption = userChoices[questionId][msg.sender];
        uint256 userStake = bets[questionId][msg.sender];
        require(userStake > 0, "No stake");

        // Find leading option
        string memory leadingOption = q.options[0];
        uint256 maxStake = optionStakes[questionId][q.options[0]];
        for (uint256 i = 1; i < q.options.length; i++) {
            if (optionStakes[questionId][q.options[i]] > maxStake) {
                maxStake = optionStakes[questionId][q.options[i]];
                leadingOption = q.options[i];
            }
        }

        // Only allow withdrawal if user's option is leading
        require(
            keccak256(abi.encodePacked(userOption)) ==
                keccak256(abi.encodePacked(leadingOption)),
            "Option not leading"
        );

        // Calculate reward with penalty
        uint256 totalLeadingStake = optionStakes[questionId][leadingOption];
        uint256 reward = (userStake * q.totalPool) / totalLeadingStake;
        uint256 penalty = (reward * PENALTY_PERCENT) / 100;
        uint256 payout = reward - penalty;

        // Update state
        bets[questionId][msg.sender] = 0;
        optionStakes[questionId][userOption] -= userStake;
        q.totalPool -= payout;

        // Send payout
        (bool sent, ) = msg.sender.call{value: payout}("");
        require(sent, "Payout failed");

        emit Withdrawn(questionId, msg.sender, payout);
    }

    function resolveQuestion(uint256 questionId) external onlyOwner {
        _resolveQuestion(questionId);
    }

    function _resolveQuestion(uint256 questionId) internal {
        // Optimized for gas
        Question storage q = questions[questionId];
        require(q.isActive, "Question not active");
        require(!q.resolved, "Already resolved");

        string memory winningOption = "";
        uint256 maxStake = 0;
        bool isTie = false;

        for (uint256 i = 0; i < q.options.length; i++) {
            uint256 stake = optionStakes[questionId][q.options[i]];
            if (stake > maxStake) {
                maxStake = stake;
                winningOption = q.options[i];
                isTie = false;
            } else if (stake == maxStake && stake > 0) {
                isTie = true;
            }
        }

        q.isActive = false;
        q.resolved = true;
        q.winningOption = isTie || maxStake == 0 ? "" : winningOption;

        emit QuestionResolved(questionId, q.winningOption, q.totalPool);
    }

    function getQuestion(uint256 questionId)
        external
        view
        returns (
            string memory topic,
            string memory question,
            string[] memory options,
            uint256 timestamp,
            bool isActive,
            uint256 totalPool,
            string memory winningOption
        )
    {
        Question storage q = questions[questionId];
        return (
            q.topic,
            q.question,
            q.options,
            q.timestamp,
            q.isActive,
            q.totalPool,
            q.winningOption
        );
    }

    function getOptionStakes(uint256 questionId, string calldata option)
        external
        view
        returns (uint256)
    {
        return optionStakes[questionId][option];
    }

    function getUserBet(uint256 questionId, address user)
        external
        view
        returns (uint256 amount, string memory option)
    {
        return (bets[questionId][user], userChoices[questionId][user]);
    }

    // Fallback to receive ETH
    receive() external payable {}
}
