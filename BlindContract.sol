pragma solidity >=0.7.0 <0.9.0;

contract bidForNFT {
    address payable public beneficiary  ;

    struct bidAndHash {
        bytes32 hashedBid ;
        uint bid;
    }

    uint public biddingEnd ;
    uint public revealEnd  ;
    bool public ended ; 

    address public highestBidder ;
    uint    public highestBid ; 

    mapping(address => bidAndHash[]) public bids ;
    mapping(address => uint) pendingReturns ;

    event bidDone (address bidder , uint bidd);
    event auctionEnd (address winner , uint _highestBid);

    modifier onlyBefore(_time) {
        require (block.timestamp < _time);
        _;
    }

    modifier onlyAfter(_time) {
        require (block.timestamp > _time);
        _;
    }

    constructor (uint _biddingTime , uint _revealTime , address payable _beneficiary){
        beneficiary = _beneficiary ;
        biddingEnd = block.timestamp + _biddingTime ;
        revealEnd = biddingEnd + _revealTime ;
    }

    function generateHashedBid( uint _bid , bool fake ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(value,fake));
    }

    function bid(bytes32 _blindedBid) public payable onlyBefore (biddingEnd) {
        bids[msg.sender].push(Bid({
            hashedBid : _blindedBid ,
            bid       : msg.value 
        }));
    }

    function auctionEnded () public payable onlyBefore(revealEnd) {
        require (!ended);
        emit auctionEnd(highestBidder ,highestBid);
        ended = true ;
        beneficiary.transfer(highestBid);

    }
    function withdraw () public{
        uint amount = pendingReturns[msg.sender];
        if(amount > 0 ){
            pendingReturns[msg.sender] = 0 ;
            payable(msg.sender).transfer(amount);
        }
    }
    function placeBid(address _bidder , uint _amount) internal returns (bool success) {
        if(_amount <= highestBid){
            return false;
        }
        if(highestBidder != address(0)){
            pendingReturns[_highestBidder] += highestBid ; 
        }
        highestBid = _amount ;
        highestBidder = _bidder

    }
}