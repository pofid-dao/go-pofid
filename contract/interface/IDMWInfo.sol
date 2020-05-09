pragma solidity ^0.4.25;

interface IDMWInfo {
    
    function keyPageContracts(string  _backedCoin,string  _mintCoin,uint256 offset,uint8 pageSize) external view returns(string result);
    
    function myPageContracts(uint256 offset,uint256 pageSize)external view returns(string result);
}
