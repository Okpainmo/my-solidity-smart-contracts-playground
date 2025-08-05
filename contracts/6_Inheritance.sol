// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title RestrictedToContractOwner
 * @author 
 * @notice Provides a reusable access control mechanism for restricting functions to the contract owner
 * @dev Contains an `onlyOwner` modifier to enforce admin-only access
 */
contract RestrictedToContractOwner {
    /// @notice The Ethereum address of the admin (contract owner)
    address internal adminAddress;

    /**
     * @notice Restricts execution to the contract owner
     * @dev Reverts if `msg.sender` is not the current `adminAddress`
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
 * @title Inheritance Contract with Admin-Only State Management
 * @author 
 * @notice Inherits admin-only access control from `RestrictedToContractOwner` and manages sales tracking and contract metadata
 * @dev Demonstrates Solidity inheritance, modifiers, and encapsulated state variables
 */
contract Inheritance is RestrictedToContractOwner {
    /// @notice The total number of sales recorded for the contract
    uint256 private totalSales;

    /// @notice UNIX timestamp of when the contract was deployed
    uint256 private creationTime;

    /// @notice A human-readable label assigned to this contract
    string private contractName;

    /**
     * @notice Deploys the contract and assigns the deployer as the admin
     * @param _name The initial name to assign to the contract
     * @dev Records the deployment timestamp in `creationTime` and sets `adminAddress` to the deployer
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        adminAddress = msg.sender;
    }

    /**
     * @notice Updates the total number of sales
     * @dev Only callable by the admin; uses the `onlyOwner` modifier
     * @param newSalesCount The new value to set for total sales
     */
    function setSalesCount(uint256 newSalesCount) public onlyOwner {
        totalSales = newSalesCount;
    }

    /**
     * @notice Retrieves the deployment timestamp of the contract
     * @return timestamp The UNIX timestamp (seconds since epoch) of when the contract was deployed
     */
    function getContractCreationTime() public view returns (uint256 timestamp) {
        return creationTime;
    }

    /**
     * @notice Retrieves the human-readable name assigned to this contract
     * @return name The string name of the contract
     */
    function getContractCreationName() public view returns (string memory name) {
        return contractName;
    }

    /**
     * @notice Retrieves the total number of recorded sales
     * @return count The current sales count
     */
    function getTotalSales() public view returns (uint256 count) {
        return totalSales;
    }

    /**
     * @notice Retrieves the Ethereum address of the current contract admin
     * @return admin The address with admin privileges for this contract
     */
    function getAdminAddress() public view returns (address admin) {
        return adminAddress;
    }
}
