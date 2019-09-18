//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 社区治理

pragma solidity >= 0.5.0;

import "./authority.sol";

contract duckgovtoken {
    function transfer(address to, uint amount) public;       //FOR不是标准的ERC20 Token.
    function transferFrom(address from, address to, uint amount) public returns (bool);
}

contract duckioutoken {
    function burn(address who, uint256 amount) public;
    function mint(address who, uint256 amount) public;
}

contract approval is authority {
    /** 投票 */
    mapping(address=>address) public votes;     //投票记录, account => proposal
    mapping(address=>uint256) public approvals; //提案的权重, proposal => weight
    mapping(address=>uint256) public deposits;  //锁定治理代币的数量, account => amount
    duckgovtoken public gov;    // voting token that gets locked up
    duckioutoken public iou;    // non-voting representation of a token, for e.g. secondary voting mechanisms
    address  public win;    //
    
    constructor(address g, address i) public {
        gov = duckgovtoken(g);
        iou = duckioutoken(i);
    }

    //锁定FOR, 如果没有投过票,则仅累加被锁定的FOR的数量, 如果之前已投过票, 则锁定的同时再为上次的投票加权.
    function lock(uint amount) public {
        gov.transferFrom(msg.sender, address(this), amount);
        iou.mint(msg.sender, amount);
        deposits[msg.sender] += amount;
        //如果是在投票之前锁定, @votes[msg.sender] 为空, 所以不会增加权重.
        //如果是在投票之后锁定, @votes[msg.sender] 为上次的投票后累计的权重, 本次再锁定意味着再次为之前投过的票加权.
        incweight(votes[msg.sender], amount);
    }

    //释放 @amount 数量的被锁定的FOR, 同时减少被投过的票的权重.
    function free(uint amount) public {
        require(deposits[msg.sender] >= amount);
        deposits[msg.sender] -= amount;
        decweight(votes[msg.sender], amount);
        iou.burn(msg.sender, amount);
        gov.transfer(msg.sender, amount);
    }

    //投票为指定的提案 @proposal;
    function vote(address proposal) public {
        uint weight = deposits[msg.sender];
        //投票前先减去之前的投票权重(如果有);
        decweight(votes[msg.sender], weight);
        votes[msg.sender] = proposal;
        incweight(votes[msg.sender], weight);
    }

    //将 @who 设置为管理员
    function award(address who) public {
        require(approvals[who] > approvals[win]);
        win = who;
    }

    //为提案 @proposal 增加 @weight 权值
    function incweight(address proposal, uint256 weight) internal {
        if(proposal != address(0)) {
            approvals[proposal] += weight;
        }
    }
    
    //为提案 @proposal 减去 @weight 权值
    function decweight(address proposal, uint weight) internal {
        require(approvals[proposal] >= weight);
        if(proposal != address(0)) {
            approvals[proposal] -= weight;
        }
    }

    function accessible(address who, address code, bytes4 sig) public view returns (bool) {
        code; sig;
        return who == win;
    }
}
