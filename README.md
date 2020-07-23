<p align="center"><a href="https://novac.pofid.com" target="_blank" rel="noopener noreferrer"><img width="500" src="./images/POFID-icon.png"></a></p>

# Introduction of Core Smart Contract

This repository contains POFID's core smart contract code. Assuming familiarity with the basic economic mechanisms described in the white paper, this is a high-level description of the system.

## DMW Smart Contract

## Introduction
In the fiat currency world, the unit of money is typically backed by gold. Meanwhile, mainstream coins like Bitcoin
coins like Bitcoin is like a new gold standard in the cryptocurrency.we can issue a stable coin in the unit of fiat currency which is backed by mainstream coins.

## How it works?
Through the cross-chain technology and the mechanism of the oracle machine, the ecology of other chains can easily realize some special business logic through smart contracts.

The DMW smart contract is a basic tool. Anyone can use this smart contract to obtain stable coins and pledge some valuable coins (for example: SERO)
The DMW smart contract has the following feature.

1.This smart contract supports the issuance of stablecoins backed by any coin
, when setting rate , collateralRate and liquidationdRate. for exmaple, we can issue a stable coin in the unit of USD (we call SUSD) which is backed by SERO.

2.Anyone can invoke the function issue() along with the collateral Valuable coins and then get Stablecoin back.

3.stableCoin holders can freely transfer any amount of stableCoin to anyone.

4.If the price of the backed coin falls, resulting in a reduction in the collateral rate of the loan but not reaching the liquidation rate, 
Borrowers can choose to redeem collateralized coins or other collateral to maintain the collateral rate of the loan.
Once the loan's collateral rate is lower than or equal to the system's liquidation rate, 
then the loan's collateralized backed coin will be publicly auctioned.For a fixed price, whoever first makes up the collateral rate of the loan to the system collateral rate will get the redemption right of the loan.
## Example scenarios of SUSTD Bcked by SERO
### Scenario 1 - SERO price is stable

<img width="500" src="./images/price-stable.png">

 1) Alice sends 3600 SERO at a current Rate 20 SERO/USD to DMW Smart Contract (calling issue());
 2) Alice receives 98 SUSD back(at 1.8 USD: 1 SUSD ratio,and 2% fee rate);
 3) Alice decides to return 100 SUSD to get her own SERO back(calling claim());
 4) Forunately the rate is still the same as when the SERO was deposited,so the DMW Smart Contract would return 3000 SERO back to Alice

### Scenario 2 - SERO price is increasing

<img width="500" src="./images/price-incr.png">

- This scenario is similar to the first scenario. Since RBTC price is increasing, Alice is able to return 1,000 RTHB to get her own RBTC back at the rate 2,500 THB/BTC.

### Scenario 3 - sero price is decreasing

<img width="500" src="./images/price-decr-1.png">

1) Alice sends 3600 SERO at a current Rate 20 SERO/USD to DMW Smart COntract (calling issue());

2) Alice receives 98 SUSD back(at 1.8 USD: 1 SUSD ratio,and 2% fee rate);

3) a month later,SERO price is dropping to 25 SERO/USD, the rate ratio is lower than 1.8 USD : 1 SUSD，but has not reached 1.3 USD : 1 SUSD，
then Alice can have two options, the first option is that he can send 100 SUSD to the smart contract to redeem 3600 SERO.
The second option is to send 900 SERO to the smart contract to maintain the rate ratio is 1.8 USD : 1 SUSD.


### Scenario 4 - sero price is decreasing

<img width="500" src="./images/price-decr-2.png">

1) Alice sends 3600 SERO at a current Rate 20 SERO/USD to DMW Smart COntract (calling issue());

2) Alice receives 98 SUSD back(at 1.8 USD: 1 SUSD ratio,and 2% fee rate);

3) a month later,SERO price is dropping to 30 SERO/USD, the rate ratio is lower than 1.3 USD : 1 SUSD，Alice's operation is similar to Scenario 3.If Alice does not redeem the pledged SERO, then anyone can bid on the asset, only need to make up the  rate ratio to 1.8 USD : 1 SUSD, on a first-come-first-served basis

4) If Bob is the first bidder, Bob obtains a right to redeem 4800 SERO.If the  rate ratio range is between 1.8-1.3 USD : 1 SUSD, Bob sends 100 SUSD to the smart contract to redeem 4800 SERO.


## Features
- Issuing new stableCoin by providing backed coin
- Oracle price feeding.
- Force auction for unhealthy contracts (below 1.3 USD : 1 SUSD ratio).
- List of all contracts.


## Staking Smart Contract

### Introduction

POFIDStaking is a protocol for decentralized apps, As an SERO token PFID, POFIDStaking first implements the Proof-of-Stake mechanism, meaning that every holder can earn some extra tokens PFID just by holding POFIDStaking for a period of 30 days,60 days or 90 days.

At the same time, participating in PFID pos can also obtain additional rewards for issuing stable coins in the POFID ecosystem. It is distributed according to the currency age.
PFID issued a total of 10 million, of which 5.1 million will have POFIDStaking output in 10 years, with a maximum output of 50W per year. By controlling the interest rate of the pledge cycle, only when all the PFIDs currently released all participate in the 90-day POS can we guarantee the annual 50W PFID is released. This means that in actual operation, PFID may be destroyed every year. The end result is that the total output of PFID is less than 10 million.

### POFIDStaking Interest
#### Interest rate change table
<img width="500" src="./images/staking-interest.png">

1) The interest for every 30 days in the first year is 4 ‰, which will decrease by 10% each year thereafter

2) The interest for every 60 days in the first year is 1 %, which will decrease by 10% each year thereafter

3) The interest for every 90 days in the first year is 2.6 ‰, which will decrease by 10% each year thereafter

### Example
<img width="500" src="./images/staking-1.png">

1) Bob pledge a part of the tokens into the pos smart contract

2) Alice issues stablecoins, the coinage fee will be sent to the pos staking contract, and the rest will be sent to Alice's personal account

3) When the pledge expires, in addition to the normal staking interest, bob can also enjoy the share of the coinage fee of the stablecoin.
