// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title StorageOps
 * @dev This contract is used for testing the storage operations in Yul.
 * @notice This contract provides functions to read and write to various storage variables such as fixed and dynamic arrays, mappings, and structs.
 * @dev Key concepts of storage layout exhibited in this contract are:
 * - Length of fixed or dynamic array is stored in the slot of the array. i.e. `array.slot`
 * - The values of fixed array are stored at `add(array.slot, index)`
 * - The values of dynamic array are stored at different location. (due to dynamic nature of array and to avoid possibilited of overwriting the values of other storage variables came after this dynamic array)
 *  - The location of dynamic array's values storage is calculated by `keccak256(abi.encode(array.slot))`
 * - The values of dynamic array are stored at `add(location, index) = value`
 * - The values of mapping are stored at `keccak256(abi.encode(key, slot)) = value`
 * - The values of nested mapping are stored at hash of hash i.e: `keccak256(abi.encode(innerKey, keccak256(abi.encode(key, slot)))) = value`
 * - The values of struct are stored at `add(location, index) = value`
 */
contract StorageOps {
    uint256 public num = 11; // public variable to store a uint256 value
    uint256[3] public fixedArray; // public fixed array to store 3 uint256 values
    uint256[] public dynamicArray; // public dynamic array to store an arbitrary number of uint256 values
    mapping(address => uint256) normalMap; // public mapping to store uint values for each address
    mapping(address => mapping(uint256 => uint64)) public nestedMap; // public mapping to store uint64 values for each address and uint256 key
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
        nestedMap[address(2)][1] = 2; // set the value of nestedMap[address(2)][1] to 2
        nestedMap[address(3)][2] = 3; // set the value of nestedMap[address(3)][2] to 3
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
    function readDynamicArray(
        uint256 index
    ) public view returns (uint256 value) {
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

    /**
     * @dev Function to write the value of _normalMap at a given key to normalMap in storage.
     * @param key The key of the value to write to normalMap.
     * @param value The value to write to normalMap.
     */
    function writeNormalMap(address key, uint256 value) public {
        uint256 slot;
        assembly {
            // fetch the slot of normalMap
            slot := normalMap.slot
        }
        // hash the slot and key to get the location of normalMap[key] in storage
        bytes32 location = keccak256(abi.encode(key, slot));
        assembly {
            // store value in normalMap[key]
            sstore(location, value)
        }
    }

    /**
     * @dev Function to read the value of normalMap at a given key from storage.
     * @param key The key of the value to read from normalMap.
     * @return value The value of normalMap at the given key.
     */
    function readNormalMap(address key) public view returns (uint256 value) {
        uint256 slot;
        assembly {
            // fetch the slot of normalMap
            slot := normalMap.slot
        }
        // hash the slot and key to get the location of normalMap[key] in storage
        bytes32 location = keccak256(abi.encode(key, slot));
        assembly {
            // load value of normalMap[key] into memory
            value := sload(location)
        }
    }

    /**
     * @dev Function to write the value of nestedMap at a given key and index to nestedMap in storage.
     * @param key The key of the value to write to nestedMap.
     * @param innerKey The inner key of the value to write to nestedMap.
     * @param value The value to write to nestedMap.
     */
    function writeNestedMap(
        address key,
        uint256 innerKey,
        uint256 value
    ) public {
        uint256 slot;
        assembly {
            // fetch the slot of nestedMap
            slot := nestedMap.slot
        }
        // hash the slot and key to get outerHash then hash it with innerKey to get the location of nestedMap[key][innerKey] in storage
        bytes32 location = keccak256(
            abi.encode(innerKey, keccak256(abi.encode(key, slot)))
        );
        assembly {
            // store value in nestedMap[key][innerKey]
            sstore(location, value)
        }
    }

    /**
     * @dev Function to read the value of nestedMap at a given key and index from storage.
     * @param key The key of the value to read from nestedMap.
     * @param innerKey The inner key of the value to read from nestedMap.
     * @return value The value of nestedMap at the given key and index.
     */
    function readNestedMap(
        address key,
        uint256 innerKey
    ) public view returns (uint256 value) {
        uint256 slot;
        assembly {
            // fetch the slot of nestedMap
            slot := nestedMap.slot
        }
        // hash the slot and key to get outerHash then hash it with innerKey to get the location of nestedMap[key][innerKey] in storage
        bytes32 location = keccak256(
            abi.encode(innerKey, keccak256(abi.encode(key, slot)))
        );
        assembly {
            // load value of nestedMap[key][innerKey] into memory
            value := sload(location)
        }
    }

    /**
     * @dev Function to read the value of structMap at a given key from storage.
     * @param key The key of the value to read from structMap.
     * @return value The Data struct of structMap at the given key.
     */
    function readStructMap(
        uint256 key
    ) public view returns (Data memory value) {
        uint256 slot;
        assembly {
            // fetch the slot of structMap
            slot := structMap.slot
        }
        // hash the slot and key to get the location of structMap[key] in storage
        bytes32 location = keccak256(abi.encode(key, slot));
        uint256 a;
        uint256 b;
        uint256 c;
        assembly {
            // load value of structMap[key].a into memory
            a := sload(location)
            // load value of structMap[key].b into memory
            b := sload(add(location, 1))
            // load value of structMap[key].c into memory
            c := sload(add(location, 2))
        }
        value = Data(a, b, c);
    }

    /**
     * @dev Function to write the value of structMap at a given key to structMap in storage.
     * @param key The key of the value to write to structMap.
     * @param data The Data struct to write to structMap.
     */
    function writeStructMap(
        uint256 key,
        Data memory data
    ) public {
        uint256 slot;
        assembly {
            // fetch the slot of structMap
            slot := structMap.slot
        }
        // hash the slot and key to get the location of structMap[key] in storage
        bytes32 location = keccak256(abi.encode(key, slot));
        assembly {
            // store value of structMap[key].a
            sstore(location, mload(data))
            /**
             * @note
             * in storage data is stored in key-value pair, so we need to add 1 to location to store value of structMap[key].b
             * memory is heap of bytes so to access next data we need to provide the offset of data (not location - i.e: key)
             */
            // store value of structMap[key].b
            sstore(add(location, 1), mload(add(data,0x20))) 

            // store value of structMap[key].c
            sstore(add(location, 2), mload(add(data,0x40)))
        }
    }
}

// Path: src/StorageOps.sol
