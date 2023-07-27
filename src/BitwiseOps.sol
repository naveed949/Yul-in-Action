// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract BitwiseOps {
    uint256 public num;
    // variables packed into a single slot. slot == 256 bits
    uint64 public a;
    uint128 public b;
    uint64 public c;

    function setNum(uint256 _num) public {
        assembly {
            // storing _num to slot 0 in storage.
            sstore(0x00, _num)
        }
    }

    function getNum() public view returns (uint256 _num) {
        assembly {
            _num := sload(num.slot) // slot 0
        }
    }

    function setA(uint64 _a) public {
        assembly {
            let slot := mload(a.slot) // slot 1
            let value := and(slot, 0xffffffffffffffffffffffffffffffff0000000000000000) // removing last 64 bits (a's previous value)
            value := or(value, _a) // adding _a to last 64 bits
            // storing value to slot 1 in storage.
            sstore(a.slot, value) // slot 1
        }
    }

    function setB(uint128 _b) public {
        assembly {
            let slot := sload(a.slot) // slot 1
            // removing middle 128 bits (b's previous value)
            let value := and(slot, 0xffffffffffffffff00000000000000000000000000000000ffffffffffffffff)
            // adding _b to middle 128 bits
            _b := shl(64, _b)
            // adding _b to previous b value in slot 1
            value := or(value, _b)
            // storing updated value to slot 1 in storage.
            sstore(a.slot, value) 
        }
    }

    function setC(uint64 _c) public {
        assembly {
            let slot := sload(a.slot) // slot 1
            // removing first 64 bits (c's previous value)
            let value := and(slot, 0x0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff)
            // adding _c to first 64 bits
            value := or(value,shl(192, _c))
            // updating slot 1 in storage.
            sstore(a.slot, value)
        }
    }

    function getA() public view returns (uint256 _a) {
        assembly {
            let slot := sload(a.slot) // slot 1
            // fetching last 64 bits
            // _a := and(slot, 0x000000000000000000000000000000000000000000000000ffffffffffffffff)
            // option 2
            _a := shr(192, shl(192,slot))
        }
    }

    function getB() public view returns (uint256 _b) {
        assembly {
            let slot := sload(a.slot) // slot 1
            // fetching middle 128 bits
            // _b := shr(64, and(slot, 0x0000000000000000ffffffffffffffffffffffffffffffff0000000000000000))
            // option 2
            _b := shr(128, shl(64,slot))

        }
    }

    function getC() public view returns (uint256 _c) {
        assembly {
            let slot := sload(a.slot) // slot 1
            // fetching first 64 bits
            // _c := shr(192, and(slot, 0xffffffffffffffff000000000000000000000000000000000000000000000000))
            // optimized version
            _c := shr(192, slot)
        }
    }
}
