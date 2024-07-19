package main

import (
	"github.com/sirupsen/logrus"
	"gitlab.host.com/pdemo/pkg/utils"
	"gitlab.host.com/pdemo/pkg/version"
)

func main() {
	version.PrintFullVersionInfo()
	logrus.Infof("hello gitlab: %v", utils.Add(1, 1))
}
