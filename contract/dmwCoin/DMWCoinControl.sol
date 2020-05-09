pragma solidity ^0.4.25;

import "./Address.sol";

contract DMWCoinControl {
    
    using OpenZeppelinUpgradesAddress for address;
    
    address public owner;
    
    address public dmwAddress;
    
    
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
    
    modifier onlyDMW() {
        require(msg.sender == dmwAddress);
        _;
    }
    
    modifier onlyApproved() {
        require(msg.sender == dmwAddress || msg.sender == owner);
        _;
    }
    
    
    
    function setDMW(address _newDMW) public {
        
        if (dmwAddress == address(0)){
            require(msg.sender ==owner,"not owner");
        }else {
            require(msg.sender ==  dmwAddress,"not dmwAddress");
        }
        require(_newDMW != address(this),"_newDMW is self" );
        
        require(_newDMW.isContract(),"_newDMW is not contract");
        
        dmwAddress = _newDMW;
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
    
    
    
    
}
