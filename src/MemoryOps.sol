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
    event Debug(
        bytes32 location,
        bytes32 len,
        bytes32 valueAtIndex0,
        bytes32 valueAtIndex1
    );

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
    function breakFreeMemoryPointer(
        uint256[1] memory foo
    ) external view returns (uint256) {
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

    /**
     * @dev Returns the values 2 and 4.
     * Demonstrates how to return multiple values from a Solidity function using assembly.
     * @return The values 2 and 4.
     */
    function return2and4() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            return(0x00, 0x40) // returns bytes from memory at address 0x00 and upto length of 0x40 (64 bytes)
        }
    }

    /**
     * @dev Requires that the caller of the function is a specific address.
     * Demonstrates how to use the `require()` function in Solidity.
     */
    function requireV1() external view {
        require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); // consumes 197 gas
    }

    /**
     * @dev Requires that the caller of the function is a specific address.
     * Demonstrates how to use assembly to implement the same functionality as `requireV1()`.
     */
    function requireV2() external view {
        // consumes 185 gas
        assembly {
            if iszero(
                eq(caller(), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
            ) {
                revert(0, 0) // saves 197 - 185 = 12 gas by reverting with no error message
            }
        }
    }

    /**
     * @dev Computes the keccak256 hash of the values 1, 2, and 3.
     * Demonstrates how to use the `keccak256()` function in Solidity.
     * @return The keccak256 hash of the values 1, 2, and 3.
     */
    function hashV1() external pure returns (bytes32) {
        // consumes 1316 gas
        bytes memory toBeHashed = abi.encode(1, 2, 3);
        return keccak256(toBeHashed);
    }

    /**
     * @dev Computes the keccak256 hash of the values 1, 2, and 3.
     * Demonstrates how to use assembly to implement the same functionality as `hashV1()`.
     * @return The keccak256 hash of the values 1, 2, and 3.
     */
    function hashV2() external pure returns (bytes32) {
        // 342 gas only
        assembly {
            let freeMemoryPointer := mload(0x40)

            // store 1, 2, 3 in memory
            mstore(freeMemoryPointer, 1)
            mstore(add(freeMemoryPointer, 0x20), 2)
            mstore(add(freeMemoryPointer, 0x40), 3)

            // update memory pointer
            mstore(0x40, add(freeMemoryPointer, 0x60)) // increase memory pointer by 96 bytes

            mstore(0x00, keccak256(freeMemoryPointer, 0x60))
            return(0x00, 0x60)
        }
    }

    // LOGS IN YUL
   /**
     * @dev Emits a `SomeLog` event with the values 5 and 6.
     * Demonstrates how to emit an event in Solidity.
     */
    function emitLog() external {
        emit SomeLog(5, 6);
    }

    /**
     * @dev Emits a `SomeLog` event with the values 5 and 6 using Yul assembly.
     * Demonstrates how to emit an event using Yul assembly in Solidity.
     */
    function yulEmitLog() external {
        assembly {
            // event's signature i.e: keccak256("SomeLog(uint256,uint256)")
            let signature := 0xc200138117cf199dd335a2c6079a6e1be01e6592b6a76d4b5fc31b169df819cc
            log3(0, 0, signature, 5, 6)
        }
    }

    /**
     * @dev Emits a `SomeLogV2` event with the values 5 and true.
     * Demonstrates how to emit an event with a boolean value in Solidity.
     */
    function v2EmitLog() external {
        emit SomeLogV2(5, true);
    }

    /**
     * @dev Emits a `SomeLogV2` event with the values 5 and true using Yul assembly.
     * Demonstrates how to emit an event with a boolean value using Yul assembly in Solidity.
     */
    function v2YulEmitLog() external {
        assembly {
            // keccak256("SomeLogV2(uint256,bool)")
            let signature := 0x113cea0e4d6903d772af04edb841b17a164bff0f0d88609aedd1c4ac9b0c15c2
            mstore(0x00, 1)
            log2(0, 0x20, signature, 5)
        }
    }

    /**
     * @dev Self-destructs the contract and sends its balance to the caller.
     * Demonstrates how to self-destruct a contract in Solidity.
     */
    function boom() external {
        assembly {
            selfdestruct(caller())
        }
    }

    /**
     * @dev The `SomeLog` event is emitted when `emitLog()` is called.
     * It has two indexed parameters, `a` and `b`, both of which are of type `uint256`.
     */
    event SomeLog(uint256 indexed a, uint256 indexed b);

    /**
     * @dev The `SomeLogV2` event is emitted when `v2EmitLog()` is called.
     * It has one indexed parameter, `a`, which is of type `uint256`, and one non-indexed parameter, `b`, which is of type `bool`.
     */
    event SomeLogV2(uint256 indexed a, bool b);
}