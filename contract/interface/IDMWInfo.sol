pragma solidity ^0.4.25;

interface IDMWInfo {
    
    function keyPageContracts(string  _backedCoin,string  _mintCoin,uint256 _lastIndex,uint8 pageSize) external view returns(string result);
    
    function myPageContracts(uint256 _lastIndex,uint8 pageSize)external view returns(string result);

    function myPageKeyContracts(string _backedCoin,string  _mintCoin,uint256 _lastIndex,uint8 pageSize) external view returns(string result);
}
