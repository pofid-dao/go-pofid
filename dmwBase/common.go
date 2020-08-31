package dmwBase


type ExchangeRate struct{
	Index uint64
	Name string
    BackedCoin string
	MintCoin string
	URL string `json:"url"`
}

type TradingPairs struct {
	ExchangeRates []ExchangeRate
}
