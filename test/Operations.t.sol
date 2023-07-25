
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Operations.sol";

contract OperationsTest is Test {
    Operations public ops;

    function setUp() public {
        ops = new Operations();
    }

    function testIsPrime(uint16 num ) public  {
        assertEq(ops.isPrime(num), true);
        
    }

    function testMaxNum( )public {
        // initialize nums with random numbers
        uint256[] memory nums = new uint256[](5);
        nums[0] = 9;
        nums[1] = 20;
        nums[2] = 1;
        nums[3] = 40;
        nums[4] = 0;

        assertEq(ops.maxNum(nums), 40);
    }

}