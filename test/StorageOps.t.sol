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

        function testReadNormalMap() public {
            uint256 value = store.readNormalMap(address(1));
            assertEq(value, 1);
        }

        function testWriteNormalMap() public {
            store.writeNormalMap(address(2), 11);
            assertEq(store.readNormalMap(address(2)), 11);
        }

        function testReadNestedMap() public {
            uint256 value = store.readNestedMap(address(2), 1);
            assertEq(value, 2);
        }

        function testWriteNestedMap() public {
            store.writeNestedMap(address(3), 2, 22);
            assertEq(store.readNestedMap(address(3), 2), 22);
        }

        function testReadStructMap() public {
            
            StorageOps.Data memory data  = store.readStructMap(1);
            assertEq(data.a, 1);
            assertEq(data.b, 2);
            assertEq(data.c, 3);
        }
}