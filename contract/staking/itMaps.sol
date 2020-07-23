pragma solidity ^0.4.25;

import "./SafeMath.sol";

import "./sortList.sol";

library itMaps {
    
    using SafeMath for uint256;
    using SortList for *;
    
    struct entryStringUint {
        uint256 keyIndex;
        uint256 value;
    }
    
    struct itMapStringUint {
        mapping(string => entryStringUint) data;
        string[] keys;
    }
    
    function upSert(itMapStringUint storage self, string key, uint256 value) internal returns (bool success) {
        entryStringUint storage e = self.data[key];
        if (e.keyIndex > 0) {
            e.value = e.value.add(value);
        } else {
            e.value = value;
            e.keyIndex = ++self.keys.length;
            self.keys[e.keyIndex - 1] = key;
        }
        return true;
    }
    
    function clear(itMapStringUint storage self, string key) internal returns (uint256) {
        self.data[key].value = 0;
    }
    
    function size(itMapStringUint storage self) internal constant returns (uint256) {
        return self.keys.length;
    }
    
    function get(itMapStringUint storage self, string key) internal constant returns (uint256) {
        return self.data[key].value;
    }
    
    function getKey(itMapStringUint storage self, uint256 idx) internal constant returns (string) {
        /* Decrepated, use getKeyByIndex. This kept for backward compatilibity */
        return self.keys[idx];
    }
    
    function getValueByIndex(itMapStringUint storage self, uint256 idx) internal constant returns (uint256) {
        return self.data[self.keys[idx]].value;
    }
    
    
    
    struct entryUintUint {
        uint256 keyIndex;
        uint256 value;
    }
    
    struct itMapUintUint {
        mapping(uint256 => entryUintUint) data;
        SortList.SortData keys;
    }
    
    function upSert(itMapUintUint storage self, uint256 key, uint256 value) internal returns (bool success) {
        entryUintUint storage e = self.data[key];
        if (e.keyIndex > 0) {
            e.value = e.value.add(value);
        } else {
            e.value = value;
            e.keyIndex++;
            self.keys.insert(key);
        }
        return true;
    }
    
    
    function get(itMapUintUint storage self, uint256 key) internal constant returns (uint256) {
        return self.data[key].value;
    }
    
    
    function getStartKey(itMapUintUint storage self) internal constant returns(uint256){
        return self.keys.getStart();
    }
    
    
    function getNextKey(itMapUintUint storage self,uint256 cur) internal constant returns(uint256){
        return self.keys.getNext(cur);
    }
    
    
}
