package config

import (
	"bufio"
	"errors"
	"fmt"
	"github.com/naoina/toml"
	"os"
	"reflect"
	"unicode"
)

type Config struct {
	URL     string
	WS      string
	Oracle  ContractConfig
	DMWBase ContractConfig
	DMW     ContractConfig
	Exs     ExURL
}

type ContractConfig struct {
	ContractAddress string
	KeystorePath    string
	Password        string
}
type ExURL struct {
	GATE   string
	BITZ   string
	BIGONE string
	MXC    string
	HBTC   string
}

var tomlSettings = toml.Config{
	NormFieldName: func(rt reflect.Type, key string) string {
		return key
	},
	FieldToKey: func(rt reflect.Type, field string) string {
		return field
	},
	MissingField: func(rt reflect.Type, field string) error {
		link := ""
		if unicode.IsUpper(rune(rt.Name()[0])) && rt.PkgPath() != "pofid" {
			link = fmt.Sprintf(", see https://godoc.org/%s#%s for available fields", rt.PkgPath(), rt.Name())
		}
		return fmt.Errorf("field '%s' is not defined in %s%s", field, rt.String(), link)
	},
}

func LoadConfig(file string) (*Config, error) {
	cfg := &Config{}

	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	err = tomlSettings.NewDecoder(bufio.NewReader(f)).Decode(cfg)
	// Add file name to errors that have a line number.
	if _, ok := err.(*toml.LineError); ok {
		err = errors.New(file + ", " + err.Error())
	}
	if err != nil {
		return nil, err
	}
	return cfg, nil
}
