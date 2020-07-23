pragma solidity ^0.4.25;

interface IStaking {
    
    function getInterest (uint64 _stakingDays)  external view returns (uint256 _interest);
    
    function getPhaseSeq() external view returns(uint256 seq);
    
    function staking(uint64 _stakingDays) external payable;
    
    function reStaking(uint256 shareIndex,uint64 _stakingDays) external returns(uint256);
    
    function withDrawShare(uint256 shareIndex) external;
    
    function allSSC() external view returns(string);
    
    function myPageShare(uint256 offset,uint256 pageSize) external view returns(string result);
    
    function stakingPoolBalance() external view returns(uint256);
    
    function getPhaseBalance(uint8 seq) external view returns(uint256);
    
    function fee()external view returns(uint256);
    
    function minStakingValue() external view returns(uint256);
    
    function mySSCWithDraw() external view returns(string result);
    
    function withDrawSSC(string sscName) external returns(bool);
    
}
