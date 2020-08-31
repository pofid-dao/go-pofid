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

    mapping(bytes32 => ExchangeRate) public exchangeRate;

    IDMW public dmw;

    constructor(address dmwAddress) public {
        dmw = IDMW(dmwAddress);
    }


    function setDMW(address _dmw) public onlyOwner{
        dmw = IDMW(_dmw);
    }

    function genStableCoinKey(string memory backedCoin,string memory mintCoin) internal pure returns(bytes32){
        return keccak256(abi.encode(backedCoin,mintCoin));
    }

    function _addExchangeRate(string memory backedCoin,string memory mintCoin,uint256 numerator,uint256 denominator) internal{
        ExchangeRate memory _exchangeRate= ExchangeRate(backedCoin,mintCoin,numerator,denominator);
        bytes32 _key = genStableCoinKey(backedCoin,mintCoin);
        exchangeRate[_key] = _exchangeRate;
    }

    function updateRate(ExchangeRate[] calldata rates) external onlyApproved{
        require(rates.length>0,"no data");
        for(uint256 i=0;i<rates.length;i++){
            dmw.setCurrentRate(rates[i].backedCoin,rates[i].mintCoin,rates[i].numerator,rates[i].denominator);
            _addExchangeRate(rates[i].backedCoin,rates[i].mintCoin,rates[i].numerator,rates[i].denominator);
        }
    }



    function getRate(string memory backedCoin,string memory mintCoin) public view returns(uint256 numerator,uint256 denominator){
        bytes32 _key = genStableCoinKey(backedCoin,mintCoin);
        return (exchangeRate[_key].numerator,exchangeRate[_key].denominator);
    }


}