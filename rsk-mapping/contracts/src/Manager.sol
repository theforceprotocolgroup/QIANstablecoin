pragma solidity >=0.5.0;

contract BridgeLike {
    function unlock(address _receiver, uint256 _amount) public returns(bool);
}

contract Manager {
    address                                         owner;

    mapping(bytes32 => mapping(address => uint))    votes;          //voteId => voter => nvotes;
    mapping(bytes32 => uint)                        nvotes;         //number of votes.
    mapping(bytes32 => bool)                        proce;           //voteId processed

    mapping(address => bool) public                 federators;     //federators
    uint public                                     nfederators;    //number of federators

    BridgeLike public                               bridge;
    
    event Vote(address voter, bytes32 txhash, address receiver, uint amount);

    modifier ownable() {
        require(msg.sender == owner, "require-owner");
        _;
    }

    modifier federatorable() {
        require(federators[msg.sender], "require-federator");
        _;
    }

    constructor(address[] memory who) public {
        nfederators = who.length;
        for (uint k = 0; k < nfederators; k++) {
            federators[who[k]] = true;
        }
        owner = msg.sender;
    }

    function vote(bytes32 txhash, address receiver, uint amount) public federatorable
    {
        bytes32 voteId = generateVoteId(txhash, receiver, amount);
        
        if (proce[voteId]) {
            return;
        }

        if(votes[voteId][msg.sender] != 0) {
            return;
        }

        nvotes[voteId] += 1;
        votes[voteId][msg.sender] = nvotes[voteId];
        
        emit Vote(msg.sender, txhash, receiver, amount);

        if (nvotes[voteId] < nfederators / 2 + 1) {
            return;
        }
            
        if (bridge.unlock(receiver, amount)) {
            proce[voteId] = true;
        }
    }

    function processed(bytes32 txhash, address receiver, uint amount)
        public view returns(bool)
    {
        bytes32 voteId = generateVoteId(txhash, receiver, amount);
        return proce[voteId];
    }
    
    function generateVoteId(bytes32 txhash, address receiver, uint amount)
        public pure returns(bytes32)
    {
        return keccak256(abi.encodePacked(txhash, receiver, amount));
    }
     
    function setBridge(address who) public ownable {
        require(who != address(0), "bad-bridge-address");
        bridge = BridgeLike(who);
    }

    function addFederator(address who) public ownable
    {
        require(who != address(0), "bad-federator-address");
        if (federators[who]){
            return;
        }
        ++nfederators;
        federators[who] = true;
    }

    function delFederator(address who) public ownable
    {
         if (federators[who]) {
             --nfederators;
            federators[who] = false;
         }
    }
}