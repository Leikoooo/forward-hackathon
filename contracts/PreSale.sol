// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract PreSale {
    event Launch(
        address indexed creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );

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
        // True if goal was reached and creator has claimed the tokens.
        bool claimed;
    }

    IERC20 public immutable preSaleToken;
    // Mapping from campaign id => pledger => amount pledged
    mapping(address => uint256) public pledgedAmount;
    Campaign public campaingData;

    constructor(address _preSaleToken) {
        preSaleToken = IERC20(_preSaleToken);
    }

    function launch(uint256 _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        campaingData = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(msg.sender, _goal, _startAt, _endAt);
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
        preSaleToken.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(msg.sender, _amount);
    }

    function unpledge(uint256 _amount) external {
        require(block.timestamp <= campaingData.endAt, "ended");

        campaingData.pledged -= _amount;
        pledgedAmount[msg.sender] -= _amount;
        preSaleToken.transfer(msg.sender, _amount);

        emit Unpledge(msg.sender, _amount);
    }

    function claim() external {

        require(campaingData.creator == msg.sender, "not creator");
        require(block.timestamp > campaingData.endAt, "not ended");
        require(campaingData.pledged >= campaingData.goal, "pledged < goal");
        require(!campaingData.claimed, "claimed");

        campaingData.claimed = true;
        preSaleToken.transfer(campaingData.creator, campaingData.pledged);

        emit Claim();
    }

    function refund() external {

        require(block.timestamp > campaingData.endAt, "not ended");
        require(campaingData.pledged < campaingData.goal, "pledged >= goal");

        uint256 bal = pledgedAmount[msg.sender];
        pledgedAmount[msg.sender] = 0;
        preSaleToken.transfer(msg.sender, bal);

        emit Refund(msg.sender, bal);
    }

    function getGoal() external {
        emit GetGoal(campaingData.goal);
    }

    function getSumDeposit() external {
        emit GetSumDeposit(campaingData.pledged);
    }
}
