// Copyright 2020 The go-pofid Authors
// This file is part of the go-pofid library.
//
// The go-pofid library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-pofid library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-pofid library. If not, see <http://www.gnu.org/licenses/>.

package service

import (
	"encoding/json"
	"fmt"
	"github.com/pofid-dao/go-pofid/config"
	"testing"
)

func TestNewBatchEngine(t *testing.T) {
	exs := config.ExURL{
		GATE:   "https://www.gatecn.io/api2/1/ticker/sero_usdt",
		BITZ:   "https://api.bitzapi.com/Market/ticker?symbol=sero_usdt",
		BIGONE: "https://www.bigonechina.com/api/v3/asset_pairs/SERO-USDT/ticker",
		MXC:    "https://www.mxcio.co/open/api/v1/data/ticker?market=SERO_USDT",
		HBTC:   "https://api.hbtc.com/openapi/quote/v1/ticker/price?symbol=SEROUSDT",
	}
	s := NewService(exs)
	r, e := s.getExchangeRate()
	if e != nil {
		t.Error(e)
	}
	j, e := json.Marshal(r)
	fmt.Println(string(j))
}
