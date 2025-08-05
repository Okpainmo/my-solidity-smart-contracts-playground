// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title ICalledContract__ContractComposition
 * @notice Interface to interact with a contract that supports updating sales count
 * @dev Defines the external function required to set sales count on the called contract
 */
interface ICalledContract__ContractComposition {
    /**
     * @notice Updates the total sales count on the implementing contract
     * @param newSalesCount The new total sales count value to set
     */
    function setSalesCount(uint256 newSalesCount) external;
}

/**
 * @title CallerContract__ContractComposition
 * @notice A contract to call external contracts' setSalesCount function via interface
 * @dev Demonstrates external contract calls through interface usage for contract composition
 */
contract CallerContract__ContractComposition {
    /**
     * @notice Calls the setSalesCount function on the specified external contract
     * @param _newSalesCount The new sales count to set
     * @param _calledContractAddress The address of the external contract to call
     */
    function handleSetSalesCount(uint256 _newSalesCount, address _calledContractAddress) public {
        ICalledContract__ContractComposition(_calledContractAddress).setSalesCount(_newSalesCount);
    }
}
