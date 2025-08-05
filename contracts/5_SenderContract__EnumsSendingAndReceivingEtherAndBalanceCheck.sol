// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Sending and Receiving Ether with Balance Tracking (Sender Contract)
 * @author
 * @notice Enables the owner to send and receive Ether, with functionality to forward or withdraw funds, while tracking actions and state changes.
 * @dev Deploy using Remix or another Solidity-compatible IDE and interact with public/external functions to test sending/receiving Ether.
 */
contract SenderContract__SendingAndReceivingEtherWithBalanceCheck {
    /// @notice Ethereum address of the contract owner.
    address internal owner;

    /// @notice Human-readable name for the contract.
    string internal contractName;

    /// @notice Enum representing tracked Ether-related actions in the contract.
    enum ActionType {
        Deployed,
        ReceivedEther,
        ReceivedEther__Forwarding,
        ReceivedEther__ContractFunding,
        SentEther__PassThrough,
        SentEther__Withdrawal
    }

    /// @notice Maximum valid enum index for `ActionType`.
    uint8 constant MAX_ACTION_INDEX = uint8(type(ActionType).max);

    /// @notice Struct holding the contract's current state details.
    struct ContractDetails {
        string contractName;       ///< Name label of the contract.
        uint256 lastActionTime;    ///< UNIX timestamp of the most recent action.
        ActionType lastAction;     ///< Last action performed in the contract.
        address deployedBy;        ///< Address that deployed the contract.
        uint256 contractBalance;   ///< Current Ether balance of the contract (in wei).
    }

    /**
     * @notice Emitted to log generic internal events.
     * @param message A human-readable event message.
     */
    event Log(string message);

    /**
     * @notice Emitted after incoming or outgoing Ether transactions.
     * @param paymentType Enum value representing the type of Ether transaction.
     * @param senderAddress Address of the sender (incoming) or recipient (outgoing).
     * @param amount Amount of Ether transferred (in wei).
     * @param sendTime Block timestamp when the transaction occurred.
     */
    event PaymentDetails(
        ActionType indexed paymentType,
        address indexed senderAddress,
        uint256 amount,
        uint256 sendTime
    );

    /// @notice Stores metadata about the most recent contract state.
    ContractDetails internal contractDetails;

    /// @notice Restricts function access to the contract owner only.
    modifier onlyOwner {
        require(msg.sender == owner, "You attempted a function call that is restricted to platform admins");
        _;
    }

    /**
     * @notice Deploys the contract and sets the deployer as the owner.
     * @param _contractName A descriptive label for the contract.
     * @dev Initializes the `contractDetails` struct with deployment data.
     */
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

    /**
     * @notice Accepts and logs incoming Ether payments.
     * @dev Triggered when Ether is sent with no calldata; updates `contractDetails` and emits `PaymentDetails`.
     */
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

    /**
     * @notice Allows the contract owner to manually fund the contract.
     * @dev Requires `msg.value > 0`; updates internal state and logs funding via `PaymentDetails`.
     */
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

    /**
     * @notice Forwards Ether sent with the function call to another address.
     * @dev Pass-through payment: requires Ether to be sent along with the call.
     * @param receiverAddress The address to receive the forwarded Ether.
     */
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

    /**
     * @notice Sends Ether from the contract balance to a recipient (owner-only).
     * @dev Requires sufficient contract balance; updates `contractDetails`.
     * @param receiverAddress The recipient address to receive the Ether.
     * @param amount Amount to withdraw and send (in wei).
     */
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
    
    /**
     * @notice Retrieves the current stored contract state.
     * @dev Access restricted to the owner.
     * @return details A `ContractDetails` struct containing name, balance, timestamps, and last action metadata.
     */
    function getContractDetails() public view onlyOwner returns (ContractDetails memory details) {
        return contractDetails;
    }

    /**
     * @notice Converts an `ActionType` enum index to its string representation.
     * @dev Ensures the provided index is within the `ActionType` bounds.
     * @param actionIndex The numeric index of an `ActionType`.
     * @return actionName A human-readable name for the given enum value.
     * @custom:example getActionTypeName(0) → "Deployed"
     * @custom:example getActionTypeName(3) → "ReceivedEther_ContractFunding"
     */
    function getActionTypeName(uint8 actionIndex) public pure returns (string memory actionName) {
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
