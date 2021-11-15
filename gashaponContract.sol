// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GashaponContract {
    using SafeMath for uint256;

    // Fix value
    uint256[5] private PRICES = [
        1000000000000000000,
        100000000000000,
        100000000,
        10000000,
        10000
    ];

    uint256 private totalBalls;
    uint256[5] private numberOfEachBalls;
    uint256 private initPrice;
    uint256 private bidIncrement;
    uint256 private count;
    uint256 private gashaBalance = 0;
    uint256 private currentPrice;

    constructor(
        uint256 _totalBalls,
        uint256[5] memory _numberOfEachBalls,
        uint256 _initPrice,
        uint256 _bidIncrement
    ) {
        totalBalls = _totalBalls;
        initPrice = _initPrice;
        bidIncrement = _bidIncrement;
        currentPrice = _initPrice;
        numberOfEachBalls = _numberOfEachBalls;
        checkNumberOfBall();
    }

    function checkNumberOfBall() private view {
        uint256 total;
        for (uint256 i = 0; i < 5; i++) {
            total += numberOfEachBalls[i];
        }
        require(
            total == totalBalls,
            "Amount of balls is not equal to the total ball"
        );
    }

    // GETTER

    function getCurrentPrice() public view returns (uint256) {
        return currentPrice;
    }

    function getNumberOfEachBall() public view returns (uint256[5] memory) {
        require(
            count >= SafeMath.div(SafeMath.mul(70, totalBalls), 100),
            "You cannot view, there is more than 30% of balls in the machine"
        );
        return numberOfEachBalls;
    }

    function getBallsLeft() public view returns (uint256) {
        uint256 ballLeft = SafeMath.sub(totalBalls, count, "There is an error");
        require(
            count >= SafeMath.div(SafeMath.mul(70, totalBalls), 100),
            "You cannot view, there is more than 30% of balls in the machine"
        );
        return ballLeft;
    }

    function getWithdrawBalance() public view returns (uint256) {
        require(
            count == totalBalls,
            "Cannot transfer money, the machine should be empty"
        );
        return gashaBalance;
    }

    function playGasha(uint256 pricePaid) public payable returns (uint256) {
        require(
            pricePaid == currentPrice,
            "Please enter the right amount, check the current price"
        );
        require(totalBalls - count != 0, "The machine is empty");
        gashaBalance += currentPrice;
        count++;
        currentPrice += bidIncrement;
        uint256 rand = random();
        numberOfEachBalls[rand] -= 1;
        if (count == SafeMath.div(SafeMath.mul(70, totalBalls), 100)) {
            recalculatePrice();
        }
        return rand;
    }

    // NOT AN EFFICIENT WAY!
    function random() private view returns (uint256) {
        // We have 5 items so 5 + 1
        uint256 randomnumber = uint256(
            keccak256(abi.encodePacked(block.timestamp))
        ) % 6;
        if (numberOfEachBalls[randomnumber] == 0) {
            for (uint256 i = 0; i < 5; i++) {
                if (numberOfEachBalls[i] != 0) {
                    return i;
                }
            }
        }
        return randomnumber;
    }

    function recalculatePrice() private {
        uint256 newPrice = 0;
        for (uint256 i = 0; i < 5; i++) {
            newPrice += SafeMath.mul(
                uint256(numberOfEachBalls[i]),
                uint256(PRICES[i])
            );
        }
        currentPrice = newPrice;
    }
}
