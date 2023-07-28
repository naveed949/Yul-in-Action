// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract StorageOps {
    uint256 public num = 11;
    uint256[] public fixedArray = [1, 2, 3, 4, 5];
    uint256[] public dynamicArray;
    mapping (address => uint) normalMap;
    mapping (address => mapping (uint256 => uint64)) public complexMap;
    mapping(uint256 => Data) public structMap;

    struct Data {
        uint256 a;
        uint256 b;
        uint256 c;
    }
    
    function readNum() public view returns (uint256) {
        assembly {
            // load num into memory
            let ptr := sload(num.slot)
            // return num
            return(0, ptr)
        }
    }

    function readFixedArray(uint8 index) public view returns (uint256 value) {
        assembly {
            // load fixedArray at index into memory
            value := sload(add(fixedArray.slot, index))
        }
    }

    function writeDynamicArray(uint256[] memory _dynamicArray) public {
        assembly {
            // load length of _dynamicArray into memory
            let length := mload(_dynamicArray)
            let dLocation := keccak256(abi.encode(dynamicArray.slot))
            // store length of _dynamicArray in dynamicArray slot
            sstore(dynamicArray.slot, length)
            // loop through _dynamicArray
            for {
                let i := 0
            } lt(i, length) {
                // increment i by 1
                i := add(i, 1)
            } {
                // store _dynamicArray[i] in dynamicArray[i]
                sstore(abi.encode())
            }
        }
    }

}