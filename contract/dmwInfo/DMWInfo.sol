pragma solidity ^0.4.25;

import "../Ownable.sol";

import "../Utils.sol";

import "./itMap.sol";

interface IDMW {

    function contractBase(uint256 contractIndex) external view returns(
        address _holder,
        uint64 _createTime,
        string _backedCoin,
        uint256 _backedValue,
        uint256 _canClaimtValue,
        string _mintCoin,
        uint256 _mintValue
    );

    function contractRate(
        uint256 contractIndex)
    external view returns
    (
        uint256 _numerator,
        uint256 _denominator,
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
        uint256 _liquidationRate);

    function isDrop (uint256 _contractIndex) external view returns(bool);
}


contract DMWInfo is Ownable{

    using utils for *;

    using ItMap for *;

    address public DMWAddress;

    function setDMW(address _addr)public  onlyOwner{
        DMWAddress = _addr;
    }


    uint256[] public contractIndexs;

    mapping(uint256 => bool) contractIndexExists;

    mapping(bytes32=>ItMap.itMapUint256)  keyContracts;

    mapping(bytes32=>uint256[]) keyHistoryContracts;

    mapping(address =>ItMap.itMapUint256)  myContracts;

    mapping (address =>mapping(bytes32 => ItMap.itMapUint256))  myKeyContracts;

    mapping (address =>mapping(bytes32 => uint256[]))  myKeyHistoryContracts;



    function transferContract(address from, address to,uint256 contractIndex) public returns(bool){

        require(msg.sender == DMWAddress || msg.sender == owner,"not approved");

        (,,string memory backedCoin,,,string  memory mintCoin,) = IDMW(DMWAddress).contractBase(contractIndex);

        bytes32 _key =  utils.genStableCoinKey(backedCoin,mintCoin);

        if (from != address(0)){

            myContracts[from].remove(contractIndex);

            myKeyContracts[from][_key].remove(contractIndex);

        }

        myContracts[to].upSert(contractIndex);

        myKeyContracts[to][_key].upSert(contractIndex);

        myKeyHistoryContracts[to][_key].push(contractIndex);

        if (!contractIndexExists[contractIndex]){

            keyContracts[_key].upSert(contractIndex);

            keyHistoryContracts[_key].push(contractIndex);

            contractIndexExists[contractIndex] = true;

            contractIndexs.push(contractIndex);
        }
        return true;
    }

    function closeContract(address holder,uint256 contractIndex) public returns(bool){

        require(msg.sender == DMWAddress || msg.sender == owner,"not approved");

        (,,string memory backedCoin,,,string  memory mintCoin,) = IDMW(DMWAddress).contractBase(contractIndex);

        bytes32 _key =  utils.genStableCoinKey(backedCoin,mintCoin);

        keyContracts[_key].remove(contractIndex);

        myKeyContracts[holder][_key].remove(contractIndex);

        myContracts[holder].remove(contractIndex);

        return true;
    }



    function _rateToString(uint256 _contractIndex) internal view returns (string result){
        (uint256 _numerator,uint256 _denominator,uint256 _fee,uint8 _state) =  IDMW(DMWAddress).contractRate(_contractIndex);

        result = result.toSlice().concat(utils._genKey("fee"));
        result = result.toSlice().concat(utils._genUintStringValue(_fee));
        result = result.toSlice().concat(",".toSlice());

        // result = result.toSlice().concat(utils._genKey("liquidationRate"));
        // result = result.toSlice().concat(utils._genUintValue(_liquidationRate));
        // result = result.toSlice().concat(",".toSlice());

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
        }

        result = result.toSlice().concat(utils._genUintValue(_status));

        result = result.toSlice().concat(",".toSlice());

        return;
    }

    function statbleCoinTostring(address _claimant,uint256 _contractIndex) public view returns (string result) {

        (
        address _holder,
        uint64 _createTime,
        string memory _backedCoin,
        uint256 _backedValue,
        uint256 _canClaimtValue,
        string  memory _mintCoin,
        uint256 _mintValue) = IDMW(DMWAddress).contractBase(_contractIndex);

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


        result = result.toSlice().concat(utils._genKey("canClaimtValue"));
        result = result.toSlice().concat(utils._genUintStringValue(_canClaimtValue));
        result = result.toSlice().concat(",".toSlice());

        result = result.toSlice().concat(utils._genKey("mintCoin"));
        result = result.toSlice().concat(utils._genStringValue(_mintCoin));
        result = result.toSlice().concat(",".toSlice());

        result = result.toSlice().concat(utils._genKey("owns"));
        if (_holder == _claimant) {
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
        ItMap.itMapUint256 storage _itmap = keyContracts[_key];
        return _itmapPageContracts(_itmap,msg.sender,offset,pageSize);

    }

    function keyHistoryPageContracts(string  _backedCoin,string  _mintCoin,uint256 offset,uint8 pageSize) external view returns(string result){
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        uint256[] memory _contractIndexs = keyHistoryContracts[_key];
        return _pageContract(_contractIndexs,offset,pageSize);
        // return _itmapPageContracts(_itmap,msg.sender,offset,pageSize);

    }

    function myPageContracts(uint256 _lastIndex,uint8 pageSize)external view returns(string result){
        ItMap.itMapUint256 storage _itmap = myContracts[msg.sender];
        return _itmapPageContracts(_itmap,msg.sender,_lastIndex,pageSize);
    }

    function myPageKeyContracts(string _backedCoin,string  _mintCoin,uint256 _lastIndex,uint8 pageSize) external view returns(string result){
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        ItMap.itMapUint256 storage _itmap = myKeyContracts[msg.sender][_key];
        return _itmapPageContracts(_itmap,msg.sender,_lastIndex,pageSize);
    }

    function myPageKeyHistoryContracts(string _backedCoin,string  _mintCoin,uint256 offset,uint8 pageSize) external view returns(string result){
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        uint256[] memory _contractIndexs = myKeyHistoryContracts[msg.sender][_key];
        return _pageContract(_contractIndexs,offset,pageSize);

    }

    function _itmapPageContracts(ItMap.itMapUint256 storage _itmap,address _claimant,uint256 offset,uint8 limit) internal view returns(string result){
        uint256 count = _itmap.size();
        result = "{".toSlice().concat(utils._genKey("total"));
        result = result.toSlice().concat(utils._genUintValue(count));
        if (offset < count) {
            uint256 start = count - offset;
            uint256 size = limit;
            if (start < limit) {
                size = start;
            }
            string[] memory datas = new string[](size);
            uint256 index = 0;
            while (index < size) {
                start--;
                uint256 _contractIndex = _itmap.getKeyByIndex(start);
                datas[index] = statbleCoinTostring(_claimant,_contractIndex);
                index++;
            }
        }


        string memory data = utils.joinArrayString(datas);
        result = result.toSlice().concat(",".toSlice());
        result = result.toSlice().concat(utils._genKey("data"));
        result = result.toSlice().concat(data.toSlice());
        // result = result.toSlice().concat(",".toSlice());
        // result = result.toSlice().concat(utils._genKey("lastIndex"));
        // result = result.toSlice().concat(utils._genUintValue(_lastIndex));
        result = result.toSlice().concat("}".toSlice());
        return ;
    }

    function _pageContract(uint256[]memory _contractIndex,uint256 offset,uint8 pageSize) internal view returns(string result){
        uint256 size = _contractIndex.length;
        result = "{".toSlice().concat(utils._genKey("total"));
        result = result.toSlice().concat(utils._genUintValue(size));
        if (size>offset) {
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
                datas[index] = statbleCoinTostring(msg.sender,_contractIndex[start]);
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

    function allPageContracts(uint256 offset, uint8 pageSize) external view returns(string result){
        return _pageContract(contractIndexs,offset,pageSize);
    }

}
