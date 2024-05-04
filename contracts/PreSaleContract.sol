// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0z;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PreSaleContract is Ownable {
    IERC20 public usdtToken; // USDT token contract
    IERC20 public preSaleToken; // preSale token contract

    uint256 public startTimeStamp; // Start time of the funding (UNIX timestamp)
    uint256 public endTimeStamp; // End time of the funding (UNIX timestamp)
    uint256 public goalUsdt; // Goal in USDT
    uint256 public totalUsdtCollected; 
    uint256 public tokensToClaim;

    bool public fundingComplete; // Flag indicating the funding is complete
    bool public tokensDeposited; // Flag indicating the preSale tokens are deposited

    mapping(address => uint256) public contributions; // Mapping of user contributions

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

        tokensToClaim = preSaleToken.balanceOf(address(this)) / goalUsdt;
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

        tokensToClaim = (contributions[msg.sender] / totalUsdtCollected) * preSaleToken.balanceOf(address(this));

        contributions[msg.sender] = 0; 
        require(preSaleToken.transfer(msg.sender, tokensToClaim), "Failed to transfer tokens");
    }

    // Function to deposit preSale tokens to the contract
    function depositPreSaleTokens(uint256 tokenAmount) public onlyOwner {
        require(!fundingComplete, "Token was already deposited");
        require(preSaleToken.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        tokensDeposited = true;
    }

    // Function to get the USDT balance of the contract
    function getUsdtBalance() external view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    // Function to get the presale token balance of the contract
    function getPreSaleTokenBalance() external view returns (uint256) {
        return preSaleToken.balanceOf(address(this));
    }

    // Function to get start time of the funding (UNIX timestemp)
    function getStartTimeStamp() external view returns (uint256) {
        return startTimeStamp;
    }
    
    // Function to get end time of the funding (UNIX timestemp)
    function getEndTimeStamp() external view returns (uint256) {
        return endTimeStamp;
    }

    // 
    function getTokensToClaim() external view returns (uint256) {
        return tokensToClaim;
    }
}