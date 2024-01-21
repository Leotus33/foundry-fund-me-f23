// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPricesETHUSD(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getPricesEURUSD(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //address 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910
        //ABI
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(1e26 / answer);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeedETHUSD,
        AggregatorV3Interface priceFeedEURUSD
    ) internal view returns (uint256) {
        return
            (ethAmount *
                getPricesETHUSD(priceFeedETHUSD) *
                getPricesEURUSD(priceFeedEURUSD)) / 1e36;
    }

    function getVersion(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        return priceFeed.version();
    }
}
