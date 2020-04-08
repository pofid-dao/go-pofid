<p align="center"><a href="#" target="_blank" rel="noopener noreferrer"><img width="500" src="../images/pofid-icon.png"></a></p>


## Introduction
In the fiat currency world, the unit of money is typically backed by gold. Meanwhile, mainstream coins like Bitcoin
coins like Bitcoin is like a new gold standard in the cryptocurrency.we can issue a stable coin in the unit of fiat currency which is backed by mainstream coins.

## How it works?
Through the cross-chain technology and the mechanism of the oracle machine, the ecology of other chains can easily realize some special business logic through smart contracts.

The DMW smart contract is a basic tool. Anyone can use this smart contract to obtain stable coins and pledge some valuable coins (for example: SERO)
The DMW smart contract has the following feature.

1.This smart contract supports the issuance of stablecoins backed by any coin
, when setting rate , collateralRate and thresholdRate. for exmaple, we can issue a stable coin in the unit of USD (we call SUSDT) which is backed by SERO.

2.Anyone can invoke the function issue() along with the collateral Valuable coins and then get Stablecoin back.
for example, the amount of SUSDT would be issued as the proportion 1:1.5 (~66.67%) of the collateralized SERO (this proportion is adjustable).

3.stableCoin holders can freely transfer any amount of stableCoin to anyone.

4.In cate the backed coin price drops which makes Backed coin price on a specific contract lese than or equals to thresholdRate of the collateralised backed coin.
The contract will be publicly auctioned，the start price is targetContract.backedValue * currentRate.After the auction, the highest bidde to take over the contract and take away the collateralized Backed coin.

## Example scenarios of SUSTD Bcked by SERO
### Scenario 1 - SERO price is stable

<img width="500" src="../images/price-stable.png">

 1) Alice sends 3000 SERO at a current Rate 20 SERO/SUSTD to DMW Smart Contract (calling issue());
 2) Alice receives 98 SUSTD back(at 1.5 SERO: 1 SUSDT ratio,and 2% fee rate);
 3) Alice decides to return 100 SUSDT to get her own SERO back(calling claim());
 4) Forunately the rate is still the same as when the SERO was deposited,so the DMW Smart Contract would return 3000 SERO back to Alice

### Scenario 2 - SERO price is increasing

<img width="500" src="../images/price-incr.png">

- This scenario is similar to the first scenario. Since RBTC price is increasing, Alice is able to return 1,000 RTHB to get her own RBTC back at the rate 2,500 THB/BTC.

### Scenario 3 - sero price is decreasing

<img width="500" src="../images/price-decr-1.png">

<img width="500" src="../images/price-decr-2.png">

1) Alice sends 3000 SERO at a current Rate 20 SERO/UST to DMW Smart COntract (calling issue());

2) Alice receives 98 SUSTD back(at 1.5 SERO: 1 SUSDT ratio,and 2% fee rate);

3) a month later,SERO price is dropping to 26 SERO/USD, Thus,DMW Smart Contract force sell of Alice contract in question(when the rate ratio is lower than 1.2 SERO: 1SUSTD).Then anyone can bid for the contract，starting price is 3000/26 SUSDT.

4) Bob participates in the auction by pledged SUSTD, and the highest bid after the  auction period，Bob takes over Alice contract by providing 120 SUDTD.

5) Bob takes away 3000 SERO and Alice loses her contract,However .Alice still holds 98 SUSDT.



## Features
- Issuing new stableCoin by providing backed coin
- Oracle price feeding.
- Force sell for unhealthy contracts (below  thresholde atio).
- List of all contracts.


