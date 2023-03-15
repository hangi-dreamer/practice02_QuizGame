// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }

    mapping(address => uint256)[] public bets;
    mapping(address => uint) bet;

    uint public vault_balance;
    address public owner;
    mapping(uint => Quiz_item) quiz_items;

    uint quiz_count;

    constructor () {
        owner = msg.sender;

        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner);

        quiz_count++;
        quiz_items[quiz_count] = q;

        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quiz_items[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory quiz_item = quiz_items[quizId];
        quiz_item.answer = "";
        return quiz_item;
    }

    function getQuizNum() public view returns (uint){
        return quiz_count;
    }

    function betToPlay(uint quizId) public payable {
        Quiz_item memory quiz_item = quiz_items[quizId];
        require(msg.value <= quiz_item.max_bet);
        require(msg.value >= quiz_item.min_bet);

        bets.push();

        bets[quizId - 1][msg.sender] += msg.value;
        vault_balance += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        bool result = keccak256(abi.encodePacked((quiz_items[quizId].answer))) == keccak256(abi.encodePacked((ans)));

        if (result) {
            vault_balance -= bets[0][msg.sender];
            bets[0][msg.sender] += bets[0][msg.sender];
        } else {
            vault_balance += bets[0][msg.sender];
            bets[0][msg.sender] = 0;
        }

        return result;
    }

    function claim() payable public {
        uint sum;

        for (uint i; i < bets.length; i ++) {
            sum += bets[i][msg.sender];
        }
        (bool sent,) = payable(msg.sender).call{value: sum}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}
}
