//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Standard ERC20 implement
//原力协议稳定币系统 - 标准ERC20实现

/**  
    Standard ERC20
    https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */

pragma solidity >= 0.5.0;

contract Stderc20 {
    string  public name;
    string  public symbol;
    uint8   public decimals;
    uint256 public totalSupply;                                         
    mapping (address => uint)                      public balanceOf;    
    mapping (address => mapping (address => uint)) public allowance;
    
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);

    constructor(string memory n, string memory s, uint8 d, uint256 t) public {
        name        = n;
        symbol      = s;
        decimals    = d;
        totalSupply = t;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address who, uint amount) public returns (bool) {
        return transferFrom(msg.sender, who, amount);
    }

    function transferFrom(address from, address to, uint amount) public returns (bool)
    {
        require(balanceOf[from] >= amount);
        if (from != msg.sender) {
            require(allowance[from][msg.sender] >= amount);
            allowance[from][msg.sender] = usub(allowance[from][msg.sender], amount);
        }
        balanceOf[from] = usub(balanceOf[from], amount);
        balanceOf[to] = uadd(balanceOf[to], amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address who, uint amount) public returns (bool) {
        allowance[msg.sender][who] = amount;
        emit Approval(msg.sender, who, amount);
        return true;
    }

    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }

    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }
}