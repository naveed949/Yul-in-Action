
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Types.sol";

contract TypesTest is Test {
    Types public types;

    function setUp() public {
        types = new Types();
    }

    function testGetNumber() public {
        assertEq(types.getNumber(), 42);
    }

    function testGetHex() public {
        assertEq(types.getHex(), 10);
    }

    function testDemoString() public {
        bytes32 myString = "lorem ipsum dolor set amet...";
        string memory expected = string(abi.encode(myString));
        string memory actual = types.demoString();

        assertEq(actual, expected);
    }

    function testRepresentation() public {
        assertEq(types.representation(), address(1));
    }

}