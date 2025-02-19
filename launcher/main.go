package main

import (
	"fmt"
	"os"
	"strings"
	"syscall"

	"gopkg.in/ini.v1"
)

const (
	DefaultPreferencesPath = "/app/config/preferences.ini"
)

type PreferenceOption struct {
	env        string
	iniSection string
	iniKey     string
	defaultVal string
}

func main() {
	arguments := os.Args[1:]

	preferencesPath := DefaultPreferencesPath

	if len(arguments) > 1 && strings.EqualFold(arguments[0], "--preferences") {
		preferencesPath = strings.Trim(arguments[1], " \"")
	}

	preferences := []PreferenceOption{
		{env: "EMULE_NICK", iniSection: "eMule", iniKey: "Nick", defaultVal: "https://emule-project.net"},
		{env: "EMULE_MAX_UPLOAD", iniSection: "eMule", iniKey: "MaxUpload", defaultVal: "1024"},
		{env: "EMULE_TCP_PORT", iniSection: "eMule", iniKey: "Port", defaultVal: "23732"},
		{env: "EMULE_UDP_PORT", iniSection: "eMule", iniKey: "UDPPort", defaultVal: "23732"},
		{env: "EMULE_EXTENDED_UDP_PORT", iniSection: "eMule", iniKey: "ServerUDPPort", defaultVal: "23735"},
		{env: "EMULE_LANGUAGE", iniSection: "eMule", iniKey: "Language", defaultVal: "1033"},
		{env: "EMULE_CAP_UPLOAD", iniSection: "eMule", iniKey: "UploadCapacityNew", defaultVal: "2048"},
		{env: "EMULE_CAP_DOWNLOAD", iniSection: "eMule", iniKey: "DownloadCapacity", defaultVal: "16384"},
		{env: "EMULE_RECONNECT", iniSection: "eMule", iniKey: "Reconnect", defaultVal: "1"},
		{env: "EMULE_UPDATE_FROM_SERVER", iniSection: "eMule", iniKey: "AddServersFromServer", defaultVal: "1"},
		{env: "EMULE_HOSTNAME", iniSection: "eMule", iniKey: "YourHostname", defaultVal: ""},
		{env: "WEB_PASS", iniSection: "WebServer", iniKey: "Password", defaultVal: "19A2854144B63A8F7617A6F225019B12"}, // admin
		{env: "WEB_PORT", iniSection: "WebServer", iniKey: "Port", defaultVal: "4711"},
		{env: "", iniSection: "eMule", iniKey: "ConfirmExit", defaultVal: "0"},
		{env: "", iniSection: "eMule", iniKey: "FilterBadIPs", defaultVal: "1"},
		{env: "", iniSection: "eMule", iniKey: "Autoconnect", defaultVal: "1"},
		{env: "", iniSection: "eMule", iniKey: "Verbose", defaultVal: "1"},
		{env: "", iniSection: "eMule", iniKey: "IncomingDir", defaultVal: "Z:\\data\\incoming"},
		{env: "", iniSection: "eMule", iniKey: "TempDir", defaultVal: "Z:\\data\\temp"},
		{env: "", iniSection: "eMule", iniKey: "NotifierConfiguration", defaultVal: "Z:\\app\\config\\Notifier.ini"},
		{env: "", iniSection: "eMule", iniKey: "WebTemplateFile", defaultVal: "Z:\\app\\config\\eMule.tmpl"},
		{env: "", iniSection: "eMule", iniKey: "ToolbarBitmapFolder", defaultVal: "Z:\\app\\skins"},
		{env: "", iniSection: "eMule", iniKey: "SkinProfileDir", defaultVal: "Z:\\app\\skins"},
		{env: "WEB_ENABLE", iniSection: "WebServer", iniKey: "Enabled", defaultVal: "1"},
		{env: "", iniSection: "UPnP", iniKey: "EnableUPnP", defaultVal: "0"},
	}

	fmt.Println(fmt.Sprintf("Opening preferences file in %s", preferencesPath))
	cfg, err := ini.Load(preferencesPath)

	if err != nil {
		fmt.Println("Emule launcher can't find preferences file")
		syscall.Exit(1)
	}

	for _, preference := range preferences {
		propertyValue := preference.defaultVal
		if preference.env != "" && os.Getenv(preference.env) != "" {
			propertyValue = os.Getenv(preference.env)
		}

		fmt.Println(fmt.Sprintf("Setting %s.%s => %s", preference.iniSection, preference.iniKey, propertyValue))
		cfg.Section(preference.iniSection).Key(preference.iniKey).SetValue(propertyValue)
	}

	fmt.Println(fmt.Sprintf("Saving preferences file in %s", preferencesPath))
	err = cfg.SaveTo(preferencesPath)

	if err != nil {
		fmt.Println("Emule launcher can't write preferences file")
		syscall.Exit(2)
	}
}
