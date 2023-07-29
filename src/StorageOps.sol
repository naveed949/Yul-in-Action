// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title StorageOps
 * @dev This contract is used for testing the storage operations in Yul.
 * @notice This contract provides functions to read and write to various storage variables such as fixed and dynamic arrays, mappings, and structs.
 */
contract StorageOps {
    uint256 public num = 11; // public variable to store a uint256 value
    uint256[3] public fixedArray; // public fixed array to store 3 uint256 values
    uint256[] public dynamicArray; // public dynamic array to store an arbitrary number of uint256 values
    mapping (address => uint) normalMap; // public mapping to store uint values for each address
    mapping (address => mapping (uint256 => uint64)) public complexMap; // public mapping to store uint64 values for each address and uint256 key
    mapping(uint256 => Data) public structMap; // public mapping to store Data struct values for each uint256 key

    /**
     * @dev Data struct to store 3 uint256 values
     */
    struct Data {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    /**
     * @dev Constructor function to initialize the storage variables with some default values.
     */
    constructor() {
        fixedArray[0] = 1; // set the first value of fixedArray to 1
        fixedArray[1] = 2; // set the second value of fixedArray to 2
        fixedArray[2] = 3; // set the third value of fixedArray to 3
        dynamicArray = [10, 20, 30]; // set the values of dynamicArray to [10, 20, 30]
        normalMap[address(1)] = 1; // set the value of normalMap[address(1)] to 1
        complexMap[address(2)][1] = 2; // set the value of complexMap[address(2)][1] to 2
        complexMap[address(3)][2] = 3; // set the value of complexMap[address(3)][2] to 3
        structMap[1] = Data(1, 2, 3); // set the value of structMap[1] to Data(1, 2, 3)
    }
    
    /**
     * @dev Function to read the value of num from storage.
     * @return value The value of num.
     */
    function readNum() public view returns (uint256 value) {
        assembly {
            // load num into memory
             value := sload(num.slot)
        }
    }

    /**
     * @dev Function to read the value of fixedArray at a given index from storage.
     * @param index The index of the value to read from fixedArray.
     * @return value The value of fixedArray at the given index.
     */
    function readFixedArray(uint256 index) public view returns (uint256 value) {
        // uint256 slot;
        assembly {
            // load fixedArray slot into memory
            value := sload(add(fixedArray.slot, index))
        }
    }

    /**
     * @dev Function to write the values of _dynamicArray to dynamicArray in storage.
     * @param _dynamicArray The array of uint256 values to write to dynamicArray.
     */
    function writeDynamicArray(uint256[] memory _dynamicArray) public {
        uint256 slot;
        assembly {
            // load dynamicArray slot into memory
            slot := dynamicArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));
        uint256 length;

        assembly {
            // load length of _dynamicArray into memory
             length := mload(_dynamicArray)
        }
        assembly {
            // store length value of _dynamicArray in dynamicArray's slot
            sstore(slot, length)
            // loop through _dynamicArray
            for {
                let i := 0
            } lt(i, length) {
                // increment i by 1
                i := add(i, 1)
            } {
                // store _dynamicArray[i] in dynamicArray[i]
                sstore(
                    add(location, i),
                    mload(add(_dynamicArray, add(0x20, mul(i, 0x20)))) // load _dynamicArray[i] into memory, padded with 0x20 bytes (32 bytes) to avoid overwriting length of _dynamicArray (which is stored at 0x00 position of _dynamicArray memory)
                    )
            }
        }
    }

    /**
     * @dev Function to read the value of dynamicArray at a given index from storage.
     * @param index The index of the value to read from dynamicArray.
     * @return value The value of dynamicArray at the given index.
     */
    function readDynamicArray(uint256 index) public view returns (uint256 value) {
        uint256 slot;
        assembly {
            // set dynamicArray slot into memory variable
            slot := dynamicArray.slot
        }
        // hash of slot is the location of storage slot where dynamicArray values stored in sequesnce as per their indexes
        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            // load value of dynamicArray[index] into memory
             value := sload(add(location, index))
        }
    }

}

// Path: src/StorageOps.sol
/**
 * @dev This contract is used for testing the storage operations in Yul.
 * @note
 * - Length of fixed or dynamic array is stored in the slot of the array. i.e. `array.slot`
 * - The values of fixed array are stored at `add(array.slot, index)`
 * - The values of dynamic array are stored at different location. (due to dynamic nature of array and to avoid possibilited of overwriting the values of other storage variables came after this dynamic array)
 *  - The location of dynamic array's values storage is calculated by `keccak256(abi.encode(array.slot))`
 * - The values of dynamic array are stored at `add(location, index) = value`
 */