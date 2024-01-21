// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address BETA_TESTEUR = makeAddr("Testeur"); //only in FOundry to simulate a tester
    uint256 constant FAKE_AMOUNT = 100e18;
    uint256 constant STARTING_BALANCE = 2000e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(BETA_TESTEUR, STARTING_BALANCE); // simulate the init of the balance of the user BETA_TESTEUR
    }

    function testUserCanFundInteractions() public {
        console.log(BETA_TESTEUR);
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(BETA_TESTEUR);
        //vm.deal(BETA_TESTEUR, STARTING_BALANCE);
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);

        //vm.prank(BETA_TESTEUR);
        //vm.deal(BETA_TESTEUR, STARTING_BALANCE);
        //address funder = fundMe.getFunder(0);
        //console.log(funder);
        //assertEq(funder, BETA_TESTEUR);
    }
}
