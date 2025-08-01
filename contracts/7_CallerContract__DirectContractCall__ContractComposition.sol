// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title ICalledContract__ContractComposition
 * @notice Interface for interacting with a contract that allows setting a sales count
 * @dev Defines the function signature expected from the external called contract
 */
interface ICalledContract__ContractComposition {
    /**
     * @notice Sets the total number of sales in the implementing contract
     * @param newSalesCount The new sales count to be recorded
     */
    function setSalesCount(uint256 newSalesCount) external;
}

/**
 * @title CallerContract__ContractComposition
 * @notice Handles calling the setSalesCount function of an external contract via its interface
 * @dev Demonstrates contract composition using interfaces and external function calls
 */
contract CallerContract__ContractComposition {
    /**
     * @notice Invokes setSalesCount on a specified external contract address
     * @param _newSalesCount The value to set as the new sales count
     * @param _calledContractAddress The address of the deployed contract implementing the interface
     */
    function handleSetSalesCount(uint256 _newSalesCount, address _calledContractAddress) public {
        ICalledContract__ContractComposition(_calledContractAddress).setSalesCount(_newSalesCount);
    }
}
