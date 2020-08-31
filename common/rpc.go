package common

import (
	"bytes"
	"context"
	"encoding/json"
	"github.com/pkg/errors"
	"github.com/pofid-dao/go-pofid/config"
	"github.com/sero-cash/go-sero/common"
	"github.com/sero-cash/go-sero/core/types"
	"github.com/sero-cash/go-sero/seroclient"
	"github.com/shopspring/decimal"
	"io/ioutil"
	"log"
	"math/big"
	"net/http"
	"strconv"
	"time"
)

var seroClient *seroclient.Client
var sero_url string

func Init(config config.Config) {
	seroClient, _ = seroclient.Dial(config.URL)
	sero_url = config.URL
}

func doRequest(paramsJson string) (body []byte, err error) {
	var jsonStr = []byte(paramsJson)
	req, err := http.NewRequest("POST", sero_url, bytes.NewBuffer(jsonStr))
	if err != nil {
		log.Println("response err:", err)
		return
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Println("response err:", err)
		return nil, err
	}
	defer resp.Body.Close()

	body, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("io util.ReadAll err", err)
	}
	return body, err
}

type errorCode struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}
type blockStringReturn struct {
	Jsonrpc string    `json:"jsonrpc"`
	id      uint64    `json:"id"`
	Result  string    `json:"result"`
	Error   errorCode `json:"error"`
}

func CurrentBlockNum() (blockNumber uint64) {
	var paramsJson = `{"jsonrpc":"2.0","method":"sero_blockNumber","params":[],"id":1}`
	body, err := doRequest(paramsJson)
	if err != nil {
		log.Println("doRequest err, ", err)
		return blockNumber
	}
	blockStringReturn := blockStringReturn{}
	err = json.Unmarshal(body, &blockStringReturn)
	if err != nil {
		log.Println("json.Unmarshal err, ", err)
		return blockNumber
	}
	blockNumber, err = strconv.ParseUint(blockStringReturn.Result, 0, 64)
	if err != nil {
		log.Println("strconv.ParseUint err, ", err)
		return blockNumber
	}
	return blockNumber
}

type JSONRpcResp struct {
	Id     *json.RawMessage       `json:"id"`
	Result *json.RawMessage       `json:"result"`
	Error  map[string]interface{} `json:"error"`
}

func GetMaxAvailable(address string, currency string) (*big.Int, error) {

	params := []string{address, currency}

	jsonReq := map[string]interface{}{"jsonrpc": "2.0", "method": "exchange_getMaxAvailable", "params": params, "id": 0}

	data, _ := json.Marshal(jsonReq)

	body, err := doRequest(string(data))
	if err != nil {
		log.Println("doRequest err, ", err)
		return nil, err
	}

	var rpcResp *JSONRpcResp

	err = json.Unmarshal(body, &rpcResp)
	if err != nil {
		return nil, err
	}
	if rpcResp.Error != nil {
		return nil, errors.New(rpcResp.Error["message"].(string))
	}

	var reply string
	err = json.Unmarshal(*rpcResp.Result, &reply)
	if err != nil {
		return nil, err
	}
	d, err := decimal.NewFromString(reply)
	if err != nil {
		return nil, err
	}

	return d.BigInt(), err
}

func TransactionReceipt(txHash common.Hash) (*types.Receipt, error) {
	return seroClient.TransactionReceipt(context.Background(), txHash)
}

func WaitTransactionReceipt(txHash common.Hash) (r *types.Receipt, e error) {
	time.Sleep(14 * time.Second)
	start := CurrentBlockNum()

	r, e = seroClient.TransactionReceipt(context.Background(), txHash)

	for {
		if r == nil || e != nil {
			r, e = seroClient.TransactionReceipt(context.Background(), txHash)
			time.Sleep(14 * time.Second)
		}
		if r != nil {
			return
		}
		current := CurrentBlockNum()
		if current > start+12 {
			return nil, errors.New("after 12 blocks")
		}
	}

}
