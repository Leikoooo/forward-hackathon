
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


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

// File: contracts/PreSaleContract.sol


pragma solidity ^0.8.20;



// Forward testnet <3

contract PreSaleContract is Ownable {
    IERC20 private usdtToken; // USDT token contract
    IERC20 private preSaleToken; // preSale token contract

    uint256 private startTimeStamp; // Start time of the funding (UNIX timestamp)
    uint256 private endTimeStamp; // End time of the funding (UNIX timestamp)
    uint256 private goalUsdt; // Goal in USDT
    uint256 private totalUsdtCollected; 
    uint256 private tokensPerUsdt;

    bool private fundingComplete; // Flag indicating the funding is complete
    bool private tokensDeposited; // Flag indicating the preSale tokens are deposited

    mapping(address => uint256) private contributions; // Mapping of user contributions

    constructor(
        address _usdtToken,
        address _preSaleToken,
        uint256 _goalUsdt,
        uint256 _startTimeStamp,
        uint256 _endTimeStamp
    ) Ownable(msg.sender) {
        require(_startTimeStamp < _endTimeStamp, "Start time must be before end time");
        require(_goalUsdt > 0, "Goal must be more than 0");

        usdtToken = IERC20(_usdtToken);
        preSaleToken = IERC20(_preSaleToken);
        goalUsdt = _goalUsdt;
        startTimeStamp = _startTimeStamp;
        endTimeStamp = _endTimeStamp;
    }

    // Function to contribute USDT to the funding
    function contribute(uint256 usdtAmount) public {
        require(block.timestamp >= startTimeStamp, "Funding is not active");
        require(block.timestamp <= endTimeStamp, "Funding is not active");
        require(tokensDeposited, "preSale tokens must be deposited first");
        require(!fundingComplete, "Funds already withdrawn");
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "Failed to transfer USDT");

        contributions[msg.sender] += usdtAmount;
        totalUsdtCollected += usdtAmount;
    }
    
    // Function to withdraw funds to the owner
    function withdrawFunds() public onlyOwner {
        require(!fundingComplete, "Funds already withdrawn");
        require(block.timestamp > endTimeStamp || totalUsdtCollected >= goalUsdt, "Funding period is not over or goal not reached");
        require(tokensDeposited, "preSale tokens must be deposited first");

        fundingComplete = true;
        require(usdtToken.transfer(owner(), totalUsdtCollected), "Failed to transfer USDT to owner");
    }

    // Function to claim tokens for the contribution
    function claimTokens() public {
        require(fundingComplete, "Funding not complete");
        require(contributions[msg.sender] > 0, "No contribution made");

        uint256 tokensToClaim = (contributions[msg.sender] / totalUsdtCollected) * preSaleToken.balanceOf(address(this));

        contributions[msg.sender] = 0; 
        require(preSaleToken.transfer(msg.sender, tokensToClaim), "Failed to transfer tokens");
    }

    // Function to deposit preSale tokens to the contract
    function depositPreSaleTokens(uint256 tokenAmount) public onlyOwner {
        require(!fundingComplete, "Token was already deposited");
        require(preSaleToken.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");

        tokensDeposited = true;

        // Convert goalUsdt to 18 decimals
        uint256 goalUsdt18Decimals = goalUsdt * 1e12;

        // Calculate tokens per USDT
        tokensPerUsdt = preSaleToken.balanceOf(address(this)) / goalUsdt18Decimals;
    }

    // Function to get the presale token balance of the contract
    function getPreSaleTokenBalance() external view returns (uint256) {
        return preSaleToken.balanceOf(address(this));
    }

    // Returns the USDT token contract address
    function getUsdtToken() public view returns (IERC20) {
        return usdtToken;
    }
    
    // Returns the pre-sale token contract address.
    function getPreSaleToken() public view returns (IERC20) {
        return preSaleToken;
    }

    // Returns the start timestamp of the funding.
    function getStartTimeStamp() public view returns (uint256) {
        return startTimeStamp;
    }

    // Returns the end timestamp of the funding.
    function getEndTimeStamp() public view returns (uint256) {
        return endTimeStamp;
    }

    // Returns the goal amount of USDT to be raised.
    function getGoalUsdt() public view returns (uint256) {
        return goalUsdt;
    }

    // Returns the total USDT collected so far.
    function getTotalUsdtCollected() public view returns (uint256) {
        return totalUsdtCollected;
    }
    
    // Returns the number of tokens per USDT.
    function getTokensPerUsdt() public view returns(uint256) {
        return tokensPerUsdt;
    }

    // Returns whether the funding is complete.
    function isFundingComplete() public view returns (bool) {
        return fundingComplete;
    }

    // Returns whether the pre-sale tokens have been deposited.
    function areTokensDeposited() public view returns (bool) {
        return tokensDeposited;
    }

    // Returns the contribution made by a specific address.
    function getContribution(address contributor) public view returns (uint256) {
        return contributions[contributor];
    }

}