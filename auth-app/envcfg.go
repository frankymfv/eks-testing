package main

import "os"

// EnvCfg holds the configuration values for the application.
type EnvCfg struct {
	Port           string
	Version        string
	AuthServiceURL string
}

var env *EnvCfg

// GetEnv reads an environment variable and returns its value if it exists, or a default value otherwise.
func GetEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

// LoadConfig loads configuration from environment variables.
func LoadEnvConfig() EnvCfg {
	if env != nil {
		return *env
	}

	env = &EnvCfg{
		Port:           GetEnv("PORT", "8081"),
		Version:        GetEnv("VERSION", "1.0"),
		AuthServiceURL: GetEnv("USER_SERVICE_URL", "http://localhost:8080"),
	}
	return *env
}
