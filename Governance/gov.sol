pragma solidity >= 0.4.24;

//seth send "$MCD_GOV" 'setAuthority(address)' "$MCD_GOV_GUARD"
//seth send "$MCD_GOV_GUARD" 'permit(address,address,bytes32)' "$MCD_FLOP" "$MCD_GOV" "$(seth --to-bytes32 "$(seth sig 'mint(address,uint256)')")"
//seth send "$MCD_GOV_GUARD" 'permit(address,address,bytes32)' "$MCD_FLAP" "$MCD_GOV" "$(seth --to-bytes32 "$(seth sig 'burn(address,uint256)')")"

contract DSAuthority {
    function canCall(address src, address dst, bytes4 sig) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

     function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }