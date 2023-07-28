// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/StorageOps.sol";

contract StorageOpsTest  is Test {
    
        StorageOps public store;
    
        function setUp() public {
            store = new StorageOps();
        }
    
        function testReadNum() public {
            uint256 num = store.readNum();
            assertEq(num, 11);
        }
    
        function testReadFixedArray() public {
            uint256 value = store.readFixedArray(2);
            assertEq(value, 3);
        }
    
        function testWriteDynamicArray() public {
            uint256[] memory dynamicArray = new uint256[](3);
            dynamicArray[0] = 1;
            dynamicArray[1] = 2;
            dynamicArray[2] = 3;
            store.writeDynamicArray(dynamicArray);
            bytes32 value = store.readDynamicArray(2);
     
            assertEq(uint256(value), 4);
            // assertEq(store.dynamicArray(1), 2);
            // assertEq(store.dynamicArray(2), 3);
        }
}