// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title RestrictedToContractAdmins
 * @notice Provides reusable admin-only access control for derived contracts.
 * @dev Contains an `onlyAdmins` modifier and internal admin tracking.
 */
contract RestrictedToContractAdmins {
    /// @notice The Ethereum address of the original contract owner
    address internal contractOwnerAddress;

    /// @notice Tracks which addresses have admin privileges
    mapping(address => bool) internal isAdmin; 

    /**
     * @notice Restricts execution to authorized admins
     * @dev Reverts if `msg.sender` is not in the `isAdmin` mapping
     */
    modifier onlyAdmins() {
        require(
            isAdmin[msg.sender],
            "Unauthorized: you attempted an admin-only task"
        );
        _;
    }
}

/**
 * @title CalledContract__ContractComposition
 * @notice Extends `RestrictedToContractAdmins` with sales tracking, contract metadata, and admin management.
 * @dev Demonstrates contract composition, inheritance, and multi-admin role management.
 */
contract CalledContract__ContractComposition is RestrictedToContractAdmins {
    /// @notice Tracks the total number of sales
    uint256 private totalSales;

    /// @notice UNIX timestamp when the contract was deployed
    uint256 private creationTime;

    /// @notice Human-readable name for the contract
    string private contractName;

    /// @notice List of all administrator addresses
    address[] private adminAddressesArray;

    /**
     * @notice Deploys the contract and assigns the deployer as the first admin
     * @param _name The initial name to assign to the contract
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        contractOwnerAddress = msg.sender;

        adminAddressesArray.push(msg.sender);
        isAdmin[msg.sender] = true;
    }

    /**
     * @notice Updates the total number of sales
     * @dev Only callable by admins
     * @param newSalesCount The new sales total to set
     */
    function setSalesCount(uint256 newSalesCount) public onlyAdmins {
        totalSales = newSalesCount;
    }

    /**
     * @notice Retrieves the timestamp when the contract was deployed
     * @return timestamp The UNIX timestamp of deployment
     */
    function getContractCreationTime() public view returns (uint256 timestamp) {
        return creationTime;
    }

    /**
     * @notice Retrieves the human-readable name assigned to the contract
     * @return name The contract name
     */
    function getContractCreationName() public view returns (string memory name) {
        return contractName;
    }

    /**
     * @notice Retrieves the total number of recorded sales
     * @return count The current sales total
     */
    function getTotalSales() public view returns (uint256 count) {
        return totalSales;
    }

    /**
     * @notice Grants admin privileges to a new address
     * @dev Only callable by existing admins
     * @param _addressToAdd The address to grant admin rights
     */
    function addAdmin(address _addressToAdd) public onlyAdmins {
        adminAddressesArray.push(_addressToAdd);
        isAdmin[_addressToAdd] = true;
    }

    /**
     * @notice Returns the list of all admin addresses
     * @return admins Array of addresses with admin privileges
     */
    function getAdminAddresses() public view onlyAdmins returns (address[] memory admins) {
        return adminAddressesArray;
    }

    /**
     * @notice Checks if a specific address is an authorized admin
     * @param _adminAddress The address to check
     * @return hasAccess True if the address has admin rights, false otherwise
     */
    function verifyAdminAccess(address _adminAddress) public view onlyAdmins returns (bool hasAccess) {
        return isAdmin[_adminAddress];
    }

    /**
     * @notice Retrieves the deployed contract's address
     * @return contractAddr The address of this contract on-chain
     */
    function getContractAddress() public view returns (address contractAddr) {
        return address(this);
    }
}
