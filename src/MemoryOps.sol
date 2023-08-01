// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title Memory
 * @dev Contains various functions that demonstrate how to work with memory in Solidity.
 */
contract Memory {
    /**
     * @dev Struct representing a point in 2D space.
     */
    struct Point {
        uint256 x;
        uint256 y;
    }

    /**
     * @dev Emitted when the current memory pointer is obtained.
     * @param x40 The current memory pointer.
     */
    event MemoryPointer(bytes32 x40);

    /**
     * @dev Emitted when the current memory pointer and size are obtained.
     * @param x40 The current memory pointer.
     * @param _msize The current memory size.
     */
    event MemoryPointerMsize(bytes32 x40, bytes32 _msize);

    /**
     * @dev Emitted when debugging information is obtained.
     * @param location The location of the array in memory.
     * @param len The length of the array.
     * @param valueAtIndex0 The value at index 0 of the array.
     * @param valueAtIndex1 The value at index 1 of the array.
     */
    event Debug(bytes32 location, bytes32 len, bytes32 valueAtIndex0, bytes32 valueAtIndex1);

    /**
     * @dev Demonstrates how to access high memory in Solidity.
     * @notice
     * gas consumption gets increasing as you access memory further away
     * mload(0xffffffffffffffff) is the highest memory address, whose cost is above block gas limit
     * so this function will always fail with "out of gas" error
     */
    function highAccess() external pure {
        assembly {
            // pop just throws away the return value
            pop(mload(0xffffffffffffffff))
        }
    }

    /**
     * @dev Demonstrates how to store a single byte in memory.
     */
    function mstore8() external pure {
        assembly {
            // store 0x7 at memory address 0x00 by writing only the first byte (8 bits)
            mstore8(0x00, 7)
            // store 0x7 at memory address 0x00 by writing the entire word (256 bits)
            mstore(0x00, 7)
        }
    }

    /**
     * @dev Demonstrates how to get the current memory pointer in Solidity plus how it gets updated.
     * Emits a `MemoryPointer` event before and after creating a new `Point` struct.
     */
    function memPointer() external {
        bytes32 x40;
        assembly {
            // retrieve the current memory pointer
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        // create a new Point struct in memory
        Point memory p = Point({x: 1, y: 2});

        assembly {
            // retrieve the current memory pointer again (after creating the Point struct)
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    /**
     * @dev Demonstrates how to get the current memory pointer and size in Solidity.
     * Emits a `MemoryPointerMsize` event before and after creating a new `Point` struct,
     * and after calling `pop(mload(0xff))`.
     */
    function memPointerV2() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            // retrieve the current memory pointer
            x40 := mload(0x40) // 0x40 is the address where next free memory slot is stored in Solidity
            // retrieve the current memory size (max memory size accessed so far in the current call)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);

        Point memory p = Point({x: 1, y: 2}); // consumes 64 bytes of memory
        assembly {
            // retrieve updated memory pointer
            x40 := mload(0x40) //
            // retrieve updated memory size
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);

        assembly {
            // load the value at memory address 0xff (the last word in memory) and pop it off the stack
            pop(mload(0xff))
            // retrieve updated memory pointer
            x40 := mload(0x40)
            // retrieve updated memory size
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);
    }

    /**
     * @dev Demonstrates how fixed size array consumes memory in Solidity.
     * Emits a `MemoryPointer` event before and after creating a new `uint256[2]` array.
     */
    function fixedArray() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40) // 0x80 (128) is the address where next free memory slot is stored in Solidity
        }
        emit MemoryPointer(x40);
        uint256[2] memory arr = [uint256(5), uint256(6)]; // consumes 64 bytes of memory (2 slots of 32 bytes each i.e: 0x80 and 0xa0)
        assembly {
            x40 := mload(0x40) // 0xc0 (192) is the address where next free memory slot is stored in Solidity
        }
        emit MemoryPointer(x40);
    }

    /**
     * @dev Demonstrates how `abi.encode()` function consumes memory in Solidity.
     * Emits a `MemoryPointer` event before and after calling `abi.encode(uint256(5), uint256(19))`.
     */
    function abiEncode() external {
        bytes32 x40;
        assembly {
            // retrieve the current memory pointer
            x40 := mload(0x40) // 0x80 (128) is the address where next free memory slot is stored in Solidity
        }
        emit MemoryPointer(x40);
        // pad the arguments to 32 bytes each and concatenate them in memory
        abi.encode(uint256(5), uint256(19)); // consumes 96 bytes of memory (3 slots of 32 bytes each i.e: 0x80, 0xa0 and 0xc0) 0x80 to store length of bytes i.e: 64 bytes (32 + 32)
        assembly {
            // retrieve the updated memory pointer
            x40 := mload(0x40) // 0xe0 (224) is the address where next free memory slot is stored in Solidity
        }
        emit MemoryPointer(x40);
    }

    /**
     * @dev Demonstrates how `abi.encode()` function with different argument types consumes memory in Solidity.
     * Emits a `MemoryPointer` event before and after calling `abi.encode(uint256(5), uint128(19))`.
     */
    function abiEncode2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint128(19));
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    /**
     * @dev Demonstrates how `abi.encodePacked()` function consumes memory in Solidity.
     * Emits a `MemoryPointer` event before and after calling `abi.encodePacked(uint256(5), uint128(19))`.
     */
    function abiEncodePacked() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encodePacked(uint256(5), uint128(19)); // packs the arguments tightly in memory, thus consumes 32 + 16 = 48 bytes of memory instead of 64 bytes
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    /**
     * @dev Demonstrates how to access the contents of a dynamic array in Solidity.
     * Takes a single parameter, `arr`, which is a dynamic array of `uint256` values.
     * Emits a `Debug` event with information about the array.
     */
    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;
        assembly {
            location := arr
            len := mload(arr)
            valueAtIndex0 := mload(add(arr, 0x20))
            valueAtIndex1 := mload(add(arr, 0x40))
            // ...
        }
        emit Debug(location, len, valueAtIndex0, valueAtIndex1);
    }

    /**
     * @dev Demonstrates how to change the current memory pointer explicitly in Solidity.
     * Takes a single parameter, `foo`, which is a fixed-size array of `uint256` values.
     * Sets the memory pointer to `0x80` and then creates a new `uint256[1]` array with a value of `6`.
     * Returns the value at index 0 of `foo`.
     */
    function breakFreeMemoryPointer(uint256[1] memory foo)
        external
        view
        returns (uint256)
    {
        assembly {
            // set the current memory pointer to 0x80 explicitly
            mstore(0x40, 0x80)
        }
        uint256[1] memory bar = [uint256(6)];
        return foo[0];
    }

    /**
     * @dev Demonstrates how to create an unpacked dynamic array in Solidity.
     * Creates a new dynamic array of `uint8` values and assigns it to the `bar` variable.
     */
    uint8[] foo = [1, 2, 3, 4, 5, 6];

    function unpacked() external {
        // packed dynamic array in storage when loaded in memory is unpacked (i.e: each element is stored in a separate slot of 32 bytes regardless of the type of the array)
        uint8[] memory bar = foo; 
    }
}