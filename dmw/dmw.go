// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package dmw

import (
	"math/big"
	"strings"

	"github.com/sero-cash/go-sero/accounts/abi"
	"github.com/sero-cash/go-sero/accounts/abi/bind"
	"github.com/sero-cash/go-sero/common"
	"github.com/sero-cash/go-sero/core/types"
)

// DMWABI is the input ABI used to generate the binding from.
const DMWABI = "[{\"constant\":true,\"inputs\":[{\"name\":\"_backedCoin\",\"type\":\"string\"},{\"name\":\"_mintCoin\",\"type\":\"string\"}],\"name\":\"currentRate\",\"outputs\":[{\"name\":\"_numerator\",\"type\":\"uint256\"},{\"name\":\"_denominator\",\"type\":\"uint256\"},{\"name\":\"_collateralRate\",\"type\":\"uint256\"},{\"name\":\"_thresholdRate\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_backedCoin\",\"type\":\"string\"},{\"name\":\"_mintCoin\",\"type\":\"string\"},{\"name\":\"_numerator\",\"type\":\"uint256\"},{\"name\":\"_denominator\",\"type\":\"uint256\"}],\"name\":\"setCurrentRate\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"

// DMWBin is the compiled bytecode used for deploying new contracts.
const DMWBin = `0x`

// DeployDMW deploys a new Ethereum contract, binding an instance of DMW to it.
func DeployDMW(auth *bind.TransactOpts, backend bind.ContractBackend) (common.Address, *types.Transaction, *DMW, error) {
	parsed, err := abi.JSON(strings.NewReader(DMWABI))
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	address, tx, contract, err := bind.DeployContract(auth, parsed, common.FromHex(DMWBin), backend)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &DMW{DMWCaller: DMWCaller{contract: contract}, DMWTransactor: DMWTransactor{contract: contract}, DMWFilterer: DMWFilterer{contract: contract}}, nil
}

// DMW is an auto generated Go binding around an Ethereum contract.
type DMW struct {
	DMWCaller     // Read-only binding to the contract
	DMWTransactor // Write-only binding to the contract
	DMWFilterer   // Log filterer for contract events
}

// DMWCaller is an auto generated read-only Go binding around an Ethereum contract.
type DMWCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// DMWTransactor is an auto generated write-only Go binding around an Ethereum contract.
type DMWTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// DMWFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type DMWFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// DMWSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type DMWSession struct {
	Contract     *DMW              // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// DMWCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type DMWCallerSession struct {
	Contract *DMWCaller    // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts // Call options to use throughout this session
}

// DMWTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type DMWTransactorSession struct {
	Contract     *DMWTransactor    // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// DMWRaw is an auto generated low-level Go binding around an Ethereum contract.
type DMWRaw struct {
	Contract *DMW // Generic contract binding to access the raw methods on
}

// DMWCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type DMWCallerRaw struct {
	Contract *DMWCaller // Generic read-only contract binding to access the raw methods on
}

// DMWTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type DMWTransactorRaw struct {
	Contract *DMWTransactor // Generic write-only contract binding to access the raw methods on
}

// NewDMW creates a new instance of DMW, bound to a specific deployed contract.
func NewDMW(address common.Address, backend bind.ContractBackend) (*DMW, error) {
	contract, err := bindDMW(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &DMW{DMWCaller: DMWCaller{contract: contract}, DMWTransactor: DMWTransactor{contract: contract}, DMWFilterer: DMWFilterer{contract: contract}}, nil
}

// NewDMWCaller creates a new read-only instance of DMW, bound to a specific deployed contract.
func NewDMWCaller(address common.Address, caller bind.ContractCaller) (*DMWCaller, error) {
	contract, err := bindDMW(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &DMWCaller{contract: contract}, nil
}

// NewDMWTransactor creates a new write-only instance of DMW, bound to a specific deployed contract.
func NewDMWTransactor(address common.Address, transactor bind.ContractTransactor) (*DMWTransactor, error) {
	contract, err := bindDMW(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &DMWTransactor{contract: contract}, nil
}

// NewDMWFilterer creates a new log filterer instance of DMW, bound to a specific deployed contract.
func NewDMWFilterer(address common.Address, filterer bind.ContractFilterer) (*DMWFilterer, error) {
	contract, err := bindDMW(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &DMWFilterer{contract: contract}, nil
}

// bindDMW binds a generic wrapper to an already deployed contract.
func bindDMW(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(DMWABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_DMW *DMWRaw) Call(opts *bind.CallOpts, result interface{}, method string, params ...interface{}) error {
	return _DMW.Contract.DMWCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_DMW *DMWRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _DMW.Contract.DMWTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_DMW *DMWRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _DMW.Contract.DMWTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_DMW *DMWCallerRaw) Call(opts *bind.CallOpts, result interface{}, method string, params ...interface{}) error {
	return _DMW.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_DMW *DMWTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _DMW.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_DMW *DMWTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _DMW.Contract.contract.Transact(opts, method, params...)
}

// CurrentRate is a free data retrieval call binding the contract method 0x0804d965.
//
// Solidity: function currentRate(_backedCoin string, _mintCoin string) constant returns(_numerator uint256, _denominator uint256, _collateralRate uint256, _thresholdRate uint256)
func (_DMW *DMWCaller) CurrentRate(opts *bind.CallOpts, _backedCoin string, _mintCoin string) (struct {
	Numerator      *big.Int
	Denominator    *big.Int
	CollateralRate *big.Int
	ThresholdRate  *big.Int
}, error) {
	ret := new(struct {
		Numerator      *big.Int
		Denominator    *big.Int
		CollateralRate *big.Int
		ThresholdRate  *big.Int
	})
	out := ret
	err := _DMW.contract.Call(opts, out, "currentRate", _backedCoin, _mintCoin)
	return *ret, err
}

// CurrentRate is a free data retrieval call binding the contract method 0x0804d965.
//
// Solidity: function currentRate(_backedCoin string, _mintCoin string) constant returns(_numerator uint256, _denominator uint256, _collateralRate uint256, _thresholdRate uint256)
func (_DMW *DMWSession) CurrentRate(_backedCoin string, _mintCoin string) (struct {
	Numerator      *big.Int
	Denominator    *big.Int
	CollateralRate *big.Int
	ThresholdRate  *big.Int
}, error) {
	return _DMW.Contract.CurrentRate(&_DMW.CallOpts, _backedCoin, _mintCoin)
}

// CurrentRate is a free data retrieval call binding the contract method 0x0804d965.
//
// Solidity: function currentRate(_backedCoin string, _mintCoin string) constant returns(_numerator uint256, _denominator uint256, _collateralRate uint256, _thresholdRate uint256)
func (_DMW *DMWCallerSession) CurrentRate(_backedCoin string, _mintCoin string) (struct {
	Numerator      *big.Int
	Denominator    *big.Int
	CollateralRate *big.Int
	ThresholdRate  *big.Int
}, error) {
	return _DMW.Contract.CurrentRate(&_DMW.CallOpts, _backedCoin, _mintCoin)
}
