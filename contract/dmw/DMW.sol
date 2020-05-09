pragma solidity ^0.4.25;
import "./DMWCore.sol";



contract DMW is DMWCore{
    
    string public  name = "DMW";
    
    bool public paused = false;
    
    
    constructor(address _dmwBase,address dmwCoin,address _dmwInfo,address _dmwAuction) public
    DMWCore(_dmwBase,dmwCoin,_dmwInfo,_dmwAuction){
    }
    
    function transferDMW(address _newDMW) public onlyOwner{
        _setDMW(_newDMW);
    }
    
    function setPaused(bool status) public onlyOwner {
        paused = status;
    }
    
    
    function setStakingContract(address _stakingContract) public onlyCOO {
        
        require(_stakingContract!=address(this),"_stakingContract is self");
        
        require(_stakingContract.isContract(),"_stakingContract is not contract");
        
        stakingAddress= _stakingContract;
    }
    
    function delStakingContract() public onlyOwner{
        
        stakingAddress = address(0);
    }
    
    
    
    function setDMWBase(address _base) public onlyCOO {
        
        require(_base!=address(this),"_base is self");
        
        require(_base.isContract(),"_base is not contract");
        
        dmwBaseAddress = _base;
    }
    
    function setDMWCoin(address _dwmCoin) public onlyOwner {
        
        require(_dwmCoin!=address(this),"_dwmCoin is self");
        
        require(_dwmCoin.isContract(),"_dwmCoin is not contract");
        
        dmwCoinAddress = _dwmCoin;
    }
    
    
    function issue(string  mintCoin) external  payable  returns(uint256) {
        
        require(!paused,"paused");
        
        require(!msg.sender.isContract(),"not approved");
        
        return _issue(msg.sender,sero_msg_currency(),mintCoin,msg.value);
        
    }
    
    function proxyIssue(address agent,string mintCoin) external payable onlyProxy returns (uint256){
        require(!paused,"paused");
        require(!agent.isContract(),"not support");
        return _issue(agent,sero_msg_currency(),mintCoin,msg.value);
    }
    
    function claim(uint256 contractIndex) public payable{
        require(!msg.sender.isContract(),"not approved");
        _claim(msg.sender,sero_msg_currency(),msg.value,contractIndex);
    }
    
    function proxyClaim(address agent,uint256 contractIndex) external payable onlyProxy returns(bool){
        _claim(agent,sero_msg_currency(),msg.value,contractIndex);
        return true;
    }
    
    
    function createAuction(uint256 _contractIndex) public   {
        require(!msg.sender.isContract(),"not approved");
        _createAuction(_contractIndex);
    }
    
    function proxyCreateAuction(uint256 _contractIndex) public onlyProxy returns(bool) {
        _createAuction(_contractIndex);
        return true;
    }
    
    
    function () public payable{
    
    }
    
    
}
