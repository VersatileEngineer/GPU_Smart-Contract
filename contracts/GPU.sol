// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GPUContract {
    address public provider;
    address public consumer;
    uint256 public rentalPeriod; // In blocks
    uint256 public rentalPrice; // In Wei

    uint256 public startTime;
    uint256 public endTime;

    enum ContractState { Created, Active, Completed, Disputed }
    ContractState public state;

    constructor(
        address _provider,
        address _consumer,
        uint256 _rentalPeriod,
        uint256 _rentalPrice
    ) {
        provider = _provider;
        consumer = _consumer;
        rentalPeriod = _rentalPeriod;
        rentalPrice = _rentalPrice;
        startTime = block.number;
        endTime = startTime + rentalPeriod;
        state = ContractState.Created;
    }

    modifier onlyProvider() {
        require(msg.sender == provider, "Only provider can perform this action");
        _;
    }

    modifier onlyConsumer() {
        require(msg.sender == consumer, "Only consumer can perform this action");
        _;
    }

    modifier onlyActive() {
        require(state == ContractState.Active, "Contract is not active");
        _;
    }

    modifier onlyCompleted() {
        require(state == ContractState.Completed, "Contract is not completed");
        _;
    }

    function startRental() external onlyConsumer {
        require(block.number >= startTime, "Rental period has not started yet");
        require(block.number <= endTime, "Rental period has ended");
        require(state == ContractState.Created, "Contract is not in the correct state");
        
        state = ContractState.Active;
    }

    function endRental() external onlyProvider onlyActive {
        require(block.number >= endTime, "Rental period has not ended yet");
        
        state = ContractState.Completed;
        payable(provider).transfer(rentalPrice);
    }

    function dispute() external onlyActive {
        require(msg.sender == provider || msg.sender == consumer, "Only provider or consumer can dispute");
        
        state = ContractState.Disputed;
    }
}
