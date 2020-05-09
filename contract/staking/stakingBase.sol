pragma solidity ^0.4.25;
import "./utils.sol";
import "./SafeMath.sol";
import "./stakingControl.sol";
import "./itMaps.sol";

contract StakingBase is StakingControl{
    
    using SafeMath for uint256;
    
    using utils for *;
    
    using itMaps for *;
    
    
    uint256 private _interestDecimals = 10;
    
    uint256 constant stakingUint = 24*60*60; //test 5, prod 24*60*60
    
    uint256 private _base_30_Interest = 4*(10**_interestDecimals)/1000;
    
    uint256 private _base_60_Interest = 10*(10**_interestDecimals)/1000;
    
    uint256 private _base_90_Interest = 26*(10**_interestDecimals)/1000;
    
    uint64 public startStakingTime = uint64(now);
    
    itMaps.itMapUintUint dayCoinAge;
    
    function getDayCoinAge(uint64 baseTime) public view returns(uint256){
        return dayCoinAge.get(baseTime);
    }
    
    function interestDecimals() public view returns (uint256){
        return _interestDecimals;
    }
    
    function base30Interest() public view returns ( uint256 interest) {
        return _base_30_Interest;
    }
    
    function base60Interest() public view returns ( uint256 interest) {
        return _base_60_Interest;
    }
    
    function base90Interest() public view returns ( uint256 interest) {
        return _base_90_Interest;
    }
    
    function setBase30Interest(uint256 base_30_Interest) public onlyOwner{
        _base_30_Interest = base_30_Interest ;
    }
    
    function setBase60Interest(uint256 base_60_Interest) public onlyOwner{
        _base_60_Interest = base_60_Interest ;
    }
    
    function setBase90Interest(uint256 base_90_Interest) public onlyOwner{
        _base_90_Interest = base_90_Interest ;
    }
    
    
    function getBaseTime(uint64 timestamp) public pure returns(uint256) {
        
        uint256 _days = uint256(timestamp).div(stakingUint);
        
        return _days.mul(stakingUint);
    }
    
    function _addCoinAge(uint64 _endTime,uint256 _coinAge) internal {
        
        uint256 _baseTime = getBaseTime(_endTime);
        
        dayCoinAge.upSert(_baseTime,_coinAge);
    }
    
    struct SSC {
        string symbol;
        uint256 amount;
        uint64 timestamp;
        uint256 coinAge;
        uint256 totalAmount;
        uint256 totalCoinAge;
    }
    
    struct Share {
        address owner;
        uint64 startTime;
        uint64 endTime;
        uint64 withDrawTime;
        uint64 stakingDays;
        uint256 value;
        uint256 seq;
        uint256 interest;
        uint256 fee;
        bool valid;
        uint256 startSscIndex;
        uint256 endSscIndex;
    }
    
    mapping(address=>uint256[]) myShare;
    
    Share[] public shares;
    
    SSC[] public SSCS;
    
    mapping(bytes32=>bool) sscNameExist;
    
    string[] sscNames;
    
    
    function allSSC() public view returns(string result){
        
        strings.slice[] memory slices = new strings.slice[](sscNames.length);
        
        for(uint256 i=0;i<sscNames.length;i++){
            
            slices[i]=sscNames[i]._genStringValue();
            
        }
        string  memory dataStr = ",".toSlice().join(slices);
        
        result = "[".toSlice().concat(dataStr.toSlice());
        
        result = result.toSlice().concat("]".toSlice());
        
        return;
    }
    
    
    function _addSSCName(string memory _name) internal {
        
        if (!sscNameExist[ _name.genBytes32()]){
            
            sscNameExist[ _name.genBytes32()] = true;
            
            sscNames.push(_name);
        }
    }
    
    function _getTotalCoinAge(uint64 _now) internal view returns (uint256 totalCoinAge) {
        
        uint256 _nowBaseTime = getBaseTime( _now);
        
        uint256 _lastBaseTime = dayCoinAge.getStartKey();
        
        while(_lastBaseTime>_nowBaseTime){
            
            totalCoinAge = totalCoinAge.add(dayCoinAge.get(_lastBaseTime));
            
            _lastBaseTime = dayCoinAge.getNextKey(_lastBaseTime);
            
        }
        
        return ;
    }
    
    function _getShareSSC(uint256 shareIndex) internal view returns(string  result) {
        
        Share memory share= shares[shareIndex];
        result = "[".toSlice().concat("".toSlice());
        if (share.startSscIndex<SSCS.length) {
            for(uint256 i = share.startSscIndex;i< SSCS.length;i++ ){
                SSC memory ssc = SSCS[i];
                if (getBaseTime(share.endTime) > getBaseTime(ssc.timestamp)){
                    uint256 _coinAge = share.value.mul(uint256(share.stakingDays));
                    uint256 _sscValue = ssc.totalAmount.mul(_coinAge).div(ssc.totalCoinAge);
                    string memory sscStr = _shareSscToString(ssc.symbol,_sscValue);
                    result = result.toSlice().concat(sscStr.toSlice());
                    result =  result.toSlice().concat(",".toSlice());
                }else {
                    break;
                }
            }
        }
        result = strings.until(result.toSlice(),",".toSlice()).concat("]".toSlice());
        return;
    }
    
    function _shareSscToString(string sscName, uint256 amount) internal pure returns(string result){
        
        string memory start = "{";
        string memory end = "}";
        result = start.toSlice().concat(utils._genKey("sscName"));
        result = result.toSlice().concat(utils._genStringValue(sscName));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("amount"));
        result = result.toSlice().concat(utils._genUintStringValue(amount));
        
        result = result.toSlice().concat(end.toSlice());
        return;
    }
    
    function _shareToString(Share _share,uint256 index) internal view returns(string result){
        string memory start = "{";
        string memory end = "}";
        result = start.toSlice().concat(utils._genKey("startTime"));
        result = result.toSlice().concat(utils._genUintValue(_share.startTime));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("shareIndex"));
        result = result.toSlice().concat(utils._genUintValue(index));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("endTime"));
        result = result.toSlice().concat(utils._genUintValue(_share.endTime));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("withDrawTime"));
        result = result.toSlice().concat(utils._genUintValue(_share.withDrawTime));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("stakingDays"));
        result = result.toSlice().concat(utils._genUintValue(_share.stakingDays));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("fee"));
        result = result.toSlice().concat(utils._genUintValue(_share.fee));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("value"));
        result = result.toSlice().concat(utils._genUintStringValue(_share.value));
        result = result.toSlice().concat(",".toSlice());
        
        
        result = result.toSlice().concat(utils._genKey("interest"));
        result = result.toSlice().concat(utils._genUintValue(_share.interest));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("interestDecimals"));
        result = result.toSlice().concat(utils._genUintValue(_interestDecimals));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("seq"));
        result = result.toSlice().concat(utils._genUintValue(_share.seq));
        result = result.toSlice().concat(",".toSlice());
        
        
        result = result.toSlice().concat(utils._genKey("valid"));
        result = result.toSlice().concat(utils._genBoolValue(_share.valid));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("startSccIndex"));
        result = result.toSlice().concat(utils._genUintValue(_share.startSscIndex));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("endSccIndex"));
        result = result.toSlice().concat(utils._genUintValue(_share.endSscIndex));
        result = result.toSlice().concat(",".toSlice());
        
        
        string memory sscs= _getShareSSC(index);
        
        result = result.toSlice().concat(utils._genKey("sscs"));
        result = result.toSlice().concat(sscs.toSlice());
        
        result = result.toSlice().concat(end.toSlice());
        return;
    }
}
