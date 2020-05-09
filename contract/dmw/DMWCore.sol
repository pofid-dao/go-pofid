pragma solidity ^0.4.25;
import "./DMWStableCoin.sol";
import "./utils.sol";

interface Staking {
    function dmwMint() external payable returns(bool);
}

interface IDMWInfo {
    function addContract(string backedCoin,string mintCoin,address own,uint256 contractIndex) external returns(bool);
}

contract DMWCore is DMWStableCoin{
    
    event Transfer(address from, address to, uint256 contractIndex);
    
    event Approval(address owner, address approved, uint256 contractIndex);
    
    event CreateStableCoinContract (address claimant,uint256 contractIndex);
    
    event CloseStableCoinContract (address claimant,uint256 contractIndex);
    
    event AuctionStableCoinContract(uint256 contractIndex);
    
    event SetAuctionPrice(uint256  contractIndex);
    
    event CloseAution(uint256 contractIndex);
    
    enum State {
        _,
        Normal,
        OnAuction,
        Close
    }
    
    struct StableCoinContract {
        address creator;
        uint64 createTime;
        string backedCoin;
        uint256 backedValue;
        string mintCoin;
        uint256 mintValue;
        uint256 numerator;
        uint256 denominator;
        uint256 thresholdRate;
        uint256 fee;
        State state;
    }
    
    StableCoinContract[] private contracts;
    
    uint256  private mintRate = 8;
    
    uint256 private  marketRate =20;
    
    address public stakingAddress;
    
    address private dmwInfoAddress;
    
    constructor(
        address dmwBase,
        address dmwCoin,
        address dmwInfo,
        address dmwAuction)  public
    DMWStableCoin(dmwBase,dmwCoin,dmwAuction) {
        
        dmwInfoAddress = dmwInfo;
        
    }
    
    function equals(string a, string b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        for (uint i = 0; i < bytes(a).length; i ++) {
            if(bytes(a)[i] != bytes(b)[i]) {
                return false;
            }
        }
        return true;
    }
    
    
    
    function setMintRate(uint256 rate) public onlyCOO  {
        mintRate = rate;
    }
    
    function setDMWAuction(address _auction) public onlyCOO {
        
        require(_auction!=address(this),"_auction is self");
        
        require(_auction.isContract(),"_auction is not contract");
        
        dmwAuctionAddress = _auction;
    }
    
    function setDMWInfo(address _dmwInfo) public onlyCOO {
        
        require(_dmwInfo!=address(this),"_dmwInfo is self");
        
        require(_dmwInfo.isContract(),"_dmwInfo is not contract");
        
        dmwInfoAddress= _dmwInfo;
    }
    
    function feeRate() public view returns(uint256 _mintRate,uint256 _markedFee){
        return (mintRate,marketRate);
    }
    
    function contractBase(address claimant,uint256 contractIndex) external view returns(
        address _creator,
        uint64 _createTime,
        string _backedCoin,
        uint256 _backedValue,
        string _mintCoin,
        uint256 _mintValue,
        bool _own
    
    ){
        _creator = contracts[contractIndex].creator;
        _createTime = contracts[contractIndex].createTime;
        _backedCoin = contracts[contractIndex].backedCoin;
        _backedValue = contracts[contractIndex].backedValue;
        _mintCoin = contracts[contractIndex].mintCoin;
        _mintValue = contracts[contractIndex].mintValue;
        _own = _owns(claimant,contractIndex);
        return;
        
    }
    
    function contractRate(uint256 contractIndex) external view returns(
        uint256 _numerator,
        uint256 _denominator,
        uint256 _thresholdRate,
        uint256 _fee,
        uint8 _state
    ){
        _numerator = contracts[contractIndex].numerator;
        _denominator = contracts[contractIndex].numerator;
        _thresholdRate = contracts[contractIndex].thresholdRate;
        _fee = contracts[contractIndex].fee;
        _state = uint8(contracts[contractIndex].state);
        return;
    }
    
    function _isOnAuction(uint256 _contractIndex) internal view returns(bool){
        return contracts[_contractIndex].state == State.OnAuction;
    }
    
    
    function _owns(address _claimant, uint256 _contractIndex) internal view returns (bool) {
        
        return contracts[_contractIndex].creator == _claimant;
    }
    
    
    function _createContract(
        address _claimant,
        string memory _backedCoin,
        uint256 _backedValue,
        string memory _mintCoin
    ) internal returns(uint256 _contractIndex,uint256 mintValue,uint256 _fee){
        
        (
        uint256 _mintValue,
        uint256 _numerator,
        uint256 _denominator,
        ,
        uint256 _thresholdRate
        ) = _estimatMintAmount(_backedCoin,_mintCoin,_backedValue);
        
        _fee = _mintValue.mul(mintRate).div(100);
        
        mintValue = _mintValue;
        
        StableCoinContract memory _contract = StableCoinContract(
            _claimant,
            uint64(now),
            _backedCoin,
            _backedValue,
            _mintCoin,
            _mintValue,
            _numerator,
            _denominator,
            _thresholdRate,
            _fee,
            State.Normal);
        
        _contractIndex = contracts.push(_contract) -1;
        
        require(dmwInfoAddress!=address(0),"dmwInfo not set");
        
        require(IDMWInfo(dmwInfoAddress).addContract(_backedCoin,_mintCoin,_claimant,_contractIndex),"dmwinfo add failed");
        
        
        return;
    }
    
    
    function contractCurentMarketValue (uint256 _contractIndex) public view returns(uint256){
        
        require(_contractIndex < contracts.length,"invalid contractIndex");
        
        return _marketValue(contracts[_contractIndex].backedCoin,
            contracts[_contractIndex].mintCoin,contracts[_contractIndex].backedValue);
    }
    
    function _contractThresholdValue(uint256 _contractIndex) internal view returns(uint256) {
        return contracts[_contractIndex].backedValue.mul(100).
        mul(contracts[_contractIndex].denominator).
        div(contracts[_contractIndex].numerator).
        div(contracts[_contractIndex].thresholdRate);
    }
    
    function isDrop (uint256 _contractIndex) public view returns(bool){
        
        require(_contractIndex < contracts.length,"invalid contractIndex");
        
        uint256 _currentMarketValue =  contractCurentMarketValue(_contractIndex);
        
        uint256 _thresholdValue = _contractThresholdValue(_contractIndex);
        
        return (_thresholdValue >= _currentMarketValue);
    }
    
    
    function estimatMintAmount(string backedCoin,string mintCoin,uint256 backedValue) external view returns (uint256 amount,uint256 fee){
        
        (uint256 _mintAmount,,,,) = _estimatMintAmount(backedCoin,mintCoin,backedValue);
        
        fee = _mintAmount.mul(mintRate).div(100);
        
        amount= _mintAmount.sub(fee);
        
        return;
    }
    
    function _issue(address _claimant,string _backedCoin,string _mintCoin,uint256 _backedValue) internal returns(uint256){
        
        require(_exists(_backedCoin,_mintCoin),"not exitst");
        
        require(_validStableCoin(_backedCoin,_mintCoin),"not valid");
        
        require(_backedValue >= getMinBackedAmount(_backedCoin),"less than min");
        
        (uint256 contractIndex, uint256 _mintValue, uint256 _fee)= _createContract(
            _claimant,
            _backedCoin,
            _backedValue,
            _mintCoin);
        
        _mint(_mintCoin,_mintValue);
        
        if (stakingAddress == address(0)){
            
            require(sero_send_token(owner,_mintCoin,_fee),"transfer failed");
            
        }else {
            
            uint256 _marketFee = _fee.mul(marketRate).div(100);
            
            uint256 _stakingProfit = _fee.sub(_marketFee);
            
            sero_setCallTokenValue(_mintCoin,_stakingProfit);
            
            require(Staking(stakingAddress).dmwMint(),"dmw mint failed");
            
            require(sero_send_token(owner,_mintCoin,_marketFee),"transfer failed");
        }
        
        uint256 _sendValue = _mintValue.sub(_fee);
        
        require(sero_send_token(_claimant,_mintCoin,_sendValue),"transfer failed");
        
        emit CreateStableCoinContract(_claimant,contractIndex);
        
        return contractIndex;
    }
    
    function _claim(address _claimant,string _currency,uint256 _value,uint256 _contractIndex) internal {
        
        require(_contractIndex < contracts.length,"invalid contractIndex");
        
        require(_owns(_claimant,_contractIndex),"not owns");
        
        StableCoinContract storage _contract = contracts[_contractIndex];
        
        require(_contract.state == State.Normal);
        
        _contract.state = State.Close;
        
        string memory _mintCoin = _contract.mintCoin;
        
        require(equals(_mintCoin,_currency),"invalid coin");
        
        require(_value >= _contract.mintValue,"msg value is not enought");
        
        uint256 _charge = _value.sub(_contract.mintValue);
        
        if (_charge > 0){
            require(sero_send_token(_claimant,_mintCoin,_charge),"send charge failed");
        }
        
        _burned(_mintCoin,_contract.mintValue);
        
        require(sero_send_token(_claimant,_contract.backedCoin,_contract.backedValue),"send backed failed");
        
        emit CloseStableCoinContract(_claimant,_contractIndex);
        
    }
    
    function _createAuction(uint256 _contractIndex) internal   {
        
        require(dmwAuctionAddress != address(0),"not set dmwAuctionAddress");
        
        require(_contractIndex < contracts.length,"invalid contractIndex");
        
        require(isDrop(_contractIndex),"not drop");
        
        StableCoinContract storage _contract  = contracts[_contractIndex];
        
        require(_contract.state == State.Normal,"invalid stats");
        
        _contract.state = State.OnAuction;
        
        uint256 _marketValue = contractCurentMarketValue(_contractIndex);
        
        
        sero_setCallTokenValue(_contract.backedCoin,_contract.backedValue);
        
        IDMWAuction(dmwAuctionAddress).createAuction(_contractIndex,
            _contract.mintCoin,
            _marketValue);
        
        emit AuctionStableCoinContract(_contractIndex);
    }
    
    
}
