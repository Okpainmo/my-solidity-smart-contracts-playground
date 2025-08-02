// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import "./10_ChainlinkDataFeeds_USDtoEthLibrary.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// error InsufficientEthAmount();
// error InsufficientUsdAmount();
error InsufficientContractBalance();

contract UsdEthLibraryUsage {
    using USDEthConverter for uint256; // setup for using a library to run data types as though they were methods.
    uint256 MINIMUM_ETH_AMOUNT = 1000;
    uint256 MINIMUM_USD_AMOUNT = 5 * 1e8;

    enum SwapType {
        ethToUsd,
        usdToEth
    }
    uint8 constant MAX_ACTION_INDEX = uint8(type(SwapType).max);

    event SwapTransactionDetails(
        address userAddress,
        uint256 swapAmount,
        string swapType
    );

    event Log(string message);

    function fundSwapReserve() public payable {
        emit Log("contract funded successfully");
    }

    function swapEthToUsd(
        string memory swapType,
        address receiverAddress,
        uint256 ethAmount
    ) public payable {
        bytes32 ethToUsdHash = keccak256(abi.encodePacked("ethToUsd"));
        // bytes32 usdToEthHash = keccak256(abi.encodePacked("usdToEth"));
        bytes32 inputHash = keccak256(abi.encodePacked(swapType));

        if (inputHash != ethToUsdHash) {
            revert("Invalid swap type");
        }

        // openzeppelin string library usage
        // if(!swapType.equals("ethToUsd") && !swapType.equals("usdToEth")) {
        // revert("Invalid swap type");
        // }

        if (msg.value < MINIMUM_ETH_AMOUNT) {
            revert("minimum swappable eth amount is 1000 wei");
        }

        (uint256 standardUnitAmount, ) = ethAmount.ethToUSD();

        emit SwapTransactionDetails(
            receiverAddress,
            standardUnitAmount,
            swapType
        );

        // proceed to use chainlink automation to trigger USD deposit offchain;
    }

    /* 
        IMPORTANT.

        The below function is left for open access for only for the purpose of this example.
        Ideally, such a function will be a token-contract on it's own which must be programmatically
        deployed by a platform-core/controller contract - thus enabling the use of a constructor setup along with 
        an authentication/validation modifier to permit only the platform-core contract to call the function.
    */

    function swapUSDToEth(
        string memory swapType,
        address payable receiverAddress,
        uint256 usdAmount
    ) public payable {
        // bytes32 ethToUsdHash = keccak256(abi.encodePacked("ethToUsd"));
        bytes32 usdToEthHash = keccak256(abi.encodePacked("usdToEth"));
        bytes32 inputHash = keccak256(abi.encodePacked(swapType));

        if (inputHash != usdToEthHash) {
            revert("Invalid swap type");
        }

        // openzeppelin string library usage
        // if(!swapType.equals("ethToUsd") && !swapType.equals("usdToEth")) {
        // revert("Invalid swap type");
        // }

        if (usdAmount < MINIMUM_USD_AMOUNT) {
            revert("minimum swappable USD amount is 5$");
        }

        (uint256 standardUnitPrice, ) = usdAmount.usdToEth();

        // proceed to send eth to the user from contract balance
        if (address(this).balance <= standardUnitPrice) {
            revert InsufficientContractBalance();
        }

        (bool transferIsSuccessful, ) = receiverAddress.call{
            value: standardUnitPrice
        }("");
        require(transferIsSuccessful, "The transaction was unsuccessful");

        emit SwapTransactionDetails(
            receiverAddress,
            standardUnitPrice,
            swapType
        );

        emit Log("contract successfully completed a usdToEthSwap");
    }

    function adminEthWithdrawal() public payable {
        (bool transferIsSuccessful, ) = msg.sender.call{
            value: address(this).balance
        }("");
        require(transferIsSuccessful, "The transaction was unsuccessful");

        emit Log("Eth withdrawal was successfully");
    }

    function getEthUsdEquivalent(
        uint256 ethAmount
    ) public view returns (uint256, uint256) {
        (uint256 ethUsdPrice, uint256 ethUsdPrice_round) = ethAmount.ethToUSD();

        return (ethUsdPrice, ethUsdPrice_round);
    }

    function getUsdEthEquivalent(
        uint256 usdAmount
    ) public view returns (uint256, uint256) {
        (uint256 usdEthPrice, uint256 usdEthPrice_round) = usdAmount.usdToEth();

        return (usdEthPrice, usdEthPrice_round);
    }

    function getSwapTypeByEnumCode(
        uint8 actionIndex
    ) public pure returns (string memory) {
        require(actionIndex <= MAX_ACTION_INDEX, "Invalid ActionType index");

        if (actionIndex == uint8(SwapType.ethToUsd)) return "ethToUsd";
        if (actionIndex == uint8(SwapType.usdToEth)) return "usdToEth";

        return "Unknown";
    }
}
