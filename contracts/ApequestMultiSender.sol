// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ApequestMultiSender is ERC1155, Ownable {
    struct Quiz {
        uint256 quizz;
        uint256 amount;
        uint256 tokenId;
        uint256 date;
        bool isPaid;
        address[] participants;
        address organiser;
    }

    mapping(address => mapping(uint256 => Quiz)) public organizerQuizzes;
    mapping(address => uint256) public userAmounts;
    bool public requireInitialQuizzData;
    mapping(uint256 => bool) public quizzesConducted;
    mapping(address => uint256) public organizerQuizzCount;

    event QuizConducted(uint256 indexed quizzId);
    event SentToUsers(
        address indexed sender,
        address[] recipients,
        uint256[] amounts,
        uint256 quizzId
    );

    modifier requireQuizzData(uint256 quizzId) {
        require(
            !requireInitialQuizzData && !quizzesConducted[quizzId],
            "Quizz data is required and quizzId is not conducted"
        );
        _;
    }

    constructor() Ownable(msg.sender) ERC1155("") {
        requireInitialQuizzData = false;
    }

    function sendToUsers(
        address[] memory _users,
        uint256[] memory _amounts,
        uint256 quizzId,
        string memory tokenURI
    ) external payable requireQuizzData(quizzId) {
        uint256 totalAmount = getTotalAmount(_amounts);

        require(
            msg.value >= totalAmount,
            "Insufficient value sent with the transaction"
        );
        for (uint256 i = 0; i < _users.length; i++) {
            userAmounts[_users[i]] += _amounts[i];
            payable(_users[i]).transfer(userAmounts[_users[i]]);
            userAmounts[_users[i]] = 0;

            if (requireInitialQuizzData) {
                _setURI(tokenURI);
                _mint(_users[i], _amounts[i], quizzId, "");
            }
        }
        emit SentToUsers(msg.sender, _users, _amounts, quizzId);
    }

    function setInitialQuizzRequirement(
        bool _requireInitialQuizzData
    ) external onlyOwner {
        requireInitialQuizzData = _requireInitialQuizzData;
    }

    function conductQuiz(uint256 quizzId) external onlyOwner {
        quizzesConducted[quizzId] = true;
        emit QuizConducted(quizzId);
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

    function addOrganizerQuizz(
        address organiser,
        uint256 amount,
        uint256 tokenId,
        uint256 date,
        bool isPaid,
        address[] memory participants
    ) external onlyOwner {
        uint256 quizzId = organizerQuizzCount[organiser] + 1;
        organizerQuizzes[organiser][quizzId] = Quiz({
            quizz: quizzId,
            amount: amount,
            tokenId: tokenId,
            date: date,
            isPaid: isPaid,
            participants: participants,
            organiser: organiser
        });
        organizerQuizzCount[organiser] = quizzId;
    }

    function getContractBalanceInEther() external view returns (uint256) {
        return address(this).balance / 1 ether;
    }

    // dev: env todo: remove on prod
    function withdrawAllBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
