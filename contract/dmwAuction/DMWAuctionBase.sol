pragma solidity ^0.4.25;
import "./Ownable.sol";
import "./seroInterface.sol";
import "./utils.sol";
import "./SafeMath.sol";



interface IDMWCoin {
    
    function burned() external payable returns(bool);
    
}

interface IDMW {
    
    function contractCurentMarketValue (uint256 _contractIndex) external view returns(uint256);
    
}

contract DMWAuctionBase is Ownable,SeroInterface {
    
    address public dmwAddress;
    
    address public dmwCoinAddress;
    
    using utils for *;
    
    using SafeMath for uint256;
    
    struct Auction {
        address seller;
        string mintCoin;
        string backedCoin;
        uint256 backedValue;
        uint256 startingPrice;
        uint256 currentPrice;
        uint64 duration;
        uint256 cut;
        uint64 startedAt;
        bool invalid;
    }
    
    uint64 interval = 10*60;
    
    uint64 public timer = uint64(now);
    
    uint64 lastActiveRequestTime = uint64(now);
    
    mapping(bytes32=>uint256) cutRates;
    
    mapping(bytes32=>uint64) durations;
    
    mapping(bytes32 =>uint256) discounts;
    
    
    uint256[] public autionContracts;
    
    mapping (uint256 => Auction) public contractIndexToAuction;
    
    mapping(bytes32 => uint256[]) keyAuctionContracts;
    
    
    event AuctionCreated(uint256 contractIndex, uint256 startingPrice, uint64 duration);
    
    event SetAuctionPrice(uint256 contractIndex, uint256 startingPrice, uint64 duration);
    
    event AuctionSuccessful(uint256 contractIndex, uint256 totalPrice, address winner);
    
    event Bid(uint256 contractIndex ,uint256 price, address bider);
    
    function updateActiveRequests() public {
        uint64 _now = uint64(now);
        if (_now-lastActiveRequestTime>interval){
            lastActiveRequestTime = _now;
            timer = timer + uint64(interval);
        }
    }
    
    function setInterval(uint64 _interval) public onlyOwner {
        interval = _interval;
    }
    
    
    
    function setDuration(string mintCoin,uint64 duration) public onlyOwner {
        
        require(duration >= interval ,"duration is nil");
        
        durations[mintCoin.genBytes32()]=duration;
        
    }
    
    function getDuration(string mintCoin) public view returns(uint64){
        
        uint64 _d = durations[mintCoin.genBytes32()];
        
        if (_d == 0){
            
            return 3 * interval;
        }
        return _d;
    }
    
    function setCutRate(string mintCoin,uint256 cutRate) public onlyOwner {
        
        require(cutRate >0 && cutRate <= 100,"invalid cut");
        
        cutRates[mintCoin.genBytes32()]= cutRate;
    }
    
    function getCutRate(string mintCoin) public view returns(uint256){
        uint256 c = cutRates[mintCoin.genBytes32()];
        
        if (c==0) {
            
            return 5;
        }
        return c ;
    }
    
    function setDiscount(string mintCoin,uint256 _discount) public onlyOwner{
        
        require(_discount >0 && _discount <=100);
        
        discounts[mintCoin.genBytes32()] = _discount;
    }
    
    function getDiscount(string mintCoin) public view returns(uint256) {
        
        uint256 d = discounts[mintCoin.genBytes32()];
        
        if (d == 0){
            
            return 50;
        }
        return d;
        
    }
    
    function _ownsBid(address _claimant, uint256 _contractIndex) internal view returns (bool) {
        
        return (contractIndexToAuction[_contractIndex].seller == _claimant);
    }
    
    
    function _addAuction(uint256 _contractIndex,
        string _mintCoin,
        string _backedCoin,
        uint256 _backedValue,
        uint256 _marketValue
    ) internal {
        
        uint64 _duration = getDuration(_mintCoin);
        
        require(_duration > 0,"_duration is zero");
        
        uint256 _discount = getDiscount(_mintCoin);
        
        uint256 _startingPrice = _marketValue.mul(_discount).div(100);
        
        uint256 _cut = _marketValue.mul(getCutRate(_mintCoin)).div(100);
        
        bytes32 _key = utils.genStableCoinKey(_backedCoin,_mintCoin);
        
        updateActiveRequests();
        
        require(contractIndexToAuction[_contractIndex].startingPrice ==0 ,"has exists");
        
        require(contractIndexToAuction[_contractIndex].startedAt ==0 ,"has exists");
        
        Auction memory _auction = Auction(
            address(0),
            _mintCoin,
            _backedCoin,
            _backedValue,
            _startingPrice,
            _startingPrice,
            _duration,
            _cut,
            timer,
            false
        );
        
        autionContracts.push(_contractIndex);
        
        keyAuctionContracts[_key].push(_contractIndex);
        
        
        contractIndexToAuction[_contractIndex]=_auction;
        
        emit AuctionCreated(
            uint256(_contractIndex),
            uint256(_auction.startingPrice),
            _auction.duration
        );
    }
    
    
    function _bid(
        address _claimant,
        uint256 _contractIndex,
        string _currency,
        uint256 _bidAmount)
    internal returns (uint256)
    {
        require(contractIndexToAuction[_contractIndex].startedAt > 0 ,"not exists");
        
        Auction storage auction = contractIndexToAuction[_contractIndex];
        
        require(utils.equals(auction.mintCoin,_currency),"invalid currency");
        
        require(_isOnAuction(auction),"has close");
        
        address _prevSeller = auction.seller;
        
        uint256 _currentBidPrice = auction.currentPrice;
        
        require(_isValidPrice(_currentBidPrice,_bidAmount,auction.cut),"invalid bid price");
        
        auction.seller= _claimant;
        
        auction.currentPrice = _bidAmount;

        if (_prevSeller !=address(0)){
            
            require(sero_send_token(_prevSeller,auction.mintCoin,_currentBidPrice),"send to seller failed");
        }
        
        emit Bid(_contractIndex, _bidAmount, _claimant);
        
        
        return _bidAmount;
    }
    
    
    function unSold(uint256 _contractIndex) public view returns(bool){
        
        Auction memory auction = contractIndexToAuction[_contractIndex];
        
        require(auction.startedAt >0,"not exists");
        
        return( auction.seller == address(0) && timer > auction.startedAt + auction.duration);
    }
    
    function _setAuctionPrice(uint256 _contractIndex) internal {
        
        require(dmwAddress!= address(0),"not set dmw Address");
        
        Auction storage auction = contractIndexToAuction[_contractIndex];
        
        require(auction.startedAt > 0,"not exitst");
        
        uint64 _duration = getDuration(auction.mintCoin);
        
        uint256 _discount = getDuration(auction.mintCoin);
        
        uint256 _marketValue = IDMW(dmwAddress).contractCurentMarketValue(_contractIndex);
        
        uint256 _startingPrice = _marketValue.mul(_discount).div(100);
        
        uint256 _cut = _marketValue.mul(getCutRate(auction.mintCoin)).div(100);
        
        require(auction.seller == address(0),"has bid");
        
        auction.startingPrice = _startingPrice;
        
        auction.cut = _cut;
        
        auction.currentPrice = _startingPrice;
        
        auction.duration = _duration;
        
        updateActiveRequests();
        
        auction.startedAt = timer;
        
        emit SetAuctionPrice(_contractIndex,_startingPrice,auction.duration);
    }
    
    function _withDraw(address _claimant,uint256 _contractIndex) internal {
        
        require(dmwCoinAddress!=address(0),"not set  dmwCoin");
        
        Auction storage _auction = contractIndexToAuction[_contractIndex];
        
        require(_auction.startedAt >0,"not exitst");
        
        require(!_isOnAuction(_auction),"is on auction");
        
        require(_ownsBid(_claimant,_contractIndex),"not owns");
        
        require(!_auction.invalid,"has closed");
        
        _auction.invalid =true;
        
        sero_setCallTokenValue(_auction.mintCoin,_auction.currentPrice);
        
        IDMWCoin(dmwCoinAddress).burned();
        
        require(sero_send_token(_claimant,_auction.backedCoin,_auction.backedValue),"send to seller failed");
        
        emit AuctionSuccessful(_contractIndex,_auction.currentPrice,_auction.seller);
    }
    
    function _isOnAuction(Auction memory _auction) internal view returns (bool) {
        
        uint64 endAt = _auction.startedAt + _auction.duration;
        
        return (_auction.startedAt > 0 && timer < endAt);
    }
    
    function _isValidPrice(uint _currentPrice,uint256 _bidPrice,uint256 _cut) internal pure returns(bool){
        
        require(_bidPrice > _currentPrice,"invalid bidPrice");
        
        require(_cut >0,"not set cut");
        
        uint256 _step = _bidPrice.sub(_currentPrice).div(_cut);
        
        require(_step>0,"not valid step");
        
        return _bidPrice == _currentPrice.add(_step.mul(_cut));
    }
    
    function auctionInfo(uint256 _contractIndex) public view returns(uint256 _currentPrice,uint256 _cut) {
        
        _currentPrice = contractIndexToAuction[_contractIndex].currentPrice;
        
        _cut = contractIndexToAuction[_contractIndex].cut;
        
        return;
    }
    
    function auctionToString(address _claimant ,uint256 _contractIndex) public view returns(string result){
        
        Auction memory auction =  contractIndexToAuction[_contractIndex];
        
        result = "{".toSlice().concat(utils._genKey("backedValue"));
        result = result.toSlice().concat(utils._genUintStringValue(auction.backedValue));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("contractIndex"));
        result = result.toSlice().concat(utils._genUintValue(_contractIndex));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("backedCoin"));
        result = result.toSlice().concat(utils._genStringValue(auction.backedCoin));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("mintCoin"));
        result = result.toSlice().concat(utils._genStringValue(auction.mintCoin));
        result = result.toSlice().concat(",".toSlice());
        
        (uint256 _currentPrice,uint256 _cut) = auctionInfo(_contractIndex);
        
        result = result.toSlice().concat(utils._genKey("currentPrice"));
        result = result.toSlice().concat(utils._genUintStringValue(_currentPrice));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("cut"));
        result = result.toSlice().concat(utils._genUintStringValue(_cut));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("startedAt"));
        result = result.toSlice().concat(utils._genUintValue(uint256(auction.startedAt)));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("timer"));
        result = result.toSlice().concat(utils._genUintValue(uint256(timer)));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("owns"));
        if (_ownsBid(_claimant,_contractIndex)){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("unSold"));
        if (unSold(_contractIndex)){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        result = result.toSlice().concat(",".toSlice());
        
        
        result = result.toSlice().concat(utils._genKey("onAuction"));
        if (_isOnAuction(auction)){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        
        
        result = result.toSlice().concat(",".toSlice());
        
        
        result = result.toSlice().concat(utils._genKey("invalid"));
        if (auction.invalid){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        
        
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("duration"));
        result = result.toSlice().concat(utils._genUintValue(auction.duration));
        result = result.toSlice().concat("}".toSlice());
    }
    
    
    function _getPageContracts(
        uint256[] _contractIndexs,
        address _claimant ,
        uint256 offset,
        uint256 pageSize)
    internal view returns(
        string result
    ){
        uint256 size = _contractIndexs.length;
        
        result = "{".toSlice().concat(utils._genKey("total"));
        
        result = result.toSlice().concat(utils._genUintValue(size));
        
        if (size>0 && size > offset) {
            
            uint256 start = size -offset-1;
            
            uint256 end = offset + pageSize;
            
            if (end > size) {
                
                end = size;
            }
            end = size - end;
            
            uint256 dataSize = start-end+1;
            
            string[] memory datas = new string[](dataSize);
            
            uint256 index = 0;
            
            while (true){
                
                datas[index] = auctionToString(_claimant,_contractIndexs[start]);
                
                index++;
                
                if (start == end){
                    break;
                }
                start--;
            }
            string memory data = utils.joinArrayString(datas);
            
            result = result.toSlice().concat(",".toSlice());
            
            result = result.toSlice().concat(utils._genKey("data"));
            
            result = result.toSlice().concat(data.toSlice());
        }
        result = result.toSlice().concat("}".toSlice());
        
        return ;
    }
    
    function pageAuctions(uint256 offset,uint256 pageSize)external view returns(string result){
        return _getPageContracts(autionContracts,msg.sender,offset,pageSize);
    }
    
    function pageQueryAuctions(string backedCoin,string mintCoin,uint256 offset,uint256 pageSize) external view returns(string result){
        if (backedCoin.equals("") || mintCoin.equals("")) {
            return _getPageContracts(autionContracts,msg.sender,offset,pageSize);
        }else {
            bytes32 _key = utils.genStableCoinKey(backedCoin,mintCoin);
            return _getPageContracts(keyAuctionContracts[_key],msg.sender,offset,pageSize);
        }
    }
    
}
