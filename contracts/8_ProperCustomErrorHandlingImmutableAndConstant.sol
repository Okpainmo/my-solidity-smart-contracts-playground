// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract ProperCustomErrorHandlingImmutableAndConstant {
    /// @notice The address of the admin (contract owner)
    address private immutable i_adminAddress;

    uint256 private constant MINIMUM_PLATFORM_BALANCE = 1000000000000000000; // not used anywhere, just practicing the use of the constant keyword

    /// @notice The total number of sales recorded
    uint256 private totalSales;

    /// @notice Timestamp of when the contract was deployed
    uint256 private creationTime;

    /// @notice Human-readable name for the contract
    string private contractName;

    error UserIsNotAdmin();

    /**
     * @notice Restricts access to only the admin/owner of the contract
     * @dev Reverts if `msg.sender` is not the admin
     */
    modifier onlyOwner() {
        // require(
        //     msg.sender == adminAddress,
        //     "unauthorized: you attempted an admin-only task"
        // );

        if (msg.sender != i_adminAddress) {
            // revert("you attempted an admin-only task");
            revert UserIsNotAdmin(); // this is more gas efficient as a string is not saved on the blockchain
        }

        _;
    }

    /**
     * @notice Initializes the contract with a name and sets the deployer as admin
     * @param _name The name to assign to the contract
     */
    constructor(string memory _name) {
        creationTime = block.timestamp;
        contractName = _name;
        i_adminAddress = msg.sender;
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
     * @notice Returns the admin address
     * @dev For transparency and external admin verification
     * @return The Ethereum address of the contract admin
     */
    function getAdminAddress() public view returns (address) {
        return i_adminAddress;
    }
}
