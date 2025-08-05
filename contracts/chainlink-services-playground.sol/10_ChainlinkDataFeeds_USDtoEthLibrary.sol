// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title USDEthConverter
 * @notice Provides utility functions to convert between USD and ETH amounts using Chainlink price feeds.
 * @dev Uses the Chainlink AggregatorV3Interface to fetch the latest ETH/USD price.
 */
library USDEthConverter {
    /**
     * @notice Retrieves the latest ETH price in USD with 18 decimals precision.
     * @dev Queries Chainlink price feed contract at a known address.
     * @return The current ETH price in USD scaled to 18 decimals.
     */
    function getEthPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int price, , , ) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    /**
     * @notice Converts a USD amount (18 decimals) to the equivalent ETH amount (18 decimals).
     * @dev Input USD amount must be scaled with 18 decimals (e.g. $3466.67 as 3466670000000000000000).
     * @param _usdAmount The USD amount in 18 decimal format.
     * @return standardUnitAmount The equivalent ETH amount in 18 decimal format.
     * @return readAbleAmount The equivalent ETH amount as a human-readable integer (without decimals).
     */
    function usdToEth(
        uint256 _usdAmount
    ) public view returns (uint256 standardUnitAmount, uint256 readAbleAmount) {
        uint256 ethPrice = getEthPrice();

        standardUnitAmount = (_usdAmount * 1e18) / ethPrice;
        readAbleAmount = standardUnitAmount / 1e18;
    }

    /**
     * @notice Converts an ETH amount (18 decimals) to the equivalent USD amount (18 decimals).
     * @dev Input ETH amount must be scaled with 18 decimals.
     * @param _ethAmount The ETH amount in 18 decimal format.
     * @return standardUnitPrice The equivalent USD amount in 18 decimal format.
     * @return readablePrice The equivalent USD amount as a human-readable integer (without decimals).
     */
    function ethToUSD(
        uint256 _ethAmount
    ) public view returns (uint256 standardUnitPrice, uint256 readablePrice) {
        uint256 ethPrice = getEthPrice();

        standardUnitPrice = (_ethAmount * ethPrice) / 1e18;
        readablePrice = standardUnitPrice / 1e18;
    }
}
