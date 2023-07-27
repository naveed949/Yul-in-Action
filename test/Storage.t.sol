// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Storage.sol";

contract StorageTest is Test {

      Storage public store;

    function setUp() public {
        store = new Storage();
    }

    function testSetNum() public {
        store.setNum(5);
        assertEq(store.getNum(), 5);
    }
    function testSetA() public {
        store.setA(1);
        store.setB(2);
        store.setC(3);
        uint256 a = store.getA();
        assertEq(a, 1);
    }

    function testSetB() public {
        store.setA(10);
        store.setB(20);
        store.setC(30);
        uint256 b = store.getB();
        assertEq(b, 20);
    }

    function testSetC() public {
        store.setA(100);
        store.setB(200);
        store.setC(300);
        uint256 c = store.getC();
        assertEq(c, 300);
    }
}
