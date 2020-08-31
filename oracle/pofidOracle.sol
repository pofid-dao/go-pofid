pragma solidity 0.4.26;

pragma experimental ABIEncoderV2;

contract  IOracle {

struct ExchangeRate {
string backedCoin;
string mintCoin;
uint256 numerator;
uint256 denominator;
}


function updateRate(ExchangeRate[] rates) external;
}