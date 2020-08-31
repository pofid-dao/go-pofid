package service

import (
	"errors"
	"fmt"
	"github.com/pofid-dao/go-pofid/client"
	"github.com/pofid-dao/go-pofid/common"
	"github.com/pofid-dao/go-pofid/config"
	"github.com/pofid-dao/go-pofid/ex"
	"github.com/pofid-dao/go-pofid/oracle"
	"github.com/shopspring/decimal"
	"log"
	"math/big"
	"time"
)

//var currencys = []ex.Currency{{"USD", "SUSD"},
//	{"CNY", "SCNY"},
//	{"JPY", "SJPY"},
//	{"KRW", "SKRW"},
//	{"EUR", "SEUR"},
//	{"GBP", "SGBP"}}

var currencys = []ex.Currency{{"USD", "SUSD", true}}

var backedCoin = "SERO"

type OracleService struct {
	currencys []ex.Currency
	cyR       *ex.CurrencyRateEngine
	engine    *ex.USDTEngine
}

func NewService(exs config.ExURL) *OracleService {
	engine := ex.NewBatchEngine(exs)
	cyR := ex.NewCurrencyEngine(currencys)
	return &OracleService{currencys, cyR, engine}
}

func (s *OracleService) getExchangeRate() (rates []oracle.ExchangeRate, err error) {

	n, d, err := s.engine.GetAVPrice()
	if err != nil {
		return nil, err
	}
	cyRates := s.cyR.GetCurrencyRate()

	for _, cy := range s.currencys {
		cyr := cyRates[cy.Alias]
		if cyr == 0 {
			return nil, errors.New(fmt.Sprintf("not find %s currencyRate", cy.Alias))
		}
		rn, rd := getExchangeRate(n, d, cyr)
		if rn.Sign() == 0 || rd.Sign() == 0 {
			continue
		}
		er := oracle.ExchangeRate{backedCoin, cy.Alias, rn, rd}

		if cy.Check {
			if validPrice(backedCoin, cy.Alias, rn.Int64(), rd.Int64()) {
				rates = append(rates, er)
			}
		} else {
			rates = append(rates, er)
		}

	}

	return
}

func getExchangeRate(n, d int64, r float64) (rn *big.Int, rd *big.Int) {
	rn = big.NewInt(n)
	rd = decimal.NewFromInt(d).Mul(decimal.NewFromFloat(r)).Truncate(8).BigInt()
	return
}

var minGasBalance, _ = big.NewInt(0).SetString("50000000000000000", 10)

func (s *OracleService) UpdateRate() {

	for {

		b, err := common.GetMaxAvailable(client.GetOraclePK(), "SERO")
		if b.Cmp(minGasBalance) < 0 {
			log.Println("not enough utxo")
			time.Sleep(10 * time.Second)
			continue
		}

		exrs, err := s.getExchangeRate()

		if err != nil {
			log.Println("get getExchangeRate error", err)
			time.Sleep(1 * time.Minute)
			continue
		}
		if len(exrs) == 0 {
			log.Println("not get getExchangeRate ")
			time.Sleep(1 * time.Minute)
			continue
		}

		tx, e := client.SetCurrentRate(exrs)
		if e != nil {
			log.Println("setCurrentRate failed", e)
			time.Sleep(10 * time.Second)
			continue
		}
		tc, err := common.WaitTransactionReceipt(tx.Hash())
		if err != nil {
			log.Println("getTransactionReceipt failed", err)
			continue
		}
		if tc.Status == 1 {
			log.Println("update successful", tx.Hash().String())
		} else {
			log.Println("update failed", tx.Hash().String())
			continue
		}
		time.Sleep(10 * time.Minute)
	}
}

func validPrice(backedCoin, mintCoint string, n, d int64) bool {

	bigN, bigD, err := client.GetCurrentRate(backedCoin, mintCoint)
	if err != nil {
		log.Println(fmt.Sprintf("get %s %s currentRate err %s", backedCoin, mintCoint, err))
	}
	currentRate := decimal.NewFromBigInt(bigD, 64).Div(decimal.NewFromBigInt(bigN, 64))

	log.Println(fmt.Sprintf(">>>> %s %s currentRate in chain is %s", backedCoin, mintCoint, currentRate.String()))

	realRate := decimal.NewFromInt(d).Div(decimal.NewFromInt(n))

	if realRate.Cmp(currentRate) < 0 {
		if realRate.Cmp(currentRate.Mul(decimal.NewFromFloat(0.7))) < 0 {
			log.Println(">>>>>>>>>> realRate is less than 70 percent of currentRate in chain >>>>>>>>>")
			return false
		} else {
			return true
		}
	} else {
		return true
	}

}
