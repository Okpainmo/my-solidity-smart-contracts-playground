// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title ContractCompositionPracticeContract
 * @author [Your Name]
 * @notice Demonstrates the use of a custom modifier for restricting access to contract administrators.
 * @dev Provides a reusable modifier for access control that can be inherited by other contracts.
 */
contract RestrictedToContractAdmins {
    mapping(address => bool) internal isAdmin;

    /**
     * @notice Restricts function access to the contract owner
     * @dev Reverts if `msg.sender` is not the admin
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
    error UserIsNotContractOwner();

    /// @notice The address of the admin (contract owner)
    address internal immutable i_ownerAddress;

    /// @notice Tracks the total number of sales
    uint256 private totalSales;

    /// @notice Timestamp representing when the contract was deployed
    uint256 private creationTime;

    /// @notice Descriptive name assigned to this contract instance
    string private contractName;

    /// @notice Dynamic list of administrator addresses
    address[] private adminAddressesArray;

    uint256 private addressIndex;

    address private adminAddress;

    /// @notice Mapping used to verify whether an address has admin privileges
    // mapping(address => bool) private isAdmin;

    /**
     * @notice Initializes the contract with a name and sets the deployer as admin
     * @dev Captures `block.timestamp` as deployment time and sets the `msg.sender` as admin
     * @param _name The name to assign to the contract
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
     * @dev Only callable by admins; in production, consider external verification of sales data
     * @param newSalesCount The updated value to store as total sales
     */
    function setSalesCount(uint256 newSalesCount) public onlyAdmins {
        totalSales = newSalesCount;
    }

    /**
     * @notice Adds a new address to the list of administrators
     * @dev Only callable by existing admins; grants the new address admin rights
     * @param _addressToAdd The address to be added as an admin
     */
    function addAdmin(address _addressToAdd) public onlyAdmins {
        adminAddressesArray.push(_addressToAdd);
        isAdmin[_addressToAdd] = true;
    }

    /**
     * @notice Lists all addresses that are designated as administrators
     * @dev Only callable by existing admins to protect sensitive information
     * @return An array of Ethereum addresses with admin privileges
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
     * @notice Confirms if the caller is currently an authorized admin
     * @dev Used to validate admin rights programmatically
     * @return A boolean indicating if the caller has admin access
     */
    function verifyAdminAccess(
        address _adminAddress
    ) public view onlyAdmins returns (bool) {
        return isAdmin[_adminAddress];
    }

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

            // adminAddressesArray = new address[](0);
            adminAddressesArray = [msg.sender];
            isAdmin[i_ownerAddress] = true;
        }
    }
}
