pragma solidity ^0.4.17;
import "./SafeMath.sol";
import "./seroInterface.sol";
import "./utils.sol";
import "./stakingBase.sol";



contract POFIDStaking is StakingBase,SeroInterface {
    
    event Staking(address _claimant,uint256 shareIndex);
    
    event WithDrawStaking(address _claimant,uint256 shareIndex);
    
    using itMaps for *;
    
    bool public paused = false;
    
    string private _name = "POFIDStaking";
    
    string private _stakingSymbol= "PFID";
    
    uint256 constant oneYear =365*24*60*60 ; //test 60*60, prod 365*24*60*60
    
    uint256 public stakingPoolBalance;
    
    uint256 public minStakingValue =100 *10**uint256(18);
    
    uint256 public fee = 0;
    
    uint256 public feeBalance;
    
    struct FeeRate {
        
        string feeCoin;
        
        uint256  numerator;
        
        uint256  denominator;
    }
    
    FeeRate public feeRate;
    
    struct Phase {
        uint256 supply;
        uint256 balance;
    }
    
    mapping (uint256=>Phase) phases;
    
    mapping(address=>itMaps.itMapStringUint)  sscBalance;
    
    
    
    function setPaused(bool status) public onlyOwner {
        paused = status;
    }
    
    function setFeeRate(string _feeCoin,uint256 _numerator,uint256 _denominator) public onlyOwner{
        
        feeRate.numerator = _numerator;
        
        feeRate.denominator = _denominator;
        
        feeRate.feeCoin = _feeCoin;
        
        require(sero_setToketRate(_feeCoin, _numerator, _denominator),"set toketRate failed");
    }
    
    function getFeeRate() public view returns(string feeCoin,uint256 numerator,uint256 denominator){
        
        if (feeRate.numerator == 0 || feeRate.denominator == 0){
            
            feeCoin = "SERO";
            
            numerator = 1;
            
            denominator = 1;
            
        }else {
            
            feeCoin = feeRate.feeCoin;
            
            numerator = feeRate.numerator;
            
            denominator = feeRate.denominator;
        }
        
        return;
    }
    
    
    /**
   * @return the name of the stableCoin.
   */
    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
     * @return the symbol of the stableCoin.
     */
    function symbol() public pure returns (string memory) {
        return "";
    }
    
    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }
    
    
    
    function setMinStakingValue(uint256 amount) public onlyOwner {
        minStakingValue = amount;
    }
    
    function getPhaseBalance(uint256 index) public view returns(uint256 balance) {
        return phases[index].balance;
    }
    
    function getInterest (uint64 _stakingDays) public view returns (uint256 _interest){
        uint256 seq = getPhaseSeq();
        
        uint256 _baseIntereset = 0;
        
        if (_stakingDays == 30){
            _baseIntereset = base30Interest();
        }else if (_stakingDays == 60){
            _baseIntereset = base60Interest();
        } else if (_stakingDays == 90){
            _baseIntereset = base90Interest();
        }else {
            require(false,"invalid stakingDays");
        }
        uint256 e = seq.sub(1);
        
        require(e>=0,"invalid params");
        
        _interest = _baseIntereset.mul(uint256(90**e)).div(uint256(100**e));
        
        return;
    }
    
    function getInterstAmount(uint256 principal,uint256 interest) public view returns(uint256){
        
        return principal.mul(interest).div(10**interestDecimals());
    }
    
    function getPhaseSeq() public view returns(uint256 seq){
        
        require(startStakingTime > 0 ,"not start");
        
        return uint256(uint64(now)-startStakingTime).div(oneYear).add(1);
    }
    
    
    function topUp(uint256 seq) public payable {
        
        uint256 _seq = getPhaseSeq();
        
        require(seq >= _seq,"invalid params");
        
        string memory _currency = sero_msg_currency();
        
        require(utils.equals(_currency,_stakingSymbol),"invalid currency");
        
        phases[seq].supply =  phases[seq].supply.add(msg.value);
        
        phases[seq].balance =  phases[seq].balance.add(msg.value);
        
    }
    
    function _withDrawSSC(Share storage _share) internal {
        
        if (_share.endSscIndex == 0 && _share.startSscIndex<SSCS.length) {
            
            for(uint256 i = _share.startSscIndex;i< SSCS.length;i++ ){
                
                SSC storage ssc = SSCS[i];
                
                if (getBaseTime(_share.endTime) > getBaseTime(ssc.timestamp)){
                    
                    uint256 _coinAge = _share.value.mul(uint256(_share.stakingDays));
                    
                    uint256 _sscValue = ssc.amount.mul(_coinAge).div(ssc.coinAge);
                    
                    if (_coinAge <= ssc.coinAge && _sscValue <= ssc.amount){
                        
                        ssc.coinAge = ssc.coinAge.sub(_coinAge);
                        
                        ssc.amount = ssc.amount.sub(_sscValue);
                        
                        sscBalance[_share.owner].upSert(ssc.symbol,_sscValue);
                        
                        _share.endSscIndex= i;
                    }
                    
                }else {
                    
                    break;
                    
                }
                
            }
        }
    }
    
    function _calShare(Share storage _share) internal returns(uint256 _pi)  {
        
        Phase storage phase = phases[_share.seq];
        
        uint256 _interest = getInterstAmount(_share.value,_share.interest);
        
        phase.balance = phase.balance.sub(_interest);
        
        uint256 _fee = _interest.mul(_share.fee).div(100);
        
        feeBalance =feeBalance.add(_fee);
        
        _interest = _interest.sub(_fee);
        
        _pi = _share.value.add(_interest);
        
        return;
        
    }
    
    function _withDrawShare(address _claimant,uint256 _shareIndex) internal  returns(uint256 pi){
        
        require(_shareIndex < shares.length,"invalid index");
        
        uint64 _now = uint64(now);
        
        Share storage share= shares[_shareIndex];
        
        require (_now > share.endTime,"staking");
        
        require(share.valid,"share end");
        
        share.valid = false;
        
        require(share.owner == _claimant,"not owns");
        
        share.withDrawTime = _now;
        
        stakingPoolBalance = stakingPoolBalance.sub(share.value);
        
        _withDrawSSC(share);
        
        pi = _calShare(share);
        
        return;
    }
    
    function reStaking(uint256 shareIndex,uint64 _stakingDays) public approved returns(uint256 _index) {
        
        require(!paused,"paused");
        
        uint256 _pi = _withDrawShare(msg.sender,shareIndex);
        
        return _staking(msg.sender,_stakingDays,_pi);
        
    }
    
    function _staking(address _claimant,uint64 _stakingDays ,uint256 _stakingValue) internal returns(uint256 _shareIndex){
        
        require(_stakingDays==30||_stakingDays==60||_stakingDays==90,"staking days not support");
        
        uint64 _now = uint64(now);
        
        uint256  _seq = getPhaseSeq();
        
        require(_seq<=10,"staking closed");
        
        
        uint64 _endTime = _now +  _stakingDays * uint64(stakingUint);
        
        
        uint256 _interest = getInterest(_stakingDays);
        
        stakingPoolBalance = stakingPoolBalance.add(_stakingValue);
        
        Share memory share = Share({
            owner:_claimant,
            startTime:_now,
            endTime:_endTime,
            withDrawTime:0,
            stakingDays:_stakingDays,
            value:_stakingValue,
            seq:_seq,
            interest:_interest,
            fee:fee,
            valid:true,
            startSscIndex:SSCS.length,
            endSscIndex:0
            });
        
        _shareIndex = shares.push(share) -1;
        
        myShare[_claimant].push(_shareIndex);
        
        _addCoinAge(_endTime,_stakingValue.mul(uint256(_stakingDays)));
        
        emit Staking(_claimant,_shareIndex);
        
        return;
    }
    
    
    function staking(uint64 _stakingDays) public payable approved returns(uint256 _shareIndex){
        
        require(!paused,"paused");
        
        string memory currency = sero_msg_currency();
        
        require(utils.equals(currency,_stakingSymbol),"currency not right");
        
        require(msg.value >= minStakingValue,"less than minStakingValue");
        
        return _staking(msg.sender,_stakingDays,msg.value);
        
    }
    
    function withDrawFee()public {
        require(sero_send_token(owner,_stakingSymbol,feeBalance),"withDrawFee failed");
        feeBalance = 0;
    }
    
    
    function withDrawShare(uint256 shareIndex) public approved returns(bool) {
        
        uint256 _pi =  _withDrawShare(msg.sender,shareIndex);
        
        require(sero_send_token(msg.sender,_stakingSymbol,_pi),"send interest failed");
        
        return true;
        
        
    }
    
    function dmwMint() public payable onlyDmw returns(bool) {
        
        string memory _currency = sero_msg_currency();
        
        uint256 _value = msg.value;
        
        uint64 _now = uint64(now);
        
        uint256 _coinAge = _getTotalCoinAge(_now);
        
        if ( _coinAge == 0 ){
            
            sero_send_token(owner,_currency,_value);
            
        }else {
            SSC memory _last =  SSC({
                symbol:_currency,
                amount:_value,
                timestamp:_now,
                coinAge:_coinAge,
                totalAmount:_value,
                totalCoinAge:_coinAge
                });
            
            SSCS.push(_last);
            
            _addSSCName(_currency);
            
        }
        return true;
    }
    
    
    function myPageShare(uint256 offset,uint256 pageSize)public view returns(string result){
        uint256[] storage myShareIndexes = myShare[msg.sender];
        uint256 size = myShareIndexes.length;
        result = "{".toSlice().concat(utils._genKey("total"));
        result = result.toSlice().concat(utils._genUintValue(size));
        if (size>0) {
            require(size>offset,"invalid offset");
            uint256 start = size -offset-1;
            uint256 end = offset+pageSize;
            if (end >size) {
                end = size;
            }
            end = size - end;
            uint256 dataSize = start-end+1;
            string[] memory datas = new string[](dataSize);
            uint256 index = 0;
            
            while (true){
                datas[index] = _shareToString(shares[myShareIndexes[start]],myShareIndexes[start]);
                index++;
                if (start ==end){
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
    
    function getShareInfo(uint256 shareIndex) external view returns(uint256 principal, uint256 income,uint64 endTime){
        
        Share memory share= shares[shareIndex];
   
        uint256 _interest = getInterstAmount(share.value,share.interest);
        
        uint256 _fee = _interest.mul(share.fee).div(100);
        
        principal = share.value;
        
        income = _interest.sub(_fee);
        
        endTime = uint64(share.endTime);
        
    }
    
    function mySSCWithDraw() external view returns(string result){
        
        itMaps.itMapStringUint storage b = sscBalance[msg.sender];
        
        result = "[".toSlice().concat("".toSlice());
        
        for(uint256 i = 0;i< b.size();i++ ){
            
            string memory sscStr = _shareSscToString(b.getKey(i),b.getValueByIndex(i));
            
            result = result.toSlice().concat(sscStr.toSlice());
            
            result =  result.toSlice().concat(",".toSlice());
        }
        
        result = strings.until(result.toSlice(),",".toSlice()).concat("]".toSlice());
        
        return;
    }
    
    function withDrawSSC(string sscName) public approved returns(bool){
        
        return _withDrawSSC(msg.sender,sscName);
        
    }
    
    function _withDrawSSC(address _claimant,string sscName) internal returns(bool){
        
        uint256 _amount = sscBalance[_claimant].get(sscName);
        
        require(_amount > 0,"no withDraw amount");
        
        sscBalance[_claimant].clear(sscName);
        
        require(sero_send_token(_claimant,sscName,_amount),"send failed");
        
        return true;
    }
    
    function ()payable public {
    
    }
    
    function transferTo(address _to) public payable {
        require(msg.value>0,"msg.value is zero");
        require(sero_send_token(_to,sero_msg_currency(),msg.value),"transfer to faield");
    }
    
}
