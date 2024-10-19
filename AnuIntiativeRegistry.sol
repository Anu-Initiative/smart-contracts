// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
//import "hardhat/console.sol";

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

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}


/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Required interface of an Account Bound NFT compliant contract.
 */
interface IAccountBoundNFT is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

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

}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IAccountBoundNFT {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC-721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC-721 asset contracts.
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

/**
 * @dev Library that provide common ERC-721 utility functions.
 *
 * See https://eips.ethereum.org/EIPS/eip-721[ERC-721].
 */
library ERC721Utils {
    /**
     * @dev Performs an acceptance check for the provided `operator` by calling {IERC721-onERC721Received}
     * on the `to` address. The `operator` is generally the address that initiated the token transfer (i.e. `msg.sender`).
     *
     * The acceptance call is not executed and treated as a no-op if the target address doesn't contain code (i.e. an EOA).
     * Otherwise, the recipient must implement {IERC721Receiver-onERC721Received} and return the acceptance magic value to accept
     * the transfer.
     */
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
                    // Token rejected
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-IERC721Receiver implementer
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
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
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC-721] Non-Fungible Token Standard 
 * modified to be account bound and singularity.
 */
abstract contract AccountBoundNFT is Context, ERC165, IAccountBoundNFT, IERC721Metadata, IERC721Errors {

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;

    mapping(address owner => uint256) private _accountId;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IAccountBoundNFT).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return _accountId[owner] > 0 ? 1 : 0;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return baseURI;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0) || _owners[tokenId] != address(0) || _accountId[to] != 0) {
            revert ERC721InvalidReceiver(address(0));
        }
        _owners[tokenId] = to;
        _accountId[to] = tokenId;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        ERC721Utils.checkOnERC721Received(_msgSender(), address(0), to, tokenId, data);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

interface IERC20Recyclable is IERC20 {
    function mint(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}

interface IDonationReceipt {
   function mintReceipt(address account, uint256 amount) external returns(uint256 id);
   function donationCount(address account) external view returns (uint256 amount);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract AnuRegistry is AccountBoundNFT, Ownable {

    event UserRegistered(address account, uint256 id, string name, address referring);
    event UserVerified(address account, bool verified);
    event Donation(address account, uint256 amount);
    event ClaimHarvested(address account, uint256 amount);

    //Registered Account Structure
    struct RegisteredAccount {
        //add more user details as needed/implemented in web account sign-up.
    	uint256 id;
    	string displayName;
        address referredBy;
        uint256 totalDonations;
        uint256 tokenClaim;
        bool verified;
        address[] referrals;
    }

    //Donation Receipt NFT contract
    IDonationReceipt private DonationReceipt;

    //Uniswap V2 Router contract
    IUniswapV2Router private UniswapV2Router;

    //Treasury account receives all donations in USDC.
    address private treasuryAccount;

    //Verication account may verify registered accounts.
    address private verificationAccount;
    
    //ANU token contract
    IERC20Recyclable private anuToken;

    //USDC token contract
    IERC20 private usdcToken;

    //Native token address
    address private maticToken;

    //Account registration index
    uint256 private registeredIndex;

    //Account registration
    mapping(address => RegisteredAccount) private registered;

    //Token addresses allowed for donations
    mapping(address => bool) public tokenAllowed;
    
    //ANU Token Reward per USDC donated 
    uint256 public rewardPerUSDC = 10000;//in pennies, 100ths

    //Allow ANU Token Claim Harvesting 
    bool public allowHarvest;

    //NFT Background Image with Anu Logo
    string private nftBackground = "https://green-domestic-whale-328.mypinata.cloud/ipfs/QmUYogxJadHdva7qHqTY8oqaC8yuh17sK6HzhGsUoiHzkJ";

    modifier onlyVerificationAccount() {
        require(_msgSender() == verificationAccount, "ANU - Verification account only.");
        _;
    }

    modifier onlyVerifiedAccount() {
        require(registered[_msgSender()].id > 0, "ANU - User address not registered.");
        require(registered[_msgSender()].verified == true, "ANU - Registered address not verified.");
        _;
    }

    constructor() AccountBoundNFT('ANU Initiative Member', 'ANU MEMBER') Ownable(msg.sender) {}

    /**
     * @notice Registers `account` with `displayName` and `referredBy` account.
     * 
     * - Soulbound NFT minted for each registered account.
     * - Registered accounts must be verified before donations can be made.
     * - `referredBy` account must be verified.
     * - Reverted if account attempts to register more than once.
     *
     */
    function register(
        string memory displayName,
        address referredBy
    ) external {
        require(registered[_msgSender()].id == 0, "ANU - User address already registered.");
        require(referredBy == address(0) || registered[referredBy].verified, "ANU - Invalid referring account.");

        registeredIndex += 1;
        registered[_msgSender()].id = registeredIndex;
        registered[_msgSender()].displayName = displayName;
        if (referredBy != address(0)) {
            registered[_msgSender()].referredBy = referredBy;
            registered[referredBy].referrals.push(_msgSender());
        }

        _mint(_msgSender(), registeredIndex);

        emit UserRegistered(_msgSender(), registeredIndex, displayName, referredBy);
    }

    /**
     * @notice Verify registered `account` if `verified`, or remove verification if not.
     * 
     * - Account must already be registered.
     * - Function can only be called by set verification account.
     *
     */
    function verifyRegistration(
    	address account,
    	bool verified
    ) external onlyVerificationAccount {
    	require(registered[account].id > 0, "ANU - User account not registered.");
    	if (verified) {
    		require(!registered[account].verified, "ANU - User already verified.");
    	} else {
    		require(registered[account].verified, "ANU - User already not verified.");
    	}

    	registered[account].verified = verified;

    	emit UserVerified(account, verified);
    }

    /**
     * @notice Donate `amount` of `token` from calling account.
     * 
     * - Calling account must be registered and verified to donate.
     * - `token` must be allowed donation token.
     * - If Matic token, msg.value (matic sent with tx) must be >= `amount`,
     * - Otherwise, `token` allowance for contract must be >= `amount` on calling account, 
     *   and `token` balance must be >= `amount` on calling account. 
     * - Donation receipt minted to calling account as proof of donation.
     * - ANU token reward claim accumulated on calling account based on donation amount * rewardPerUSDC.
     *
     */
    function donate(
        uint256 amount,
        address token
    ) external payable onlyVerifiedAccount {
        require(amount > 0, "ANU - User address not registered.");
        require(tokenAllowed[token] == true, "ANU - Donation token not allowed.");

        uint256 amountInUSDC;

        if (token == address(usdcToken)) {
            require(usdcToken.balanceOf(_msgSender()) >= amount, "ANU: USDC balance insufficient.");
            require(usdcToken.allowance(_msgSender(), address(this)) >= amount, "ANU: USDC allowance required.");
            usdcToken.transferFrom(_msgSender(), payable(treasuryAccount), amount);
            amountInUSDC = amount;

        } else {
            address[] memory path = new address[](2);
            path[0] = address(token);
            path[1] = address(usdcToken);
            uint256[] memory amounts;

            if (token == maticToken) {
                require(msg.value >= amount, "ANU - Matic amount must be sent with tx.");
                if (msg.value > amount) {
                    refundOverpay(msg.value - amount);
                }

                amounts = UniswapV2Router.swapExactETHForTokens{value: amount}(0, path, treasuryAccount, block.timestamp);
                amountInUSDC = amounts[1];

            } else {//any token
                require(IERC20(token).balanceOf(_msgSender()) >= amount, "ANU: token balance insufficient.");
                require(IERC20(token).allowance(_msgSender(), address(this)) >= amount, "ANU: token allowance required.");
                IERC20(token).transferFrom(_msgSender(), address(this), amount);
                IERC20(token).approve(address(UniswapV2Router), amount);

                amounts = UniswapV2Router.swapExactTokensForTokens(amount, 0, path, treasuryAccount, block.timestamp);
                amountInUSDC = amounts[1];
            }
        }
        
        DonationReceipt.mintReceipt(_msgSender(), amountInUSDC);
        registered[_msgSender()].totalDonations += amountInUSDC;

        uint256 claimAmount = amountInUSDC * rewardPerUSDC / 100;
        registered[_msgSender()].tokenClaim += claimAmount;

        emit Donation(_msgSender(), amountInUSDC);
    }

    /**
     * @notice Harvest `amount` from calling account's ANU token claim.
     * 
     * - Amount in ANU tokens is minted directly to calling account.
     * - `allowHarvest` must be set to true.
     *
     */
    function harvest(
    	uint256 amount
    ) external {
        require(allowHarvest, "ANU - Harvest not allowed yet.");
        require(amount > 0, "ANU - Harvest amount must be greater than zero.");
        require(amount <= registered[_msgSender()].tokenClaim, "ANU - Harvest amount exceeds token claim.");
        
        registered[_msgSender()].tokenClaim -= amount;
        anuToken.mint(_msgSender(), amount);

        emit ClaimHarvested(_msgSender(), amount);
    }

    /**
     * @notice Set Donation Receipt contract with `receiptContract` address.
     * 
     * - Uses IDonationReceipt contract interface.
     * - Only callable by owner account.
     *
     */
    function setDonationReceiptContract(
        address _contract
    ) external onlyOwner {
        require(_contract != address(0), "ANU - Invalid donation receipt address.");

        DonationReceipt = IDonationReceipt(_contract);
    }

    /**
     * @notice Set Uniswap Router contract with `uniswapV2RouterContract` address.
     * 
     * - Uses IUniswapV2Router contract interface.
     * - Only callable by owner account.
     *
     */
    function setRouterContract(
        address _contract
    ) external onlyOwner {
        require(_contract != address(0), "ANU - Invalid router address.");

        UniswapV2Router = IUniswapV2Router(_contract);
    }

    /**
     * @notice Set Treasury account with `account` address.
     * 
     * - Treasury account receives all donations in USDC.
     * - Only callable by owner account.
     *
     */
    function setTreasuryAccount(
        address account
    ) external onlyOwner {
        require(account != address(0), "ANU - Invalid account address.");

        treasuryAccount = account;
    }

    /**
     * @notice Set Verification account with `account` address.
     * 
     * - Only Verication account may verify registered accounts.
     * - Only callable by owner account.
     *
     */
    function setVerificationAccount(
        address account
    ) external onlyOwner {
        require(account != address(0), "ANU - Invalid account address.");

        verificationAccount = account;
    }

    /**
     * @notice Set ANU Token contract with `anuTokenAddress` address.
     * 
     * - Uses IERC20Recyclable contract interface.
     * - Only callable by owner account.
     *
     */
    function setANUToken(
        address token
    ) external onlyOwner {
        require(token != address(0), "ANU - Invalid token address.");

        anuToken = IERC20Recyclable(token);
    }

    /**
     * @notice Set USDC Token contract with `usdcTokenAddress` address.
     * 
     * - Uses IERC20 contract interface.
     * - Only callable by owner account.
     *
     */
    function setUSDCToken(
        address token
    ) external onlyOwner {
        require(token != address(0), "ANU - Invalid token address.");

        usdcToken = IERC20(token);
    }

    /**
     * @notice Set MATIC Token contract with `maticTokenAddress` address.
     * 
     * - Uses IERC20 contract interface.
     * - Only callable by owner account.
     *
     */
    function setMATICToken(
        address token
    ) external onlyOwner {
        require(token != address(0), "ANU - Invalid token address.");

        maticToken = token;
    }

    /**
     * @notice Set `token` address `allowed` for donations.
     *
     * - Only callable by owner account.
     */
    function setDonationTokenAllowed(
        address token,
        bool allowed
    ) external onlyOwner {
        require(token != address(0), "ANU - Invalid token address.");

        tokenAllowed[token] = allowed;
    }

    /**
     * @notice Set ANU Token reward `amount` per USDC donation amount.
     * 
     * - Only callable by owner account.
     *
     */
    function setRewardPerUSDC(
        uint256 amount
    ) external onlyOwner {
        rewardPerUSDC = amount;
    }

    /**
     * @notice Set allow ANU Token claim harvesting.
     * 
     * - Account may only harvest ANU Token claim if set to true.
     * - Only callable by owner account.
     *
     */
    function setAllowHarvest(
        bool allowed
    ) external onlyOwner {
        allowHarvest = allowed;
    }

    /**
     * @notice Returns true if `account` is registered.
     *
     */
    function isRegistered(
        address account
    ) external view returns (bool) {
        return registered[account].id > 0;
    }

    /**
     * @notice Returns true if `account` is registered and verified.
     *
     */
    function isVerified(
        address account
    ) external view returns (bool) {
        return registered[account].verified;
    }

    /**
     * @notice Returns total registered users.
     *
     */
    function totalSupply(
    ) external view returns (uint256 supply) {
        supply = registeredIndex;
    }

    /**
     * @notice Returns registered name for `account`.
     * 
     * - Name will be empty string for non-registered accounts.
     *
     */
    function registeredName(
        address account
    ) public view returns (string memory name) {
        name = registered[account].displayName;
    }

    /**
     * @notice Returns registered id for `account`.
     * 
     * - Id will be 0 for non-registered accounts.
     *
     */
    function registeredId(
        address account
    ) external view returns (uint256 id) {
        id = registered[account].id;
    }

    /**
     * @notice Returns ANU token claim available for `account`.
     *
     */
    function tokenClaimAvailable(
        address account
    ) public view returns (uint256 amount) {
        amount = registered[account].tokenClaim;
    }

    /**
     * @notice Returns total donations amount for `account`.
     *
     */
    function totalDonations(
        address account
    ) public view returns (uint256 amount) {
        amount = registered[account].totalDonations;
    }

    /**
     * @notice Returns number of referrals for `account`.
     *
     */
    function referralCount(
        address account
    ) public view returns (uint256 amount) {
        amount = registered[account].referrals.length;
    }

    /**
     * @notice Returns array of referrals by `account`.
     *
     */
    function referralsByAccount(
        address account
    ) public view returns (address[] memory referrals) {
        referrals = registered[account].referrals;
    }

    /**
     * @notice Returns referral account for `account`.
     *
     */
    function referralAccount(
        address account
    ) public view returns (address referral) {
        referral = registered[account].referredBy;
    }

    /**
     * @notice Returns `rank` if calling account is registered and verified.
     * 
     * TODO - Update rank equation 
     *
     */
    function rankOf(
        address account
    ) public view returns (uint256 rank) {
        rank = DonationReceipt.donationCount(account) + referralCount(account);
    }

    /**
     * @notice Returns token URI for given `tokenId`.
     * 
     * - URI is generated dynamically from contract data reflecting:
     *    - Account registered Display Name
     *    - Total donations made by account
     *    - Account Rank
     *
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory uri) {
        string memory _name = registeredName(ownerOf(tokenId));
        string memory _donation = toString(totalDonations(ownerOf(tokenId)) / 10 ** 18);
        string memory _rank = toString(rankOf(ownerOf(tokenId)));
        string memory svg = string(abi.encodePacked(
            '<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="480pt" height="480pt" viewBox="0 0 480 480" preserveAspectRatio="xMidYMid meet"><style>.base0 { fill: #000000; overflow:hidden; text-anchor: middle; font-size: 20px; font-weight: bold; font-family: Verdana, Helvetica, Arial, sans-serif; } .base1 { fill: #000000; overflow:hidden; text-anchor: middle; width: 100%; font-size: 32px; font-weight: bold; font-family: Arial, sans-serif; }</style><g transform="translate(0,480) scale(0.1,-0.1)" fill="#000000" stroke="none"></g>',
            '<image href="', nftBackground, '" height="280" width="480" />',
            '<text x="244" y="84" class="base1">', _name,
            '</text><text x="244" y="300" class="base0">Donations: ', _donation, ' USDC</text><text x="244" y="300" class="base0">Donation: ', _donation, ' USDC</text>',
            '<text x="244" y="330" class="base0">Rank: ', _rank, ' </text></svg>'
        ));
        string memory json = base64(bytes(string(abi.encodePacked(
            '{"name": "Anu Intiative Member #',
            toString(tokenId),
            '", "description": "Anu Initiative Membership Badge", "image": "data:image/svg+xml;base64,',
            base64(bytes(svg)), '"}'
        ))));
        uri = string(abi.encodePacked('data:application/json;base64,', json));
    }

    /**
     * @notice Withdraw any access funds from the contract.
     * 
     * - Overpay is refunded, so should only include tokens sent directly, if at all.
     * - Only callable by owner account.
     *
     */
    function withdraw(
    ) external onlyOwner {
        require(address(this).balance > 0, "ANU - Nothing to withdraw");
        Address.sendValue(payable(owner()), address(this).balance);
    }

    /**
     * @notice Refund any overpay to msg sender.
     *
     */
    function refundOverpay(
        uint256 amount
    ) internal {
        if (amount > 0 && msg.value >= amount) {
            (bool refunded, ) = payable(_msgSender()).call{value: amount}("");
            require(refunded, "ANU - Failed to refund overpayment");
        }
    }

    /**
     * @notice Encodes some bytes to the base64 representation.
     */
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 
    function base64(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }

    /**
     * @notice Converts a `uint256` to its ASCII string decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}