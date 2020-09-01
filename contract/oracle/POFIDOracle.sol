pragma solidity 0.6.8;

import "./POFIDOracleControl.sol";

pragma experimental ABIEncoderV2;

interface IDMW {
    function setCurrentRate(
        string calldata _backedCoin,
        string calldata _mintCoin,
        uint256 _numerator,
        uint256 _denominator) external;
}

contract POFIDOracle is POFIDOracleControl {

    struct ExchangeRate {
        string backedCoin;
        string mintCoin;
        uint256 numerator;
        uint256 denominator;
    }

    struct ExchangeRateReq {
        string fiat;
        string backedCoin;
        string mintCoin;
        uint256 numerator;
        uint256 denominator;
        bool push;
    }

    struct Rate {
        uint256 numerator;
        uint256 denominator;
    }

    mapping(bytes32 =>Rate) seroOfFiat;

    mapping(bytes32 =>Rate) seroOfMint;

    mapping(bytes32 => ExchangeRate) public exchangeRate;

    IDMW public dmw;

    constructor(address dmwAddress) public {
        dmw = IDMW(dmwAddress);
    }


    function equals(string memory a, string memory b) internal pure returns (bool) {
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

    function setDMW(address _dmw) public onlyOwner{
        dmw = IDMW(_dmw);
    }

    function genStableCoinKey(string memory backedCoin,string memory mintCoin) internal pure returns(bytes32){
        return keccak256(abi.encode(backedCoin,mintCoin));
    }

    function _addExchangeRate(string memory fiat,string memory backedCoin,string memory mintCoin,uint256 numerator,uint256 denominator) internal{
        ExchangeRate memory _exchangeRate= ExchangeRate(backedCoin,mintCoin,numerator,denominator);
        bytes32 _key = genStableCoinKey(backedCoin,mintCoin);
        exchangeRate[_key] = _exchangeRate;
        if (equals(backedCoin,"SERO")){
            Rate memory _rate = Rate(numerator,denominator);
            bytes32 _fiatKey = keccak256(abi.encode(fiat));
            seroOfFiat[_fiatKey] = _rate;
            bytes32 _mintKey = keccak256(abi.encode(mintCoin));
            seroOfMint[_mintKey] = _rate;
        }

    }

    function updateRate(ExchangeRateReq[] calldata rates) external onlyApproved{
        require(rates.length>0,"no data");
        for(uint256 i=0;i<rates.length;i++){
            require(rates[i].numerator>0&&rates[i].denominator>0,"invalid rate");
            if (rates[i].push) {
                dmw.setCurrentRate(rates[i].backedCoin,rates[i].mintCoin,rates[i].numerator,rates[i].denominator);
            }
            _addExchangeRate(rates[i].fiat,rates[i].backedCoin,rates[i].mintCoin,rates[i].numerator,rates[i].denominator);
        }
    }



    function getRate(string memory backedCoin,string memory mintCoin) public view returns(uint256 numerator,uint256 denominator){
        bytes32 _key = genStableCoinKey(backedCoin,mintCoin);
        return (exchangeRate[_key].numerator,exchangeRate[_key].denominator);
    }


    function seroPrice(string memory fiat) public view returns(uint256 ,uint256 ) {
        bytes32 _fiatKey = keccak256(abi.encode(fiat));
        Rate memory _rate = seroOfFiat[_fiatKey];
        require(_rate.numerator>0&& _rate.denominator >0,"not exists");
        return (_rate.denominator,_rate.numerator);
    }

    function seroPriceOfMint(string memory mint) public view returns(uint256 ,uint256 ) {
        bytes32 _mintKey = keccak256(abi.encode(mint));
        Rate memory _rate = seroOfMint[_mintKey];
        require(_rate.numerator>0&& _rate.denominator >0,"not exists");
        return (_rate.denominator,_rate.numerator);
    }



}