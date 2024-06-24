package main

import "os"

// EnvCfg holds the configuration values for the application.
type EnvCfg struct {
	Port           string
	Version        string
	AuthServiceURL string
}

// GetEnv reads an environment variable and returns its value if it exists, or a default value otherwise.
func GetEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

// LoadConfig loads configuration from environment variables.
func LoadEnvConfig() EnvCfg {
	return EnvCfg{
		Port:           GetEnv("PORT", "8080"),
		Version:        GetEnv("VERSION", "1.0"),
		AuthServiceURL: GetEnv("AUTH_SERVICE_URL", "http://localhost:8081"),
	}
}
