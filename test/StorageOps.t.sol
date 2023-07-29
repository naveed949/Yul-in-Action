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
            uint256[] memory dynamicArray = new uint256[](4);
            dynamicArray[0] = 11;
            dynamicArray[1] = 22;
            dynamicArray[2] = 33;
            dynamicArray[3] = 44;
            store.writeDynamicArray(dynamicArray);
        
            assertEq(store.readDynamicArray(0), 11);
            assertEq(store.readDynamicArray(1), 22);
            assertEq(store.readDynamicArray(2), 33);
            assertEq(store.readDynamicArray(3), 44);
        }
}