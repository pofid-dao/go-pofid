pragma solidity ^0.4.25;

import "./Ownable.sol";

import "./utils.sol";

interface IDMW {
    
    function contractBase(
        address _claimant,
        uint256 contractIndex)
    external view returns
    (
        address _creator,
        uint64 _createTime,
        string _backedCoin,
        uint256 _backedValue,
        string _mintCoin,
        uint256 _mintValue,
        bool _own
    );
    
    function contractRate(
        uint256 contractIndex)
    external view returns
    (
        uint256 _numerator,
        uint256 _denominator,
        uint256 _thresholdRate,
        uint256 _fee,
        uint8 _state
    );
    
    function currentRate(
        string  _backedCoin,
        string  _mintCoin)
    external  view returns
    (
        uint256 _numerator ,
        uint256 _denominator,
        uint256 _collateralRate,
        uint256 _thresholdRate);
    
    function isDrop (uint256 _contractIndex) external view returns(bool);
}


contract DMWInfo is Ownable{
    
    using utils for *;
    
    address public DMWAddress;
    
    function setDMW(address _addr)public  onlyOwner{
        DMWAddress = _addr;
    }
    
    
    uint256[] public contractIndexs;
    
    mapping(uint256 => bool) contractIndexExists;
    
    mapping(bytes32=>uint256[]) public keyContracts;
    
    mapping(address =>uint256[]) public myContracts;
    
    mapping (address =>mapping(bytes32 => uint256[])) public myKeyContracts;
    
    
    function addContract(string backedCoin,string mintCoin,address _own,uint256 contractIndex) public returns(bool){
        
        require(msg.sender == DMWAddress || msg.sender == owner,"not approved");
        
        if (!contractIndexExists[contractIndex]){
            
            contractIndexExists[contractIndex] = true;
            
            bytes32 _key =  utils.genStableCoinKey(backedCoin,mintCoin);
            
            keyContracts[_key].push(contractIndex);
            
            myContracts[_own].push(contractIndex);
            
            myKeyContracts[_own][_key].push(contractIndex);
            
            contractIndexs.push(contractIndex);
        }
        return true;
    }
    
    
    function _rateToString(uint256 _contractIndex) internal view returns (string result){
        (uint256 _numerator,uint256 _denominator,uint256 _thresholdRate,uint256 _fee,uint8 _state) =  IDMW(DMWAddress).contractRate(_contractIndex);
        
        result = result.toSlice().concat(utils._genKey("fee"));
        result = result.toSlice().concat(utils._genUintStringValue(_fee));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("thresholdRate"));
        result = result.toSlice().concat(utils._genUintValue(_thresholdRate));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("rateNumerator"));
        result = result.toSlice().concat(utils._genUintValue(_numerator));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("rateDenominator"));
        result = result.toSlice().concat(utils._genUintValue(_denominator));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("status"));
        
        uint256 _status = 0;
        
        
        if (_state == 1){
            if(IDMW(DMWAddress).isDrop(_contractIndex)){
                _status = 2;
            }else {
                _status = 1;
            }
        }else if (_state == 2){
            
            _status =3;
        }
        
        result = result.toSlice().concat(utils._genUintValue(_status));
        
        result = result.toSlice().concat(",".toSlice());
        
        return;
    }
    
    function statbleCoinTostring(address _claimant,uint256 _contractIndex) public view returns (string result) {
        
        (,uint64 _createTime,string memory _backedCoin,uint256 _backedValue,string  memory _mintCoin,uint256 _mintValue,bool _own) = IDMW(DMWAddress).contractBase(_claimant,_contractIndex);
        
        result = "{".toSlice().concat(utils._genKey("backedValue"));
        result = result.toSlice().concat(utils._genUintStringValue(_backedValue));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("contractIndex"));
        result = result.toSlice().concat(utils._genUintValue(_contractIndex));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("createTime"));
        result = result.toSlice().concat(utils._genUintValue(_createTime));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("backedCoin"));
        result = result.toSlice().concat(utils._genStringValue(_backedCoin));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("mintValue"));
        result = result.toSlice().concat(utils._genUintStringValue(_mintValue));
        result = result.toSlice().concat(",".toSlice());
        
        
        
        
        result = result.toSlice().concat(utils._genKey("mintCoin"));
        result = result.toSlice().concat(utils._genStringValue(_mintCoin));
        result = result.toSlice().concat(",".toSlice());
        
        
        
        
        
        result = result.toSlice().concat(utils._genKey("owns"));
        if (_own) {
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        result = result.toSlice().concat(",".toSlice());
        
        string memory mid = _rateToString(_contractIndex);
        
        result = result.toSlice().concat(mid.toSlice());
        
        
        
        
        (uint256 _n,uint256 _d,,) = IDMW(DMWAddress).currentRate(_backedCoin,_mintCoin);
        
        result = result.toSlice().concat(utils._genKey("currentRateNumerator"));
        result = result.toSlice().concat(utils._genUintValue(_n));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("currentRateDenominator"));
        result = result.toSlice().concat(utils._genUintValue(_d));
        result = result.toSlice().concat("}".toSlice());
    }
    
    function _getPageContracts(address _claimant ,uint256[] _contractIndexs,uint256 offset,
        uint256 pageSize)internal view returns(string result){
        uint256 size = _contractIndexs.length;
        result = "{".toSlice().concat(utils._genKey("total"));
        result = result.toSlice().concat(utils._genUintValue(size));
        if (size>0 && size > offset) {
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
                
                datas[index] = statbleCoinTostring(_claimant,_contractIndexs[start]);
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
    
    
    function keyPageContracts(string  _backedCoin,string  _mintCoin,uint256 offset,uint8 pageSize) external view returns(string result){
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        uint256[] memory _contractIndexs = keyContracts[_key];
        return _getPageContracts(msg.sender,_contractIndexs,offset,pageSize);
        
    }
    
    function myPageContracts(uint256 offset,uint256 pageSize)external view returns(string result){
        uint256[] memory _contractIndexs = myContracts[msg.sender];
        return _getPageContracts(msg.sender,_contractIndexs,offset,pageSize);
    }
    
    function myPageKeyContracts(string _backedCoin,string  _mintCoin,uint256 offset,uint8 pageSize) external view returns(string result){
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        uint256[] memory _contractIndexs = myKeyContracts[msg.sender][_key];
        return _getPageContracts(msg.sender,_contractIndexs,offset,pageSize);
    }
    
    
    function allPageContracts(uint256 offset, uint8 pageSize) external view returns(string result){
        uint256 size = contractIndexs.length;
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
                datas[index] = statbleCoinTostring(msg.sender,contractIndexs[start]);
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
    
}
