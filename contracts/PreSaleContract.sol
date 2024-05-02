// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PreSaleContract is Ownable {
    IERC20 public usdtToken; // USDT token contract
    IERC20 public preSaleToken; // preSale token contract

    uint256 public startTimestamp; // Start time of the funding (UNIX timestamp)
    uint256 public endTimestamp; // End time of the funding (UNIX timestamp)
    uint256 public goalUsdt; // Goal in USDT

    bool public fundingComplete = false; // Flag indicating the funding is complete
    bool public tokensDeposited = false; // Flag indicating the preSale tokens are deposited
    uint256 public totalUsdtCollected = 0; 
    mapping(address => uint256) public contributions; // Mapping of user contributions

    constructor(
        address _usdtToken,
        address _preSaleToken,
        uint256 _goalUsdt,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) Ownable(msg.sender) {
        require(_startTimestamp < _endTimestamp, "Start time must be before end time");
        require(_goalUsdt > 0, "Goal must be more than 0");

        usdtToken = IERC20(_usdtToken);
        preSaleToken = IERC20(_preSaleToken);
        goalUsdt = _goalUsdt;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
    }

    // Function to contribute USDT to the funding
    function contribute(uint256 usdtAmount) public {
        require(block.timestamp >= startTimestamp && block.timestamp <= endTimestamp, "Funding is not active");
        require(tokensDeposited, "preSale tokens must be deposited first");
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "Failed to transfer USDT");

        contributions[msg.sender] += usdtAmount;
        totalUsdtCollected += usdtAmount;
    }
    
    // Function to withdraw funds to the owner
    function withdrawFunds() public onlyOwner {
        require(fundingComplete == false, "Funds already withdrawn");
        require(block.timestamp > endTimestamp || totalUsdtCollected >= goalUsdt, "Funding period is not over or goal not reached");
        require(tokensDeposited, "preSale tokens must be deposited first");

        fundingComplete = true;
        require(usdtToken.transfer(owner(), totalUsdtCollected), "Failed to transfer USDT to owner");
    }

    // Function to claim tokens for the contribution
    function claimTokens() public {
    require(fundingComplete, "Funding not complete");
    require(contributions[msg.sender] > 0, "No contribution made");

    uint256 totalPreSaleTokens = preSaleToken.balanceOf(address(this));

    uint256 tokensToClaim = (contributions[msg.sender] / totalUsdtCollected) * totalPreSaleTokens;

    contributions[msg.sender] = 0; 
    require(preSaleToken.transfer(msg.sender, tokensToClaim), "Failed to transfer tokens");
    }

    // Function to deposit preSale tokens to the contract
    function depositPreSaleTokens(uint256 tokenAmount) public onlyOwner {
        require(preSaleToken.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        tokensDeposited = true;
    }

    // Function to get the USDT balance of the contract
    function getUsdtBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    // Function to get the presale token balance of the contract
    function getpreSaleTokenBalance() public view returns (uint256) {
        return preSaleToken.balanceOf(address(this));
    }
}
