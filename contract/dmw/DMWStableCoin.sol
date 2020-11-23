pragma solidity ^0.4.26;

import "../interface/IDMWCoin.sol";

import "../seroInterface.sol";
import "../SafeMath.sol";
import "../Utils.sol";
import "./DMWControl.sol";

interface IDMWBase {

    function addPair(string _backedCoin,
        string _mintCoin,
        uint256 _numerator,
        uint256 _denominator,
        uint256 _collateralRate,
        uint256 _thresholdRate) external;

    function updateCurrentRate(string _backedCoin,string _mintCoin,uint256 _numerator,uint256 _denominator) external;

    function updateCollateralRate(string _backedCoin,string _mintCoin,uint256 _collateralRate) external;

    function updateThresholdRate(string _backedCoin,string _mintCoin,uint256 _thresholdRate) external;

    function setProxyAddress(string backedCoin,string mintCoin,address proxy) external;

}

//interface IBindings {
 //   function binding(string  backedCoin,string  mintCoin) external returns(bool);
//}

contract DMWStableCoin is DMWControl,SeroInterface {

    using SafeMath for uint256;

    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    struct Rate {
        uint256   collateralRate;
        Fraction  currentRate;
        uint256   liquidationdRate;
    }

    mapping(bytes32 => Rate) private rates;

    address public dmwBaseAddress;

    address public dmwCoinAddress;

    address public dmwBindingAddress;

    mapping(bytes32 => bool) stableCoinExists;

    mapping(bytes32 =>uint256) private minBackedAmount;


    constructor(address dmwBase,address dmwCoin) public {

        dmwBaseAddress = dmwBase;

        dmwCoinAddress = dmwCoin;
    }

    function genStableCoinKey(string memory backedCoin,string memory mintCoin) internal pure returns(bytes32){
        return utils.genStableCoinKey(backedCoin,mintCoin);
    }

    function getMinBackedAmount(string _backedCoin,string _mintCoin) public view returns(uint256) {

        bytes32 _key = genStableCoinKey(_backedCoin,_mintCoin);

        uint256 _min = minBackedAmount[_key];

        if (_min == 0){

            return 100*10**uint256(18);
        }
        return _min;
    }

    function setMinBackedAmount(string _backedCoin,string _mintCoin,uint256 _amount) public onlyCOO{
        bytes32 _key = genStableCoinKey(_backedCoin,_mintCoin);
        minBackedAmount[_key]= _amount;
    }

    function _burned(string _mintCoin,uint256 _amount) internal {

        require(dmwCoinAddress !=address(0),"not set dmwCoinAddress");

        sero_setCallTokenValue(_mintCoin,_amount);

        require(IDMWCoin(dmwCoinAddress).burned(),"stableCoin _burned falied");
    }

    function _mint(string _mintCoin,uint256 _amount) internal {

        require(dmwCoinAddress !=address(0),"not set dmwCoinAddress");

        require(IDMWCoin(dmwCoinAddress).mint(_mintCoin,_amount),"stableCoin mint falied");
    }



    function registerStableCoin(
        string _backedCoin,
        string _mintCoin,
        uint256 _collateralRate,
        uint256 _liquidationdRate,
        uint256 _minBackedAmount) public payable approved {

        bytes32 _key = genStableCoinKey(_backedCoin,_mintCoin);

        require(!stableCoinExists[_key],"has exists");

 //       require(dmwBindingAddress !=address(0),"not set dmwBindingAddress");

  //      require(IBindings(dmwBindingAddress).binding(_backedCoin,_mintCoin),"invalid binding");

        stableCoinExists[_key] = true;

        require(dmwCoinAddress !=address(0),"not set dmwCoinAddress");

        if (!IDMWCoin(dmwCoinAddress).isSymbolExists(_mintCoin)){

            require(msg.value>0,"msg.value is zero");

            sero_setCallTokenValue(sero_msg_currency(),msg.value);

            require(IDMWCoin(dmwCoinAddress).register(_mintCoin),"registerDMWCoin failed");

        }else {

            if (msg.value >0){
                require(sero_send_token(owner,sero_msg_currency(),msg.value),"send rigister fee failed");
            }
        }

        require(_collateralRate  >= 100 ,"invalid collateralRate");

        require(_liquidationdRate  >= 100,"invalid thresholdRate");

        require(_collateralRate > _liquidationdRate ,"invalid collaterRate and thresholdRate");

        require(_minBackedAmount >0,"invalid _minBackedValue");

        minBackedAmount[_key] = _minBackedAmount;

        Fraction memory _currentRate = Fraction(0,0);

        Rate memory _rate = Rate(_collateralRate,_currentRate,_liquidationdRate);

        rates[_key] = _rate;

        require(dmwBaseAddress !=address(0),"not set base");

        IDMWBase(dmwBaseAddress).addPair(_backedCoin,_mintCoin,0,0,_collateralRate,_liquidationdRate);

    }

    function _validStableCoin(string memory _backedCoin,string memory _mintCoin) internal view returns(bool){

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        require(rates[_key].currentRate.numerator>0 ,"not set numerator");

        require(rates[_key].currentRate.denominator >0,"not set denominator");

        require(rates[_key].collateralRate >=100,"invalid collateralRate");

        require(rates[_key].liquidationdRate >=100,"invalid liquidationdRate");

        return true;
    }

    function stabeCoinExists(string memory _backedCoin,string memory _mintCoin) public view returns(bool){

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        return stableCoinExists[_key];

    }


    function setCurrentRate(
        string memory _backedCoin,
        string memory _mintCoin,
        uint256 _numerator,
        uint256 _denominator) public onlyOracle {

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        rates[_key].currentRate.numerator = _numerator;

        rates[_key].currentRate.denominator = _denominator;

        IDMWBase(dmwBaseAddress).updateCurrentRate(_backedCoin,_mintCoin,_numerator,_denominator);

    }

    function setLiquidationdRate(
        string memory _backedCoin,
        string memory _mintCoin,
        uint256 _liquidationdRate
    ) public onlyOracle {

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        rates[_key].liquidationdRate = _liquidationdRate;

        IDMWBase(dmwBaseAddress).updateThresholdRate(_backedCoin,_mintCoin,_liquidationdRate);

    }

    function setCollateralRate(
        string memory _backedCoin,
        string memory _mintCoin,
        uint256 _collateralRate) public onlyOracle {

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        rates[_key].collateralRate = _collateralRate;

        IDMWBase(dmwBaseAddress).updateCollateralRate(_backedCoin,_mintCoin,_collateralRate);

    }

    function _estimatMintAmount(
        string memory _backedCoin,
        string memory _mintCoin,
        uint256 _backedValue)
    internal view returns
    (
        uint256 _mintValue,
        uint256 _numerator,
        uint256 _denominator,
        uint256 _collateralRate,
        uint256 _liquidationdRate
    ){

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        require(_validStableCoin(_backedCoin,_mintCoin),"not validStableCoin");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        _numerator = rates[_key].currentRate.numerator;

        _denominator = rates[_key].currentRate.denominator;

        _collateralRate = rates[_key].collateralRate;

        _liquidationdRate = rates[_key].liquidationdRate;

        _mintValue = _backedValue.mul(100).mul(_denominator).div(_numerator).div(_collateralRate);

        return;
    }

    function _calLiquidationdValue(string _backedCoin,string _mintCoin,uint256 _mintValue) internal view returns(uint256 _liquidationValue) {

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        require(_validStableCoin(_backedCoin,_mintCoin),"not validStableCoin");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        uint256 _liquidationdRate = rates[_key].liquidationdRate;

        _liquidationValue = _mintValue.mul(_liquidationdRate).div(100);
    }

    function _calRequiredDepositBackedValue(string _backedCoin,string _mintCoin,uint256 _mintValue) internal view returns(uint256 _depositBackedValue,
        uint256 _numerator,
        uint256 _denominator){

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        require(_validStableCoin(_backedCoin,_mintCoin),"not validStableCoin");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        _numerator = rates[_key].currentRate.numerator;

        _denominator = rates[_key].currentRate.denominator;

        uint256 _collateralRate = rates[_key].collateralRate;

        _depositBackedValue = _mintValue.mul(_collateralRate).mul(_numerator).div(_denominator).div(100);

        return;
    }

    function _calCurrentMarketBackedValue(string _backedCoin,string _mintCoin,uint256 _mintValue) internal view returns(uint256 _marketBackedValue){

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        require(_validStableCoin(_backedCoin,_mintCoin),"not validStableCoin");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        uint256 _numerator = rates[_key].currentRate.numerator;

        uint256 _denominator = rates[_key].currentRate.denominator;

        _marketBackedValue = _mintValue.mul(_numerator).div(_denominator);

        return;
    }

    function currentRate(
        string memory _backedCoin,
        string memory _mintCoin)
    public  view returns(
        uint256 _numerator,
        uint256 _denominator,
        uint256 _collateralRate,
        uint256 _liquidationdRate){

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        _numerator = rates[_key].currentRate.numerator;

        _denominator = rates[_key].currentRate.denominator;

        _collateralRate = rates[_key].collateralRate;

        _liquidationdRate = rates[_key].liquidationdRate;

        return;

    }
    function _marketMintValue(
        string memory _backedCoin,
        string memory _mintCoin,
        uint256 _backedValue) internal view returns(uint256 _amount) {

        require(stabeCoinExists(_backedCoin,_mintCoin),"not exitst");

        bytes32 _key =  genStableCoinKey(_backedCoin,_mintCoin);

        Rate memory _rate = rates[_key];

        _amount = _backedValue.mul(_rate.currentRate.denominator).div(_rate.currentRate.numerator);

        return;
    }



    function _setDMW(address _newDMW) internal {
        IDMWCoin(dmwCoinAddress).setDMW(_newDMW);
    }

}
