// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./7_CalledContract__ContractComposition.sol";

contract CallerContract__DirectContractCall {
    CalledContract__ContractComposition internal calledContract;

    // constructor() {
    //     calledContract = new CalledContract__ContractComposition("ProgramaticCalledContract");
    // }

    function deployCalledContract(string memory _calledContractName) public {
        calledContract = new CalledContract__ContractComposition(_calledContractName);
    }

    function getCalledContractName(address _contractAddress) public view returns(string memory){
        // calling in-directly via contract address
        return CalledContract__ContractComposition(_contractAddress).getContractCreationName();
    }

    function getCalledContractTotalSales(address _contractAddress) public view returns(uint256) {
        // calling in-directly via contract address
        return CalledContract__ContractComposition(_contractAddress).getTotalSales();
    }

    function setSalesCount(uint256 _newSalesCount) public {
        // calling directly
        calledContract.setSalesCount(_newSalesCount);
    }

    // below commented code works as well - to get the deployed contract address
    // function getDeployedCalledContractAddress() public view returns(CalledContract__ContractComposition) {
    //     return calledContract;
    // }

    function getDeployedCalledContractAddress() public view returns(address) {
        return address(calledContract);
    }
}