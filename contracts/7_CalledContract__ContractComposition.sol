// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title CalledContract__ContractComposition
 * @author [Your Name]
 * @notice Inherits admin-only access control and provides state tracking for contract metadata
 * @dev Demonstrates inheritance, contract composition, and encapsulated state without external modifiers
 */
contract CalledContract__ContractComposition {
    /// @notice The address of the admin (contract owner)
    address private adminAddress;

    /// @notice The total number of sales recorded
    uint256 private totalSales;

    /// @notice Timestamp of when the contract was deployed
    uint256 private creationTime;

    /// @notice Human-readable name for the contract
    string private contractName;

    /**
     * @notice Initializes the contract with a name and sets the deployer as admin
     * @dev Captures `block.timestamp` as deployment time and sets the `msg.sender` as admin
     * @param _name The name to assign to the contract
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        adminAddress = msg.sender;
    }

    /**
     * @notice Sets the total number of sales
     * @dev In a production setup, should include access control to restrict this to authorized users
     * @param newSalesCount The new sales count value to assign to `totalSales`
     */
    function setSalesCount(uint256 newSalesCount) public {
        totalSales = newSalesCount;
    }

    /**
     * @notice Returns the deployment timestamp of the contract
     * @dev Helpful for audit trails or activity timelines
     * @return UNIX timestamp of when the contract was deployed
     */
    function getContractCreationTime() public view returns (uint256) {
        return creationTime;
    }

    /**
     * @notice Returns the name assigned to this contract
     * @dev Provides user-friendly metadata for contract identification
     * @return The human-readable name of the contract
     */
    function getContractCreationName() public view returns (string memory) {
        return contractName;
    }

    /**
     * @notice Returns the total recorded sales
     * @dev Public view accessor for internal `totalSales` tracking
     * @return The value of total sales
     */
    function getTotalSales() public view returns (uint256) {
        return totalSales;
    }

    /**
     * @notice Returns the address of the contract's admin
     * @dev Useful for transparency, delegation, or admin-specific logic
     * @return The Ethereum address of the contract owner
     */
    function getAdminAddress() public view returns (address) {
        return adminAddress;
    }
}
