pragma solidity ^0.4.25;

contract IDMWBase {
    
    function getTradingPairs(string lang)external view returns(string);
    
    function addExchange(string backedCoin,string name) external;
    
    function exchangeLength(string backedCoin) external view returns (uint256);
    
    function delExchange(string backedCoin,uint256 index) external;
    
    function addDescription(string backedCoin,string lang,string descption) external;
    
    function getProxyAddress(string backedCoin,string mintCoin) external view returns(address);
    
}
