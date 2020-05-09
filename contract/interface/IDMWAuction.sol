pragma solidity ^0.4.25;

interface IDMWAuction {
    
    function createAuction(
        uint256 _contractIndex,
        string _mintCoin,
        uint256 _marketValue
    ) external payable;
    
    function bid(uint256 _contractIndex) external payable;
    
    function unSold(uint256 _contractIndex) external view returns(bool);
    
    function setAuctionPrice(uint256 _contractIndex) external;
    
    function pageAuctions(uint256 offset,uint256 pageSize)external view returns(string result);
    
    function withDraw(uint256 contractIndex) external;
    
    function timer() external view returns(uint64);
    
    function updateActiveRequests() external;
}
