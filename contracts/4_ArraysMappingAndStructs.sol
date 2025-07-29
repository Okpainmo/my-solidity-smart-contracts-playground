// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Cashbook for Monthly Payment Tracking
 * @author
 * @notice This contract allows an accountancy firm to register users, track wallet balances, and record monthly payouts.
 * @dev Demonstrates the use of structs, arrays, mappings and data access control.
 */
contract ArraysMappingsAndStructs {
    /// @notice Represents a payout made by a user
    struct Payout {
        address paidBy; ///< Address of the payer
        uint256 amountPaid; ///< Amount paid
        uint256 paymentDate; ///< Timestamp of payment
        address recipient; ///< Recipient of the payout
        uint256 id; ///< Unique identifier for payout
    }

    /// @notice Represents a registered user
    struct User {
        string name; ///< Full name of the user
        uint256 walletBalance; ///< User's current wallet balance
        address userWalletAddress; ///< User's Ethereum wallet address
        Payout[] payouts; ///< List of all payouts made by the user
        uint256 id; ///< Unique identifier for the user
    }

    User[] internal users;
    Payout[] internal payouts;

    mapping(address => User) internal userData_ByAddress;
    mapping(uint256 => User) internal userData_ById;
    mapping(address => Payout[]) internal payoutMapping_AdminHas;
    mapping(address => Payout[]) internal payoutMapping_UserPayout;
    mapping(uint256 => Payout) internal payoutData;
    mapping(address => bool) public isRegistered_ByAddress;
    mapping(uint256 => bool) public isRegistered_ById;
    mapping(address => bool) public adminHasRecordedPayouts;

    /**
     * @notice Registers a new user
     * @param _name The name of the user
     * @param _walletBalance The initial wallet balance
     * @param _userWalletAddress The Ethereum address of the user
     * @return userId The unique ID assigned to the registered user
     */
    function registerUser(
        string calldata _name,
        uint256 _walletBalance,
        address _userWalletAddress
    ) public returns (uint256) {
        require(
            !isRegistered_ByAddress[_userWalletAddress],
            "A user already exist with this wallet address. Duplicate users not allowed"
        );

        Payout[] memory userPayouts;
        users.push();

        User memory userToUpdate = users[users.length - 1];

        userToUpdate.name = _name;
        userToUpdate.walletBalance = _walletBalance;
        userToUpdate.userWalletAddress = _userWalletAddress;
        userToUpdate.payouts = userPayouts;
        userToUpdate.id = users.length + 1;

        User memory userMapping = userData_ByAddress[_userWalletAddress];

        userMapping.name = _name;
        userMapping.walletBalance = _walletBalance;
        userMapping.userWalletAddress = _userWalletAddress;
        userMapping.payouts = userPayouts;
        userToUpdate.id = payouts.length + 1;

        isRegistered_ById[payouts.length + 1] = true;
        isRegistered_ByAddress[_userWalletAddress] = true;

        return userToUpdate.id;
    }

    /**
     * @notice Updates user information
     * @param _name New name
     * @param _walletBalance Updated wallet balance
     * @param _userWalletAddress Updated address
     * @param _payouts New payout history
     * @param _id User ID
     * @return user Updated user data
     */
    function updateUser(
        string memory _name,
        uint256 _walletBalance,
        address _userWalletAddress,
        Payout[] memory _payouts,
        uint256 _id
    ) public returns (User memory) {
        require(
            isRegistered_ById[_id],
            "A registered user with this id not found or does not exist"
        );

        User memory user = userData_ById[_id];

        isRegistered_ByAddress[user.userWalletAddress] = false;

        user.name = _name;
        user.payouts = _payouts;
        user.walletBalance = _walletBalance;
        user.userWalletAddress = _userWalletAddress;

        isRegistered_ByAddress[_userWalletAddress] = true;

        return user;
    }

    /**
     * @notice Updates payout record
     * @param paidBy Who made the payment
     * @param amountPaid Amount paid
     * @param paymentDate When it was paid
     * @param recipient Who received the payment
     * @param id Payout ID
     * @return payout The updated payout data
     */
    function updatePayout(
        address paidBy,
        uint256 amountPaid,
        uint256 paymentDate,
        address recipient,
        uint256 id
    ) public view returns (Payout memory) {
        Payout memory payout = payoutData[id];

        payout.paidBy = paidBy;
        payout.amountPaid = amountPaid;
        payout.paymentDate = paymentDate;
        payout.recipient = recipient;
        payout.id = id;

        return payout;
    }

    /**
     * @notice Retrieves full account data for a user
     * @param _userWalletAddress The wallet address of the user
     * @return user The full User struct
     */
    function getUserAccountData(
        address _userWalletAddress
    ) public view returns (User memory) {
        require(
            isRegistered_ByAddress[_userWalletAddress],
            "A user with this wallet address not found or does not exist"
        );
        return userData_ByAddress[_userWalletAddress];
    }

    /**
     * @notice Records a payout for a user
     * @param _paidBy Who made the payment
     * @param _amountPaid Amount paid
     * @param _recipient Who received the payment
     */
    function recordPayOut(
        address _paidBy,
        uint256 _amountPaid,
        address _recipient
    ) public {
        payouts.push();
        Payout storage payoutToUpdate = payouts[payouts.length - 1];

        payoutToUpdate.paidBy = _paidBy;
        payoutToUpdate.amountPaid = _amountPaid;
        payoutToUpdate.paymentDate = block.timestamp;
        payoutToUpdate.recipient = _recipient;
        payoutToUpdate.id = payouts.length + 1;

        Payout[] storage adminPayoutsToUpdate = payoutMapping_AdminHas[_paidBy];
        adminPayoutsToUpdate.push(payoutToUpdate);

        adminHasRecordedPayouts[_paidBy] = true;
        payoutData[payouts.length + 1] = payoutToUpdate;

        User storage user = userData_ByAddress[_recipient];
        Payout[] storage userPayouts = user.payouts;
        userPayouts.push(payoutToUpdate);
    }

    /**
     * @notice Returns all payouts made on the platform
     * @return payoutsArray The list of all payouts
     */
    function getAllPlatformPayouts() public view returns (Payout[] memory) {
        return payouts;
    }

    /**
     * @notice Returns all registered users on the platform
     * @return usersArray The list of all users
     */
    function getAllPlatformUsers() public view returns (User[] memory) {
        return users;
    }

    /**
     * @notice Retrieves all payouts for a specific user
     * @param _userWalletAddress The user's wallet address
     * @return userPayouts The payouts made by the user
     */
    function getAllUserPayouts(
        address _userWalletAddress
    ) public view returns (Payout[] memory) {
        require(
            isRegistered_ByAddress[_userWalletAddress],
            "A user with this wallet address not found or does not exist"
        );

        User memory user = userData_ByAddress[_userWalletAddress];
        return user.payouts;
    }

    /**
     * @notice Retrieves all payouts made by a given admin address
     * @param _adminAddress The Ethereum address of the admin
     * @return payoutsList List of payouts recorded by this admin
     */
    function getAllPayoutsMadeByAnAdmin(
        address _adminAddress
    ) public view returns (Payout[] memory) {
        require(
            adminHasRecordedPayouts[_adminAddress],
            "No payouts made by this admin"
        );

        return payoutMapping_AdminHas[_adminAddress];
    }
}
