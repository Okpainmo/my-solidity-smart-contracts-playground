// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title CustomModifierPracticeContract
 * @author [Your Name]
 * @notice Demonstrates the use of a custom modifier and admin-only access control
 * @dev Allows the admin to assign a contract name, track deployment time, and update a sales counter
 */
contract RestrictedToContractOwner {
    /// @notice The address of the admin (contract owner)
    address internal adminAddress;

    /**
     * @notice Restricts function access to the contract owner
     * @dev Reverts if `msg.sender` is not the admin
     */
    modifier onlyOwner() {
        require(
            msg.sender == adminAddress,
            "unauthorized: you attempted an admin-only task"
        );
        _;
    }
}

/**
 * @title Inheritance Contract
 * @author [Your Name]
 * @notice Inherits admin-only access control and provides state tracking for contract metadata
 * @dev Demonstrates inheritance, modifiers, and encapsulated state
 */
contract Inheritance is RestrictedToContractOwner {
    /// @notice The total number of sales recorded
    uint256 private totalSales;

    /// @notice Timestamp of when the contract was deployed
    uint256 private creationTime;

    /// @notice Human-readable name for the contract
    string private contractName;

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
     * @notice Sets the total number of sales
     * @dev Only callable by the admin using the `onlyOwner` modifier
     * @param newSalesCount The new sales count value
     */
    function setSalesCount(uint256 newSalesCount) public onlyOwner {
        totalSales = newSalesCount;
    }

    /**
     * @notice Returns the deployment timestamp of the contract
     * @return UNIX timestamp of when the contract was deployed
     */
    function getContractCreationTime() public view returns (uint256) {
        return creationTime;
    }

    /**
     * @notice Returns the name assigned to this contract
     * @return The human-readable name of the contract
     */
    function getContractCreationName() public view returns (string memory) {
        return contractName;
    }

    /**
     * @notice Returns the total recorded sales
     * @return The value of total sales
     */
    function getTotalSales() public view returns (uint256) {
        return totalSales;
    }

    /**
     * @notice Returns the address of the contract's admin
     * @return The Ethereum address of the contract owner
     */
    function getAdminAddress() public view returns (address) {
        return adminAddress;
    }
}
