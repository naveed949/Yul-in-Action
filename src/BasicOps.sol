// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title BasicOps
 * @dev This contract contains functions for performing various mathematical operations in Yul.
 */
contract BasicOps {
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
            } lt(i, half) {
                // loop until i < half
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
     * @return _max The maximum value in the array.
     * @notice array slot is 0
     * array length is stored in first 32 bytes
     * array elements start at 32 bytes
     * nums[0] can loaded by mload(add(nums, 0x20))
     * nums[1] can loaded by mload(add(nums, 0x40))
     * nums[2] can loaded by mload(add(nums, 0x60))
     * and so on...
     */
    function maxNum(uint256[] memory nums) public pure returns (uint256 _max) {
        assembly {
            // loading nums[0] into max - skipped first 32 bytes (length of array)
            _max := mload(add(nums, 0x20))
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
                if gt(j, _max) {
                    _max := j
                }
            }
        }
    }

    // >>>>> HERE ARE SOME BASIC OPERATIONS IN YUL (in the case you're wondering how to perform them) <<<<<
    
    /**
     * @dev Determines whether the value 2 is truthy.
     * @return result if 2 is truthy, 0 otherwise.
     */
    function isTruthy() external pure returns (uint256 result) {
        result = 2;
        assembly {
            if 2 {
                result := 1
            }
        }

        return result; // returns 1
    }

    /**
     * @dev Determines whether the value 0 is falsy.
     * @return result if 0 is falsy, 1 otherwise.
     */
    function isFalsy() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if 0 {
                result := 2
            }
        }

        return result; // returns 1
    }

    /**
     * @dev Performs a logical negation on the value 0.
     * @return result if the negation of 0 is true, 1 otherwise.
     */
    function negation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(0) {
                result := 2
            }
        }

        return result; // returns 2
    }

    /**
     * @dev Performs a logical negation on the value 0 using the `not()` function.
     * @return result if the negation of 0 is true, 1 otherwise.
     */
    function unsafe1NegationPart1() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(0) {
                result := 2
            }
        }

        return result; // returns 2
    }

    /**
     * @dev Performs a bitwise NOT operation on the value 2.
     * @return result The bitwise NOT of 2.
     */
    function bitFlip() external pure returns (bytes32 result) {
        assembly {
            result := not(2)
        }
    }

    /**
     * @dev Performs a logical negation on the value 2 using the `not()` function. [UNSAFE - use `iszero()` instead]
     * @return result if the negation of 2 is true, 1 otherwise.
     */
    function unsafe2NegationPart() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(2) {
                result := 2
            }
        }

        return result; // returns 2
    }

    /**
     * @dev Performs a logical negation on the value 2 using the `iszero()` function.
     * @return result if the negation of 2 is true, 1 otherwise.
     */
    function safeNegation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(2) {
                result := 2
            }
        }

        return result; // returns 1
    }

    /**
     * @dev Returns the maximum of two uint256 values.
     * @param x The first value.
     * @param y The second value.
     * @return result The maximum of x and y.
     */
    function max(uint256 x, uint256 y) external pure returns (uint256 result) {
        assembly {
            if lt(x, y) {
                result := y
            }
            if iszero(lt(x, y)) {
                result := x
            }
        }
    }
}
