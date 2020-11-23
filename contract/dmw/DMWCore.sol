pragma solidity ^0.4.26;
import "./DMWStableCoin.sol";

interface Staking {
    function dmwMint() external payable returns(bool);
}

interface IDMWInfo {

    function transferContract(address from, address to,uint256 contractIndex) external returns(bool);

    function closeContract(address holder,uint256 contractIndex) external  returns(bool);

}

contract DMWCore is DMWStableCoin{

    event CreateStableCoinContract (address claimant,uint256 contractIndex);

    event CloseStableCoinContract (address claimant,uint256 contractIndex);

    event DepositStableCoinContract (address claimant,uint256 contractIndex);


    enum State {
        _,
        Normal,
        Close
    }

    struct StableCoinContract {
        address holder;
        uint64 createTime;
        string backedCoin;
        uint256 backedValue;
        uint256 canClaimtValue;
        string mintCoin;
        uint256 mintValue;
        uint256 numerator;
        uint256 denominator;
        uint256 fee;
        State state;
    }

    StableCoinContract[] public contracts;

    uint256  private mintRate = 8;

    uint256 private  marketRate =20;

    address public stakingAddress;

    address private dmwInfoAddress;

    constructor(
        address dmwBase,
        address dmwCoin,
        address dmwInfo)  public
    DMWStableCoin(dmwBase,dmwCoin) {

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



    function setDMWInfo(address _dmwInfo) public onlyCOO {

        require(_dmwInfo!=address(this),"_dmwInfo is self");

        require(_dmwInfo.isContract(),"_dmwInfo is not contract");

        dmwInfoAddress= _dmwInfo;
    }

    function feeRate() public view returns(uint256 _mintRate,uint256 _markedFee){
        return (mintRate,marketRate);
    }

    function contractBase(uint256 contractIndex) external view returns(
        address _holder,
        uint64 _createTime,
        string _backedCoin,
        uint256 _backedValue,
        uint256 _canClaimtValue,
        string _mintCoin,
        uint256 _mintValue
    ){
        _holder = contracts[contractIndex].holder;
        _createTime = contracts[contractIndex].createTime;
        _backedCoin = contracts[contractIndex].backedCoin;
        _backedValue = contracts[contractIndex].backedValue;
        _canClaimtValue = contracts[contractIndex].canClaimtValue;
        _mintCoin = contracts[contractIndex].mintCoin;
        _mintValue = contracts[contractIndex].mintValue;
        return;

    }

    function contractRate(uint256 contractIndex) external view returns(
        uint256 _numerator,
        uint256 _denominator,
        uint256 _fee,
        uint8 _state
    ){
        _numerator = contracts[contractIndex].numerator;
        _denominator = contracts[contractIndex].numerator;
        // _liquidationdRate = contracts[contractIndex].liquidationdRate;
        _fee = contracts[contractIndex].fee;
        _state = uint8(contracts[contractIndex].state);
        return;
    }


    function owns(address _claimant, uint256 _contractIndex) public view returns (bool) {
        return contracts[_contractIndex].holder == _claimant;
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

        ) = _estimatMintAmount(_backedCoin,_mintCoin,_backedValue);

        _fee = _mintValue.mul(mintRate).div(100);

        mintValue = _mintValue;

        StableCoinContract memory _contract = StableCoinContract(
            _claimant,
            uint64(now),
            _backedCoin,
            _backedValue,
            _backedValue,
            _mintCoin,
            _mintValue,
            _numerator,
            _denominator,
        // _thresholdRate,
            _fee,
            State.Normal);

        _contractIndex = contracts.push(_contract) -1;

        require(dmwInfoAddress!=address(0),"dmwInfo not set");

        require(IDMWInfo(dmwInfoAddress).transferContract(address(0),_claimant,_contractIndex),"dmwinfo add failed");

        return;
    }


    function contractCurentMarketMintValue (uint256 _contractIndex) public view returns(uint256){

        require(_contractIndex < contracts.length,"invalid contractIndex");

        return _marketMintValue(contracts[_contractIndex].backedCoin,
            contracts[_contractIndex].mintCoin,contracts[_contractIndex].backedValue);
    }

    function _contractLiquidationdValue(uint256 _contractIndex) internal view returns(uint256) {

        return _calLiquidationdValue(contracts[_contractIndex].backedCoin,contracts[_contractIndex].mintCoin,contracts[_contractIndex].mintValue);
    }

    function isDrop (uint256 _contractIndex) public view returns(bool){

        require(_contractIndex < contracts.length,"invalid contractIndex");

        uint256 _currentMarketValue =  contractCurentMarketMintValue(_contractIndex);

        uint256 _liquidationdValue = _contractLiquidationdValue(_contractIndex);

        return (_liquidationdValue >= _currentMarketValue);
    }


    function estimatMintAmount(string backedCoin,string mintCoin,uint256 backedValue) external view returns (uint256 amount,uint256 fee){

        (uint256 _mintAmount,,,,) = _estimatMintAmount(backedCoin,mintCoin,backedValue);

        fee = _mintAmount.mul(mintRate).div(100);

        amount= _mintAmount.sub(fee);

        return;
    }


    function _issue(address _claimant,string _backedCoin,string _mintCoin,uint256 _backedValue) internal returns(uint256){

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        require(_validStableCoin(_backedCoin,_mintCoin),"not valid");

        require(_backedValue >= getMinBackedAmount(_backedCoin,_mintCoin),"less than min");

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

        require(owns(_claimant,_contractIndex),"not owns");

        StableCoinContract storage _contract = contracts[_contractIndex];

        require(_contract.state == State.Normal);

        _contract.state = State.Close;

        string memory _mintCoin = _contract.mintCoin;

        require(equals(_mintCoin,_currency),"invalid coin");

        require(_value >= _contract.mintValue,"msg value is not enought");

        _burned(_mintCoin,_contract.mintValue);

        uint256 _canClaimtValue = _contract.canClaimtValue;

        require(_canClaimtValue >0,"has closed");

        _contract.canClaimtValue = 0;

        uint256 _backedValue = _contract.backedValue;

        if (_backedValue > _canClaimtValue){

            require(sero_send_token(owner,_contract.backedCoin,_backedValue.sub(_canClaimtValue)),"send to owner backed failed");
        }

        require(sero_send_token(_claimant,_contract.backedCoin,_canClaimtValue),"send backed failed");

        uint256 _charge = _value.sub(_contract.mintValue);

        if (_charge > 0){
            require(sero_send_token(_claimant,_mintCoin,_charge),"send charge failed");
        }

        require(IDMWInfo(dmwInfoAddress).closeContract(_claimant,_contractIndex),"dmwinfo close failed");


        emit CloseStableCoinContract(_claimant,_contractIndex);

    }

    function _deposit(
        address _claimant,
        string _currency,
        uint256 _value,
        uint256 _contractIndex) internal {

        require(_contractIndex < contracts.length,"invalid contractIndex");

        StableCoinContract storage _contract = contracts[_contractIndex];

        require(equals(_contract.backedCoin,_currency),"invalid coin");

        require(_contract.state == State.Normal);

        bool _ows = owns(_claimant,_contractIndex);

        if (!_ows){

            require(isDrop(_contractIndex),"not drop");

            require(IDMWInfo(dmwInfoAddress).transferContract(
                    _contract.holder,
                    _claimant,
                    _contractIndex),"dmwinfo add failed");

            _contract.holder = _claimant;
        }

        (uint256 _requiredBackeValue,uint256 n,uint256 d) = _calRequiredDepositBackedValue(
            _contract.backedCoin,
            _contract.mintCoin,
            _contract.mintValue);

        require(_requiredBackeValue > _contract.backedValue,"not need deposit");

        uint256 _addDepositValue = _requiredBackeValue.sub(_contract.backedValue);

        require(_value >= _addDepositValue,"not enough value");

        (uint256 _backedValue,uint256 _canClaimtValue) =_calContractBackedValue(_ows,_contractIndex,_addDepositValue);

        _contract.backedValue =_backedValue;

        _contract.canClaimtValue = _canClaimtValue;

        _contract.numerator = n;

        _contract.denominator = d;



        uint256 _charge = _value.sub(_addDepositValue);

        if (_charge > 0){
            require(sero_send_token(_claimant,_currency,_charge),"send charge failed");
        }
        emit DepositStableCoinContract(_claimant,_contractIndex);
    }

    function _calContractBackedValue(bool _ows,uint256 _contractIndex,uint256 _depositValue) internal view returns(uint256 _backedValue,uint256 _canClaimtValue){

        _backedValue = contracts[_contractIndex].backedValue.add(_depositValue);

        _canClaimtValue = contracts[_contractIndex].canClaimtValue.add(_depositValue);

        if (!_ows){

            uint256 _currentMarketBackeValue =  _calCurrentMarketBackedValue(
                contracts[_contractIndex].backedCoin,
                contracts[_contractIndex].mintCoin,
                contracts[_contractIndex].mintValue);

            _canClaimtValue = _currentMarketBackeValue.add(_depositValue);

            if (_backedValue < _canClaimtValue){

                _canClaimtValue = _backedValue;
            }

        }
        return;
    }

    function _calContractAddBackedValue(uint256 _contractIndex) internal view returns(uint256 _depositValue){

        (uint256 _requiredBackeValue,,) =
        _calRequiredDepositBackedValue(
            contracts[_contractIndex].backedCoin,
            contracts[_contractIndex].mintCoin,
            contracts[_contractIndex].mintValue);
        if (_requiredBackeValue > contracts[_contractIndex].backedValue){
            _depositValue = _requiredBackeValue.sub(contracts[_contractIndex].backedValue);
        }
        return;
    }

    function estimatAddDepositAmount(uint256 _contractIndex) public view returns(uint256 _depositValue,uint256 _canClaimtValue){

        require(_contractIndex < contracts.length,"invalid contractIndex");

        _depositValue = _calContractAddBackedValue(_contractIndex);

        bool _ows = owns(msg.sender,_contractIndex);

        (,_canClaimtValue) = _calContractBackedValue(_ows,_contractIndex,_depositValue);

        return;
    }


}
