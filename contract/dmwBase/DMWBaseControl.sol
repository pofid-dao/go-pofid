pragma solidity ^0.4.25;

import "./Address.sol";

import "./utils.sol";

contract DMWBaseControl {
    
    using OpenZeppelinUpgradesAddress for address;
    
    using utils for *;
    
    address public owner;
    
    address public dmwAddress;
    
    
    mapping(bytes32=>address) stableCoinOwner;
    
    mapping(bytes32=>address) backedCoinOwner;
    
    
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
    
    function setDMW(address _newDMW) public onlyOwner {
        require(_newDMW != address(this),"_newDMW is self" );
        require(_newDMW.isContract(),"_newDMW is not contract");
        dmwAddress = _newDMW;
    }
    
    function stableCoinApproved(string backedCoin,string mintCoin) internal view returns(bool){
        return (msg.sender == owner || msg.sender == stableCoinOwner[backedCoin.genStableCoinKey(mintCoin)]);
    }
    
    function backedCoinApproved(string backedCoin) internal view returns(bool){
        return (msg.sender == owner || msg.sender == backedCoinOwner[backedCoin.genBytes32()]);
    }
    
    function setStableCoinOwner(string backedCoin,string mintCoin,address o) external onlyOwner {
        
        stableCoinOwner[backedCoin.genStableCoinKey(mintCoin)] = o;
        
    }
    
    function setBackedCoinOwner(string backedCoin,address o) external onlyOwner {
        
        backedCoinOwner[backedCoin.genBytes32()] = o;
        
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
