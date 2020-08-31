package ex

import (
	"fmt"
	"github.com/pofid-dao/go-pofid/config"
	"testing"
)

func TestGetGateSEROUSDPrice(t *testing.T) {
	cys := []Currency{{Name: "CNY", Alias: "SCNY"}}
	r, err := getCurrencyRateByFixer(cys)

	if err != nil {
		t.Error(err)
	}
	fmt.Println(r)
}

func TestNewBatchEngine(t *testing.T) {
	exs := config.ExURL{
		GATE:   "https://www.gatecn.io/api2/1/ticker/sero_usdt",
		BITZ:   "https://api.bitzapi.com/Market/ticker?symbol=sero_usdt",
		BIGONE: "https://www.bigonechina.com/api/v3/asset_pairs/SERO-USDT/ticker",
		MXC:    "https://www.mxcio.co/open/api/v1/data/ticker?market=SERO_USDT",
		HBTC:   "https://api.hbtc.com/openapi/quote/v1/ticker/price?symbol=SEROUSDT",
	}
	b := NewBatchEngine(exs)
	n, d, err := b.GetAVPrice()
	if err != nil {
		t.Error(err)
	}
	fmt.Println(">>>", n, d)
}
