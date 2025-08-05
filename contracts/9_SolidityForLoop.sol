// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title ContractCompositionPracticeContract
 * @author [Your Name]
 * @notice Demonstrates the use of a custom modifier for restricting access to contract administrators.
 * @dev Provides a reusable modifier for access control that can be inherited by other contracts.
 */
contract RestrictedToContractAdmins {
    /// @notice Mapping to track admin addresses and their privileges
    mapping(address => bool) internal isAdmin;

    /**
     * @notice Modifier restricting function access to admins only
     * @dev Reverts with an error message if caller is not an admin
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
 * @author [Your Name]
 * @notice Extends admin-only control and manages contract metadata and a sales counter.
 * @dev Demonstrates smart contract inheritance, state tracking, and admin role management.
 */
contract ForLoopPracticeContract is RestrictedToContractAdmins {
    /// @notice Custom error thrown when a non-owner attempts restricted actions
    error UserIsNotContractOwner();

    /// @notice The immutable address of the contract owner/admin
    address internal immutable i_ownerAddress;

    /// @notice Tracks the total number of sales
    uint256 private totalSales;

    /// @notice Timestamp of contract deployment
    uint256 private creationTime;

    /// @notice Human-readable name of the contract instance
    string private contractName;

    /// @notice Dynamic array storing all admin addresses
    address[] private adminAddressesArray;

    /// @notice Internal index variable used for looping through admin addresses
    uint256 private addressIndex;

    /// @notice Temporary address variable used during admin reset loops
    address private adminAddress;

    /**
     * @notice Constructor initializes the contract name, owner address, and admin list
     * @dev Sets deployer as initial admin and stores deployment timestamp
     * @param _name The name assigned to this contract instance
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        i_ownerAddress = msg.sender;

        adminAddressesArray.push(msg.sender);
        isAdmin[msg.sender] = true;
    }

    /**
     * @notice Updates the total sales count
     * @dev Can only be called by an admin
     * @param newSalesCount The new sales count to record
     */
    function setSalesCount(uint256 newSalesCount) public onlyAdmins {
        totalSales = newSalesCount;
    }

    /**
     * @notice Adds a new admin address to the contract
     * @dev Callable only by existing admins; grants admin privileges to the new address
     * @param _addressToAdd The address to add as an admin
     */
    function addAdmin(address _addressToAdd) public onlyAdmins {
        adminAddressesArray.push(_addressToAdd);
        isAdmin[_addressToAdd] = true;
    }

    /**
     * @notice Retrieves the list of admin addresses
     * @dev Only accessible by admins to protect sensitive data
     * @return An array containing all current admin Ethereum addresses
     */
    function getAdminAddresses()
        public
        view
        onlyAdmins
        returns (address[] memory)
    {
        return adminAddressesArray;
    }

    /**
     * @notice Checks if a given address has admin privileges
     * @dev Only callable by admins to verify admin status programmatically
     * @param _adminAddress The address to verify
     * @return True if the address is an admin, false otherwise
     */
    function verifyAdminAccess(
        address _adminAddress
    ) public view onlyAdmins returns (bool) {
        return isAdmin[_adminAddress];
    }

    /**
     * @notice Resets all admin access except for the contract owner
     * @dev Only the contract owner can call this; removes all other admins
     *      Resets the admin list array to contain only the owner address
     */
    function resetAdminAccess() public {
        if (msg.sender != i_ownerAddress) {
            revert UserIsNotContractOwner();
        }

        for (
            addressIndex = 0;
            addressIndex < adminAddressesArray.length;
            addressIndex++
        ) {
            adminAddress = adminAddressesArray[addressIndex];
            isAdmin[adminAddress] = false;

            // Reset admin list to contain only the owner address
            adminAddressesArray = [msg.sender];
            isAdmin[i_ownerAddress] = true;
        }
    }
}
