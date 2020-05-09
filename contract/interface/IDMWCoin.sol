pragma solidity ^0.4.25;

interface IDMWCoin {
    
    function isSymbolExists(string _symbol) external view returns (bool);
    
    function decimals() external view returns (uint8);
    
    function totalSupply(string _symbol) external view returns (uint256);
    
    function register(string _symbol) external payable returns(bool);
    
    function mint(string symbol,uint256 amount) external returns(bool);
    
    function burned(string symbol,uint256 amount) external payable returns(bool);
    
    function setDMW(address _newDMW) external;
}
