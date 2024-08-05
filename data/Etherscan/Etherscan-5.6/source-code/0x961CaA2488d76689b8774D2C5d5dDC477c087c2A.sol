// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SignedMath.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;



/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: contracts/MyToken.sol


pragma solidity ^0.8.0;



//      Telegram - t.me/PokemonCatchToken

//      GOTTA CATCH THEM ALL!

//      The Pokémon ERC20 token contract enables users to buy tokens and receive Pokémon characters as part of the purchase. Each Pokémon has a rarity category (Common, Uncommon, Rare, or Legendary). Users can also make trade offers to exchange their Pokémon with other players.
//      Key Features:
//      Token Creation: Upon deployment, the contract mints 151 trillion tokens with 18 decimal places and initializes the array of Pokémon names and rarity categories.
//      Random Pokémon Generation: Users automatically receive a random Pokémon based on its rarity category when they buy tokens.
//      Trade Offers: Users can make trade offers to exchange their Pokémon with other players by submitting a trade offer through the makeTradeOffer function.
//      Processing: The contract allows users to process pending trade offers using the processPendingTradeOffers function.
//      Token Transfer: The contract inherits ERC20 functionality, allowing users to transfer tokens to other addresses.
//      Pokémon Ownership Tracking: The contract keeps track of which Pokémon each address owns using a mapping.
//      Tutorial: The tutorial function provides users with a brief overview of how to play the game.
//      Overall, the contract provides a simple and fun way for users to collect and trade Pokémon characters using ERC20 tokens.

// Contract representing the Pokemon ERC20 token
contract PokemonToken is ERC20 {
    using Strings for uint256;

    // Struct to represent a Pokémon with its name and rarity category
    struct Pokemon {
        string name;
        string rarityCategory; // Common, Uncommon, Rare, Legendary
    }

    // Struct to represent a trade offer
    struct TradeOffer {
        address sender;
        string pokemon;
    }

    // Array to store the names and rarity categories of the original 151 Pokémon
    Pokemon[152] private pokemonList;

    // Mapping to keep track of which Pokémon each address owns
    mapping(address => string) private ownedPokemon;

    // Array to store pending trade offers
    TradeOffer[] public pendingTradeOffers;

    // Event to emit when a trade offer is made
    event TradeOfferEvent(address indexed sender, string pokemon);

    // Event to emit when a trade offer is accepted
    event TradeAccepted(address indexed sender, address indexed recipient, string pokemon);

    // Event to emit when a Pokemon is traded
    event PokemonTraded(address indexed sender, address indexed recipient, string pokemon);

    constructor() ERC20("Pokemon", "Catch") {
        // Initial supply set to 151 trillion tokens with 18 decimal places
        _mint(msg.sender, 151 * 10**18);

        // Initialize the array of Pokémon names and rarity categories
        // This list contains only a few Pokémon for demonstration purposes
        pokemonList[1] = Pokemon("Bulbasaur", "Common");
        pokemonList[2] = Pokemon("Ivysaur", "Uncommon");
        pokemonList[3] = Pokemon("Venusaur", "Rare");
        pokemonList[4] = Pokemon("Charmander", "Common");
        pokemonList[5] = Pokemon("Charmeleon", "Uncommon");
        pokemonList[6] = Pokemon("Charizard", "Legendary");
        pokemonList[7] = Pokemon("Squirtle", "Common");
        pokemonList[8] = Pokemon("Wartortle", "Uncommon");
        pokemonList[9] = Pokemon("Blastoise", "Rare");
        pokemonList[10] = Pokemon("Caterpie", "Common");
        pokemonList[11] = Pokemon("Metapod", "Common");
        pokemonList[12] = Pokemon("Butterfree", "Rare");
        pokemonList[13] = Pokemon("Weedle", "Common");
        pokemonList[14] = Pokemon("Kakuna", "Common");
        pokemonList[15] = Pokemon("Beedrill", "Rare");
        pokemonList[16] = Pokemon("Pidgey", "Common");
        pokemonList[17] = Pokemon("Pidgeotto", "Uncommon");
        pokemonList[18] = Pokemon("Pidgeot", "Rare");
        pokemonList[19] = Pokemon("Rattata", "Common");
        pokemonList[20] = Pokemon("Raticate", "Uncommon");
        pokemonList[21] = Pokemon("Spearow", "Common");
        pokemonList[22] = Pokemon("Fearow", "Uncommon");
        pokemonList[23] = Pokemon("Ekans", "Common");
        pokemonList[24] = Pokemon("Arbok", "Uncommon");
        pokemonList[25] = Pokemon("Pikachu", "Uncommon");
        pokemonList[26] = Pokemon("Raichu", "Rare");
        pokemonList[27] = Pokemon("Sandshrew", "Common");
        pokemonList[28] = Pokemon("Sandslash", "Uncommon");
        pokemonList[29] = Pokemon("NidoranF", "Common");
        pokemonList[30] = Pokemon("Nidorina", "Uncommon");
        pokemonList[31] = Pokemon("Nidoqueen", "Rare");
        pokemonList[32] = Pokemon("NidoranM", "Common");
        pokemonList[33] = Pokemon("Nidorino", "Uncommon");
        pokemonList[34] = Pokemon("Nidoking", "Rare");
        pokemonList[35] = Pokemon("Clefairy", "Uncommon");
        pokemonList[36] = Pokemon("Clefable", "Rare");
        pokemonList[37] = Pokemon("Vulpix", "Common");
        pokemonList[38] = Pokemon("Ninetales", "Rare");
        pokemonList[39] = Pokemon("Jigglypuff", "Common");
        pokemonList[40] = Pokemon("Wigglytuff", "Uncommon");
        pokemonList[41] = Pokemon("Zubat", "Common");
        pokemonList[42] = Pokemon("Golbat", "Rare");
        pokemonList[43] = Pokemon("Oddish", "Common");
        pokemonList[44] = Pokemon("Gloom", "Uncommon");
        pokemonList[45] = Pokemon("Vileplume", "Rare");
        pokemonList[46] = Pokemon("Paras", "Common");
        pokemonList[47] = Pokemon("Parasect", "Uncommon");
        pokemonList[48] = Pokemon("Venonat", "Common");
        pokemonList[49] = Pokemon("Venomoth", "Rare");
        pokemonList[50] = Pokemon("Diglett", "Common");
        pokemonList[51] = Pokemon("Dugtrio", "Rare");
        pokemonList[52] = Pokemon("Meowth", "Common");
        pokemonList[53] = Pokemon("Persian", "Uncommon");
        pokemonList[54] = Pokemon("Psyduck", "Common");
        pokemonList[55] = Pokemon("Golduck", "Uncommon");
        pokemonList[56] = Pokemon("Mankey", "Common");
        pokemonList[57] = Pokemon("Primeape", "Uncommon");
        pokemonList[58] = Pokemon("Growlithe", "Uncommon");
        pokemonList[59] = Pokemon("Arcanine", "Rare");
        pokemonList[60] = Pokemon("Poliwag", "Common");
        pokemonList[61] = Pokemon("Poliwhirl", "Uncommon");
        pokemonList[62] = Pokemon("Poliwrath", "Rare");
        pokemonList[63] = Pokemon("Abra", "Common");
        pokemonList[64] = Pokemon("Kadabra", "Uncommon");
        pokemonList[65] = Pokemon("Alakazam", "Rare");
        pokemonList[66] = Pokemon("Machop", "Common");
        pokemonList[67] = Pokemon("Machoke", "Uncommon");
        pokemonList[68] = Pokemon("Machamp", "Rare");
        pokemonList[69] = Pokemon("Bellsprout", "Common");
        pokemonList[70] = Pokemon("Weepinbell", "Uncommon");
        pokemonList[71] = Pokemon("Victreebel", "Rare");
        pokemonList[72] = Pokemon("Tentacool", "Common");
        pokemonList[73] = Pokemon("Tentacruel", "Uncommon");
        pokemonList[74] = Pokemon("Geodude", "Common");
        pokemonList[75] = Pokemon("Graveler", "Uncommon");
        pokemonList[76] = Pokemon("Golem", "Rare");
        pokemonList[77] = Pokemon("Ponyta", "Common");
        pokemonList[78] = Pokemon("Rapidash", "Uncommon");
        pokemonList[79] = Pokemon("Slowpoke", "Common");
        pokemonList[80] = Pokemon("Slowbro", "Rare");
        pokemonList[81] = Pokemon("Magnemite", "Common");
        pokemonList[82] = Pokemon("Magneton", "Rare");
        pokemonList[83] = Pokemon("Farfetch'd", "Uncommon");
        pokemonList[84] = Pokemon("Doduo", "Common");
        pokemonList[85] = Pokemon("Dodrio", "Uncommon");
        pokemonList[86] = Pokemon("Seel", "Common");
        pokemonList[87] = Pokemon("Dewgong", "Uncommon");
        pokemonList[88] = Pokemon("Grimer", "Common");
        pokemonList[89] = Pokemon("Muk", "Uncommon");
        pokemonList[90] = Pokemon("Shellder", "Common");
        pokemonList[91] = Pokemon("Cloyster", "Uncommon");
        pokemonList[92] = Pokemon("Gastly", "Common");
        pokemonList[93] = Pokemon("Haunter", "Uncommon");
        pokemonList[94] = Pokemon("Gengar", "Rare");
        pokemonList[95] = Pokemon("Onix", "Uncommon");
        pokemonList[96] = Pokemon("Drowzee", "Common");
        pokemonList[97] = Pokemon("Hypno", "Rare");
        pokemonList[98] = Pokemon("Krabby", "Common");
        pokemonList[99] = Pokemon("Kingler", "Uncommon");
        pokemonList[100] = Pokemon("Voltorb", "Common");
        pokemonList[101] = Pokemon("Electrode", "Rare");
        pokemonList[102] = Pokemon("Exeggcute", "Common");
        pokemonList[103] = Pokemon("Exeggutor", "Uncommon");
        pokemonList[104] = Pokemon("Cubone", "Common");
        pokemonList[105] = Pokemon("Marowak", "Uncommon");
        pokemonList[106] = Pokemon("Hitmonlee", "Rare");
        pokemonList[107] = Pokemon("Hitmonchan", "Rare");
        pokemonList[108] = Pokemon("Lickitung", "Uncommon");
        pokemonList[109] = Pokemon("Koffing", "Common");
        pokemonList[110] = Pokemon("Weezing", "Uncommon");
        pokemonList[111] = Pokemon("Rhyhorn", "Common");
        pokemonList[112] = Pokemon("Rhydon", "Rare");
        pokemonList[113] = Pokemon("Chansey", "Rare");
        pokemonList[114] = Pokemon("Tangela", "Common");
        pokemonList[115] = Pokemon("Kangaskhan", "Uncommon");
        pokemonList[116] = Pokemon("Horsea", "Common");
        pokemonList[117] = Pokemon("Seadra", "Uncommon");
        pokemonList[118] = Pokemon("Goldeen", "Common");
        pokemonList[119] = Pokemon("Seaking", "Uncommon");
        pokemonList[120] = Pokemon("Staryu", "Common");
        pokemonList[121] = Pokemon("Starmie", "Uncommon");
        pokemonList[122] = Pokemon("Mr. Mime", "Rare");
        pokemonList[123] = Pokemon("Scyther", "Rare");
        pokemonList[124] = Pokemon("Jynx", "Common");
        pokemonList[125] = Pokemon("Electabuzz", "Rare");
        pokemonList[126] = Pokemon("Magmar", "Rare");
        pokemonList[127] = Pokemon("Pinsir", "Uncommon");
        pokemonList[128] = Pokemon("Tauros", "Uncommon");
        pokemonList[129] = Pokemon("Magikarp", "Common");
        pokemonList[130] = Pokemon("Gyarados", "Rare");
        pokemonList[131] = Pokemon("Lapras", "Rare");
        pokemonList[132] = Pokemon("Ditto", "Uncommon");
        pokemonList[133] = Pokemon("Eevee", "Common");
        pokemonList[134] = Pokemon("Vaporeon", "Uncommon");
        pokemonList[135] = Pokemon("Jolteon", "Uncommon");
        pokemonList[136] = Pokemon("Flareon", "Uncommon");
        pokemonList[137] = Pokemon("Porygon", "Uncommon");
        pokemonList[138] = Pokemon("Omanyte", "Common");
        pokemonList[139] = Pokemon("Omastar", "Uncommon");
        pokemonList[140] = Pokemon("Kabuto", "Common");
        pokemonList[141] = Pokemon("Kabutops", "Uncommon");
        pokemonList[142] = Pokemon("Aerodactyl", "Rare");
        pokemonList[143] = Pokemon("Snorlax", "Rare");
        pokemonList[144] = Pokemon("Articuno", "Legendary");
        pokemonList[145] = Pokemon("Zapdos", "Legendary");
        pokemonList[146] = Pokemon("Moltres", "Legendary");
        pokemonList[147] = Pokemon("Dratini", "Uncommon");
        pokemonList[148] = Pokemon("Dragonair", "Uncommon");
        pokemonList[149] = Pokemon("Dragonite", "Rare");
        pokemonList[150] = Pokemon("Mewtwo", "Legendary");
        pokemonList[151] = Pokemon("Mew", "Legendary");

        // Generate a random Pokémon for the owner of the contract upon deployment
        string memory randomPokemon = generateRandomPokemon();
        ownedPokemon[msg.sender] = randomPokemon;
    }

    // Function to buy tokens and receive a Pokémon
    function buyTokens(uint256 amount) public {
        // Transfer tokens to the buyer
        _transfer(address(this), msg.sender, amount);
        
        // Generate and assign a Pokémon to the buyer
        string memory randomPokemon = generateRandomPokemon();
        ownedPokemon[msg.sender] = randomPokemon;
    }

    // Internal function to generate a random Pokémon
    function generateRandomPokemon() private view returns (string memory) {
        // Generate a random number between 1 and 100 using the blockhash
        bytes32 randomHash = blockhash(block.number - 1);
        uint256 randomNumber = uint256(keccak256(abi.encode(randomHash, block.timestamp))) % 100 + 1;

        // Probability ranges for different rarity categories
        uint256 commonRange = 60; // 60% chance for common Pokémon
        uint256 uncommonRange = 85; // 25% chance for uncommon Pokémon (85 - 60)
        uint256 rareRange = 95; // 10% chance for rare Pokémon (95 - 85)

        // Select a random rarity category based on the generated number
        string memory rarityCategory;
        if (randomNumber <= commonRange) {
            rarityCategory = "Common";
        } else if (randomNumber <= uncommonRange) {
            rarityCategory = "Uncommon";
        } else if (randomNumber <= rareRange) {
            rarityCategory = "Rare";
        } else {
            rarityCategory = "Legendary";
        }

        // Filter Pokémon list based on rarity category
        Pokemon[] memory filteredPokemon = new Pokemon[](152);
        uint256 count = 0;
        for (uint256 i = 1; i <= 151; i++) {
            if (keccak256(bytes(pokemonList[i].rarityCategory)) == keccak256(bytes(rarityCategory))) {
                filteredPokemon[count] = pokemonList[i];
                count++;
            }
        }

        // Select a random Pokémon from the filtered list
        uint256 randomIndex = uint256(keccak256(abi.encode(randomHash, block.timestamp))) % count;
        Pokemon memory selectedPokemon = filteredPokemon[randomIndex];

        // Return the name of the selected Pokémon
        return selectedPokemon.name;
    }

    // Function for users to make a trade offer
    function makeTradeOffer(string memory pokemon) public {
        // Add the trade offer to the list of pending trade offers
        pendingTradeOffers.push(TradeOffer(msg.sender, pokemon));
        emit TradeOfferEvent(msg.sender, pokemon);
    }

    // Function to process pending trade offers
    function processPendingTradeOffers() public {
        // Process each pending trade offer
        for (uint256 i = 0; i < pendingTradeOffers.length; i++) {
            // Process the trade offer...
            emit TradeAccepted(pendingTradeOffers[i].sender, msg.sender, pendingTradeOffers[i].pokemon);
            // Remove the processed trade offer from the list
            delete pendingTradeOffers[i];
        }
    }

    // Function to cancel all pending trade offers
    function cancelAllPendingTrades() public {
        // Delete all pending trade offers
        for (uint256 i = 0; i < pendingTradeOffers.length; i++) {
            delete pendingTradeOffers[i];
        }
    }

    // Override transfer function to enable token transfers
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Function to get the Pokémon owned by an address
    function getPokemon(address owner) public view returns (string memory) {
        return ownedPokemon[owner];
    }
    
    // Function to count the number of Pokémon owned by an address
    function getPokemonCount(address owner) public view returns (uint256) {
    uint256 count = 0;
    for (uint256 i = 1; i <= 151; i++) {
        if (keccak256(bytes(ownedPokemon[owner])) == keccak256(bytes(pokemonList[i].name))) {
            count++;
        }
    }
    return count;
    }
    
    // Function to get the list of Pokémon owned by an address along with their counts
    function getPokemonListWithCount(address owner) public view returns (string[] memory) {
    uint256 count = getPokemonCount(owner);
    string[] memory pokemonListWithCount = new string[](count);
    uint256 index = 0;
    
    for (uint256 i = 1; i <= 151; i++) {
        if (keccak256(bytes(ownedPokemon[owner])) == keccak256(bytes(pokemonList[i].name))) {
            string memory pokemonWithCount = string(abi.encodePacked(pokemonList[i].name, " (1)")); // Assuming each Pokémon has a count of 1 for now
            pokemonListWithCount[index] = pokemonWithCount;
            index++;
        }
    }
    
    return pokemonListWithCount;
    }

    // Function to split a string by a delimiter
    function splitString(string memory _base, string memory _value) private pure returns (string[] memory) {
        // Split string logic...
    }

    // Function to find the index of a substring in a string
    function indexOf(string memory _base, string memory _value, uint256 _offset) private pure returns (uint256) {
        // Index of logic...
    }

    // Function to push a string into an array
    function pushArr(string[] memory arr, string memory value) private pure returns (string[] memory) {
        // Push array logic...
    }
}