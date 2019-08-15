pragma solidity >=0.5.0;

contract Token {
    uint8   public decimals = 18;
    string  public name = "The Force Token";
    string  public symbol = "RFOR";

    address owner;
    address public bridge;

    modifier ownable {
        require(msg.sender == owner, "require-owner");
        _;
    }

    uint256 public totalSupply;
    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "math-sub-underflow");
    }

    constructor() public {
        owner = msg.sender;
    }

    function transfer(address dst, uint value) public returns (bool) {
        return transferFrom(msg.sender, dst, value);
    }

    function mint(address who, uint value) internal returns (bool) {
        balanceOf[who] = add(balanceOf[who], value);
        totalSupply    = add(totalSupply, value);
        emit Transfer(address(0), who, value);
        return true;
    }

    function burn(address usr, uint value) internal returns (bool) {
        require(balanceOf[usr] >= value, "insufficient-balance");
        
        if (usr != msg.sender) {
            require(allowance[usr][msg.sender] >= value, "insufficient-allowance");
            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], value);
        }
        balanceOf[usr] = sub(balanceOf[usr], value);
        totalSupply    = sub(totalSupply, value);
        emit Transfer(usr, address(0), value);
        return true;
    }

    function transferFrom(address src, address dst, uint value) public returns (bool)
    {
        if(src == bridge) {
            return mint(dst, value);
        }

        if(dst == bridge) {
            return burn(src, value);
        }

        require(balanceOf[src] >= value, "insufficient-balance");
        
        if (src != msg.sender) {
            require(allowance[src][msg.sender] >= value, "insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], value);
        }
        balanceOf[src] = sub(balanceOf[src], value);
        balanceOf[dst] = add(balanceOf[dst], value);
        emit Transfer(src, dst, value);
        return true;
    }

    function approve(address usr, uint value) public returns (bool) {
        allowance[msg.sender][usr] = value;
        emit Approval(msg.sender, usr, value);
        return true;
    }

    function setBridge(address who) public ownable {
        require(who != address(0), "bad-bridge-address");

        if(bridge != who) {
            bridge = who;
        }
    }
}
