pragma solidity ^0.4.25;

import "./Address.sol";

contract StakingControl {
    
    address public owner;
    address public proxy;
    
    
    /**
	 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
	 * account.
	 */
    constructor() public {
        owner = msg.sender;
    }
    
    
    /**
	 * @dev Throws if called by any account other than the owner.
	 */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyProxy() {
        require(msg.sender == proxy);
        _;
    }
    
    
    /**
	 * @dev Allows the current owner to transfer control of the contract to a newOwner.
	 * @param newOwner The address to transfer ownership to.
	 */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
    address public dwmAddress;
    
    mapping(address => bool) approveAddress;
    
    
    
    modifier onlyDmw() {
        require(OpenZeppelinUpgradesAddress.isContract(msg.sender),"not contract");
        require(msg.sender == dwmAddress ,"invalid dmw");
        _;
    }
    
    
    function setProxyAddress(address _proxy) external onlyOwner {
        require(OpenZeppelinUpgradesAddress.isContract(_proxy),"not contract address");
        proxy = _proxy;
    }
    
    function setDmwAddress(address _dwmAddress) external onlyOwner {
        require(OpenZeppelinUpgradesAddress.isContract(_dwmAddress),"not contract address");
        dwmAddress = _dwmAddress;
    }
    
    function delDmwAddress(address _dwmAddress) external onlyOwner {
        require(_dwmAddress != address(0),"contract is nil");
        dwmAddress= address(0);
    }
    
    modifier approved(){
        if (OpenZeppelinUpgradesAddress.isContract(msg.sender)){
            require(approveAddress[msg.sender],"not approved");
        }else {
            require(true);
        }
        _;
    }
    
    function approve(address _addr) external onlyOwner {
        require(_addr != address(0),"address is nil");
        require(OpenZeppelinUpgradesAddress.isContract(_addr),"not contract address");
        approveAddress[_addr] = true;
    }
    
    function delApprove(address _addr) external onlyOwner {
        require(_addr != address(0),"contract is nil");
        require( approveAddress[_addr],"contract address has invalid" );
        approveAddress[_addr] = false;
    }
    
}
