// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title SimpleStoragePracticeContract
 * @notice Demonstrates basic storage and retrieval of a number on the blockchain.
 * @dev This contract provides simple setter and getter functionality for a uint256 state variable.
 */
contract SimpleStoragePracticeContract {
    // @notice State variable that stores the number
    // @dev Stored persistently in contract storage
    uint256 private number;

    /**
     * @notice Stores a new number in the contract's state.
     * @dev This function modifies the contract's storage.
     * @param numberToStore The unsigned integer value to be stored.
     */
    function handleStore(uint256 numberToStore) public {
        number = numberToStore;
    }

    /**
     * @notice Retrieves the stored number.
     * @dev This is an internal view function, meaning it can only be called 
     *      within this contract or contracts deriving from it, and does not modify state.
     * @return storedNumber The number currently stored in the contract.
     */
    function handleRetrieve() internal view returns (uint256 storedNumber) {
        return number;
    }
}
