// File: contracts/interface/INFTMarketplace.sol


pragma solidity ^0.8.4;

interface INFTMarketplace {
    struct Auction {
        uint256 auctionStart;
        uint256 auctionEnd;
        uint256 minPrice;
        uint256 nftHighestBid;
        uint256 royalty;
        address nftHighestBidder;
        address nftSeller;
        address erc20;
        address royaltyReciever;
    }

    struct FixedSale {
        address nftSeller;
        address nftBuyer;
        address erc20;
        address royaltyReciever;
        uint256 salePrice;
        uint256 royalty;
    }

    struct SaleInfo {
        address _nftContractAddress;
        uint256 _tokenID;
    }

    event NftFixedSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 tokenId,
        uint256 salePrice,
        uint256 timeOfSale
    );

    event CancelNftFixedSale(
        address nftContractAddress,
        address nftSeller,
        uint256 tokenId
    );

    event NftFixedSalePriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 updateSalePrice
    );

    event NftBuyFromFixedSale(
        address nftContractAddress,
        address nftBuyer,
        uint256 tokenId,
        uint256 nftBuyPrice
    );

    event NftAuctionSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 tokenId,
        uint256 auctionStart,
        uint256 auctionEnd,
        uint256 minPrice
    );

    event NftBidPrice(
        address nftContractAddress,
        uint256 tokenId,
        uint256 bidPrice,
        address nftBidder
    );

    event NftAuctionBidPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 finalBidPrice,
        address nftBidder
    );

    event CancelNftAuctionSale(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller
    );

    event NftBuyNowPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 updateBuyNowPrice,
        address nftOwner
    );

    event NftAuctionSettle(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder,
        uint256 nftHighestBid,
        address nftSeller
    );

    event withdrawNftBid(
        address nftContractAddress,
        uint256 tokenId,
        address bidClaimer
    );

    event UpdateOwner(address oldAddress, address newAddress);
}


// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

// File: contracts/library/AmountTransfer.sol


pragma solidity ^0.8.4;

/**
        @notice this  contract contains erc20 token transfer related functions and library.
       
*/
library AmountTransfer {
    function bidAmountTransfer(uint256 _buyAmount, address _erc20, address _to) internal {
        require(
            IERC20(_erc20).transferFrom(_to, address(this), _buyAmount),
            "allowance not enough"
        );
    }

     /**
     * @dev nativeAmountTransfer internal function 
     * This internal function is to check the amount transfered or not 
     * Emits a {Transfer amount} event.
    
     */

    function nativeAmountTransfer(address _nftSeller, uint256 _buyAmount)
        internal
    {
        (bool success, ) = _nftSeller.call{value: _buyAmount}("");
        require(success, "refund failed");
    }
   /**
     * @dev Moves `amount` of tokens from `from` to `address(this)`
     * This internal function is equivalent to {transfer}, and can be used to transfer token to nft seller 
     * Emits a {Transfer} event.
    
     */
    function tokenAmountTransfer(
        address _to,
        address _nftSeller,
        address _erc20,
        uint256 _buyAmount
    ) internal {
        require(
            IERC20(_erc20).transferFrom(_to, address(this), _buyAmount),
            "allowance not enough"
        );
        IERC20(_erc20).transfer(_nftSeller, _buyAmount);
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;


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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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

// File: contracts/Abstract/ANFTMarketplace.sol


pragma solidity ^0.8.4;





    /***
        @notice abstract contract ANFTMarketplace  .
        @param owner  The address of the token holder
        @return        The account's balance of the Token type requested
     */
abstract contract ANFTMarketplace is INFTMarketplace {
    using SafeMath for uint256;

    uint256 public makerFee;
    address public owner;

    mapping(address => mapping(uint256 => uint256)) indexFixedSaleNFT;
    mapping(address => mapping(uint256 => uint256)) indexAuctionSaleNFT;
    mapping(address => mapping(uint256 => Auction)) nftContractAuctionSale;
    mapping(address => mapping(uint256 => FixedSale)) nftContractFixedSale;
    mapping(address => mapping(uint256 => uint256)) public nftSaleStatus;
    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public userBidPriceOnNFT;

    SaleInfo[] fixedSaleNFT;
    SaleInfo[] auctionSaleNFT;

    modifier buyPriceMeetSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _buyPrice
    ) {
        require(
            _buyPrice >=
                nftContractFixedSale[_nftContractAddress][_tokenId].salePrice,
            "buy Price not enough"
        );
        _;
    }

    modifier isAuctionOngoing(address _nftContractAddress, uint256 _tokenId) {
        require(
            block.timestamp <
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .auctionEnd,
            "Auction end"
        );
        _;
    }

    modifier isAuctionResetByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        require(
            msg.sender ==
                nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller,
            "not nft owner"
        );
        _;
    }

    modifier isAuctionOver(address _nftContractAddress, uint256 _tokenId) {
        require(
            block.timestamp >
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .auctionEnd,
            "Auction not end"
        );
        _;
    }

    modifier isbidNotMakeTillNow(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        require(
            address(0) ==
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .nftHighestBidder,
            "bid make"
        );
        _;
    }

    modifier isContractApprove(address _nftContractAddress, uint256 _tokenId) {
        require(
            IERC721(_nftContractAddress).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Nft not approved to contract"
        );
        _;
    }

    modifier isNftAlreadyInSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 0,
            "Nft already in sale"
        );
        _;
    }

    modifier isNftInAuctionSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 2,
            "Nft not in auction sale"
        );
        _;
    }

    modifier isNftInFixedSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 1,
            "Nft not in fixed sale"
        );
        _;
    }

    modifier islatestBidGreaterPreviousOne(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice,
        uint256 _bidPrice1
    ) {
        if (
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20 ==
            address(0)
        ) {
            require(
                _bidPrice >
                    nftContractAuctionSale[_nftContractAddress][_tokenId]
                        .nftHighestBid,
                "Bid Greater than Previous Bid"
            );
        } else {
            require(
                _bidPrice1 >
                    nftContractAuctionSale[_nftContractAddress][_tokenId]
                        .nftHighestBid,
                "Bid Greater than Previous Bid"
            );
        }

        _;
    }

    modifier isSaleStartByOwner(address _nftContractAddress, uint256 _tokenId) {
        require(
            msg.sender == IERC721(_nftContractAddress).ownerOf(_tokenId),
            "You are not nft owner"
        );
        _;
    }

    modifier isSaleResetByOwner(address _nftContractAddress, uint256 _tokenId) {
        require(
            msg.sender ==
                nftContractFixedSale[_nftContractAddress][_tokenId].nftSeller,
            "You are not nft owner"
        );
        _;
    }

    modifier isUpdatedBidGreaterPreviousOne(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateBidPrice,
        uint256 _updateBidPrice1
    ) {
        uint256 _finalBidPrice;
        if (
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20 ==
            address(0)
        ) {
            _finalBidPrice = userBidPriceOnNFT[_nftContractAddress][_tokenId][
                msg.sender
            ].add(_updateBidPrice);
        } else {
            _finalBidPrice = userBidPriceOnNFT[_nftContractAddress][_tokenId][
                msg.sender
            ].add(_updateBidPrice1);
        }
        require(
            _finalBidPrice >
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .nftHighestBid,
            "Bid Greater than Previous Bid"
        );
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not a owner");
        _;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }
     /**
        @notice function _isTokenOrCoin  .
        its a function is to check wheather it is erc2o token or blockchain coin
        accordingly it will do its operations on blockchain  
     */

    function _isTokenOrCoin(
        address _royaltyReciever,
        address _nftSeller,
        address _erc20,
        uint256 _buyAmount,
        uint256 _royalty,
        bool auction
    ) internal {
        uint256 taxAmount = (_buyAmount * makerFee) / uint256(100);
        uint256 royalty = (_buyAmount * _royalty) / uint256(100);

        uint256 userAmount = _buyAmount - (taxAmount + royalty);

        if (_erc20 != address(0)) {
            if (auction) {
                IERC20(_erc20).transfer(_nftSeller, userAmount);
                IERC20(_erc20).transfer(owner, taxAmount);
                IERC20(_erc20).transfer(_royaltyReciever, royalty);
            } else {
                AmountTransfer.tokenAmountTransfer(
                    msg.sender,
                    _nftSeller,
                    _erc20,
                    userAmount
                );
                AmountTransfer.tokenAmountTransfer(msg.sender,owner, _erc20, taxAmount);
                AmountTransfer.tokenAmountTransfer(
                    msg.sender,
                    _royaltyReciever,
                    _erc20,
                    royalty
                );
            }
        } else {
            AmountTransfer.nativeAmountTransfer(_nftSeller, userAmount);
            AmountTransfer.nativeAmountTransfer(owner, taxAmount);
            AmountTransfer.nativeAmountTransfer(_royaltyReciever, royalty);
        }
    }
     /**
        @notice function _storedNftAuctionDetails  .
        its a function is to store details of nft 
     */

    function _storedNftAuctionDetails(
        address _nftContractAddress,
        address _erc20,
        address _royaltyReciever,
        uint256 _royalty,
        uint256 _tokenId,
        uint256 _auctionStart,
        uint256 _auctionEnd,
        uint256 _minPrice
    ) internal {
        nftContractAuctionSale[_nftContractAddress][_tokenId] = Auction(
            _auctionStart,
            _auctionEnd,
            _minPrice,
            _minPrice,
            _royalty,
            address(0),
            msg.sender,
            _erc20,
            _royaltyReciever
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 2;

        IERC721(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        indexAuctionSaleNFT[_nftContractAddress][_tokenId] = auctionSaleNFT
            .length;
        auctionSaleNFT.push(SaleInfo(_nftContractAddress, _tokenId));

        emit NftAuctionSale(
            _nftContractAddress,
            msg.sender,
            _erc20,
            _tokenId,
            _auctionStart,
            _auctionEnd,
            _minPrice
        );
    }

    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice,
        address _nftBuyer
    ) internal {
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            _nftBuyer,
            _tokenId
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        _isTokenOrCoin(
            nftContractAuctionSale[_nftContractAddress][_tokenId]
                .royaltyReciever,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller,
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20,
            _bidPrice,
            nftContractAuctionSale[_nftContractAddress][_tokenId].royalty,
            true
        );
    }
}

// File: contracts/NFTMarketplace.sol


pragma solidity ^0.8.0;









contract NFTMarketplace is INFTMarketplace, ANFTMarketplace {
    using SafeMath for uint256;

    constructor(address _owner, uint256 _makerFee) {
        owner = _owner;
        makerFee = _makerFee;
    }

    // owner Function

    function setMakerFee(uint256 _makerFee) external onlyOwner {
        makerFee = _makerFee;
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
        emit UpdateOwner(msg.sender, _owner);
    }
 
    // NFT FIXED SALE

    function buyFromFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount
    )
        external
        payable
        isNftInFixedSale(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_amount)
        buyPriceMeetSalePrice(_nftContractAddress, _tokenId, _amount)
    {
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;
        delete fixedSaleNFT[(indexFixedSaleNFT[_nftContractAddress][_tokenId])];

        nftContractFixedSale[_nftContractAddress][_tokenId].nftBuyer = msg
            .sender;

        _isTokenOrCoin(
            nftContractFixedSale[_nftContractAddress][_tokenId].royaltyReciever,
            nftContractFixedSale[_nftContractAddress][_tokenId].nftSeller,
            nftContractFixedSale[_nftContractAddress][_tokenId].erc20,
            nftContractFixedSale[_nftContractAddress][_tokenId].salePrice,
            nftContractFixedSale[_nftContractAddress][_tokenId].royalty,
            false
        );

        emit NftBuyFromFixedSale(
            _nftContractAddress,
            msg.sender,
            _tokenId,
            _amount
        );
    }

    function cancelFixedsale(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInFixedSale(_nftContractAddress, _tokenId)
        isSaleResetByOwner(_nftContractAddress, _tokenId)
    {
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        delete fixedSaleNFT[(indexFixedSaleNFT[_nftContractAddress][_tokenId])];

        emit CancelNftFixedSale(_nftContractAddress, msg.sender, _tokenId);
    }

    function nftFixedSale(
        address _nftContractAddress,
        address _erc20,
        address _royaltyReciever,
        uint256 _royalty,
        uint256 _tokenId,
        uint256 _salePrice
    )
        external
        isSaleStartByOwner(_nftContractAddress, _tokenId)
        isNftAlreadyInSale(_nftContractAddress, _tokenId)
        isContractApprove(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_salePrice)
    {
        nftContractFixedSale[_nftContractAddress][_tokenId] = FixedSale(
            msg.sender,
            address(0),
            _erc20,
            _royaltyReciever,
            _salePrice,
            _royalty
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 1;

        indexFixedSaleNFT[_nftContractAddress][_tokenId] = fixedSaleNFT.length;
        fixedSaleNFT.push(SaleInfo(_nftContractAddress, _tokenId));

        IERC721(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        emit NftFixedSale(
            _nftContractAddress,
            msg.sender,
            _erc20,
            _tokenId,
            _salePrice,
            block.timestamp
        );
    }

    function updateFixedSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateSalePrice
    )
        external
        isNftInFixedSale(_nftContractAddress, _tokenId)
        isSaleResetByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_updateSalePrice)
    {
        nftContractFixedSale[_nftContractAddress][_tokenId]
            .salePrice = _updateSalePrice;

        emit NftFixedSalePriceUpdated(
            _nftContractAddress,
            _tokenId,
            _updateSalePrice
        );
    }

    // NFT AUCTION SALE

    function createNftAuctionSale(
        address _nftContractAddress,
        address _erc20,
        address _royaltyReciever,
        uint256 _royalty,
        uint256 _tokenId,
        uint256 _auctionStart,
        uint256 _auctionEnd,
        uint256 _minPrice
    )
        external
        isSaleStartByOwner(_nftContractAddress, _tokenId)
        isNftAlreadyInSale(_nftContractAddress, _tokenId)
        isContractApprove(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
    {
        _storedNftAuctionDetails(
            _nftContractAddress,
            _erc20,
            _royaltyReciever,
            _royalty,
            _tokenId,
            _auctionStart,
            _auctionEnd,
            _minPrice
        );
    }

    function _cancelAuctionSale(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionResetByOwner(_nftContractAddress, _tokenId)
        isbidNotMakeTillNow(_nftContractAddress, _tokenId)
    {
        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        delete auctionSaleNFT[
            (indexAuctionSaleNFT[_nftContractAddress][_tokenId])
        ];

        emit CancelNftAuctionSale(_nftContractAddress, _tokenId, msg.sender);
    }

    function makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice
    )
        external
        payable
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_bidPrice)
        islatestBidGreaterPreviousOne(
            _nftContractAddress,
            _tokenId,
            msg.value,
            _bidPrice
        )
    {
        if (
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20 !=
            address(0)
        ) {
            AmountTransfer.bidAmountTransfer(
                _bidPrice,
                nftContractAuctionSale[_nftContractAddress][_tokenId].erc20,
                msg.sender
            );
        }

        nftContractAuctionSale[_nftContractAddress][_tokenId]
            .nftHighestBid = _bidPrice;
        nftContractAuctionSale[_nftContractAddress][_tokenId]
            .nftHighestBidder = msg.sender;

        userBidPriceOnNFT[_nftContractAddress][_tokenId][
            msg.sender
        ] = _bidPrice;

        emit NftBidPrice(_nftContractAddress, _tokenId, _bidPrice, msg.sender);
    }

    function settleAuction(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOver(_nftContractAddress, _tokenId)
    {
        address nftBuyer = nftContractAuctionSale[_nftContractAddress][_tokenId]
            .nftHighestBidder;

        _transferNftAndPaySeller(
            _nftContractAddress,
            _tokenId,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftHighestBid,
            nftBuyer
        );

        userBidPriceOnNFT[_nftContractAddress][_tokenId][nftBuyer] = 0;
        delete auctionSaleNFT[
            (indexAuctionSaleNFT[_nftContractAddress][_tokenId])
        ];

        emit NftAuctionSettle(
            _nftContractAddress,
            _tokenId,
            nftBuyer,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftHighestBid,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller
        );
    }

    function updateTheBidPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateBidPrice
    )
        external
        payable
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_updateBidPrice)
        isUpdatedBidGreaterPreviousOne(
            _nftContractAddress,
            _tokenId,
            msg.value,
            _updateBidPrice
        )
    {
        address nftContractAddress = _nftContractAddress;
        uint256 tokenId = _tokenId;
        uint256 finalBidPrice = userBidPriceOnNFT[nftContractAddress][tokenId][
            msg.sender
        ].add(_updateBidPrice);

        if (
            nftContractAuctionSale[nftContractAddress][tokenId].erc20 !=
            address(0)
        ) {
            AmountTransfer.bidAmountTransfer(
                _updateBidPrice,
                nftContractAuctionSale[nftContractAddress][tokenId].erc20,
                msg.sender
            );
        }

        nftContractAuctionSale[nftContractAddress][tokenId]
            .nftHighestBid = finalBidPrice;
        nftContractAuctionSale[nftContractAddress][tokenId]
            .nftHighestBidder = msg.sender;

        userBidPriceOnNFT[nftContractAddress][tokenId][
            msg.sender
        ] = finalBidPrice;

        emit NftAuctionBidPriceUpdate(
            nftContractAddress,
            tokenId,
            finalBidPrice,
            msg.sender
        );
    }

    function withdrawBid(address _nftContractAddress, uint256 _tokenId)
        external
    {
        require(
            msg.sender !=
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .nftHighestBidder,
            "You are highest bidder"
        );
        require(
            userBidPriceOnNFT[_nftContractAddress][_tokenId][msg.sender] > 0,
            "nothing to withdraw"
        );

        uint256 amount = userBidPriceOnNFT[_nftContractAddress][_tokenId][
            msg.sender
        ];
        address _erc20 = nftContractAuctionSale[_nftContractAddress][_tokenId]
            .erc20;

        if (_erc20 != address(0)) {
            IERC20(_erc20).transfer(msg.sender, amount);
        } else {
            AmountTransfer.nativeAmountTransfer(msg.sender, amount);
        }

        userBidPriceOnNFT[_nftContractAddress][_tokenId][msg.sender] = 0;

        emit withdrawNftBid(_nftContractAddress, _tokenId, msg.sender);
    }

    //view function

    function getAuctionSaleNFT() external view returns (SaleInfo[] memory) {
        return auctionSaleNFT;
    }

    function getFixedSale(address _nftContractAddress, uint256 _tokenId)
        external
        view
        returns (FixedSale memory)
    {
        return nftContractFixedSale[_nftContractAddress][_tokenId];
    }

    function getFixedSaleNFT() external view returns (SaleInfo[] memory) {
        return fixedSaleNFT;
    }

    function getNftAuctionSaleDetails(
        address _nftContractAddress,
        uint256 _tokenId
    ) external view returns (Auction memory) {
        return nftContractAuctionSale[_nftContractAddress][_tokenId];
    }

    function onERC721Received(
        address,
        // address from,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}