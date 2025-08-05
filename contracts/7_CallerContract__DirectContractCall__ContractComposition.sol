// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./7_CalledContract__ContractComposition.sol";

/**
 * @title CallerContract__DirectContractCall
 * @notice Demonstrates deploying and interacting with another contract (CalledContract__ContractComposition) both directly and indirectly.
 * @dev Shows two interaction patterns:
 *      1. Direct calls via a stored contract instance
 *      2. Indirect calls via an address reference
 */
contract CallerContract__DirectContractCall {
    /// @notice Instance of the called contract when deployed from this contract
    CalledContract__ContractComposition internal calledContract;

    /**
     * @notice Deploys a new instance of the called contract from this contract
     * @param _calledContractName The name to assign to the newly deployed contract
     */
    function deployCalledContract(string memory _calledContractName) public {
        calledContract = new CalledContract__ContractComposition(_calledContractName);
    }

    /**
     * @notice Retrieves the name of a CalledContract__ContractComposition instance
     * @dev Uses the contract address to call the function without a stored instance
     * @param _contractAddress Address of the deployed called contract
     * @return name The human-readable contract name
     */
    function getCalledContractName(address _contractAddress) public view returns (string memory name) {
        return CalledContract__ContractComposition(_contractAddress).getContractCreationName();
    }

    /**
     * @notice Retrieves the total sales count from a CalledContract__ContractComposition instance
     * @dev Uses the contract address to call the function without a stored instance
     * @param _contractAddress Address of the deployed called contract
     * @return salesCount The recorded total sales value
     */
    function getCalledContractTotalSales(address _contractAddress) public view returns (uint256 salesCount) {
        return CalledContract__ContractComposition(_contractAddress).getTotalSales();
    }

    /**
     * @notice Updates the total sales count in the stored called contract instance
     * @dev Requires that `deployCalledContract` has been called first
     * @param _newSalesCount The new sales count to set
     */
    function setSalesCount(uint256 _newSalesCount) public {
        calledContract.setSalesCount(_newSalesCount);
    }

    /**
     * @notice Returns the address of the called contract instance deployed by this contract
     * @return contractAddr The Ethereum address of the deployed called contract
     */
    function getDeployedCalledContractAddress() public view returns (address contractAddr) {
        return address(calledContract);
    }
}
