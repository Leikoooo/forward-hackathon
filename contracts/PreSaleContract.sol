// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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
