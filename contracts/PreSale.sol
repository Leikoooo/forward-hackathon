// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PreSale {
    // admins methods
    event Cancel();
    event Claim();
    event Refund(address indexed caller, uint256 amount);

    // users methods
    event Pledge(address indexed caller, uint256 amount);
    event Unpledge(address indexed caller, uint256 amount);

    struct Campaign {
        // Creator of campaign
        address creator;
        // Amount of tokens to raise
        uint256 goal;
        // Total amount pledged
        uint256 pledged;
        // Timestamp of start of campaign
        uint32 startAt;
        // Timestamp of end of campaign
        uint32 endAt;
        // True if campaign is over (goal completed or time is out)
        bool campaingIsOver;
    }

    // The coin in which we receive money
    IERC20 public immutable depositUSDT;

    // The address of the coin that will be distributed
    IERC20 public immutable preSaleToken;

    mapping(address => uint256) public pledgedAmount;
    Campaign public campaingData;

    constructor(address _preSaleToken, uint256 _goal, uint32 _startAt, uint32 _endAt) {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        depositUSDT = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        preSaleToken = IERC20(_preSaleToken);
        campaingData = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            campaingIsOver: false
        });
    }


    //function cancel() external {
    //    require(campaingData.creator == msg.sender, "not creator");
    //    require(block.timestamp < campaingData.startAt, "started");
    //
    //    emit Cancel();
    //}

    function pledge(uint256 _amount) external {
        require(block.timestamp >= campaingData.startAt, "not started");
        require(block.timestamp <= campaingData.endAt, "ended");
        require(!campaingData., "campaing completed");
        require(_amount > 0, "amount <= 0");

        // check if user has enough balance
        require(
            depositUSDT.balanceOf(msg.sender) >= _amount,
            "insufficient balance"
        );

        depositUSDT.transferFrom(msg.sender, address(this), _amount);
        campaingData.pledged += _amount;
        pledgedAmount[msg.sender] += _amount;

        if (campaingData.pledged >= campaingData.goal) {
            campaingData.claimed = true;
        }

        emit Pledge(msg.sender, _amount);
    }

    function unpledge(uint256 _amount) external {
        require(block.timestamp <= campaingData.endAt, "ended");
        require(!campaingData.claimed, "Already claimed");
        require(pledgedAmount[msg.sender] >= _amount, "insufficient balance");
        require(_amount > 0, "amount <= 0");

        campaingData.pledged -= _amount;
        pledgedAmount[msg.sender] -= _amount;
        depositUSDT.transfer(msg.sender, _amount);

        emit Unpledge(msg.sender, _amount);
    }

    function awardPreSaleToken() private {
        // award presale tokens to users who payed
    
    function claim() external onlyOwner{
        
        require((campaingData.pledged >= campaingData.goal || block.timestamp > campaingData.endAt), "presale not ended");

        campaingData.campaingIsOver = true;
        depositUSDT.transfer(campaingData.creator, campaingData.pledged);

        // refund tokens to users who payed
        for (uint256 i = 0; i < pledgedAmount.length(); i++) { 
            address userAddress = pledgedAmount.getKeyAtIndex(i);
            uint256 coeff = (campaingData.pledged / campaingData.goal) <= 1
                ? (campaingData.pledged / campaingData.goal)
                : 1;
            uint256 refundAmounts = pledgedAmount[userAddress] * coeff;

            pledgedAmount[userAddress] = 0;
            preSaleToken.transfer(userAddress, refundAmounts);
        }
    }

    function claim() external {
        require(campaingData.creator == msg.sender, "not creator");
        require((campaingData.pledged >= campaingData.goal || block.timestamp > campaingData.endAt), "presale not ended");

        campaingData.claimed = true;
        depositUSDT.transfer(campaingData.creator, campaingData.pledged);
        awardPreSaleToken(); // call private function to award presale tokens

        emit Claim();
    }

    function refund() external {
        require(block.timestamp > campaingData.endAt, "not ended");
        require(campaingData.pledged < campaingData.goal, "pledged >= goal");

        uint256 bal = pledgedAmount[msg.sender];
        pledgedAmount[msg.sender] = 0;
        depositUSDT.transfer(msg.sender, bal);

        emit Refund(msg.sender, bal);
    }

    function getGoal() external view returns (uint256) {
        return campaingData.goal;
    }

    function getSumDeposit() external view returns (uint256) {
        return campaingData.pledged;
    }

    function getUserDeposit() external view returns (uint256) {
        return pledgedAmount[msg.sender];
    }
}
