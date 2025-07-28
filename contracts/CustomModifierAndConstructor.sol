// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title CustomModifierPracticeContract
 * @author
 * @notice Demonstrates the use of a custom modifier and admin-only access control
 * @dev Allows the admin to assign a contract name, track deployment time, and update a sales counter
 */
contract CustomModifierPracticeContract {
    /// @notice The address of the admin (contract owner)
    address private adminAddress;

    /// @notice The total number of sales recorded
    uint256 private totalSales;

    /// @notice Timestamp of when the contract was deployed
    uint256 private creationTime;

    /// @notice Human-readable name for the contract
    string private contractName;

    /**
     * @notice Restricts access to only the admin/owner of the contract
     * @dev Reverts if `msg.sender` is not the admin
     */
    modifier onlyOwner() {
        require(
            msg.sender == adminAddress,
            "unauthorized: you attempted an admin-only task"
        );
        _;
    }

    /**
     * @notice Initializes the contract with a name and sets the deployer as admin
     * @param _name The name to assign to the contract
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        adminAddress = msg.sender;
    }

    /**
     * @notice Updates the total sales count
     * @dev Only callable by the admin
     * @param newSalesCount The new value to assign to totalSales
     */
    function updateSalesCount(uint256 newSalesCount) public onlyOwner {
        totalSales = newSalesCount;
    }

    /**
     * @notice Returns the timestamp when the contract was deployed
     * @return The creation time of the contract in UNIX timestamp format
     */
    function getContractCreationTime() public view returns (uint256) {
        return creationTime;
    }

    /**
     * @notice Returns the name assigned to the contract
     * @return The human-readable name of the contract
     */
    function getContractCreationName() public view returns (string memory) {
        return contractName;
    }

    /**
     * @notice Returns the total number of sales recorded
     * @dev Exposes private state variable for external view
     * @return The current total sales count
     */
    function getTotalSales() public view returns (uint256) {
        return totalSales;
    }

    /**
     * @notice Returns the admin address
     * @dev For transparency and external admin verification
     * @return The Ethereum address of the contract admin
     */
    function getAdminAddress() public view returns (address) {
        return adminAddress;
    }
}
