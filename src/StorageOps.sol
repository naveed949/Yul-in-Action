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
        // dynamicArray.push(1);
        // dynamicArray.push(2);
        // dynamicArray.push(3);
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
            slot := sload(dynamicArray.slot)
        }
        // bytes32 location = keccak256(abi.encode(slot));

        assembly {
            
            // load length of _dynamicArray into memory
            let length := mload(_dynamicArray)
            // store length of _dynamicArray in dynamicArray's location (hash of slot)
            sstore(slot, length)
            // loop through _dynamicArray
            for {
                let i := 0
            } lt(i, length) {
                // increment i by 1
                i := add(i, 1)
            } {
                // store _dynamicArray[i] in dynamicArray[i]
                sstore(add(add(slot, 0x20), mul(i, 0x20)), mload(add(_dynamicArray, add(0x20, mul(i, 0x20)))))
            }
        }
    }

    function readDynamicArray(uint256 index) public view returns (bytes32 value) {
        uint256 slot;
        assembly {
            // load dynamicArray slot into memory
            slot := sload(dynamicArray.slot)
        }
        // hash of slot and index is the location of dynamicArray[index]
        bytes32 indexLocation = keccak256(abi.encode(slot, index));

        assembly {
            // load length of dynamicArray into memory
            //  value := sload(indexLocation)
            
            // load dynamicArray[index] into memory
            // value := sload(add(add(slot, 0x20), mul(index, 0x20)))
            value := sload(dynamicArray.slot)
        }
    }

}