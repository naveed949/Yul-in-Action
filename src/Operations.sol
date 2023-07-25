// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title Operations
 * @dev This contract contains functions for performing various mathematical operations in Yul.
 */
contract Operations {
    /**
     * @dev Determines whether a given number is prime.
     * @param num The number to check.
     * @return ret True if the number is prime, false otherwise.
     */
    function isPrime(uint256 num) public pure returns (bool ret) {
        uint256 half;

        assembly {
            // check if even return false
            if eq(mod(num, 2), 0) {
                ret := 0
            }
            // half = num / 2 + 1
            half := add(div(num, 2), 1)
            // if half < 2 return false
            if lt(half, 2) {
                ret := 0
            }
            for {
                let i := 2
            } lt(i, half) { // loop until i < half
                // increment i by 1
                i := add(i, 1)
            } {
                // if num % i == 0 return false
                if eq(mod(num, i), 0) {
                    ret := 0
                }
            }
            // if num is not even and not divisible by any number between 2 and half return true
            ret := 1
        }
    }

    /**
     * @dev Returns the maximum value in an array of uint256 values.
     * @param nums The array of values to search.
     * @return max The maximum value in the array.
     * @notice array slot is 0
     * array length is stored in first 32 bytes
     * array elements start at 32 bytes
     * nums[0] can loaded by mload(add(nums, 0x20))
     * nums[1] can loaded by mload(add(nums, 0x40))
     * nums[2] can loaded by mload(add(nums, 0x60))
     * and so on...
     */
    function maxNum(uint256[] memory nums) public pure returns (uint256 max) {
        assembly {
            // loading nums[0] into max - skipped first 32 bytes (length of array)
            max := mload(add(nums, 0x20))
            // index of 2nd element is 2 * 32 = 0x40
            let i := 2
            let j
            for {

            } lt(i, add(mload(nums), 1)) {
                // loop until i < length of array + 1
                i := add(i, 1)
            } {
                // increment i by 1
                // load nums[i] into j
                j := mload(add(nums, mul(i, 0x20)))
                // if j > max, set max to j
                if gt(j, max) {
                    max := j
                }
            }
        }
    }
}
