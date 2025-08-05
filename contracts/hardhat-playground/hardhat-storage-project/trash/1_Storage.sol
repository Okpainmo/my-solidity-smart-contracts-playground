// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title SimpleStoragePracticeContract
 * @dev A simple smart contract to store and retrieve a number on the blockchain.
 */

contract SimpleStoragePracticeContract {
    // State variable to hold the stored number
    uint256 private number;

    /**
     * @notice Stores a number in the contract's state
     * @dev This function writes to blockchain storage
     * @param numberToStore The number to be stored
     */
    function handleStore(uint256 numberToStore) public {
        number = numberToStore;
    }

    /**
     * @notice Retrieves the stored number
     * @dev This function reads from blockchain storage
     * @return The number currently stored in the contract
     * @notice This function is internal, only accessible within this contract or derived contracts
     */
    function handleRetrieve() internal view returns (uint256) {
        return number;
    }
}
