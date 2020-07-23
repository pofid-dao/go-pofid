pragma solidity ^0.4.25;

import "./DMWBaseControl.sol";


contract DMWBase is DMWBaseControl{
    
    struct Exchange {
        string name;
        bool invalid;
    }
    
    mapping(bytes32 =>Exchange[]) exchanges;
    
    mapping(bytes32 => mapping(bytes32 =>string)) descriptions;
    
    struct ExchangeRate {
        string name;
        string url;
        bool invalid;
    }
    
    mapping(bytes32 =>ExchangeRate[]) exchangeRate;
    
    mapping (bytes32 =>bool) exists;
    
    
    
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }
    
    
    struct TradingPair {
        string backedCoin;
        string mintCoin;
        uint256   collateralRate;
        Fraction  currentRate;
        uint256  thresholdRate;
        bool invalid;
    }
    
    TradingPair[] public pairs;
    
    mapping(bytes32 => uint256) pairToIndex;
    
    mapping (bytes32 => address) proxyAddress;
    
    
    function addPair(string _backedCoin,
        string _mintCoin,
        uint256 _numerator,
        uint256 _denominator,
        uint256 _collateralRate,
        uint256 _thresholdRate) public onlyApproved{
        
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        
        if (!exists[_key]){
            
            Fraction memory _f = Fraction(_numerator,_denominator);
            
            TradingPair memory pair = TradingPair(_backedCoin,_mintCoin,_collateralRate,_f,_thresholdRate,false);
            
            uint256 _index = pairs.push(pair)-1;
            
            pairToIndex[_key] = _index;
            
            exists[_key] = true;
            
        }
    }

    function exists(string _backedCoin,string mintCoin) public view returns(bool){
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        return exists[_key];
    }
    
    function getProxyAddress(string backedCoin,string mintCoin) public view returns(address){
        bytes32 _key =backedCoin.genStableCoinKey(mintCoin);
        return proxyAddress[_key];
        
    }
    
    function setProxyAddress(string backedCoin,string mintCoin,address proxy) public {
        
        require(stableCoinApproved(backedCoin,mintCoin),"not approved");
        
        bytes32 _key =backedCoin.genStableCoinKey(mintCoin);
        
        proxyAddress[_key] = proxy;
    }
    
    function setPairStatus(string backedCoin,string mintCoin,bool invalid) public onlyOwner {
        
        bytes32 _key =backedCoin.genStableCoinKey(mintCoin);
        
        require(exists[_key],"not exits");
        
        uint256 _index = pairToIndex[_key];
        
        pairs[_index].invalid = invalid;
        
    }
    
    function updateCurrentRate(string _backedCoin,string _mintCoin,uint256 _numerator,uint256 _denominator) public onlyApproved {
        
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        
        if (exists[_key]){
            
            uint256 _index = pairToIndex[_key];
            
            pairs[_index].currentRate.numerator = _numerator;
            
            pairs[_index].currentRate.denominator = _denominator;
            
        }
    }
    
    function updateCollateralRate(string _backedCoin,string _mintCoin,uint256 _collateralRate) public onlyApproved {
        
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        
        if (exists[_key]){
            
            uint256 _index = pairToIndex[_key];
            
            pairs[_index].collateralRate = _collateralRate;
            
        }
    }
    
    function updateThresholdRate(string _backedCoin,string _mintCoin,uint256 _thresholdRate) public onlyApproved{
        
        bytes32 _key =_backedCoin.genStableCoinKey(_mintCoin);
        
        if (exists[_key]){
            
            uint256 _index = pairToIndex[_key];
            
            pairs[_index].thresholdRate = _thresholdRate;
            
        }
    }
    
    function addExchange(string backedCoin,string name) public {
        
        require(backedCoinApproved(backedCoin),"not approved");
        
        bytes32 _key = backedCoin.genBytes32();
        
        Exchange memory ex = Exchange(name,false);
        
        exchanges[_key].push(ex);
    }
    
    function exchangeLength(string backedCoin) public view returns (uint256) {
        
        return  exchanges[backedCoin.genBytes32()].length;
        
    }
    
    function delExchange(string backedCoin,uint256 index) public {
        
        require(backedCoinApproved(backedCoin),"not approved");
        
        bytes32 _key = backedCoin.genBytes32();
        
        require(index < exchanges[_key].length,"invalid index");
        
        exchanges[_key][index].invalid =true;
    }
    
    function addExchangeRate(string backedCoin,string mintCoin,string name,string url) public {
        
        require(stableCoinApproved(backedCoin,mintCoin),"not approved");
        
        bytes32 _key =backedCoin.genStableCoinKey(mintCoin);
        
        ExchangeRate memory rate = ExchangeRate(name,url,false);
        
        exchangeRate[_key].push(rate);
        
    }
    
    function exchangeRateLength(string backedCoin,string mintCoin) public view returns (uint256) {
        
        bytes32 _key =backedCoin.genStableCoinKey(mintCoin);
        
        return  exchangeRate[_key].length;
        
    }
    
    function delExchangeRate(string backedCoin,string mintCoin,uint256 index) public {
        
        require(stableCoinApproved(backedCoin,mintCoin),"not approved");
        
        bytes32 _key =backedCoin.genStableCoinKey(mintCoin);
        
        require(index < exchangeRate[_key].length,"invalid index");
        
        exchangeRate[_key][index].invalid =true;
    }
    
    function addDescription(string backedCoin,string lang,string descption) public {
        
        require(backedCoinApproved(backedCoin),"not approved");
        
        descriptions[backedCoin.genBytes32()][lang.genBytes32()] = descption;
        
    }
    
    function getTradingPairs(string lang)public view returns(string){
        
        string[] memory datas = new string[](pairs.length);
        
        if (pairs.length>0) {
            
            for(uint256 i =0;i<pairs.length;i++){
                
                datas[i] = _tradingPairToString(pairs[i],lang);
            }
        }
        return datas.joinArrayString();
    }
    
    function _exchangeToString(string _backedCoin) internal view returns(string result){
        
        Exchange[] memory exs = exchanges[_backedCoin.genBytes32()];
        
        for(uint256 i= 0;i<exs.length;i++){
            
            if (!exs[i].invalid) {
                
                result = result.toSlice().concat("{".toSlice()).toSlice().concat(utils._genKey("name"));
                
                result = result.toSlice().concat(utils._genStringValue(exs[i].name));
                
                result = result.toSlice().concat(",".toSlice());
                
                result = result.toSlice().concat(utils._genKey("index"));
                
                result = result.toSlice().concat(utils._genUintValue(i));
                
                result = result.toSlice().concat("}".toSlice());
                
                result = result.toSlice().concat(",".toSlice());
                
            }
        }
        
        result = "[".toSlice().concat(result.toSlice());
        
        result = result.toSlice().until(",".toSlice()).concat("]".toSlice());
        
    }
    
    function allExchangeRate(string backedCoin,string mintCoin) public view returns(string result){
        
        ExchangeRate[] memory exs = exchangeRate[backedCoin.genStableCoinKey(mintCoin)];
        
        for(uint256 i= 0;i<exs.length;i++){
            
            if (!exs[i].invalid) {
                
                result = result.toSlice().concat("{".toSlice()).toSlice().concat(utils._genKey("name"));
                result = result.toSlice().concat(utils._genStringValue(exs[i].name));
                result = result.toSlice().concat(",".toSlice());
                
                result = result.toSlice().concat(utils._genKey("index"));
                result = result.toSlice().concat(utils._genUintValue(i));
                result = result.toSlice().concat(",".toSlice());
                
                result = result.toSlice().concat(utils._genKey("backedCoin"));
                result = result.toSlice().concat(utils._genStringValue(backedCoin));
                result = result.toSlice().concat(",".toSlice());
                
                result = result.toSlice().concat(utils._genKey("mintCoin"));
                result = result.toSlice().concat(utils._genStringValue(mintCoin));
                result = result.toSlice().concat(",".toSlice());
                
                result = result.toSlice().concat(utils._genKey("url"));
                result = result.toSlice().concat(utils._genStringValue(exs[i].url));
                
                result = result.toSlice().concat("}".toSlice());
                result = result.toSlice().concat(",".toSlice());
            }
        }
        
        result = "[".toSlice().concat(result.toSlice());
        
        result = result.toSlice().until(",".toSlice()).concat("]".toSlice());
    }
    
    function _tradingPairToString(TradingPair pair,string _lang)  internal view returns(string result){
        
        if (pair.invalid){
            return;
        }
        
        bytes32 _key = pair.backedCoin.genStableCoinKey(pair.mintCoin);
        
        result = "{".toSlice().concat(utils._genKey("backeCoin"));
        result = result.toSlice().concat(utils._genStringValue(pair.backedCoin));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("mintCoin"));
        result = result.toSlice().concat(utils._genStringValue(pair.mintCoin));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("description"));
        result = result.toSlice().concat(utils._genStringValue(descriptions[pair.backedCoin.genBytes32()][_lang.genBytes32()]));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("exchanges"));
        result = result.toSlice().concat(_exchangeToString(pair.backedCoin).toSlice());
        result = result.toSlice().concat(",".toSlice());
        
        
        result = result.toSlice().concat(utils._genKey("ownsBackedCoin"));
        if (backedCoinApproved(pair.backedCoin)){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("proxy"));
        if (proxyAddress[_key] !=address(0)){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        result = result.toSlice().concat(",".toSlice());
        
        
        
        result = result.toSlice().concat(utils._genKey("owns"));
        if (stableCoinApproved(pair.backedCoin,pair.mintCoin)){
            result = result.toSlice().concat("true".toSlice());
        }else {
            result = result.toSlice().concat("false".toSlice());
        }
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("exchangeRates"));
        result = result.toSlice().concat(allExchangeRate(pair.backedCoin,pair.mintCoin).toSlice());
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("thresholdRate"));
        result = result.toSlice().concat(utils._genUintValue(pair.thresholdRate));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("collateralRate"));
        result = result.toSlice().concat(utils._genUintValue(pair.collateralRate));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("currentRateNumerator"));
        result = result.toSlice().concat(utils._genUintValue(pair.currentRate.numerator));
        result = result.toSlice().concat(",".toSlice());
        
        result = result.toSlice().concat(utils._genKey("currentRateDenominator"));
        result = result.toSlice().concat(utils._genUintValue(pair.currentRate.denominator));
        result = result.toSlice().concat("}".toSlice());
        
        return;
    }
}
