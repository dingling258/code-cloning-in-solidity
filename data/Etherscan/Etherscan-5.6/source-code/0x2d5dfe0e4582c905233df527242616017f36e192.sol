// SPDX-License-Identifier: GPL-3.0
/**
 * @title LinkdropEscrow
 * @author Mikhail Dobrokhvalov <mikhail@linkdrop.io>
 * @contact https://www.linkdrop.io
 * @dev This is an implementation of the escrow contract for Linkdrop P2P. Linkdrop P2P allows a new type of token transfers, comparable to a signed blank check with a pre-defined amount. In this system, the sender does not set the destination address. Instead, they deposit tokens into the Escrow Contract, create a claim link, and share it with the recipient. The recipient can then use the claim link to redeem the escrowed tokens from the Escrow Contract. If the claim link is not redeemed before the expiration date set by the sender, the escrowed tokens are transferred back to the sender.
 */


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// Dependency file: openzeppelin-solidity/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

// pragma solidity ^0.8.0;

// import "openzeppelin-solidity/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// Dependency file: openzeppelin-solidity/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
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
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}


// Dependency file: openzeppelin-solidity/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

// pragma solidity ^0.8.0;

// import "openzeppelin-solidity/contracts/utils/math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
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
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// Dependency file: openzeppelin-solidity/contracts/utils/cryptography/ECDSA.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

// pragma solidity ^0.8.0;

// import "openzeppelin-solidity/contracts/utils/Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


// Dependency file: openzeppelin-solidity/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

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
}


// Dependency file: openzeppelin-solidity/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// pragma solidity ^0.8.0;

// import "openzeppelin-solidity/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC1155/IERC1155.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

// pragma solidity ^0.8.0;

// import "openzeppelin-solidity/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


// Dependency file: openzeppelin-solidity/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: contracts/libraries/EIP712.sol

// pragma solidity ^0.8.17;

contract EIP712 {
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    
    // Domain
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }
    EIP712Domain public domain;
    bytes32 public immutable _DOMAIN_SEPARATOR;
    bytes32 public constant _TRANSFER_TYPE_HASH = keccak256(
        "Transfer(address linkKeyId,address transferId)"
    );

    constructor(){
      uint256 chainId;
        assembly {
            chainId := chainid()
        }
        domain = EIP712Domain({
            name: "LinkdropEscrow",
            version: "3",
            chainId: chainId,
            verifyingContract: address(this)
        });
        _DOMAIN_SEPARATOR = keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH,
                                                 keccak256(bytes(domain.name)),
                                                 keccak256(bytes(domain.version)),
                                                 domain.chainId,
                                                 address(this)
                                                 ));
        require(_TRANSFER_TYPE_HASH == keccak256( 
                                                 "Transfer(address linkKeyId,address transferId)"
                                                  ), "EIP712: invalid type hash");
                
    }
    
    function _hashTransfer(
                           address linkKeyId_,
                           address transferId_
    ) internal view returns (bytes32) {
        bytes32 transferHash = keccak256(
            abi.encode(
                _TRANSFER_TYPE_HASH,
                linkKeyId_,
                transferId_
            )
        );

        return keccak256(
            abi.encodePacked("\x19\x01", _DOMAIN_SEPARATOR, transferHash)
        );
    }
}


// Dependency file: contracts/libraries/TransferHelper.sol

// pragma solidity >=0.6.0;

// import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

library TransferHelper {

   /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
                              address token,
                              address from,
                              address to,
                              uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }
    

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
                          address token,
                          address to,
                          uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
                         address token,
                         address to,
                         uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}


// Dependency file: contracts/LinkdropEscrowCommon.sol

// SPADX-License-Identifier: GPL-3.0
// import "openzeppelin-solidity/contracts/access/Ownable.sol";
// import "openzeppelin-solidity/contracts/utils/cryptography/ECDSA.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
// import "openzeppelin-solidity/contracts/token/ERC1155/IERC1155.sol";
// import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
// import "contracts/libraries/EIP712.sol";
// import "contracts/libraries/TransferHelper.sol";

contract LinkdropEscrowCommon is EIP712, Ownable, ReentrancyGuard {
    //// EVENTS ////
    event Deposit(
                  address indexed sender,
                  address indexed token,
                  address transferId,
                  uint120 expiration,
                  uint8 tokenType,                  
                  uint256 tokenId,
                  uint128 amount,
                  address feeToken,
                  uint128 fee
    );

    event Redeem(               
                 address indexed sender,
                 address indexed token,               
                 address indexed receiver,
                 address transferId,
                 uint8 tokenType,                 
                 uint256 tokenId,
                 uint128 amount
    );

    event Cancel(
                 address indexed sender,
                 address indexed token,
                 address transferId,
                 uint8 tokenType,                 
                 uint256 tokenId,
                 uint128 amount
    );

    event Refund(
                 address indexed sender,
                 address indexed token,
                 address transferId,
                 uint8 tokenType,
                 uint256 tokenId,
                 uint128 amount
    );

    event UpdateFees(
                     uint128 claimFee,
                     uint128 depositFee
    );
    
    struct DepositData {
        uint256 tokenId;        
        uint128 amount;                
        uint120 expiration;
        uint8 tokenType; // 0 - native, 1 - ERC20, 2 - ERC721, 3 - ERC1155
    }    
        mapping(address => mapping(address => mapping(address => DepositData))) public deposits; // sender => token => transferId => DepositData
    
    event UpdateRelayer(
                        address relayer,
                        bool active
    );

    event WithdrawFees(
                       address feeReceiver,
                       address token_,
                       uint256 amount
    );      
    mapping(address => uint256) public accruedFees; // token -> accrued fees
    

    mapping(address => bool) public relayers;

    //// MODIFIERS ////

    modifier onlyRelayer {
        require(relayers[msg.sender], "LinkdropEscrow: msg.sender is not relayer.");
        _;
    }


    function getDeposit(
                        address token_,
                        address sender_,
                        address transferId_
    ) public view returns (
                           address token,
                           uint8 tokenType,
                           uint256 tokenId,
                           uint128 amount,
                           uint120 expiration
    ) {
        DepositData memory deposit_ = deposits[sender_][token_][transferId_];
        return (
                token_,
                deposit_.tokenType,
                deposit_.tokenId,
                deposit_.amount,
                deposit_.expiration);
    }

    
    function verifyFeeAuthorization(
                                    address sender_,
                                    address token_,
                                    address transferId_,
                                    uint256 tokenId_,
                                    uint128 amount_,
                                    uint120 expiration_,
                                    address feeToken_,
                                    uint128 feeAmount_,
                                    bytes calldata feeAuthorization_)
        public view returns (bool isValid) {
        bytes32 prefixedHash_ = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(
                                                                                        sender_,
                                                                                        token_,
                                                                                        transferId_,
                                                                                        tokenId_,
                                                                                        amount_,
                                                                                        expiration_,
                                                                                        feeToken_,
                                                                                        feeAmount_)));
        address signer = ECDSA.recover(prefixedHash_, feeAuthorization_);
        return relayers[signer];
    }

    
    function recoverLinkKeyId(
                              address receiver_,
                              bytes calldata receiverSig_) public pure returns (address linkKeyId) {
        bytes32 prefixedHash_ = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(receiver_)));
        return ECDSA.recover(prefixedHash_, receiverSig_);    
    }


    function recoverSender(
                           address linkKeyId_,
                           address transferId_,
                           bytes calldata senderSig_) public view returns (address sender) {
        // senderHash_ - hash that should have been signed by the sender of the transfer
        bytes32 senderHash_ = EIP712._hashTransfer(
                                                   linkKeyId_,
                                                   transferId_
        );
        return ECDSA.recover(senderHash_, senderSig_);
    }

    function _transferTokens(address token_, address to_, uint8 tokenType_, uint256 tokenId_, uint256 amount_) internal {
        require(tokenType_ < 4, "LinkdropEscrow: unknown token type");        
        if (tokenType_ == 0) { // ETH
            require(token_ == address(0), "LinkdropEscrow: address should be 0 for ETH transfers");
            return TransferHelper.safeTransferETH(to_, amount_);
        }

        require(token_ != address(0), "LinkdropEscrow: token address not provided to make transfer");
        if (tokenType_ == 1) { 
            return TransferHelper.safeTransfer(token_, to_, amount_);
        }
        if (tokenType_ == 2) {             
            return IERC721(token_).safeTransferFrom(address(this), to_, tokenId_);            
        }
        if (tokenType_ == 3) {             
            return IERC1155(token_).safeTransferFrom(address(this), to_, tokenId_, amount_, new bytes(0));            
        }                
    }

    function cancel(
                    address token_,
                    address transferId_
    ) public nonReentrant {

        DepositData memory deposit_ = deposits[msg.sender][token_][transferId_];
        uint128 amount_ = deposit_.amount;
        uint8 tokenType_ = deposit_.tokenType;
        uint256 tokenId_ = deposit_.tokenId;

        require(amount_ > 0, "LinkdropEscrow: Deposit not found");
        delete deposits[msg.sender][token_][transferId_];

        _transferTokens(token_, msg.sender, tokenType_, tokenId_, amount_);
        emit Cancel(msg.sender, token_, transferId_, tokenType_, tokenId_, amount_);
    }

        /**
     * @dev redeem via original claim link, where Link Key was generated by the sender on original deposit. In this case transferID is the address corresponding to Link Key. 
     */
    function redeem(
                    address receiver_,
                    address sender_,
                    address token_,
                    bytes calldata receiverSig_
    ) public onlyRelayer {

        address transferId_ = recoverLinkKeyId(receiver_, receiverSig_);
        _redeem(sender_, token_, transferId_, receiver_);
    }

    /**
     * @dev redeem via recovered claim link. If sender lost the original claim link and Link Key, they can generate new claim link that has a new Link Key. In this case, new Link Key ID should be signed by Sender private key and the escrow contract ensures that the new Link Key was authorized by Sender by verifying Sender Signature.
     */  
    function redeemRecovered(
                             address receiver_,
                             address token_,
                             address transferId_,
                             bytes calldata receiverSig_,
                             bytes calldata senderSig_
    ) public onlyRelayer {
      
        address linkKeyId_ = recoverLinkKeyId(receiver_, receiverSig_);
        address sender_ = recoverSender(
                                        linkKeyId_,
                                        transferId_,
                                        senderSig_);
      
        _redeem(sender_, token_, transferId_, receiver_);
    }
  
    function _redeem(address sender_, address token_, address transferId_, address receiver_) private {
        DepositData memory deposit_ = deposits[sender_][token_][transferId_];
        uint128 amount_ = deposit_.amount;
        uint8 tokenType_ = deposit_.tokenType;
        uint256 tokenId_ = deposit_.tokenId;

        require(amount_ > 0, "LinkdropEscrow: invalid redeem params");
        require(block.timestamp < deposit_.expiration, "LinkdropEscrow: transfer expired.");
     
        delete deposits[sender_][token_][transferId_];

        _transferTokens(token_, receiver_, tokenType_, tokenId_, amount_);
        emit Redeem(sender_, token_, receiver_, transferId_, tokenType_, tokenId_, amount_);
    }

    function refund(
                    address sender_,
                    address token_,
                    address transferId_
    ) public onlyRelayer {
        DepositData memory deposit_ = deposits[sender_][token_][transferId_];
        uint128 amount_ = deposit_.amount;
        uint8 tokenType_ = deposit_.tokenType;
        uint256 tokenId_ = deposit_.tokenId;
        require(amount_ > 0, "LinkdropEscrow: invalid transfer ID");
        delete deposits[sender_][token_][transferId_];
    
        _transferTokens(token_, sender_, tokenType_, tokenId_, amount_);
        emit Refund(sender_, token_, transferId_, tokenType_, tokenId_, amount_);
    }


    function _makeDeposit(
                          address sender_,
                          address token_,
                          address transferId_,
                          uint256 tokenId_,
                          uint128 amount_,
                          uint120 expiration_,
                          uint8 tokenType_,
                          address feeToken_,
                          uint128 feeAmount_) internal {
        deposits[sender_][token_][transferId_] = DepositData({
            tokenId: tokenId_,
            amount: amount_,
            expiration: expiration_,
            tokenType: tokenType_
            });

        // accrue fees
        accruedFees[feeToken_] += uint256(feeAmount_);        
        
        emit Deposit(sender_, token_, transferId_, expiration_, tokenType_, tokenId_, amount_, feeToken_, feeAmount_);
    }
    
    //// ONLY OWNER ////  
    function setRelayer(
                        address relayer_,
                        bool active_
    ) public onlyOwner {
        relayers[relayer_] = active_;
        emit UpdateRelayer(relayer_, active_);
    }

    function withdrawAccruedFees(address token_) public onlyOwner {
        uint256 amount_ = accruedFees[token_];
        accruedFees[token_] = 0;
        uint8 tokenType_ = 0;
        if (token_ != address(0)) {
            tokenType_ = 1;
        }
        _transferTokens(token_, msg.sender, tokenType_, 0 /*tokenId*/, amount_);
        emit WithdrawFees(msg.sender, token_, amount_);
    }
}


// Root file: contracts/LinkdropEscrow.sol

/**
 * @title LinkdropEscrowStablecoin
 * @author Mikhail Dobrokhvalov <mikhail@linkdrop.io>
 * @contact https://www.linkdrop.io
 * @dev This is an implementation of the escrow contract for Linkdrop P2P. Linkdrop P2P allows a new type of token transfers, comparable to a signed blank check with a pre-defined amount. In this system, the sender does not set the destination address. Instead, they deposit tokens into the Escrow Contract, create a claim link, and share it with the recipient. The recipient can then use the claim link to redeem the escrowed tokens from the Escrow Contract. If the claim link is not redeemed before the expiration date set by the sender, the escrowed tokens are transferred back to the sender.
 */
pragma solidity ^0.8.17;
// import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
// import "openzeppelin-solidity/contracts/utils/cryptography/ECDSA.sol";

// import "contracts/LinkdropEscrowCommon.sol";
// import "contracts/libraries/TransferHelper.sol";

contract LinkdropEscrow is LinkdropEscrowCommon {
    //// CONSTRUCTOR ////
    constructor(
                address relayer_
    ) EIP712() {
        relayers[relayer_] = true;
    }

    
    //// PUBLIC FUNCTIONS ////

    function deposit(address token_,
                     address transferId_,
                     uint128 amount_,
                     uint120 expiration_,
                     address feeToken_,
                     uint128 feeAmount_,
                     bytes calldata feeAuthorization_
    ) public nonReentrant payable {
        bool feesAuthorized_ = verifyFeeAuthorization(
                                                      msg.sender,
                                                      token_,
                                                      transferId_,
                                                      0, // tokenId is 0 for ERC20
                                                      amount_,
                                                      expiration_,
                                                      feeToken_,
                                                      feeAmount_,
                                                      feeAuthorization_);
        require(feesAuthorized_, "LinkdropEscrow: Fees not authorized.");        
        require(token_ != address(0), "LinkdropEscrow: can't be address(0) as a token.");
        
        TransferHelper.safeTransferFrom(token_, msg.sender, address(this), uint256(amount_));

         // stablecoins have fees in the same token
        if (feeToken_ == token_) {
            return _depositStablecoins(msg.sender, token_, transferId_, amount_, expiration_, feeToken_, uint128(feeAmount_));
        }
        
        // all other ERC20 tokens have fees in native tokens
        return _depositERC20(msg.sender, token_, transferId_, amount_, expiration_, feeToken_, uint128(feeAmount_));               
    }
    
    
    /**
     * @dev deposit is used to perform direct deposits. In this case depositFee is 0
     */
    function depositETH(
                     address transferId_,
                     uint128 amount_,
                     uint120 expiration_,
                     uint128 feeAmount_,
                     bytes calldata feeAuthorization_
    ) public nonReentrant payable {
        bool feesAuthorized_ = verifyFeeAuthorization(
                                                      msg.sender,
                                                      address(0), // token is 0x000..000 for ETH
                                                      transferId_,
                                                      0, // tokenId is 0 for ETH transfers
                                                      amount_,
                                                      expiration_,
                                                      address(0), // fee token is 0x000..000 for ETH
                                                      feeAmount_,
                                                      feeAuthorization_);
        require(feesAuthorized_, "Fees not authorized.");        
        require(deposits[msg.sender][address(0)][transferId_].amount == 0, "LinkdropEscrow: transferId is in use.");
        require(expiration_ > block.timestamp, "LinkdropEscrow: depositing with invalid expiration.");
        require(msg.value == amount_, "LinkdropEscrow: amount not covered.");       
        require(amount_ > feeAmount_, "LinkdropEscrow: amount does not cover fee.");
        
        amount_ = uint128(amount_ - feeAmount_);
    
        _makeDeposit(
                     msg.sender,
                     address(0), // token is 0x000..000 for ETH
                     transferId_,
                     0, // token id is 0 for ETH
                     amount_,
                     expiration_,
                     0, // tokentype is 0 for ETH
                     address(0), // token is 0x000..000 for ETH
                     feeAmount_); 
    }

  
    //// ONLY RELAYER ////
    function depositWithAuthorization(
                                      address token_,
                                      address transferId_,
                                      uint120 expiration_,
                                      bytes4 authorizationSelector_,                                                                 
                                      uint128 fee_,
                                      bytes calldata receiveAuthorization_
    ) public onlyRelayer {

        // native USDC supports receiveWithAuthorization and bridged USDC.e supports approveWithAuthorization instead. Selector should be one of the following depending on the token contract:
        // 0xe1560fd3 - approveWithAuthorization selector
        // 0xef55bec6 - recieveWithAuthorization selector
        require(authorizationSelector_ == 0xe1560fd3 || authorizationSelector_ == 0xef55bec6, "LinkdropEscrow: invalid selector");    
      
        address from_;
        address to_;
        uint256 amount_;

        {
            // Retrieving deposit information from receiveAuthorization_
            uint256 validAfter_;
            uint256 validBefore_;
            bytes32 nonce;
    
            (from_,
             to_,
             amount_,
             validAfter_,
             validBefore_,       
             nonce) = abi.decode(
                                 receiveAuthorization_[0:192], (
                                                                address,
                                                                address,
                                                                uint256,
                                                                uint256,
                                                                uint256,
                                                                bytes32
                                 ));

            require(to_ == address(this), "LinkdropEscrow: receiveAuthorization_ decode fail. Recipient is not this contract.");
            require(keccak256(abi.encodePacked(from_, transferId_, amount_, expiration_, fee_)) == nonce, "LinkdropEscrow: receiveAuthorization_ decode fail. Invalid nonce.");

            (bool success, ) = token_.call(
                                           abi.encodePacked(
                                                            authorizationSelector_,
                                                            receiveAuthorization_
                                           )
            );
            require(success, "LinkdropEscrow: approve failed.");
        }

        // if approveWithAuthorization (for bridged USDC.e)
        // transfer tokens from sender to the escrow contract
        if (authorizationSelector_ == 0xe1560fd3) { 
            TransferHelper.safeTransferFrom(token_, from_, address(this), uint256(amount_));
        } // if receiveWithAuthorization (for native USDC) nothing is needed to be done
    
        _depositStablecoins(from_, token_, transferId_, uint128(amount_), expiration_, token_, fee_);
    }

    
    //// INTERNAL FUNCTIONS ////
  
    function _depositStablecoins(
                                 address sender_,
                                 address token_,
                                 address transferId_,
                                 uint128 amount_,
                                 uint120 expiration_,
                                 address feeToken_,
                                 uint128 feeAmount_
    ) private {
        require(deposits[sender_][token_][transferId_].amount == 0, "LinkdropEscrow: transferId is in use.");
        require(expiration_ > block.timestamp, "LinkdropEscrow: depositing with invalid expiration.");
        require(feeToken_ == token_, "LinkdropEscrow: Fees for transfers in stablecoins should be paid in the stablecoin token.");
        require(token_ != address(0), "LinkdropEscrow: token should not be address(0)");
        require(amount_ > feeAmount_, "LinkdropEscrow: amount does not cover fee.");
        require(msg.value == 0, "LinkdropEscrow: fees should be paid in token not ether");
    
        amount_ = uint128(amount_ - feeAmount_);    
        _makeDeposit(
                     sender_,
                     token_,
                     transferId_,
                     0, // tokenId is 0 for ERC20
                     amount_,
                     expiration_,
                     1, // tokenType is 1 for ERC20
                     feeToken_,
                     feeAmount_);
    }

    function _depositERC20(
                           address sender_,
                           address token_,
                           address transferId_,
                           uint128 amount_,
                           uint120 expiration_,
                           address feeToken_,
                           uint128 feeAmount_
    ) private {
        require(deposits[sender_][token_][transferId_].amount == 0, "LinkdropEscrow: transferId is in use.");
        require(expiration_ > block.timestamp, "LinkdropEscrow: depositing with invalid expiration.");
        require(feeToken_ == address(0), "LinkdropEscrow: fees for ERC20 tokens can be paid in native tokens only.");
        require(token_ != address(0), "LinkdropEscrow: token should not be address(0)");    
        require(msg.value == feeAmount_, "LinkdropEscrow: fee not covered.");
    
        _makeDeposit(
                     sender_,
                     token_,
                     transferId_,
                     0, // tokenId is 0 for ERC20
                     amount_,
                     expiration_,
                     1, //tokenType, 1 - for ERC20
                     feeToken_,
                     feeAmount_);
    } 
}