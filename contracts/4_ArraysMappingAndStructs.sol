// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Cashbook for Monthly Payment Tracking
 * @author
 * @notice Enables an accountancy firm to register users, track wallet balances, and record monthly payouts.
 * @dev Demonstrates the use of structs, arrays, mappings, and data access control.
 */
contract ArraysMappingsAndStructs {
    /// @notice Represents a payout made by a user.
    struct Payout {
        address paidBy;        ///< Address of the payer.
        uint256 amountPaid;    ///< Amount of Ether paid (in wei).
        uint256 paymentDate;   ///< UNIX timestamp of when the payment was made.
        address recipient;     ///< Recipient of the payout.
        uint256 id;            ///< Unique identifier for the payout.
    }

    /// @notice Represents a registered user.
    struct User {
        string name;                 ///< Full name of the user.
        uint256 walletBalance;       ///< Current wallet balance of the user.
        address userWalletAddress;   ///< User's Ethereum wallet address.
        Payout[] payouts;            ///< List of payouts made by the user.
        uint256 id;                  ///< Unique identifier for the user.
    }

    // Storage of users and payouts
    User[] internal users;
    Payout[] internal payouts;

    // User and payout mappings
    mapping(address => User) internal userData_ByAddress;
    mapping(uint256 => User) internal userData_ById;
    mapping(address => Payout[]) internal payoutMapping_AdminHas;
    mapping(address => Payout[]) internal payoutMapping_UserPayout;
    mapping(uint256 => Payout) internal payoutData;

    // Registration and tracking mappings
    mapping(address => bool) public isRegistered_ByAddress;
    mapping(uint256 => bool) public isRegistered_ById;
    mapping(address => bool) public adminHasRecordedPayouts;

    /**
     * @notice Registers a new user on the platform.
     * @dev Prevents duplicate registrations by wallet address.
     * @param _name The name of the user.
     * @param _walletBalance The initial wallet balance of the user.
     * @param _userWalletAddress The Ethereum wallet address of the user.
     * @return userId The unique ID assigned to the registered user.
     */
    function registerUser(
        string calldata _name,
        uint256 _walletBalance,
        address _userWalletAddress
    ) public returns (uint256 userId) {
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
     * @notice Updates an existing user's information.
     * @dev Updates user details and wallet address mapping.
     * @param _name The updated name of the user.
     * @param _walletBalance The updated wallet balance.
     * @param _userWalletAddress The updated Ethereum wallet address.
     * @param _payouts The updated payout history.
     * @param _id The user's unique ID.
     * @return updatedUser The updated user data.
     */
    function updateUser(
        string memory _name,
        uint256 _walletBalance,
        address _userWalletAddress,
        Payout[] memory _payouts,
        uint256 _id
    ) public returns (User memory updatedUser) {
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
     * @notice Updates a payout record.
     * @param paidBy The address that made the payment.
     * @param amountPaid The amount paid (in wei).
     * @param paymentDate The timestamp of when it was paid.
     * @param recipient The address that received the payment.
     * @param id The payout ID.
     * @return updatedPayout The updated payout data.
     */
    function updatePayout(
        address paidBy,
        uint256 amountPaid,
        uint256 paymentDate,
        address recipient,
        uint256 id
    ) public view returns (Payout memory updatedPayout) {
        Payout memory payout = payoutData[id];

        payout.paidBy = paidBy;
        payout.amountPaid = amountPaid;
        payout.paymentDate = paymentDate;
        payout.recipient = recipient;
        payout.id = id;

        return payout;
    }

    /**
     * @notice Retrieves the full account data for a user by wallet address.
     * @param _userWalletAddress The wallet address of the user.
     * @return userData The full `User` struct of the requested user.
     */
    function getUserAccountData(
        address _userWalletAddress
    ) public view returns (User memory userData) {
        require(
            isRegistered_ByAddress[_userWalletAddress],
            "A user with this wallet address not found or does not exist"
        );
        return userData_ByAddress[_userWalletAddress];
    }

    /**
     * @notice Records a new payout for a user.
     * @dev Automatically sets the payment date to the current block timestamp.
     * @param _paidBy The address that made the payment.
     * @param _amountPaid The amount paid (in wei).
     * @param _recipient The address that received the payment.
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
     * @notice Retrieves all payouts made on the platform.
     * @return payoutsArray The list of all payouts.
     */
    function getAllPlatformPayouts() public view returns (Payout[] memory payoutsArray) {
        return payouts;
    }

    /**
     * @notice Retrieves all registered users on the platform.
     * @return usersArray The list of all users.
     */
    function getAllPlatformUsers() public view returns (User[] memory usersArray) {
        return users;
    }

    /**
     * @notice Retrieves all payouts made by a specific user.
     * @param _userWalletAddress The wallet address of the user.
     * @return userPayouts The list of payouts made by the specified user.
     */
    function getAllUserPayouts(
        address _userWalletAddress
    ) public view returns (Payout[] memory userPayouts) {
        require(
            isRegistered_ByAddress[_userWalletAddress],
            "A user with this wallet address not found or does not exist"
        );

        User memory user = userData_ByAddress[_userWalletAddress];
        return user.payouts;
    }

    /**
     * @notice Retrieves all payouts recorded by a given admin address.
     * @param _adminAddress The Ethereum address of the admin.
     * @return payoutsList The list of payouts recorded by the specified admin.
     */
    function getAllPayoutsMadeByAnAdmin(
        address _adminAddress
    ) public view returns (Payout[] memory payoutsList) {
        require(
            adminHasRecordedPayouts[_adminAddress],
            "No payouts made by this admin"
        );

        return payoutMapping_AdminHas[_adminAddress];
    }
}
