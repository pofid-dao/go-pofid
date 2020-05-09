pragma solidity ^0.4.25;

contract blackHole {
    
    string private _name = "BurnedPofidCoin";
    
    function() public payable{
    
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
}
