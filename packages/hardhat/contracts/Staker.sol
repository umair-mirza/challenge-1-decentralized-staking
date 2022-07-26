// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  event Stake(address, uint256);

  uint256 public deadline = block.timestamp + 72 hours;

  mapping (address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  bool openForWithdraw = false;

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable notCompleted {
    require(msg.value > 0, "Amount is less than or equal to zero");
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() external notCompleted {
    require(block.timestamp >= deadline, "Deadline has not been reached yet");
    if(address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw()` function to let users withdraw their balance

  function withdraw() external notCompleted {
    require(openForWithdraw == true, "Cannot withdraw funds unless the Contract balance is less than Threshold");
    payable(msg.sender).transfer(balances[msg.sender]);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns(uint256) {
    if(block.timestamp < deadline) {
      return deadline - block.timestamp;
    } else {
      return 0;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()

  receive() external payable {
    stake();
  }

  modifier notCompleted {
    require(exampleExternalContract.completed() != true);
    _;
  }

}
