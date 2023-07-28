// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract StorageOps {
    uint256 public num = 11;
    uint256[3] public fixedArray;
    uint256[] public dynamicArray;
    mapping (address => uint) normalMap;
    mapping (address => mapping (uint256 => uint64)) public complexMap;
    mapping(uint256 => Data) public structMap;

    struct Data {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    constructor() {
        fixedArray[0] = 1;
        fixedArray[1] = 2;
        fixedArray[2] = 3;
        dynamicArray = [10, 20, 30];
        normalMap[address(1)] = 1;
        complexMap[address(2)][1] = 2;
        complexMap[address(3)][2] = 3;
        structMap[1] = Data(1, 2, 3);
    }
    
    function readNum() public view returns (uint256 value) {
        assembly {
            // load num into memory
             value := sload(num.slot)
        }
    }

    function readFixedArray(uint256 index) public view returns (uint256 value) {
        // uint256 slot;
        assembly {
            // load fixedArray slot into memory
            value := sload(add(fixedArray.slot, index))
        }
        // bytes32 location = keccak256(abi.encode(slot, index));

        // assembly {
    
        //     // load fixedArray[index] into memory
        //     value := sload(location)
        // }
    }

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
        emit Info("memory length", length);
        assembly {
            // store length value of _dynamicArray in dynamicArray's slot
            // sstore(slot, length)
            // loop through _dynamicArray
            for {
                let i := 0
            } lt(i, length) {
                // increment i by 1
                i := add(i, 1)
            } {
                // store _dynamicArray[i] in dynamicArray[i]
                sstore(
                    add(location, mul(i, 0x20)),
                     mload(add(_dynamicArray, add(0x20, mul(i, 0x20))))
                     )
            }
        }
    }
    
    function read(uint256[] memory values, uint256 index) public pure returns (uint256 value) {
        assembly {
            value := mload(add(values, add(0x20, mul(index, 0x20))))
        }
    }

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
    event Info(string message, uint256 value);

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