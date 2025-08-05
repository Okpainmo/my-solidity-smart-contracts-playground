// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import "./10_ChainlinkDataFeeds_USDtoEthLibrary.sol";

// error InsufficientEthAmount();
// error InsufficientUsdAmount();
error InsufficientContractBalance();

/**
 * @title UsdEthLibraryUsage
 * @notice Enables swapping between ETH and USD amounts using Chainlink price feeds, including contract funding and withdrawal.
 * @dev Uses the USDEthConverter library for price conversions and handles minimum swap amounts and balance checks.
 */
contract UsdEthLibraryUsage {
    using USDEthConverter for uint256; // Enables calling library functions as if they were methods on uint256

    /// @notice Minimum ETH amount (in wei) allowed for swapping
    uint256 MINIMUM_ETH_AMOUNT = 1000;

    /// @notice Minimum USD amount (scaled to 8 decimals) allowed for swapping
    uint256 MINIMUM_USD_AMOUNT = 5 * 1e8;

    /// @notice Enumeration of supported swap types
    enum SwapType {
        ethToUsd,
        usdToEth
    }

    /// @notice Maximum valid index for SwapType enum values
    uint8 constant MAX_ACTION_INDEX = uint8(type(SwapType).max);

    /**
     * @notice Emitted on every swap transaction to log details
     * @param userAddress The address receiving the swap output
     * @param swapAmount The amount swapped (in smallest unit)
     * @param swapType The type of swap performed (as string)
     */
    event SwapTransactionDetails(
        address userAddress,
        uint256 swapAmount,
        string swapType
    );

    /// @notice General purpose logging event for contract actions
    event Log(string message);

    /**
     * @notice Allows anyone to fund the contract with Ether to reserve balance for swaps
     * @dev Emits a log event upon successful funding
     */
    function fundSwapReserve() public payable {
        emit Log("contract funded successfully");
    }

    /**
     * @notice Swaps Ether to USD equivalent and emits a swap detail event
     * @dev Validates swap type string, minimum ETH amount, and calculates USD amount using Chainlink price feed
     * @param swapType The type of swap, must be "ethToUsd"
     * @param receiverAddress The address to receive swap output
     * @param ethAmount The amount of ETH to swap (in wei)
     */
    function swapEthToUsd(
        string memory swapType,
        address receiverAddress,
        uint256 ethAmount
    ) public payable {
        bytes32 ethToUsdHash = keccak256(abi.encodePacked("ethToUsd"));
        bytes32 inputHash = keccak256(abi.encodePacked(swapType));

        require(inputHash == ethToUsdHash, "Invalid swap type");
        require(
            msg.value >= MINIMUM_ETH_AMOUNT,
            "minimum swappable eth amount is 1000 wei"
        );

        (uint256 standardUnitAmount, ) = ethAmount.ethToUSD();

        emit SwapTransactionDetails(
            receiverAddress,
            standardUnitAmount,
            swapType
        );

        // proceed to use chainlink automation to trigger USD deposit offchain;
    }

    /**
     * @notice Swaps USD to Ether equivalent and transfers Ether to receiver
     * @dev Validates swap type string, minimum USD amount, contract balance, and transfers ETH accordingly
     * @param swapType The type of swap, must be "usdToEth"
     * @param receiverAddress The payable address to receive ETH
     * @param usdAmount The amount of USD to swap, scaled to 18 decimals
     */
    function swapUSDToEth(
        string memory swapType,
        address payable receiverAddress,
        uint256 usdAmount
    ) public payable {
        bytes32 usdToEthHash = keccak256(abi.encodePacked("usdToEth"));
        bytes32 inputHash = keccak256(abi.encodePacked(swapType));

        require(inputHash == usdToEthHash, "Invalid swap type");
        require(
            usdAmount >= MINIMUM_USD_AMOUNT,
            "minimum swappable USD amount is 5$"
        );

        (uint256 standardUnitPrice, ) = usdAmount.usdToEth();

        require(
            address(this).balance > standardUnitPrice,
            "Insufficient contract balance"
        );

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

    /**
     * @notice Allows the contract caller to withdraw all Ether from the contract
     * @dev Emits a log event upon successful withdrawal
     */
    function adminEthWithdrawal() public payable {
        (bool transferIsSuccessful, ) = msg.sender.call{
            value: address(this).balance
        }("");
        require(transferIsSuccessful, "The transaction was unsuccessful");

        emit Log("Eth withdrawal was successfully");
    }

    /**
     * @notice Returns the USD equivalent of a given ETH amount
     * @param ethAmount The ETH amount in wei
     * @return ethUsdPrice The converted USD amount (18 decimals)
     * @return ethUsdPrice_round The converted USD amount as a whole number
     */
    function getEthUsdEquivalent(
        uint256 ethAmount
    ) public view returns (uint256, uint256) {
        (uint256 ethUsdPrice, uint256 ethUsdPrice_round) = ethAmount.ethToUSD();

        return (ethUsdPrice, ethUsdPrice_round);
    }

    /**
     * @notice Returns the ETH equivalent of a given USD amount
     * @param usdAmount The USD amount scaled to 18 decimals
     * @return usdEthPrice The converted ETH amount (18 decimals)
     * @return usdEthPrice_round The converted ETH amount as a whole number
     */
    function getUsdEthEquivalent(
        uint256 usdAmount
    ) public view returns (uint256, uint256) {
        (uint256 usdEthPrice, uint256 usdEthPrice_round) = usdAmount.usdToEth();

        return (usdEthPrice, usdEthPrice_round);
    }

    /**
     * @notice Converts a SwapType enum value to its string representation
     * @param actionIndex The enum index of the swap type
     * @return A string describing the swap type
     */
    function getSwapTypeByEnumCode(
        uint8 actionIndex
    ) public pure returns (string memory) {
        require(actionIndex <= MAX_ACTION_INDEX, "Invalid ActionType index");

        if (actionIndex == uint8(SwapType.ethToUsd)) return "ethToUsd";
        if (actionIndex == uint8(SwapType.usdToEth)) return "usdToEth";

        return "Unknown";
    }
}
