pragma solidity ^0.4.25;

interface IDMW {

    function claim(uint256 contractIndex) external payable;

    function deposit(uint256 contractIndex) external payable;

    function issue(string  mintCoin) external  payable;

    function getMinBackedAmount(string _backedCoin, string _mintCoin) external view returns(uint256);

    function estimatMintAmount(string  _backedCoin,string  _mintCoin,uint256 _backedValue) external view returns (uint256 amount,uint256 fee);

    function estimatAddDepositAmount(uint256 _contractIndex) external view returns(uint256 _depositValue,uint256 _canClaimtValue);
}
