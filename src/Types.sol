// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/**
 * @title YulTypes
 * @dev This contract demonstrates the Types of Yul assembly language in Solidity.
 * @notice This contract is for demonstration purposes only.
 * @dev In fact in this contract, it is demostrated that
 ****** Yul assembly language has only bytes32 type.
 ****** It is solidity that casts bytes32 to other types as shown in this contract.  
 */
contract Types {
    /**
     * @dev Returns the value 42 as a uint256 using Yul assembly.
     * @return The value 42 as a uint256.
     */
    function getNumber() external pure returns (uint256) {
        uint256 x;

        assembly {
            x := 42
        }

        return x;
    }

    /**
     * @dev Returns the value 0xa as a uint256 using Yul assembly.
     * @return The value 0xa as a uint256.
     */
    function getHex() external pure returns (uint256) {
        uint256 x;

        assembly {
            x := 0xa
        }

        return x; // 10
    }

    /**
     * @dev Returns the string "lorem ipsum dolor set amet..." as a string using Yul assembly.
     * @return The string "lorem ipsum dolor set amet..." as a string.
     */
    function demoString() external pure returns (string memory) {
        bytes32 myString = "";

        assembly {
            myString := "lorem ipsum dolor set amet..." // string > bytes32 given compiler error, because Yul assembly language has only bytes32 type.
        }

        return string(abi.encode(myString));  // cast bytes32 to string explicitly
    }

    /**
     * @dev Returns the value 1 as an address using Yul assembly.
     * @return The value 1 as an address.
     */
    function representation() external pure returns (address) {
        address x;

        assembly {
            x := 1
        }

        return x; // implicitly casted from bytes32 to address
    }
}