// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Sending and Receiving Ether with Balance Tracking
 * @author
 * @notice Enables the owner to send and receive Ether, while tracking actions and contract state changes.
 * @dev Use Remix or another Solidity-compatible IDE to deploy and interact with this contract.
 */
contract ReceiverContract__SendingAndReceivingEtherWithBalanceCheck {
    /// @notice The Ethereum address of the contract owner.
    address internal owner;

    /// @notice Human-readable name for the contract.
    string internal contractName;

    /// @notice Enum representing different tracked actions within the contract.
    enum ActionType {
        Deployed,
        ReceivedEther,
        ReceivedEther__Forwarding,
        ReceivedEther__ContractFunding,
        SentEther__PassThrough,
        SentEther__Withdrawal
    }

    /// @notice The highest valid index for the `ActionType` enum.
    uint8 constant MAX_ACTION_INDEX = uint8(type(ActionType).max);

    /// @notice Struct describing the contract's tracked state information.
    struct ContractDetails {
        string contractName;       ///< Human-readable label for the contract.
        uint256 lastActionTime;    ///< UNIX timestamp of the last recorded action.
        ActionType lastAction;     ///< Last action performed in the contract.
        address deployedBy;        ///< Ethereum address that deployed the contract.
        uint256 contractBalance;   ///< Current Ether balance of the contract (in wei).
    }

    /**
     * @notice Emitted for logging internal informational messages.
     * @param message A human-readable log message.
     */
    event Log(string message);

    /**
     * @notice Emitted after any incoming or outgoing Ether transaction.
     * @param paymentType The type of Ether transaction as defined in `ActionType`.
     * @param senderAddress The address of the sender (for incoming) or recipient (for outgoing).
     * @param amount The amount of Ether transferred (in wei).
     * @param sendTime The block timestamp when the transaction occurred.
     */
    event PaymentDetails(
        ActionType indexed paymentType,
        address indexed senderAddress,
        uint256 amount,
        uint256 sendTime
    );

    /// @notice Stores the most recent state and metadata of the contract.
    ContractDetails internal contractDetails;

    /// @notice Restricts function access to the contract owner only.
    modifier onlyOwner {
        require(msg.sender == owner, "You attempted a function call that is restricted to platform admins");
        _;
    }

    /**
     * @notice Deploys the contract and sets the deployer as owner.
     * @param _contractName A descriptive label for the contract.
     * @dev Initializes the `contractDetails` struct with deployment metadata.
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
     * @notice Accepts and logs incoming Ether payments with no calldata.
     * @dev Triggered automatically when Ether is sent via `address(this).transfer` or `send` without calldata.
     *      Updates the contract details and emits a `PaymentDetails` event.
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
     * @notice Accepts and logs incoming Ether payments with calldata.
     * @dev Triggered automatically when Ether is sent with calldata that does not match any function signature.
     *      Updates the contract details and emits a `PaymentDetails` event.
     */
    fallback() external payable {
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
     * @notice Allows the contract owner to fund the contract manually.
     * @dev Requires a nonzero `msg.value`. Updates internal state and emits a funding event.
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
     * @notice Forwards Ether sent with the transaction directly to another address.
     * @dev Functions as a pass-through payment; requires Ether sent in the transaction.
     * @param receiverAddress The recipient of the passthrough Ether.
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
     * @notice Allows the contract owner to withdraw Ether from the contract balance.
     * @dev Requires sufficient contract balance and a nonzero withdrawal amount.
     * @param receiverAddress The recipient address to receive the withdrawn Ether.
     * @param amount The amount of Ether to withdraw (in wei).
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
     * @notice Retrieves the current internal state of the contract.
     * @dev Access is restricted to the contract owner.
     * @return details A `ContractDetails` struct containing name, balance, timestamps, and last action metadata.
     */
    function getContractDetails() public view onlyOwner returns (ContractDetails memory details) {
        return contractDetails;
    }

    /**
     * @notice Converts an `ActionType` enum index to a descriptive string.
     * @dev Validates that the provided index is within bounds.
     * @param actionIndex Numeric value representing an `ActionType` enum.
     * @return actionName A human-readable string label for the specified action.
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
