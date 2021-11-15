// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./gashaponContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameCenter is Ownable {
    struct Item {
        address machineAddrs;
        uint256 timestamp;
        uint256 blockNo;
        string prize;
        uint256 paid;
    }

    struct Gashapon {
        address gashaAddress;
        string gashaName;
    }

    // FIX VALUE (For simplicity)
    string[5] ITEMS = ["gold", "silver", "blue", "red", "yellow"];

    mapping(address => Item[]) public gashaReceive;
    mapping(address => Gashapon[]) public gashaList;

    event ShowItem(address player, string item);

    // GETTER
    function getAllGashaBalls(address gashaAddress)
        public
        view
        returns (uint256)
    {
        GashaponContract gashaGen = GashaponContract(gashaAddress);
        return gashaGen.getBallsLeft();
    }

    function getCurrentGashaPrice(address gashaAddress)
        public
        view
        returns (uint256)
    {
        GashaponContract gashaGen = GashaponContract(gashaAddress);
        return gashaGen.getCurrentPrice();
    }

    function getNumberOfEachGashaBall(address gashaAddress)
        public
        view
        returns (uint256[5] memory)
    {
        GashaponContract gashaGen = GashaponContract(gashaAddress);
        return gashaGen.getNumberOfEachBall();
    }

    function createGasha(
        string memory _name,
        uint256 _totalBalls,
        uint256[5] memory _numberOfEachBall,
        uint256 _initPrice,
        uint256 _bidIncrement
    ) public returns (address) {
        GashaponContract newGashapon = new GashaponContract(
            _totalBalls,
            _numberOfEachBall,
            _initPrice,
            _bidIncrement
        );
        gashaList[msg.sender].push(Gashapon(address(newGashapon), _name));
        return address(newGashapon);
    }

    function playGasha(address gashaAddress) public payable {
        GashaponContract gashaGen = GashaponContract(gashaAddress);
        string memory itemName = ITEMS[gashaGen.playGasha(msg.value)];
        gashaReceive[msg.sender].push(
            Item(
                address(gashaGen),
                block.timestamp,
                block.number,
                itemName,
                msg.value
            )
        );
        emit ShowItem(msg.sender, itemName);
    }

    function withdrawMoney(address gashaAddress) public onlyOwner {
        GashaponContract gashaGen = GashaponContract(gashaAddress);
        uint256 amount = gashaGen.getWithdrawBalance();
        payable(Ownable.owner()).transfer(amount);
    }
}
