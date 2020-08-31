package main

import (
	"errors"
	"fmt"
	"github.com/pofid-dao/go-pofid/client"
	"github.com/pofid-dao/go-pofid/common"
	"github.com/pofid-dao/go-pofid/config"
	"github.com/pofid-dao/go-pofid/service"
	"golang.org/x/crypto/ssh/terminal"
	"gopkg.in/urfave/cli.v1"
	"log"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

const verion = "v0.0.1"

var (
	app        = cli.NewApp()
	configFlag = cli.StringFlag{
		Name:  "config",
		Usage: "TOML configuration file",
	}
	passwordFlag = cli.StringFlag{
		Name:  "password",
		Usage: "",
	}

	backedFlag = cli.BoolFlag{
		Name:  "backed",
		Usage: "",
	}
)

var password string

func init() {
	app.Name = filepath.Base(os.Args[0])
	app.Version = verion
	app.Flags = append(app.Flags, configFlag, passwordFlag, backedFlag)
	app.Usage = "POFID"
	app.Action = start
	app.Before = beforeFunc
	app.HideVersion = true
	app.Copyright = "Copyright 2013-2020 The POFID Authors"
}

func credentials() string {

	fmt.Print("Enter Password: ")
	bytePassword, err := terminal.ReadPassword(int(syscall.Stdin))
	if err != nil {
		panic("input password failed")
	}
	password := string(bytePassword)

	return strings.TrimSpace(password)
}

func beforeFunc(ctx *cli.Context) error {
	if args := ctx.Args(); len(args) > 0 {
		return fmt.Errorf("invalid command: %q", args[0])
	}

	var daemon bool

	if ctx.IsSet(backedFlag.Name) {
		daemon = ctx.Bool(backedFlag.Name)
	}
	if daemon {
		password = credentials()

	}
	return nil
}

func start(ctx *cli.Context) error {

	if args := ctx.Args(); len(args) > 0 {
		return fmt.Errorf("invalid command: %q", args[0])
	}

	if ctx.IsSet(passwordFlag.Name) {
		password = ctx.String(passwordFlag.Name)
	}

	if password == "" {
		return errors.New("not set password")
	}

	if ctx.IsSet(configFlag.Name) {
		configFile := ctx.String(configFlag.Name)
		cfg, err := config.LoadConfig(configFile)
		if err != nil {
			return err
		}
		common.Init(*cfg)
		client.InitContractClient(*cfg, password)
		os := service.NewService(cfg.Exs)
		go os.UpdateRate()
	} else {
		return errors.New("config file not set")
	}
	log.Println("started")

	select {}
	return nil
}

func setLog() {
	logFile := "./go-pofid-" + time.Now().Format("2006-01-02") + ".log"
	outfile, err := os.OpenFile(logFile, os.O_CREATE|os.O_RDWR|os.O_APPEND, 0666)
	if err != nil {
		fmt.Println(*outfile, "open failed")
		os.Exit(1)
	}
	log.SetOutput(outfile)
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
}

func main() {

	setLog()

	go app.RunAndExitOnError()
	quit := make(chan bool)
	<-quit
}
