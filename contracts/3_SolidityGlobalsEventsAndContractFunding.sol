// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Solidity Globals, Events and Payments Demonstrator
 * @author
 * @notice Captures and emits blockchain-level global data when staff payouts occur.
 * @dev Demonstrates use of Solidity globals like block number, timestamp, chain ID,
 *      handling contract funding via payable functions, and emitting structured on-chain events.
 */
contract SolidityGlobalsEventsAndPayments {
    /// @notice The Ethereum address of this contract instance.
    /// @dev Set during deployment using `address(this)`.
    address internal contractAddress;

    /// @notice The Ethereum address that deployed this contract.
    /// @dev Recorded during contract construction using `msg.sender`.
    address internal deployedBy;

    /// @notice The address that directly initiated the latest staff payout transaction.
    /// @dev Captured from `msg.sender` in the `handleStaffPayout` function.
    address internal payer;

    /// @notice The original externally owned account (EOA) that initiated the latest transaction.
    /// @dev Captured from `tx.origin` in the `handleStaffPayout` function.
    address internal origin;

    /// @notice The value (in wei) of the most recent staff payout.
    uint256 internal latestStaffPayout;

    /// @notice The block number when the most recent payout occurred.
    uint256 internal blockNumber;

    /// @notice The timestamp when the most recent payout occurred.
    /// @dev Captured from `block.timestamp` at the time of payout.
    uint256 internal timeStamp;

    /// @notice The chain ID of the blockchain network where the most recent payout occurred.
    /// @dev Captured from `block.chainid`.
    uint256 internal chainId;

    /**
     * @notice Emitted when a staff payout is received.
     * @param payer The address that directly sent the payout transaction.
     * @param origin The original EOA that initiated the transaction.
     * @param amount The amount of Ether sent in the payout (in wei).
     * @param chainId The chain ID of the network on which the payout occurred.
     * @param blockNumber The block number in which the payout transaction was included.
     * @param timeStamp The block timestamp when the payout occurred.
     */
    event StaffPayoutReceived(
        address indexed payer,
        address indexed origin,
        uint256 amount,
        uint256 chainId,
        uint256 blockNumber,
        uint256 timeStamp
    );

    /**
     * @notice Initializes the contract by recording its own address and the deployer's address.
     * @dev `contractAddress` is set to `address(this)` and `deployedBy` is set to `msg.sender`.
     */
    constructor() {
        contractAddress = address(this);
        deployedBy = msg.sender;
    }

    /**
     * @notice Handles a staff payout and records blockchain global data.
     * @dev Requires a nonzero payment amount. Captures transaction metadata and emits it via the `StaffPayoutReceived` event.
     * @custom:requirements `msg.value` must be greater than zero.
     */
    function handleStaffPayout() external payable {
        require(msg.value > 0, "Payout amount must be greater than zero");

        payer = msg.sender;
        origin = tx.origin;
        latestStaffPayout = msg.value;

        chainId = block.chainid;
        blockNumber = block.number;
        timeStamp = block.timestamp;

        emit StaffPayoutReceived(
            payer,
            origin,
            msg.value,
            chainId,
            blockNumber,
            timeStamp
        );
    }

    /**
     * @notice Retrieves the address that deployed the contract.
     * @return deployer The deployer's Ethereum address.
     */
    function getContractDeployer() public view returns (address deployer) {
        return deployedBy;
    }

    /**
     * @notice Retrieves details of the most recent payout transaction.
     * @return payoutPayer The address that initiated the payout call.
     * @return payoutOrigin The original EOA that initiated the transaction.
     * @return payoutAmount The amount of Ether sent in the payout (in wei).
     */
    function getLatestPayoutTransactionData()
        public
        view
        returns (address payoutPayer, address payoutOrigin, uint256 payoutAmount)
    {
        return (payer, origin, latestStaffPayout);
    }

    /**
     * @notice Retrieves blockchain metadata for the most recent payout.
     * @return payoutBlockNumber The block number when the payout occurred.
     * @return payoutTimeStamp The block timestamp when the payout occurred.
     * @return payoutChainId The chain ID of the network where the payout occurred.
     */
    function getLatestPayoutBlockData()
        public
        view
        returns (uint256 payoutBlockNumber, uint256 payoutTimeStamp, uint256 payoutChainId)
    {
        return (blockNumber, timeStamp, chainId);
    }

    /**
     * @notice Retrieves the Ethereum address of this contract instance.
     * @return contractAddr The contract's own address.
     */
    function getContractAddress() public view returns (address contractAddr) {
        return contractAddress;
    }
}
