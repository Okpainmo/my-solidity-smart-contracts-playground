// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract ProperCustomErrorHandlingImmutableAndConstant {
    /// @notice The address of the admin (contract owner), immutable for gas efficiency
    address private immutable i_adminAddress;

    /// @notice A constant representing the minimum platform balance (1 ether) - currently unused
    uint256 private constant MINIMUM_PLATFORM_BALANCE = 1000000000000000000;

    /// @notice The total number of sales recorded
    uint256 private totalSales;

    /// @notice Timestamp when the contract was deployed
    uint256 private creationTime;

    /// @notice Human-readable name for the contract
    string private contractName;

    /// @notice Custom error for unauthorized access by non-admins
    error UserIsNotAdmin();

    /**
     * @notice Modifier that restricts access to only the admin/owner of the contract
     * @dev Reverts with custom error `UserIsNotAdmin` if caller is not admin
     */
    modifier onlyOwner() {
        if (msg.sender != i_adminAddress) {
            revert UserIsNotAdmin();
        }
        _;
    }

    /**
     * @notice Contract constructor that sets the contract name and deployer as admin
     * @param _name The name to assign to the contract
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        i_adminAddress = msg.sender;
    }

    /**
     * @notice Updates the total sales count
     * @dev Callable only by the admin
     * @param newSalesCount The new total sales count value
     */
    function updateSalesCount(uint256 newSalesCount) public onlyOwner {
        totalSales = newSalesCount;
    }

    /**
     * @notice Retrieves the admin address
     * @dev Provides external visibility of the admin address for verification
     * @return The Ethereum address of the contract admin
     */
    function getAdminAddress() public view returns (address) {
        return i_adminAddress;
    }
}
