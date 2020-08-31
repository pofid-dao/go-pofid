package client

import (
	"encoding/json"
	"github.com/pofid-dao/go-pofid/config"
	"github.com/pofid-dao/go-pofid/dmw"
	"github.com/pofid-dao/go-pofid/dmwBase"
	"github.com/pofid-dao/go-pofid/oracle"
	"github.com/sero-cash/go-sero/accounts/abi/bind"
	"github.com/sero-cash/go-sero/common"
	"github.com/sero-cash/go-sero/core/types"
	"github.com/sero-cash/go-sero/seroclient"
	"io/ioutil"
	"log"
	"math/big"
	"strings"
)

var IDMWBase *dmwBase.IDMWBase

var IOracle *oracle.IOracle

var IDMW *dmw.DMW

var oracleAuth *bind.TransactOpts

func InitContractClient(config config.Config, password string) {
	backend, err := seroclient.Dial(config.WS)
	if err != nil {
		panic(err)
	}
	IDMWBase, _ = dmwBase.NewIDMWBase(common.Base58ToAddress(config.DMWBase.ContractAddress), backend)

	IDMW, _ = dmw.NewDMW(common.Base58ToAddress(config.DMW.ContractAddress), backend)

	IOracle, _ = oracle.NewIOracle(common.Base58ToAddress(config.Oracle.ContractAddress), backend)
	json, err := ioutil.ReadFile(config.Oracle.KeystorePath)
	if err != nil {
		panic(err)
	}

	oracleAuth, err = bind.NewTransactor(strings.NewReader(string(json)), password, nil)
	if err != nil {
		panic(err)
	}
}

func SetCurrentRate(rates []oracle.ExchangeRate) (*types.Transaction, error) {
	return IOracle.UpdateRate(oracleAuth, rates)
}

func GetCurrentRate(backedCoin, mintCoin string) (*big.Int, *big.Int, error) {
	result, err := IDMW.CurrentRate(&bind.CallOpts{}, backedCoin, mintCoin)
	if err != nil {
		return nil, nil, err
	}
	return result.Numerator, result.Denominator, nil
}

func GetTradingPair(backedCoin, mintCoin string) *dmwBase.TradingPairs {
	tradingJsonStr, err := IDMWBase.GetTradingPairs(&bind.CallOpts{}, "")
	if err != nil {
		log.Println("GetTradingPairs err", err)
		return nil
	}
	var tradingPairs dmwBase.TradingPairs

	err = json.Unmarshal([]byte(tradingJsonStr), &tradingPairs)

	if err != nil {
		log.Println("Unmarshal tradingJsonStr err", err)
		return nil
	}
	return &tradingPairs
}

func GetOraclePK() string {
	return oracleAuth.From.String()
}
