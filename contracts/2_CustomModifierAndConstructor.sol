// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title CustomModifierPracticeContract
 * @author
 * @notice Demonstrates the use of a custom modifier and admin-only access control.
 * @dev Allows the admin to assign a contract name, track deployment time, and update a sales counter.
 */
contract CustomModifierPracticeContract {
    /// @notice Ethereum address of the contract admin (owner).
    /// @dev Set once at deployment to the address that deployed the contract.
    address private adminAddress;

    /// @notice The total number of sales recorded by the contract.
    uint256 private totalSales;

    /// @notice UNIX timestamp of when the contract was deployed.
    uint256 private creationTime;

    /// @notice Human-readable name assigned to the contract.
    string private contractName;

    /**
     * @notice Restricts function access to only the contract admin (owner).
     * @dev Reverts with a custom message if `msg.sender` is not `adminAddress`.
     */
    modifier onlyOwner() {
        require(
            msg.sender == adminAddress,
            "unauthorized: you attempted an admin-only task"
        );
        _;
    }

    /**
     * @notice Deploys the contract with a specified name and sets the deployer as the admin.
     * @dev Records the deployment timestamp and initializes state variables.
     * @param _name The name to assign to the contract.
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        adminAddress = msg.sender;
    }

    /**
     * @notice Updates the total sales count.
     * @dev Only callable by the admin. Overwrites the existing sales count with the new value.
     * @param newSalesCount The new value to assign to `totalSales`.
     */
    function updateSalesCount(uint256 newSalesCount) public onlyOwner {
        totalSales = newSalesCount;
    }

    /**
     * @notice Retrieves the timestamp when the contract was deployed.
     * @return contractCreationTime The deployment time in UNIX timestamp format.
     */
    function getContractCreationTime() public view returns (uint256 contractCreationTime) {
        return creationTime;
    }

    /**
     * @notice Retrieves the name assigned to the contract.
     * @return name The human-readable name of the contract.
     */
    function getContractCreationName() public view returns (string memory name) {
        return contractName;
    }

    /**
     * @notice Retrieves the total number of sales recorded.
     * @dev Exposes the `totalSales` private state variable for external read access.
     * @return salesCount The current total sales count.
     */
    function getTotalSales() public view returns (uint256 salesCount) {
        return totalSales;
    }

    /**
     * @notice Retrieves the admin address.
     * @dev Can be used by external callers to verify the admin identity.
     * @return admin The Ethereum address of the contract admin.
     */
    function getAdminAddress() public view returns (address admin) {
        return adminAddress;
    }
}
