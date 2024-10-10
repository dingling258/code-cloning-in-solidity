// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

library SignedMath {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            int256 mask = n >> 255;
            return uint256((n + mask) ^ mask);
        }
    }
}

library Math {
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor,
        Ceil,
        Trunc,
        Expand
    }

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            return a / b;
        }

        unchecked {
            return a == 0 ? 0 : (a - 1) / b + 1;
        }
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                return prod0 / denominator;
            }

            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)

                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = denominator & (0 - denominator);
            assembly {
                denominator := div(denominator, twos)

                prod0 := div(prod0, twos)

                twos := add(div(sub(0, twos), twos), 1)
            }

            prod0 |= prod1 * twos;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = prod0 * inverse;
            return result;
        }
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            uint256 remainder = a % n;
            uint256 gcd = n;

            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    remainder,
                    gcd - remainder * quotient
                );

                (x, y) = (
                    y,
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0;
            return x < 0 ? (n - uint256(-x)) : uint256(x);
        }
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 result = 1 << (log2(a) >> 1);

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

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

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

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

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

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

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

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC2981 is IERC165 {
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

interface IERC721Errors {

    error ERC721InvalidOwner(address owner);

    error ERC721NonexistentToken(uint256 tokenId);

    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    error ERC721InvalidSender(address sender);

    error ERC721InvalidReceiver(address receiver);

    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    error ERC721InvalidApprover(address approver);

    error ERC721InvalidOperator(address operator);
}

interface IERC1155Errors {

    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    error ERC1155InvalidSender(address sender);

    error ERC1155InvalidReceiver(address receiver);

    error ERC1155MissingApprovalForAll(address operator, address owner);

    error ERC1155InvalidApprover(address approver);

    error ERC1155InvalidOperator(address operator);

    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    error StringsInsufficientHexLength(uint256 value, uint256 length);

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

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

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

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

abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 tokenId => RoyaltyInfo) private _tokenRoyaltyInfo;

    error ERC2981InvalidDefaultRoyalty(uint256 numerator, uint256 denominator);

    error ERC2981InvalidDefaultRoyaltyReceiver(address receiver);

    error ERC2981InvalidTokenRoyalty(uint256 tokenId, uint256 numerator, uint256 denominator);

    error ERC2981InvalidTokenRoyaltyReceiver(uint256 tokenId, address receiver);

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        uint256 denominator = _feeDenominator();
        if (feeNumerator > denominator) {
            revert ERC2981InvalidDefaultRoyalty(feeNumerator, denominator);
        }
        if (receiver == address(0)) {
            revert ERC2981InvalidDefaultRoyaltyReceiver(address(0));
        }

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        uint256 denominator = _feeDenominator();
        if (feeNumerator > denominator) {
            revert ERC2981InvalidTokenRoyalty(tokenId, feeNumerator, denominator);
        }
        if (receiver == address(0)) {
            revert ERC2981InvalidTokenRoyaltyReceiver(tokenId, address(0));
        }

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}

library ERC721Utils {
    function checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(operator, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IfancyGirlsWeb3 is 
    IERC165,
    IERC2981,
    IERC721, 
    IERC721Metadata
{
    struct Whitelist {
        address account;
        uint256 deadline;
        uint256 nonce;
    }

    function withdrawEthers(uint256 amount, address to) external;

    function updateBaseURI(string memory newBaseURI) external;

    function setInvalidS(uint256 invalidCurve) external;

    function setPrivateSaleStarted(bool start) external;

    function setPublicSaleStarted(bool start) external;

    function setContractURI(string memory newURI) external;

    function getNonce(address account) external view returns (uint256);

    function getbaseURI() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function getCurrentPrice() external view returns (uint256);

    function privateSaleStarted() external view returns (bool);
    
    function publicSaleStarted() external view returns (bool);

    function transfer(address to, uint256 tokenId) external;

    function safeTransfer(address to, uint256 tokenId, bytes memory data) external;

    function mint(address to, uint256 tokenId) external payable;

    function safeMint(address to, uint256 tokenId, bytes memory data) external payable;

    function mintWithSignature(address to, uint256 tokenId, Whitelist calldata w, bytes calldata ownersApproval) external payable;

    function safeMintWithSignature(address to, uint256 tokenId, bytes memory data, Whitelist calldata w, bytes calldata ownersApproval) external payable;

    // ERC173
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() view external returns(address);
	
    function transferOwnership(address _newOwner) external;

    // EIP7572
    event ContractURIUpdated();

    function contractURI() external view returns (string memory);
}

contract fancyGirlsWeb3 is 
    Context, 
    ERC165,
    ERC2981,
    IfancyGirlsWeb3
{
    using Strings for uint256;
    
    mapping(address => uint256) private _nonces;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    address private _contractOwner;

    bool private _privateSaleStarted;
    bool private _publicSaleStarted;

    bytes32 private NAME_TYPEHASH;
    bytes32 private VERSION_TYPEHASH;
    bytes32 private EIP712DOMAINHASH;

    bytes32 private WHITELIST_TYPEHASH = keccak256(
        "Whitelist(address account,uint256 deadline,uint256 nonce)"
    );
    bytes32 private EIP712_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    uint256 private _totalSupply;

    uint256 private invalidS = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;

    uint256 private priceSlot;
    uint256[3] private priceLimit = [500, 5000, 10000];
    uint256[3] private prices = [0, 0.01 ether, 0.02 ether];

    string private _name = "Fancy Girls Web3";
    string private _symbol = "FGW";

    string private _version = "1";
    string private _baseURI;

    string private _contractURI = "https://www.fancygirlsweb3.com/contracturi/contracturi.json";
    
    modifier onlyOwner() {
        require(
            _msgSender() == _contractOwner, 
            "Only the owner of the contract can call this function"
        );
        _;
    }

    constructor() {
        NAME_TYPEHASH = hashString(_name);
        VERSION_TYPEHASH = hashString(_version);

        EIP712DOMAINHASH = keccak256(
            abi.encode(
                EIP712_TYPEHASH,
                NAME_TYPEHASH,
                VERSION_TYPEHASH,
                block.chainid,
                address(this)
            )
        );

        _contractOwner = 0x674e9933F9e813CA6D68766716C3516049153D63;
    }

    receive() external payable {}

    function withdrawEthers(
        uint256 amount, 
        address to
    ) 
        external 
        onlyOwner
    {
        require(
            amount <= address(this).balance,
            "Amount exceeds contract balance"
        );

        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Failed to send ethers");
    }

    function transferOwnership(
        address _newOwner
    ) 
        external
        onlyOwner
    {
        require(
            _newOwner != address(0),
            "Cannot set owner to null address"
        );
        require(
            _newOwner != _contractOwner,
            "New owner and current owner are the same"
        );
        emit OwnershipTransferred(_contractOwner, _newOwner);
        _contractOwner = _newOwner;
    }

    function updateBaseURI(
        string memory newBaseURI
    ) 
        external
        onlyOwner
    {
        require(
            keccak256(bytes(newBaseURI)) != keccak256(bytes(_baseURI)),
            "New baseURI and current baseURI are the same"
        );
        _baseURI = newBaseURI;
    }

    function setInvalidS(
        uint256 invalidCurve
    ) 
        external
        onlyOwner
    {
        invalidS = invalidCurve;
    }

    function setPrivateSaleStarted(
        bool start
    ) 
        external
        onlyOwner
    {
        require(
            start != _privateSaleStarted,
            "New privateSaleStarted and current privateSaleStarted are the same"
        );
        _privateSaleStarted = start;
    }

    function setPublicSaleStarted(
        bool start
    ) 
        external
        onlyOwner
    {
        require(
            start != _publicSaleStarted,
            "New publicSaleStarted and current publicSaleStarted are the same"
        );
        _publicSaleStarted = start;
    }

    function setContractURI(
        string memory newURI
    ) 
        external 
        onlyOwner 
    {
        require(
            keccak256(bytes(newURI)) != keccak256(bytes(_contractURI)),
            "New contractURI and current contractURI are the same"
        );
        _contractURI = newURI;
        emit ContractURIUpdated();
    }

    function getNonce(
        address account
    )
        external
        view
        returns (uint256)
    {
        return _nonces[account];
    }

    function getbaseURI()
        external
        view
        returns (string memory)
    {
        return _baseURI;
    }

    function totalSupply()
        external
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function getCurrentPrice()
        external
        view
        returns (uint256)
    {
        require(
            _totalSupply <= 10000,
            "All tokens have been minted"
        );
        uint256 currentSlot = priceSlot;
        if (_totalSupply == priceLimit[currentSlot]) {
            currentSlot++;
        }
        return prices[currentSlot];
    }

    function privateSaleStarted() 
        external
        view
        returns (bool)
    {
        return _privateSaleStarted;
    }

    function publicSaleStarted() 
        external
        view
        returns (bool)
    {
        return _publicSaleStarted;
    }

    function approve(
        address to, 
        uint256 tokenId
    ) 
        public 
    {
        _approve(to, tokenId, _msgSender(), true);
    }

    function setApprovalForAll(
        address operator, 
        bool approved
    ) 
        public 
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function transfer(
        address to,
        uint256 tokenId
    ) 
        public
    {
        _transfer(_msgSender(), to, tokenId);
    }

    function safeTransfer(
        address to,
        uint256 tokenId,
        bytes memory data
    ) 
        public
    {
        _safeTransfer(_msgSender(), to, tokenId, data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) 
        public 
    {
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert("Incorrect Owner");
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) 
        public 
    {
        transferFrom(from, to, tokenId);
        ERC721Utils.checkOnERC721Received(
            _msgSender(),
            from,
            to,
            tokenId,
            data
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) 
        public 
    {
        safeTransferFrom(from, to, tokenId, "");
    }

    function mint(
        address to,
        uint256 tokenId
    )
        public
        payable     
    {
        require(
            _publicSaleStarted,
            "Public sale has not yet started"
        );
        _mint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        payable     
    {
        require(
            _publicSaleStarted,
            "Public sale has not yet started"
        );
        _safeMint(to, tokenId, data);
    }

    function mintWithSignature(
        address to,
        uint256 tokenId,
        Whitelist calldata w,
        bytes calldata ownersApproval
    ) 
        public
        payable
    {
        require(
            _privateSaleStarted,
            "Private sale has not yet started"
        );
        address caller = _msgSender();
        uint256 currentNonce = _nonces[caller];

        checkWhitelist(caller, currentNonce, w, ownersApproval);

        _nonces[caller] = currentNonce + 1;
        _mint(to, tokenId);
    }

    function safeMintWithSignature(
        address to,
        uint256 tokenId,
        bytes memory data,
        Whitelist calldata w,
        bytes calldata ownersApproval
    ) 
        public
        payable
    {
        require(
            _privateSaleStarted,
            "Private sale has not yet started"
        );
        address caller = _msgSender();
        uint256 currentNonce = _nonces[caller];

        checkWhitelist(caller, currentNonce, w, ownersApproval);

        _nonces[caller] = currentNonce + 1;
        _safeMint(to, tokenId, data);
    }

    function owner() 
        public 
        view 
        returns(address) 
    {
        return _contractOwner;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) 
        public 
        view 
        override(ERC165, IERC165, ERC2981) 
        returns (bool) 
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == 0x7f5828d0 ||
            super.supportsInterface(interfaceId);
    }

    function contractURI() 
        public 
        view 
        returns (string memory) 
    {
        return _contractURI;
    }

    function balanceOf(
        address _owner
    ) 
        public 
        view
        returns (uint256) 
    {
        return _balances[_owner];
    }

    function ownerOf(
        uint256 tokenId
    ) 
        public 
        view
        returns (address) 
    {
        return _requireOwned(tokenId);
    }

    function name() 
        public 
        view
        returns (string memory) 
    {
        return _name;
    }

    function symbol() 
        public 
        view
        returns (string memory) 
    {
        return _symbol;
    }

    function tokenURI(
        uint256 tokenId
    ) 
        public 
        view
        returns (string memory)
    {
        _requireOwned(tokenId);
        return string.concat(_baseURI, tokenId.toString(), ".json");
    }

    function getApproved(
        uint256 tokenId
    ) 
        public 
        view
        returns (address) 
    {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    function isApprovedForAll(
        address _owner,
        address operator
    ) 
        public 
        view
        returns (bool) 
    {
        return _operatorApprovals[_owner][operator];
    }

    function royaltyInfo(
        uint256 tokenId, 
        uint256 salePrice
    ) 
        public 
        view 
        override(IERC2981, ERC2981) 
        returns (address, uint256) 
    {
        if (tokenId == 0 || tokenId > 10000) {
            revert("Invalid tokenId");
        }
        uint256 royaltyAmount = (salePrice * 5) / 100;
        return (_contractOwner, royaltyAmount);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) 
        internal 
        returns (address) 
    {
        address from = _ownerOf(tokenId);

        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        if (from != address(0)) {
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (tokenId == 0) {
            revert("Invalid tokenId");
        }
        
        if (to == address(0)) {
            revert("Invalid receiver");
        }

        unchecked {
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }
    
    function _mint(
        address to, 
        uint256 tokenId
    ) 
        internal 
    {
        checkPrice();
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert("Invalid sender");
        }
        _totalSupply++;
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) 
        internal 
    {
        _mint(to, tokenId);
        ERC721Utils.checkOnERC721Received(
            _msgSender(),
            address(0),
            to,
            tokenId,
            data
        );
    }

    function _transfer(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
    {
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert("Invalid tokenId");
        } else if (previousOwner != from) {
            revert("Caller is not the owner of the token");
        }
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) 
        internal 
    {
        _transfer(from, to, tokenId);
        ERC721Utils.checkOnERC721Received(
            _msgSender(),
            from,
            to,
            tokenId,
            data
        );
    }

    function _approve(
        address to,
        uint256 tokenId,
        address auth,
        bool emitEvent
    ) 
        internal 
    {
        if (emitEvent || auth != address(0)) {
            address _owner = _requireOwned(tokenId);

            if (
                auth != address(0) &&
                _owner != auth &&
                !isApprovedForAll(_owner, auth)
            ) {
                revert("Invalid approver");
            }

            if (emitEvent) {
                emit Approval(_owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    function _setApprovalForAll(
        address _owner,
        address operator,
        bool approved
    ) 
        internal 
    {
        if (operator == address(0)) {
            revert("Invalid operator");
        }
        _operatorApprovals[_owner][operator] = approved;
        emit ApprovalForAll(_owner, operator, approved);
    }

    function checkPrice()
        internal
    {
        if (_totalSupply == priceLimit[priceSlot]) {
            priceSlot++;
        }
        require(
            msg.value >= prices[priceSlot],
            "Not enough Ethers sent for minting based on current price slot"
        );
        require(
            _totalSupply < 10000, 
            "All available tokens have been minted"
        );
    }

    function _ownerOf(
        uint256 tokenId
    ) 
        internal 
        view 
        returns (address) 
    {
        return _owners[tokenId];
    }

    function _getApproved(
        uint256 tokenId
    ) 
        internal 
        view 
        returns (address) 
    {
        return _tokenApprovals[tokenId];
    }

    function _isAuthorized(
        address _owner,
        address spender,
        uint256 tokenId
    ) 
        internal 
        view 
        returns (bool) 
    {
        return
            spender != address(0) &&
            (_owner == spender ||
                isApprovedForAll(_owner, spender) ||
                _getApproved(tokenId) == spender);
    }

    function _checkAuthorized(
        address _owner,
        address spender,
        uint256 tokenId
    ) 
        internal 
        view 
    {
        if (!_isAuthorized(_owner, spender, tokenId)) {
            if (_owner == address(0)) {
                revert("Invalid owner");
            } else {
                revert("Insufficient approval");
            }
        }
    }

    function _requireOwned(
        uint256 tokenId
    ) 
        internal 
        view 
        returns (address) 
    {
        address _owner = _ownerOf(tokenId);
        if (_owner == address(0)) {
            revert("Token has not been minted");
        }
        return _owner;
    }

    function checkWhitelist(
        address caller,
        uint256 currentNonce,
        Whitelist calldata w,
        bytes calldata ownersApproval
    ) 
        internal
        view
    {
        require(
            w.deadline > block.timestamp,
            "Deadline is no longer valid"
        );
        require(
            w.account == caller,
            "Caller is not the account of the whitelist"
        );
        require(
            w.nonce > currentNonce,
            "Invalid nonce, signature is no longer valid"
        );
        require(
            isOwnersSignature(w, ownersApproval),
            "Invalid contract owner's approval"
        );    
    }

    function getEIP712Hash(
        bytes32 hashStruct
    )
        internal 
        view 
        returns (bytes32) 
    {
        return keccak256(
            abi.encodePacked(
                "\x19\x01", 
                EIP712DOMAINHASH, 
                hashStruct
            )
        );
    }

    function recoverSigner(
        bytes32 _hash, 
        bytes memory _signature
    )
        internal 
        view 
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        return 
            uint256(s) > invalidS ?
            address(0) : ecrecover(_hash, v, r, s);
    }

    function isOwnersSignature(
        Whitelist memory w,
        bytes memory ownersApproval
    ) 
        internal
        view
        returns (bool)
    {
        return recoverSigner(
            getEIP712Hash(keccak256(abi.encode(
                WHITELIST_TYPEHASH,
                w
            ))),
            ownersApproval
        ) == _contractOwner;
    }
    
    function hashString(
        string memory str
    ) 
        internal
        pure
        returns (bytes32)
    {
        return keccak256(bytes(str));
    }
}