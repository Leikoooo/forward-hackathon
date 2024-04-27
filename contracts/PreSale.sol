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
    event GetGoal(uint256 goal);
    event GetSumDeposit(uint256 amount);
    event GetAmountDeposit(uint256 amount);


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
        bool campaignIsOver;
    }

    IERC20 public immutable depositUSDT;
    IERC20 public immutable preSaleToken;

    mapping(address => uint256) public pledgedAmount;
    Campaign public campaignData;

    constructor(address _preSaleToken, uint256 _goal, uint32 _startAt, uint32 _endAt) {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        depositUSDT = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        preSaleToken = IERC20(_preSaleToken);
        campaignData = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            campaignIsOver: false
        });
    }


    function cancel() external {
        require(campaingData.creator == msg.sender, "not creator");
        require(block.timestamp < campaingData.startAt, "started");

        emit Cancel();
    }

    function pledge(uint256 _amount) external {
        require(block.timestamp >= campaingData.startAt, "not started");
        require(block.timestamp <= campaingData.endAt, "ended");

        campaingData.pledged += _amount;
        pledgedAmount[msg.sender] += _amount;
        depositUSDT.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(msg.sender, _amount);
    }

    function unpledge(uint256 _amount) external {
        require(block.timestamp <= campaingData.endAt, "ended");

        campaingData.pledged -= _amount;
        pledgedAmount[msg.sender] -= _amount;
        depositUSDT.transfer(msg.sender, _amount);

        emit Unpledge(msg.sender, _amount);
    }

    function claim() external {

        require(campaingData.creator == msg.sender, "not creator");
        require(block.timestamp > campaingData.endAt, "not ended");
        require(campaingData.pledged >= campaingData.goal, "pledged < goal");
        require(!campaingData.claimed, "claimed");

        campaingData.claimed = true;
        depositUSDT.transfer(campaingData.creator, campaingData.pledged);

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

    function getGoal() external {
        emit GetGoal(campaingData.goal);
    }

    function getSumDeposit() external {
        emit GetSumDeposit(campaingData.pledged);
    }

    function getAmountDeposit() external {
        emit GetAmountDeposit(pledgedAmount[msg.sender]);
    }
}
