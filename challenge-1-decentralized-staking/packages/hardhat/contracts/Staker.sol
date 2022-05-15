// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    event Stake(address sender, uint256 amount);

    mapping(address => uint256) public balances;
    uint256 public deadline = block.timestamp + 30 seconds;
    uint256 public constant threshold = 1 ether;
    bool availableToWithdraw = false;

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    function stake() public payable {
      require(block.timestamp < deadline, "Deadline has passed");
        uint256 _amount = msg.value;
        address _staker = msg.sender;
        balances[_staker] = _amount;
        emit Stake(_staker, _amount);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() public {
        require(block.timestamp >= deadline, "deadline has not passed");
        require(!availableToWithdraw, "already called once");

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            availableToWithdraw = true;
        }
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `withdraw()` function to let users withdraw their balance
    function withdraw() public {
        require(block.timestamp >= deadline, "deadline has not passed");
        require(availableToWithdraw, "threshold not met");
        // address(msg.sender).complete{value: balances[msg.sender]};
        payable(msg.sender).transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
