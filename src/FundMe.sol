//get funds from users
//Withdraw funds
//set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__CallFailed();
error FundMe__RequestMoreEth();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_owner;
    uint256 public constant MINIMUM_EUR = 5e18;
    AggregatorV3Interface private s_priceFeedETHUSD;
    AggregatorV3Interface private s_priceFeedEURUSD;

    address[] private s_funders;
    mapping(address funder => uint256 s_amountFunded)
        private s_addressToAmountFunded;

    constructor(address priceFeedETHUSD, address priceFeedEURUSD) {
        i_owner = msg.sender;
        s_priceFeedETHUSD = AggregatorV3Interface(priceFeedETHUSD);
        s_priceFeedEURUSD = AggregatorV3Interface(priceFeedEURUSD);
    }

    function fund() public payable {
        //Allow users to send €
        //set a minimumm in €
        //require(msg.value.getConversionRate() < MINIMUM_EUR, "Request more ETH to run");
        if (
            msg.value.getConversionRate(s_priceFeedETHUSD, s_priceFeedEURUSD) <=
            MINIMUM_EUR
        ) {
            revert FundMe__RequestMoreEth();
        }
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //require(callSuccess, "Call failed");
        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == owner, "Must be owner");
        for (
            /*starting index; ending index; step value */
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        //transfer - not recommended
        //payable(msg.sender).transfer(address(this).balance);
        //send - not recommended
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //require(callSuccess, "Call failed");
        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeedETHUSD.version();
    }

    modifier onlyOwner() {
        //_; means execute everything and then what is below
        //require(msg.sender == i_owner, "Sender is not the owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; //means execute what is above then eveything below
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
