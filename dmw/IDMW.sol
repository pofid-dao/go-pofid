pragma solidity ^0.4.25;

interface DMW {

    function currentRate(
        string  _backedCoin,
        string  _mintCoin)
    external  view returns(
        uint256 _numerator,
        uint256 _denominator,
        uint256 _collateralRate,
        uint256 _thresholdRate);
}
