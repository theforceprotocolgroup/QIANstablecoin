
pragma solidity >= 0.5.0;

import "./arith.sol";


contract Transferable {
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
}

contract virtualwallet is arith {
    
}
