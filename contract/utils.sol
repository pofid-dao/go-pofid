pragma solidity ^0.4.25;

import "github.com/Arachnid/solidity-stringutils/strings.sol";

library  utils{
    
    using strings for *;
    
    
    function equals(string a, string b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        for (uint i = 0; i < bytes(a).length; i ++) {
            if(bytes(a)[i] != bytes(b)[i]) {
                return false;
            }
        }
        return true;
    }
    
    function uint2str(uint256 i) internal pure returns (string memory){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = bytes1(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }
    
    function genBytes32(string key) internal pure returns(bytes32){
        return  keccak256(bytes(key));
    }
    
    function genStableCoinKey(string memory backedCoin,string memory mintCoin) internal pure returns(bytes32){
        return keccak256(bytes(backedCoin.toSlice().concat(mintCoin.toSlice())));
    }
    
    function _genKey(string key) internal pure returns (strings.slice){
        string memory result = "\"".toSlice().concat(key.toSlice());
        result = result.toSlice().concat("\":".toSlice());
        return result.toSlice();
    }
    function _genUintStringValue(uint256 _value) internal pure returns(strings.slice){
        string memory result = "\"".toSlice().concat(uint2str(_value).toSlice());
        result = result.toSlice().concat("\"".toSlice());
        return result.toSlice();
    }
    
    function _genUintValue(uint256 _value) internal pure returns(strings.slice){
        return uint2str(_value).toSlice();
    }
    
    function _genStringValue(string _value) internal pure returns(strings.slice){
        string memory result = "\"".toSlice().concat(_value.toSlice());
        result = result.toSlice().concat("\"".toSlice());
        return result.toSlice();
    }
    
    function _genBoolValue(bool _value)  internal pure returns(strings.slice result){
        if (_value){
            return "true".toSlice();
        }else {
            return "false".toSlice();
        }
    }
    
    function _actualLength(string[] datas) internal pure returns(uint256){
        uint256 size = 0;
        for(uint256 i=0;i<datas.length;i++){
            if(bytes(datas[i]).length>0){
                size++;
            }
        }
        return size;
    }
    
    
    function joinArrayString(string[] datas) internal pure returns(string result ){
        strings.slice[] memory slices = new strings.slice[](_actualLength(datas));
        uint256 start = 0;
        for(uint256 i=0;i<datas.length;i++){
            if(bytes(datas[i]).length>0){
                slices[start]=datas[i].toSlice();
                start++;
            }
        }
        string  memory dataStr = ",".toSlice().join(slices);
        result = "[".toSlice().concat(dataStr.toSlice());
        result = result.toSlice().concat("]".toSlice());
        return;
    }
    
    function toSlice(string data) internal pure returns (strings.slice){
        return data.toSlice();
    }
    
    function concat(strings.slice a, strings.slice b) internal pure returns(string memory){
        return a.concat(b);
    }
    
    function join(strings.slice a, strings.slice[] b) internal pure returns(string memory){
        return a.join(b);
    }
    
    function until(strings.slice self, strings.slice needle )internal pure returns (strings.slice memory){
        return self.until(needle);
    }
}
