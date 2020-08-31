package ex

import (
	"encoding/json"
	"errors"
	"github.com/gojektech/heimdall/httpclient"
	"github.com/pofid-dao/go-pofid/config"
	"github.com/shopspring/decimal"
	"log"
	"sort"
	"time"
)

type ExchangePrice interface {
	GetSEROUSDPrice() (n int64, d int64, e error)
}

type ExchangeEngine struct {
	url string
}

//const (
//	GATEURL   = "https://www.gatecn.io/api2/1/ticker/sero_usdt"
//	BITZURL   = "https://api.bitzapi.com/Market/ticker?symbol=sero_usdt"
//	BIGONEURL = "https://bigonezh.com/api/v3/asset_pairs/SERO-USDT/ticker"
//	MXCURL    = "https://www.mxcio.co/open/api/v1/data/ticker?market=SERO_USDT"
//)

var timeout = 30 * time.Second

var client = httpclient.NewClient(httpclient.WithHTTPTimeout(timeout))

var Base = int64(100000000)

func exchange(price string) (n int64, d int64, err error) {
	priceDecimal, err := decimal.NewFromString(price)
	if err != nil {
		return
	}
	priceDecimal = priceDecimal.Truncate(8)
	n = Base
	d = priceDecimal.Mul(decimal.NewFromInt(Base)).BigInt().Int64()
	return
}

type BITZEngine ExchangeEngine

type BITZJSONRpcResp struct {
	Status int64            `json:"status"`
	Msg    string           `json:"msg"`
	Data   *json.RawMessage `json:"data"`
}

func (b *BITZEngine) GetSEROUSDPrice() (n int64, d int64, e error) {

	res, e := client.Get(b.url, nil)

	if e != nil {
		log.Println("BITZEngine GetSEROUSDPrice first error", e)
		res, e = client.Get(b.url, nil)
		if e != nil {
			log.Println("BITZEngine GetSEROUSDPrice second error", e)
			return
		}

	}
	var result BITZJSONRpcResp
	e = json.NewDecoder(res.Body).Decode(&result)

	if e != nil {
		log.Println("BITZEngine GetSEROUSDPrice Decode error", e)
		return
	}

	if result.Status != 200 || result.Msg != "" {
		log.Println("BITZEngine GetSEROUSDPrice result error")
		e = errors.New("BigOneEngine GetSEROUSDPrice result error")
		return
	}

	data := map[string]interface{}{}

	e = json.Unmarshal([]byte(*result.Data), &data)

	if e != nil {
		log.Println("BITZEngine GetSEROUSDPrice Unmarsha data error", e)
		return
	}

	nowPrice := data["now"]

	n, d, e = exchange(nowPrice.(string))

	if e != nil {
		log.Println("BITZEngine GetSEROUSDPrice exchange error", e)
		return
	}
	log.Println(">>>> BITZ SERO USDT Exchange Rate", n, d)

	return
}

type GateEngine ExchangeEngine

type Gate struct {
	QuoteVolume   string
	BaseVolume    string
	HighestBid    string
	High24hr      string
	Last          string
	LowestAsk     string
	Elapsed       string
	Result        string
	Low24hr       string
	PercentChange string
}

func (b *GateEngine) GetSEROUSDPrice() (n int64, d int64, e error) {
	res, e := client.Get(b.url, nil)
	if e != nil {

		log.Println("GateEngine GetSEROUSDPrice first error", e)

		res, e = client.Get(b.url, nil)
		if e != nil {
			log.Println("GateEngine GetSEROUSDPrice second error", e)
			return
		}

	}
	var result Gate
	e = json.NewDecoder(res.Body).Decode(&result)

	if e != nil {
		log.Println("GateEngine GetSEROUSDPrice Decode error", e)
		return
	}

	n, d, e = exchange(result.Last)

	if e != nil {
		log.Println("GateEngine GetSEROUSDPrice exchange error", e)
		return
	}
	log.Println(">>>> Gate SERO USDT Exchange Rate", n, d)

	return

}

type HBTCEngine ExchangeEngine

type HBTCJSONRpcResp struct {
	Price string `json:"price"`
}

func (b *HBTCEngine) GetSEROUSDPrice() (n int64, d int64, e error) {
	res, e := client.Get(b.url, nil)

	if e != nil {
		log.Println("HBTCEngine GetSEROUSDPrice first error", e)
		res, e = client.Get(b.url, nil)
		if e != nil {
			log.Println("HBTCEngine GetSEROUSDPrice second error", e)
			return
		}

	}
	var result HBTCJSONRpcResp
	e = json.NewDecoder(res.Body).Decode(&result)

	if e != nil {
		log.Println("HBTCEngine GetSEROUSDPrice Decode error", e)
		return
	}

	if result.Price == "" {
		log.Println("HBTCEngine GetSEROUSDPrice result error")
		e = errors.New("HBTCEngine GetSEROUSDPrice result error")
		return
	}

	n, d, e = exchange(result.Price)

	if e != nil {
		log.Println("HBTCEngine GetSEROUSDPrice exchange error", e)
		return
	}
	log.Println(">>>> HBTCEngine SERO USDT Exchange Rate", n, d)

	return

}

type BigOneEngine ExchangeEngine

type BigOneJSONRpcResp struct {
	Code int64            `json:"code"`
	Data *json.RawMessage `json:"data"`
}

func (b *BigOneEngine) GetSEROUSDPrice() (n int64, d int64, e error) {
	res, e := client.Get(b.url, nil)

	if e != nil {
		log.Println("BigOneEngine GetSEROUSDPrice first error", e)
		res, e = client.Get(b.url, nil)
		if e != nil {
			log.Println("BigOneEngine GetSEROUSDPrice second error", e)
			return
		}

	}
	var result BigOneJSONRpcResp
	e = json.NewDecoder(res.Body).Decode(&result)

	if e != nil {
		log.Println("BigOneEngine GetSEROUSDPrice Decode error", e)
		return
	}

	if result.Code != 0 {
		log.Println("BigOneEngine GetSEROUSDPrice result error")
		e = errors.New("BigOneEngine GetSEROUSDPrice result error")
		return
	}

	data := map[string]interface{}{}

	e = json.Unmarshal([]byte(*result.Data), &data)

	if e != nil {
		log.Println("BigOneEngine GetSEROUSDPrice Unmarsha data error", e)
		return
	}

	nowPrice := data["close"]

	n, d, e = exchange(nowPrice.(string))

	if e != nil {
		log.Println("BigOneEngine GetSEROUSDPrice exchange error", e)
		return
	}
	log.Println(">>>> BigOne SERO USDT Exchange Rate", n, d)

	return

}

type MXCEngine ExchangeEngine

type MXJSONRpcResp struct {
	Code int64            `json:"code"`
	Data *json.RawMessage `json:"data"`
	Msg  string           `json:"msg"`
}

func (b *MXCEngine) GetSEROUSDPrice() (n int64, d int64, e error) {
	res, e := client.Get(b.url, nil)

	if e != nil {
		log.Println("MXCEngine GetSEROUSDPrice  first error", e)
		res, e = client.Get(b.url, nil)
		if e != nil {
			log.Println("MXCEngine GetSEROUSDPrice  second error", e)
			return
		}

	}
	var result MXJSONRpcResp
	e = json.NewDecoder(res.Body).Decode(&result)

	if e != nil {
		log.Println("MXCEngine GetSEROUSDPrice Decode error", e)
		return
	}

	if result.Code != 200 || result.Msg != "OK" {
		log.Println("MXCEngine GetSEROUSDPrice result error")
		e = errors.New("MXCEngine GetSEROUSDPrice result error")
		return
	}

	data := map[string]interface{}{}

	e = json.Unmarshal([]byte(*result.Data), &data)

	if e != nil {
		log.Println("MXCEngine GetSEROUSDPrice Unmarsha data error", e)
		return
	}

	nowPrice := data["last"]

	n, d, e = exchange(nowPrice.(string))

	if e != nil {
		log.Println("MXCEngine GetSEROUSDPrice exchange error", e)
		return
	}
	log.Println(">>>> MXC SERO USDT Exchange Rate", n, d)

	return

}

type USDTEngine []ExchangePrice

const (
	minEngineNum = 3
)

func NewBatchEngine(exs config.ExURL) *USDTEngine {
	result := []ExchangePrice{}
	result = append(result, &GateEngine{exs.GATE})
	result = append(result, &MXCEngine{exs.MXC})
	result = append(result, &BigOneEngine{exs.BIGONE})
	result = append(result, &BITZEngine{exs.BITZ})
	result = append(result, &HBTCEngine{exs.HBTC})

	usdtEngine := USDTEngine(result)

	return &usdtEngine
}

func (ue *USDTEngine) GetAVPrice() (n int64, d int64, err error) {

	if len(*ue) < minEngineNum {
		err = errors.New("not enough engine")
		log.Println("USDTEngine GetAVPrice error,not enough engine")
		return
	}
	var floatPrices []float64

	for _, e := range *ue {
		n, d, err := e.GetSEROUSDPrice()
		if err == nil && n != 0 && d != 0 {
			fp, _ := decimal.NewFromInt(d).Div(decimal.NewFromInt(n)).Truncate(8).Float64()
			if fp > 0 {
				floatPrices = append(floatPrices, fp)
			}
		}
	}

	if len(floatPrices) < minEngineNum {
		err = errors.New("not enough price")
		log.Println("USDTEngine GetAVPrice error,not enough price")
		return
	}

	sort.Sort(Float64Slice(floatPrices))

	floatPrices = floatPrices[1:]

	totalDecimal := decimal.NewFromInt(0)

	for _, p := range floatPrices {
		totalDecimal = totalDecimal.Add(decimal.NewFromFloat(p))
	}
	avg := totalDecimal.Div(decimal.NewFromInt(int64(len(floatPrices))))

	n = Base
	d = avg.Mul(decimal.NewFromInt(Base)).BigInt().Int64()

	log.Println(">>>>>avg price", n, d)

	return

}

type Float64Slice []float64

func (s Float64Slice) Len() int { return len(s) }

func (s Float64Slice) Swap(i, j int) { s[i], s[j] = s[j], s[i] }

func (s Float64Slice) Less(i, j int) bool { return s[i] < s[j] }
