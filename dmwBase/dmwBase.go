// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package dmwBase

import (
	"strings"

	"github.com/sero-cash/go-sero/accounts/abi"
	"github.com/sero-cash/go-sero/accounts/abi/bind"
	"github.com/sero-cash/go-sero/common"
	"github.com/sero-cash/go-sero/core/types"
)

// IDMWBaseABI is the input ABI used to generate the binding from.
const IDMWBaseABI = "[{\"constant\":true,\"inputs\":[{\"name\":\"lang\",\"type\":\"string\"}],\"name\":\"getTradingPairs\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"

// IDMWBaseBin is the compiled bytecode used for deploying new contracts.
const IDMWBaseBin = `0x`

// DeployIDMWBase deploys a new Ethereum contract, binding an instance of IDMWBase to it.
func DeployIDMWBase(auth *bind.TransactOpts, backend bind.ContractBackend) (common.Address, *types.Transaction, *IDMWBase, error) {
	parsed, err := abi.JSON(strings.NewReader(IDMWBaseABI))
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	address, tx, contract, err := bind.DeployContract(auth, parsed, common.FromHex(IDMWBaseBin), backend)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &IDMWBase{IDMWBaseCaller: IDMWBaseCaller{contract: contract}, IDMWBaseTransactor: IDMWBaseTransactor{contract: contract}, IDMWBaseFilterer: IDMWBaseFilterer{contract: contract}}, nil
}

// IDMWBase is an auto generated Go binding around an Ethereum contract.
type IDMWBase struct {
	IDMWBaseCaller     // Read-only binding to the contract
	IDMWBaseTransactor // Write-only binding to the contract
	IDMWBaseFilterer   // Log filterer for contract events
}

// IDMWBaseCaller is an auto generated read-only Go binding around an Ethereum contract.
type IDMWBaseCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDMWBaseTransactor is an auto generated write-only Go binding around an Ethereum contract.
type IDMWBaseTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDMWBaseFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type IDMWBaseFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDMWBaseSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type IDMWBaseSession struct {
	Contract     *IDMWBase         // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// IDMWBaseCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type IDMWBaseCallerSession struct {
	Contract *IDMWBaseCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts   // Call options to use throughout this session
}

// IDMWBaseTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type IDMWBaseTransactorSession struct {
	Contract     *IDMWBaseTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts   // Transaction auth options to use throughout this session
}

// IDMWBaseRaw is an auto generated low-level Go binding around an Ethereum contract.
type IDMWBaseRaw struct {
	Contract *IDMWBase // Generic contract binding to access the raw methods on
}

// IDMWBaseCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type IDMWBaseCallerRaw struct {
	Contract *IDMWBaseCaller // Generic read-only contract binding to access the raw methods on
}

// IDMWBaseTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type IDMWBaseTransactorRaw struct {
	Contract *IDMWBaseTransactor // Generic write-only contract binding to access the raw methods on
}

// NewIDMWBase creates a new instance of IDMWBase, bound to a specific deployed contract.
func NewIDMWBase(address common.Address, backend bind.ContractBackend) (*IDMWBase, error) {
	contract, err := bindIDMWBase(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &IDMWBase{IDMWBaseCaller: IDMWBaseCaller{contract: contract}, IDMWBaseTransactor: IDMWBaseTransactor{contract: contract}, IDMWBaseFilterer: IDMWBaseFilterer{contract: contract}}, nil
}

// NewIDMWBaseCaller creates a new read-only instance of IDMWBase, bound to a specific deployed contract.
func NewIDMWBaseCaller(address common.Address, caller bind.ContractCaller) (*IDMWBaseCaller, error) {
	contract, err := bindIDMWBase(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &IDMWBaseCaller{contract: contract}, nil
}

// NewIDMWBaseTransactor creates a new write-only instance of IDMWBase, bound to a specific deployed contract.
func NewIDMWBaseTransactor(address common.Address, transactor bind.ContractTransactor) (*IDMWBaseTransactor, error) {
	contract, err := bindIDMWBase(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &IDMWBaseTransactor{contract: contract}, nil
}

// NewIDMWBaseFilterer creates a new log filterer instance of IDMWBase, bound to a specific deployed contract.
func NewIDMWBaseFilterer(address common.Address, filterer bind.ContractFilterer) (*IDMWBaseFilterer, error) {
	contract, err := bindIDMWBase(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &IDMWBaseFilterer{contract: contract}, nil
}

// bindIDMWBase binds a generic wrapper to an already deployed contract.
func bindIDMWBase(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(IDMWBaseABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDMWBase *IDMWBaseRaw) Call(opts *bind.CallOpts, result interface{}, method string, params ...interface{}) error {
	return _IDMWBase.Contract.IDMWBaseCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDMWBase *IDMWBaseRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDMWBase.Contract.IDMWBaseTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDMWBase *IDMWBaseRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDMWBase.Contract.IDMWBaseTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDMWBase *IDMWBaseCallerRaw) Call(opts *bind.CallOpts, result interface{}, method string, params ...interface{}) error {
	return _IDMWBase.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDMWBase *IDMWBaseTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDMWBase.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDMWBase *IDMWBaseTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDMWBase.Contract.contract.Transact(opts, method, params...)
}

// GetTradingPairs is a free data retrieval call binding the contract method 0x07574c32.
//
// Solidity: function getTradingPairs(lang string) constant returns(string)
func (_IDMWBase *IDMWBaseCaller) GetTradingPairs(opts *bind.CallOpts, lang string) (string, error) {
	var (
		ret0 = new(string)
	)
	out := ret0
	err := _IDMWBase.contract.Call(opts, out, "getTradingPairs", lang)
	return *ret0, err
}

// GetTradingPairs is a free data retrieval call binding the contract method 0x07574c32.
//
// Solidity: function getTradingPairs(lang string) constant returns(string)
func (_IDMWBase *IDMWBaseSession) GetTradingPairs(lang string) (string, error) {
	return _IDMWBase.Contract.GetTradingPairs(&_IDMWBase.CallOpts, lang)
}

// GetTradingPairs is a free data retrieval call binding the contract method 0x07574c32.
//
// Solidity: function getTradingPairs(lang string) constant returns(string)
func (_IDMWBase *IDMWBaseCallerSession) GetTradingPairs(lang string) (string, error) {
	return _IDMWBase.Contract.GetTradingPairs(&_IDMWBase.CallOpts, lang)
}
