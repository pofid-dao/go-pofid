pragma solidity ^0.4.25;
import "./DMWAuctionBase.sol";
import "./Address.sol";


contract DMWAuction is DMWAuctionBase {
    
    using OpenZeppelinUpgradesAddress for address;
    
    
    function setAuctionPrice(uint256 _contractIndex) public {
        require(!msg.sender.isContract(),"not approved");
        _setAuctionPrice(_contractIndex);
    }
    
    function setDMW(address _dmw) public onlyOwner{
        dmwAddress = _dmw;
    }
    
    function setDMWCoin(address _dmwCoin) public onlyOwner {
        dmwCoinAddress  = _dmwCoin;
    }
    
    
    function createAuction(
        uint256 _contractIndex,
        string _mintCoin,
        uint256 _marketValue
    )
    external payable
    {
        require(msg.sender ==dmwAddress,"not dmw");
        
        string  memory _backedCoin = sero_msg_currency();
        
        uint256 _backedValue = msg.value;
        
        _addAuction(_contractIndex,
            _mintCoin,
            _backedCoin,
            _backedValue,
            _marketValue);
    }
    
    function bid(uint256 _contractIndex)
    external
    payable
    {
        require(!msg.sender.isContract(),"invalid sender");
        
        _bid(msg.sender,_contractIndex,sero_msg_currency(), msg.value);
    }
    
    function withDraw(uint256 contractIndex) public {
        _withDraw(msg.sender,contractIndex);
    }
    
    
    
}
