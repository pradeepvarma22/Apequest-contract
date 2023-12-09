// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ApequestMultiSender {
    struct Quiz {
        uint256 quizz;
        address walletAddress;
        uint256 amount;
        string nftEarned;
        uint256 date;
        bool isPaid;
        address[] participants;
        address organiser;
    }

    mapping(address => mapping(uint256 => Quiz)) public userQuizzes;
    mapping(address => uint256) public userQuizCount;
    mapping(address => uint256) public userAmounts;

    bool public requireQuizAdder;
    uint256[] public quizzesConducted;

    event QuizConducted(uint256 indexed quizzId);
    event SentToUsers(
        address indexed sender,
        address[] recipients,
        uint256[] amounts,
        uint256 quizzId
    );

    constructor() {
        requireQuizAdder = true;
    }

    function sendToUsers(
        address[] memory _users,
        uint256[] memory _amounts,
        uint256 quizzId
    ) external payable {
        require(
            requireQuizAdder && quizzId != 0,
            "Quiz fields are required and quizzId cannot be zero"
        );
        require(_users.length == _amounts.length, "Arrays length mismatch");
        require(isQuizzConducted(quizzId), "Quizz ID is not conducted");

        uint256 totalAmountToSend = getTotalAmount(_amounts);
        require(
            msg.value >= totalAmountToSend,
            "Insufficient value sent with the transaction"
        );

        for (uint256 i = 0; i < _users.length; i++) {
            userAmounts[_users[i]] += _amounts[i];
            require(
                msg.value >= userAmounts[_users[i]],
                "Insufficient value sent for user"
            );
        }

        for (uint256 i = 0; i < _users.length; i++) {
            payable(_users[i]).transfer(userAmounts[_users[i]]);
            emit SentToUsers(msg.sender, _users, _amounts, quizzId);
            userAmounts[_users[i]] = 0;
        }
    }

    function isQuizzConducted(uint256 quizzId) internal view returns (bool) {
        for (uint256 i = 0; i < quizzesConducted.length; i++) {
            if (quizzesConducted[i] == quizzId) {
                return true;
            }
        }
        return false;
    }

    function getTotalAmount(
        uint256[] memory _amounts
    ) internal pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            total += _amounts[i];
        }
        return total;
    }

    function setGlobalRequireQuizFields(bool _requireQuizFields) external {
        requireQuizAdder = _requireQuizFields;
    }

    function conductQuiz(uint256 quizzId) external {
        quizzesConducted.push(quizzId);
        emit QuizConducted(quizzId);
    }
}
