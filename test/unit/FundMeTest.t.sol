// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address BETA_TESTEUR = makeAddr("Testeur"); //only in FOundry to simulate a tester
    uint256 constant FAKE_AMOUNT = 100e18;
    uint256 constant STARTING_BALANCE = 1000e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(BETA_TESTEUR, STARTING_BALANCE); // simulate the init of the balance of the user BETA_TESTEUR
    }

    modifier funded() {
        // Modifier is used to be declared with a functon and will be executed at the start of the function
        vm.prank(BETA_TESTEUR); //Only in Foundry, the next transaction is sent by the fake user betatesteur
        fundMe.fund{value: FAKE_AMOUNT}();
        _; // all the rest of the function will de executed after
    }

    function testMinimumEuroIsFive() public {
        console.log("I'm here");
        //assertEq(number, 2);
        assertEq(fundMe.MINIMUM_EUR(), 5e18);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //check cheatcodes on FoundryBook/CheatCodes/Assertions
        fundMe.fund();
    }

    function testFundUpdatesFundMeDataStructure() public funded {
        //use of the modifier
        // Not needed anymore because of the modifier
        //vm.prank(BETA_TESTEUR); //Only in Foundry, the next transaction is sent by the fake user betatesteur
        //fundMe.fund{value: FAKE_AMOUNT}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(BETA_TESTEUR);
        assertEq(amountFunded, FAKE_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        //use of the modifier
        // Not needed anymore because of the modifier
        //vm.prank(BETA_TESTEUR); //Only in Foundry, the next transaction is sent by the fake user betatesteur
        //fundMe.fund{value: FAKE_AMOUNT}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, BETA_TESTEUR);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //use of the modifier
        // Not needed anymore because of the modifier
        //vm.prank(BETA_TESTEUR); //Only in Foundry, the next transaction is sent by the fake user betatesteur
        //fundMe.fund{value: FAKE_AMOUNT}();
        vm.expectRevert();
        vm.prank(BETA_TESTEUR);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        //Assert
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            address(fundMe.getOwner()).balance
        );
        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawWithMultipleFunder() public funded {
        //Arrange
        uint160 numberOfFunders = 10; //uint160 to use the possiblity to generate adress with address(i)
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), FAKE_AMOUNT * 2); // equivalent de PRANK (genère une adresse) et DEAL (initialise un portefeuille)
            fundMe.fund{value: FAKE_AMOUNT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        //fundMe.withdraw();
        vm.stopPrank();
        //Assert
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            address(fundMe.getOwner()).balance
        );
        assertEq(address(fundMe).balance, 0);
        assertEq(address(5).balance, FAKE_AMOUNT);
    }

    function testOwnerisMsgSender() public {
        //console.log(fundMe.i_owner());
        //console.log(address(this));
        //assertEq(fundMe.i_owner(), address(this)); // Le test crée FundMeTest qui crée une instance de FundMe. On vérifie non pas msg.sender mais l'adresse de FundMeTest
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceConversionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }
}
