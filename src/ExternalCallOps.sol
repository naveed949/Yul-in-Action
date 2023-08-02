// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title OtherContract
 * @dev Contains various functions that can be called externally from another contract.
 */
contract OtherContract {
    /**
     * @dev A public variable that can be read from another contract.
     */
    uint256 public x;

    /**
     * @dev A public array that can be set from another contract.
     */
    uint256[] public arr;

    /**
     * @dev Returns the value 21.
     * Demonstrates how to call an external pure function from another contract.
     */
    function get21() external pure returns (uint256) {
        return 21;
    }

    /**
     * @dev Reverts with the value 999.
     * Demonstrates how to call an external pure function that reverts from another contract.
     */
    function revertWith999() external pure returns (uint256) {
        assembly {
            mstore(0x00, 999)
            revert(0x00, 0x20)
        }
    }

    /**
     * @dev Sets the value of `x` to `_x`.
     * Demonstrates how to call an external function that changes state from another contract.
     */
    function setX(uint256 _x) external {
        x = _x;
    }

    /**
     * @dev Multiplies `_x` by `_y` and returns the result.
     * Demonstrates how to call an external pure function with multiple arguments from another contract.
     */
    function multiply(uint128 _x, uint16 _y) external pure returns (uint256) {
        return _x * _y;
    }

    /**
     * @dev Sets the value of `arr` to `data`.
     * Demonstrates how to call an external function with a variable-length array argument from another contract.
     */
    function variableLength(uint256[] calldata data) external {
        arr = data;
    }

    /**
     * @dev Returns a `bytes` array of length `len` filled with the value 0xab.
     * Demonstrates how to call an external pure function that returns a variable-length array from another contract.
     */
    function variableReturnLength(uint256 len) external pure returns (bytes memory) {
        bytes memory ret = new bytes(len);
        for (uint256 i = 0; i < ret.length; i++) {
            ret[i] = 0xab;
        }
        return ret;
    }

    /**
     * @dev Compares two variable-length arrays `data1` and `data2` and returns `true` if they are equal.
     * Demonstrates how to call an external function with multiple variable-length array arguments from another contract.
     */
    function multipleVariableLength(uint256[] calldata data1, uint256[] calldata data2) external pure returns (bool) {
        require(data1.length == data2.length, "invalid");

        for (uint256 i = 0; i < data1.length; i++) {
            if (data1[i] != data2[i]) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Compares two variable-length arrays `data1` and `data2` up to a maximum length of `max` and returns `true` if they are equal.
     * Demonstrates how to call an external function with multiple variable-length array arguments and a maximum length from another contract.
     */
    function multipleVariableLength2(uint256 max, uint256[] calldata data1, uint256[] calldata data2) external pure returns (bool) {
        require(data1.length < max, "data1 too long");
        require(data2.length < max, "data2 too long");

        for (uint256 i = 0; i < max; i++) {
            if (data1[i] != data2[i]) {
                return false;
            }
        }
        return true;
    }
}

/**
 * @title ExternalCalls
 * @dev Contains various functions that demonstrate how to call external functions from another contract.
 */
contract ExternalCalls {
    /**
     * @dev Calls the `get21()` function of `OtherContract` and returns the result.
     * Demonstrates how to call an external pure function with no arguments from another contract.
     */
    function externalViewCallNoArgs(address _a) external view returns (uint256) {
        assembly {
            mstore(0x00, 0x9a884bde)
            let success := staticcall(gas(), _a, 28, 32, 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            return(0x00, 0x20)
        }
    }

    /**
     * @dev Calls the `revertWith999()` function of `OtherContract` and returns the result.
     * Demonstrates how to call an external pure function that reverts from another contract.
     */
    function getViaRevert(address _a) external view returns (uint256) {
        assembly {
            mstore(0x00, 0x73712595)
            pop(staticcall(gas(), _a, 28, 32, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    /**
     * @dev Calls the `multiply()` function of `OtherContract` and returns the result.
     * Demonstrates how to call an external pure function with multiple arguments from another contract.
     */
    function callMultiply(address _a) external view returns (uint256 result) {
        assembly {
            let mptr := mload(0x40)
            let oldMptr := mptr
            mstore(mptr, 0x196e6d84)
            mstore(add(mptr, 0x20), 3)
            mstore(add(mptr, 0x40), 11)
            mstore(0x40, add(mptr, 0x60))
            let success := staticcall(
                gas(),
                _a,
                add(oldMptr, 28),
                mload(0x40),
                0x00,
                0x20
            )
            if iszero(success) {
                revert(0, 0)
            }

            result := mload(0x00)
        }
    }

    /**
     * @dev Calls the `setX()` function of `OtherContract`.
     * Demonstrates how to call an external function that changes state from another contract.
     */
    function externalStateChangingCall(address _a) external {
        assembly {
            mstore(0x00, 0x4018d9aa)
            mstore(0x20, 999)
            let success := call(
                gas(),
                _a,
                callvalue(),
                28,
                add(28, 32),
                0x00,
                0x00
            )
            if iszero(success) {
                revert(0, 0)
            }
        }
    }

    /**
     * @dev Calls the `variableReturnLength()` function of `OtherContract` and returns the result.
     * Demonstrates how to call an external pure function that returns a variable-length array from another contract.
     */
    function unknownReturnSize(address _a, uint256 amount) external view returns (bytes memory) {
        assembly {
            mstore(0x00, 0x7c70b4db)
            mstore(0x20, amount)

            let success := staticcall(gas(), _a, 28, add(28, 32), 0x00, 0x00)
            if iszero(success) {
                revert(0, 0)
            }

            returndatacopy(0, 0, returndatasize())
            return(0, returndatasize())
        }
    }
}