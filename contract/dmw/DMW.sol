pragma solidity ^0.4.26;
import "./DMWCore.sol";



contract DMW is DMWCore{

    string public  name = "DMW";

    bool public paused = false;


    constructor(address _dmwBase,address _dmwCoin,address _dmwInfo,address _dmwBinding) public
    DMWCore(_dmwBase,_dmwCoin,_dmwInfo,_dmwBinding){
    }

    function transferDMW(address _newDMW)  external onlyOwner{
        _setDMW(_newDMW);
    }

    function setPaused(bool status) external onlyCOO {
        paused = status;
    }


    function setStakingContract(address _stakingContract) external onlyCOO {

        require(_stakingContract!=address(this),"_stakingContract is self");

        require(_stakingContract.isContract(),"_stakingContract is not contract");

        stakingAddress= _stakingContract;
    }

    function delStakingContract() external onlyOwner{

        stakingAddress = address(0);
    }



    function setDMWBase(address _base) public onlyCOO {

        require(_base!=address(this),"_base is self");

        require(_base.isContract(),"_base is not contract");

        dmwBaseAddress = _base;
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

    function deposit(uint256 contractIndex) external  payable{

        require(!msg.sender.isContract(),"not approved");

        _deposit(msg.sender,sero_msg_currency(),msg.value,contractIndex);

    }

    function proxyDeposit(address agent,uint256 contractIndex) external payable onlyProxy returns (bool){

        _deposit(agent,sero_msg_currency(),msg.value,contractIndex);

        return true;

    }

    function claim(uint256 contractIndex) public payable{
        require(!msg.sender.isContract(),"not approved");
        _claim(msg.sender,sero_msg_currency(),msg.value,contractIndex);
    }

    function proxyClaim(address agent,uint256 contractIndex) external payable onlyProxy returns(bool){
        _claim(agent,sero_msg_currency(),msg.value,contractIndex);
        return true;
    }

    function ()  public payable {

    }
}
