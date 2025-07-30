// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/// @title Sending and Receiving Ether with Balance Tracking
/// @notice Enables the owner to send and receive Ether, while tracking actions and state changes.
/// @dev Use Remix or a compatible IDE to deploy and interact with this contract
contract ReceiverContract__SendingAndReceivingEtherWithBalanceCheck {
    address internal owner;
    string internal contractName;

    /// @notice Represents different types of tracked actions
    enum ActionType { Deployed, ReceivedEther, ReceivedEther__Forwarding, ReceivedEther__ContractFunding, SentEther__PassThrough, SentEther__Withdrawal }

    /// @notice The highest valid index for ActionType enum
    uint8 constant MAX_ACTION_INDEX = uint8(type(ActionType).max);

    /// @notice Describes the contract's tracked state information
    struct ContractDetails {
        string contractName;
        uint256 lastActionTime;
        ActionType lastAction;
        address deployedBy;
        uint256 contractBalance;
    }

    /// @notice Emitted for logging internal events
    /// @param message A human-readable log message
    event Log(string message);

    /// @notice Emitted after incoming or outgoing Ether transactions
    /// @param paymentType The type of Ether transaction as defined in ActionType
    /// @param senderAddress The address of the sender (incoming) or recipient (outgoing)
    /// @param amount The amount of Ether transferred
    /// @param sendTime The block timestamp when the transaction occurred
    event PaymentDetails(
        ActionType indexed paymentType,
        address indexed senderAddress,
        uint256 amount,
        uint256 sendTime
    );

    ContractDetails internal contractDetails;

    /// @notice Restricts access to contract owner only
    modifier onlyOwner {
        require(msg.sender == owner, "You attempted a function call that is restricted to platform admins");
        _;
    }

    /// @notice Initializes the contract and sets the deployer as owner
    /// @param _contractName A descriptive label for the contract
    constructor(string memory _contractName) {
        owner = msg.sender;
        contractName = _contractName;

        contractDetails = ContractDetails({
            contractName: _contractName,
            lastActionTime: block.timestamp,
            lastAction: ActionType.Deployed,
            deployedBy: owner,
            contractBalance: address(this).balance
        });

        emit Log("contract deployed successfully");
    }

    /// @notice Accepts and logs incoming Ether payments
    /// @dev Updates the contract details and emits PaymentDetails event
    receive() external payable {
        emit Log("contract received a new payment");

        contractDetails = ContractDetails({
            contractName: contractName,
            lastActionTime: block.timestamp,
            lastAction: ActionType.ReceivedEther,
            deployedBy: owner,
            contractBalance: address(this).balance
        });

        emit PaymentDetails(ActionType.ReceivedEther, msg.sender, msg.value, block.timestamp);
    }

    /// @notice Allows the owner to fund the contract manually
    /// @dev Updates the internal contract state and logs a funding event
    function handleContractFunding() external payable onlyOwner {
        require(msg.value > 0, "Funding amount must be greater than zero");

        contractDetails = ContractDetails({
            contractName: contractName,
            lastActionTime: block.timestamp,
            lastAction: ActionType.ReceivedEther__ContractFunding,
            deployedBy: owner,
            contractBalance: address(this).balance
        });

        emit PaymentDetails(ActionType.ReceivedEther__ContractFunding, msg.sender, msg.value, block.timestamp);
        emit Log("contract received a new payment");
    }

    /// @notice Allows the caller to forward attached Ether to another address
    /// @dev Ether must be sent with the function call; behaves like a passthrough payment
    /// @param receiverAddress The recipient of the passthrough Ether
    function sendEther__PassThrough(address payable receiverAddress) public payable {
        require(msg.value > 0, "Transfer amount must be greater than zero");

        (bool transferIsSuccessful, ) = receiverAddress.call{value: msg.value}("");
        require(transferIsSuccessful, "The transaction was unsuccessful");

        emit Log("contract successfully completed a new passthrough transfer");

        contractDetails = ContractDetails({
            contractName: contractName,
            lastActionTime: block.timestamp,
            lastAction: ActionType.SentEther__PassThrough,
            deployedBy: owner,
            contractBalance: address(this).balance
        });

        emit PaymentDetails(ActionType.SentEther__PassThrough, msg.sender, msg.value, block.timestamp);
    }

    /// @notice Allows the contract owner to send Ether from the contract balance
    /// @dev Withdraws from existing contract balance; requires sufficient funds
    /// @param receiverAddress The recipient of the Ether
    /// @param amount The amount of Ether to withdraw and send
    function sendEther__Withdrawal(address payable receiverAddress, uint256 amount) public payable onlyOwner {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(address(this).balance >= amount, "Insufficient contract balance");

        (bool transferIsSuccessful, ) = receiverAddress.call{value: amount}("");
        require(transferIsSuccessful, "The transaction was unsuccessful");

        emit Log("contract successfully completed a new contract transfer");

        contractDetails = ContractDetails({
            contractName: contractName,
            lastActionTime: block.timestamp,
            lastAction: ActionType.SentEther__Withdrawal,
            deployedBy: owner,
            contractBalance: address(this).balance
        });

        emit PaymentDetails(ActionType.SentEther__Withdrawal, msg.sender, msg.value, block.timestamp);
    }
    
    /// @notice Returns the current internal state of the contract
    /// @dev Access is restricted to the contract owner
    /// @return A ContractDetails struct containing name, balance, timestamps, and last action metadata
    function getContractDetails() public view onlyOwner returns (ContractDetails memory) {
        return contractDetails;
    }

    /// @notice Converts an ActionType enum index to a descriptive string label
    /// @dev Ensures input index is within the bounds of the ActionType enum
    /// @param actionIndex A numeric value representing an ActionType
    /// @return A human-readable string for the specified ActionType enum value
    /// @custom:example getActionTypeName(0) returns "Deployed"
    /// @custom:example getActionTypeName(3) returns "ReceivedEther_ContractFunding"
    function getActionTypeName(uint8 actionIndex) public pure returns (string memory) {
        require(actionIndex <= MAX_ACTION_INDEX, "Invalid ActionType index");

        if (actionIndex == uint8(ActionType.Deployed)) return "Deployed";
        if (actionIndex == uint8(ActionType.ReceivedEther)) return "ReceivedEther";
        if (actionIndex == uint8(ActionType.ReceivedEther__Forwarding)) return "ReceivedEther_Forwarding";
        if (actionIndex == uint8(ActionType.ReceivedEther__ContractFunding)) return "ReceivedEther_ContractFunding";
        if (actionIndex == uint8(ActionType.SentEther__PassThrough)) return "SentEther__PassThrough";
        if (actionIndex == uint8(ActionType.SentEther__Withdrawal)) return "SentEther__Withdrawal";

        return "Unknown";
    }
}
