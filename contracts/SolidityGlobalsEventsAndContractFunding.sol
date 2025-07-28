// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/// @title Solidity Globals, Events and Payments Demonstrator
/// @author
/// @notice This contract captures and emits blockchain-level global data on staff payouts
/// @dev Demonstrates use of Solidity globals like block number, timestamp, and chain ID, and also contract funding, and on-chain events

contract SolidityGlobalsEventsAndPayments {
    /// @notice The address of this contract
    address internal contractAddress;

    /// @notice The address that deployed this contract
    address internal deployedBy;

    /// @notice The address that called the latest staff payout
    address internal payer;

    /// @notice The original sender (external account) of the latest transaction
    address internal origin;

    /// @notice The value (in wei) of the latest payout transaction
    uint256 internal latestStaffPayout;

    /// @notice The block number when the latest payout occurred
    uint256 internal blockNumber;

    /// @notice The timestamp when the latest payout occurred
    uint256 internal timeStamp;

    /// @notice The chain ID of the network where the latest payout occurred
    uint256 internal chainId;

    /// @notice Emitted when a staff payout is received
    /// @param payer Address that directly sent the transaction
    /// @param origin Original external account that initiated the transaction
    /// @param amount Amount of Ether sent in the payout
    /// @param chainId Chain ID of the network
    /// @param blockNumber Block number of the transaction
    /// @param timeStamp Block timestamp when the payout occurred
    event StaffPayoutReceived(
        address indexed payer,
        address indexed origin,
        uint256 amount,
        uint256 chainId,
        uint256 blockNumber,
        uint256 timeStamp
    );

    /// @notice Initializes the contract and records the deployer's address
    constructor() {
        contractAddress = address(this);
        deployedBy = msg.sender;
    }

    /// @notice Handles a staff payout and emits global blockchain data
    /// @dev Captures several blockchain globals and emits them via event
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

    /// @notice Returns the address that deployed the contract
    /// @return The deployer's address
    function getContractDeployer() public view returns (address) {
        return deployedBy;
    }

    /// @notice Returns details of the most recent payout sender and value
    /// @return payer Address that called the payout
    /// @return origin Original external account
    /// @return latestStaffPayout Amount sent in the payout
    function getLatestPayoutTransactionData()
        public
        view
        returns (address, address, uint256)
    {
        return (payer, origin, latestStaffPayout);
    }

    /// @notice Returns block-related data of the latest payout
    /// @return blockNumber The block number at the time of payout
    /// @return timeStamp The timestamp when the payout occurred
    /// @return chainId The chain ID where payout was processed
    function getLatestPayoutBlockData()
        public
        view
        returns (uint256, uint256, uint256)
    {
        return (blockNumber, timeStamp, chainId);
    }

    /// @notice Returns the address of the deployed contract
    /// @return The contract's own address
    function getContractAddress() public view returns (address) {
        return contractAddress;
    }
}
