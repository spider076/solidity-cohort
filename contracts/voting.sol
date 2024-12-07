// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Vote {
    struct Voter {
        string name;
        uint256 age;
        uint256 voterId;
        Gender gender;
        uint256 voteCandidateId; // candidate id to whom the voter has voted
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint256 age;
        Gender gender;
        uint256 candidateId;
        address candidateAddress;
        uint256 votes;
    }

    address electionCommission;
    address public winner;
    uint256 nextVoterId = 1;
    uint256 nextCandidateId = 1;
    uint256 startTime;
    uint256 endTime;
    bool stopVoting;
    VotingStatus votingStatus;

    mapping(uint256 => Voter) voterDetails;
    mapping(uint256 => Candidate) candidateDetails;

    enum VotingStatus {
        NotStarted,
        InProgress,
        Ended
    }
    enum Gender {
        NotSpecified,
        Male,
        Female,
        Other
    }

    constructor() {
        electionCommission = msg.sender;
    }

    modifier isVotingOver() {
        require(block.timestamp < endTime || !stopVoting, "Voting is Over !");
        _;
    }

    modifier onlyCommissioner() {
        require(
            msg.sender == electionCommission,
            "Only Election Commission can call this function !"
        );
        _;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint256 _age,
        Gender _gender
    ) external isVotingOver {
        require(
            _age > 18 && _age < 60,
            "You are too young or aged to be a candidate !"
        );
        require(
            !isCandidateRegistered(msg.sender),
            "You have already registered !"
        );
        require(nextCandidateId < 3, "Candidate registration is full !");
        require(
            msg.sender != electionCommission,
            "Election Commisioner can't be a candidate !"
        );

        candidateDetails[nextCandidateId] = Candidate(
            _name,
            _party,
            _age,
            _gender,
            nextCandidateId,
            msg.sender,
            0
        );
        nextCandidateId++;
    }

    function isCandidateRegistered(address _person)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 1; i <= nextCandidateId; i++) {
            if (
                candidateDetails[i].candidateAddress == _person &&
                candidateDetails[i].candidateAddress !=
                0x0000000000000000000000000000000000000000
            ) {
                return true;
            }
        }
        return false;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidates = new Candidate[](nextCandidateId - 1);

        for (uint256 i = 0; i < nextCandidateId - 1; i++) {
            candidates[i] = candidateDetails[i + 1];
        }

        return candidates;
    }

    function isVoterRegistered(address _person) internal view returns (bool) {
        for (uint256 i = 1; i <= nextVoterId; i++) {
            if (voterDetails[i].voterAddress == _person) {
                return true;
            }
        }
        return false;
    }

    function registerVoter(
        string calldata _name,
        uint256 _age,
        Gender _gender
    ) external {
        require(_age > 18, "You are undeage to be a voter !");
        require(
            !isVoterRegistered(msg.sender),
            "You have already registered as the voter !"
        );

        voterDetails[nextVoterId] = Voter(
            _name,
            _age,
            nextVoterId,
            _gender,
            0,
            msg.sender
        );
        nextVoterId++;
    }

    function getVoterList() public view returns (Voter[] memory) {
        Voter[] memory voters = new Voter[](nextVoterId - 1);

        for (uint256 i = 0; i < nextCandidateId - 1; i++) {
            voters[i] = voterDetails[i + 1];
        }

        return voters;
    }

    function castVote(uint256 _voterId, uint256 _candidateId)
        external
        isVotingOver
    {
        address candidateAddress = candidateDetails[_candidateId]
            .candidateAddress;

        require(
            voterDetails[_voterId].voteCandidateId == 0,
            "You have already casted an vote !"
        );
        require(
            voterDetails[_voterId].voterAddress == msg.sender,
            "Please Vote with the same registered voter id."
        );
        require(
            isCandidateRegistered(candidateAddress),
            "This Candidate is not registered !"
        );
        voterDetails[_voterId].voteCandidateId = _candidateId;
        candidateDetails[_candidateId].votes++;
    }

    function setVotingPeriod(uint256 _startTime, uint256 _endTime)
        external
        onlyCommissioner
        isVotingOver
    {
        require(_endTime > 3600, "Endtime duration must be more than 1 hour !");
        startTime = block.timestamp + _startTime;
        endTime = startTime + _endTime;
    }

    function getVotingStatus() public view returns (VotingStatus) {
        if (startTime == 0) {
            return VotingStatus.NotStarted;
        } else if (endTime > block.timestamp && !stopVoting) {
            return VotingStatus.InProgress;
        } else {
            return VotingStatus.Ended;
        }
    }

    function announceVotingResult() external onlyCommissioner {
        require(nextCandidateId == 3, "Not enough candidates registered !");

        Candidate memory can1 = candidateDetails[1];
        Candidate memory can2 = candidateDetails[2];

        if (can1.votes > can2.votes) {
            winner = can1.candidateAddress;
        } else {
            winner = can2.candidateAddress;
        }
    }

    function emergencyStopVoting() public onlyCommissioner {
        stopVoting = true;
    }
}
