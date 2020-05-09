pragma solidity ^0.4.25;
import "./SafeMath.sol";
import "./seroInterface.sol";
import "./DMWCoinControl.sol";

contract DMWCoin is DMWCoinControl, SeroInterface {
    
    using SafeMath for uint256;
    
    address public blackHole;
    
    string public name = "DMWCoinFactory";
    
    string[] public symbols;
    
    uint8  private _decimals  =18;
    
    mapping(string => bool)  symbolExists;
    
    mapping(string => uint256) _totalMinted;
    
    mapping(string => uint256) _totalSupply;
    
    event Register(address claimant, string symbol);
    
    event Mint(address claimant, string symbol,uint256 _amount);
    
    event Transfer(address from,address to, string symbol,uint256 _amount);
    
    event Burned(address claimant,string symbol,uint256 _amount);
    
    constructor(address _blackHole) public {
        
        require(_blackHole.isContract(),"_blackHole not contract");
        
        blackHole = _blackHole;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function isSymbolExists(string _symbol) public view returns (bool) {
        return symbolExists[_symbol];
    }
    
    
    function totalSupply(string symbol) public view returns (uint256) {
        return _totalSupply[symbol];
    }
    
    function totalMinted(string symbol) public view returns(uint256) {
        return _totalMinted[symbol];
    }
    
    function register(string _symbol) public payable onlyApproved returns(bool) {
        
        require(msg.value >0,"msg.value is zero");
        
        require(!symbolExists[_symbol],"has exists");
        
        symbolExists[_symbol] = true;
        
        require(sero_issueToken(0,_symbol),"register symbol failed");
        
        symbols.push(_symbol);
        
        emit Register(msg.sender,_symbol);
        
        return true;
    }
    
    function mint(string _symbol,uint256 _amount) public onlyDMW returns(bool) {
        
        require(symbolExists[_symbol],"_symbol not exists");
        
        require(sero_issueToken(_amount,_symbol),"mint faield");
        
        _totalSupply[_symbol] = _totalSupply[_symbol].add(_amount);
        
        _totalMinted[_symbol] = _totalMinted[_symbol].add(_amount);
        
        require(sero_send_token(msg.sender,_symbol,_amount));
        
        emit Mint(msg.sender,_symbol,_amount);
        
        return true;
        
    }
    
    function burned() public payable returns(bool){
        
        string memory _currency = sero_msg_currency();
        
        uint256 _amount = msg.value;
        
        require(_amount >0,"amount is zero");
        
        require(symbolExists[_currency],"_symbol not exists");
        
        _totalSupply[_currency] = _totalSupply[_currency].sub(_amount);
        
        require(sero_send_token(blackHole,_currency,_amount));
        
        emit Burned(msg.sender,_currency,_amount);
        
        return true;
    }
    
}




