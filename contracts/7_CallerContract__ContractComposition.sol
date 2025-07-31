// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface ICalledContract__ContractComposition {
    /* no implementation(1.e. no curly braces) - just the declaration(along with any parameters), 
    then returns - if any. */
    function setSalesCount(uint256 newSalesCount) external;
}

contract CallerContract__ContractComposition {
    function handleSetSalesCount(
        uint256 _newSalesCount,
        address _calledContractAddress
    ) public {
        ICalledContract__ContractComposition(_calledContractAddress)
            .setSalesCount(_newSalesCount);
    }
}
