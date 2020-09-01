package ex

import (
	"encoding/json"
	"github.com/robfig/cron"
	"github.com/shopspring/decimal"
	"io/ioutil"
	"log"
	"sync"
)

type CurrencyRate struct {
	base string
	to   string
	rate float64
}

const BaseCurrency = "USD"

type Currency struct {
	Name  string
	Alias string
	Check bool
	Push  bool
}

type CurrencyRateEngine struct {
	rux sync.RWMutex

	currenys []Currency

	rates map[string]float64
}

var ecbUrl = "https://api.exchangeratesapi.io/latest"

var fixerUrl = "http://data.fixer.io/api/latest?access_key=fde8e0fd9882301b483f7dd9927bc03a&format=1"

type ECBResult struct {
	Success bool               `json:"success"`
	Base    string             `json:"base"`
	Date    string             `json:"date"`
	Rates   map[string]float64 `json:"rates"`
}

func getCurrencyRateByECB(currencys []Currency) (result map[string]float64, err error) {
	res, err := client.Get(ecbUrl, nil)
	if err != nil {
		log.Println("getCurrencyRateByECB first error", err)
		res, err = client.Get(ecbUrl, nil)
		if err != nil {
			log.Println("getCurrencyRateByECB second error", err)
			return
		}
	}
	var ecbResult ECBResult
	err = json.NewDecoder(res.Body).Decode(&ecbResult)
	if err != nil {
		return
	}
	result = ecbResult.convert(currencys)
	return
}

func getCurrencyRateByFixer(currencys []Currency) (result map[string]float64, err error) {
	res, err := client.Get(fixerUrl, nil)
	if err != nil {
		log.Println("getCurrencyRateByFixer first error", err)
		res, err = client.Get(fixerUrl, nil)
		if err != nil {
			log.Println("getCurrencyRateByFixer second error", err)
			return
		}

	}
	var ecbResult ECBResult

	b, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	log.Println(">>", string(b))
	err = json.Unmarshal(b, &ecbResult)
	//err = json.NewDecoder(res.Body).Decode(&ecbResult)
	if err != nil {
		log.Println("getCurrencyRateByFixer Unmarshal error", err)
		return
	}
	result = ecbResult.convert(currencys)
	return
}

func (e ECBResult) convert(currencys []Currency) (result map[string]float64) {
	if len(e.Rates) > 0 {
		base := e.Rates[BaseCurrency]
		if base > 0 {
			result = map[string]float64{}
			for _, c := range currencys {
				if e.Rates[c.Name] > 0 {
					result[c.Alias], _ = decimal.NewFromFloat(e.Rates[c.Name]).Div(decimal.NewFromFloat(base)).Truncate(8).Float64()
				}
			}
		}
	}
	return
}

func NewCurrencyEngine(currencys []Currency) *CurrencyRateEngine {
	rates, err := getCurrencyRateByFixer(currencys)
	if err != nil {
		log.Println("NewCurrencyEngine", err)
		panic("getCurrencyRate failed")
	}

	ce := &CurrencyRateEngine{
		currenys: currencys,
		rates:    rates,
	}

	//ce.updateRate()

	c := cron.New()

	c.AddFunc("@every 2h", ce.updateRate)

	c.Start()

	return ce
}

func (e *CurrencyRateEngine) GetCurrencyRate() map[string]float64 {
	return e.rates
}

func (e *CurrencyRateEngine) updateRate() {

	r, err := getCurrencyRateByFixer(e.currenys)

	if err != nil {
		log.Println("getCurrencyRateByFixer err", err)
		return

	}
	e.rates = r

}
