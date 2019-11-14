//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 交易转发

pragma solidity >= 0.5.0;

contract IDebtor {
    function deposit(address who, uint256 amount) public;
    function hol(address who) public view returns(uint256);
}

contract ICollateral {
    function deposit(address who, uint256 amount) public payable;
    function withdraw(address payable who, uint256 amount) public;
    
    function move(address from, address to, uint256 amount) public;
    function tok() public view returns(address);
    function dor() public view returns(address);

    function debt(address who) public view returns(uint256);

    function borrow(address who, uint256 s, uint256 c) public;
    function payback(address who, uint256 s, uint256 c) public;

    function evaluatepaybacks(address who, uint256 s) public view returns(uint256);
}

contract IToken {
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address who, uint256 amount) public returns (bool);
}

contract Forward {
    function deposit(address payable dist, uint256 amount) public payable {
        ICollateral c = ICollateral(dist);
        address tok = c.tok();
        if(tok == address(0)) {
            require(amount == msg.value, "amount mismatch with msg.value");
            c.deposit.value(msg.value)(address(this), amount);
            c.move(address(this), msg.sender, amount);
            c.borrow(msg.sender, 0, amount);
            return;
        }
        require(IToken(tok).transferFrom(msg.sender, address(this), amount));
        IToken(tok).approve(dist, amount);
        c.deposit(address(this), amount);
        c.move(address(this), msg.sender, amount);
        c.borrow(msg.sender, 0, amount);
    }

    function withdraw(address dist, uint256 amount) public payable {
        ICollateral c = ICollateral(dist);
        c.payback(msg.sender, 0, amount);
        c.withdraw(msg.sender, amount);
    }

    function depositborrow(address payable dist, uint256 c, uint256 s) public payable {
        deposit(dist, c);
        ICollateral(dist).borrow(msg.sender, s, 0);
    }

    function payback(address dist, uint256 amount) public {
        ICollateral c = ICollateral(dist);
        IDebtor d = IDebtor(c.dor());
        
        uint256 amount2 = min(amount, c.debt(msg.sender));
        uint256 hol = d.hol(msg.sender);
        if(hol < amount2) {
            uint256 diff = usub(amount2, hol);
            d.deposit(msg.sender, diff);
        }
        uint256 s = c.evaluatepaybacks(msg.sender, amount2);
        c.payback(msg.sender, s, 0);
    }

    function min(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = (x <= y ? x : y);
    }

    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }
}