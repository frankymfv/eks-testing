// File: main.go
package main

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"
)

// Response structure
type Response struct {
	ClientIP    string `json:"client_ip"`
	Hostname    string `json:"hostname"`
	OS          string `json:"os"`
	APIVersion  string `json:"api_version"`
	ServiceName string `json:"service_name"`
}

// getClientIP returns the client's IP address from the request
func getClientIP(r *http.Request) string {
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip, _, _ = net.SplitHostPort(r.RemoteAddr)
	}
	return ip
}

// handler function that writes client IP, hostname, OS name, and API version to the response as JSON
func helloHandler(version string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		clientIP := getClientIP(r)
		hostname, err := os.Hostname()
		if err != nil {
			hostname = "Unknown"
		}
		osName := strings.ToLower(os.Getenv("OSTYPE"))
		if osName == "" {
			osName = "Unknown"
		}
		response := Response{
			ClientIP:    clientIP,
			Hostname:    hostname,
			OS:          osName,
			APIVersion:  version,
			ServiceName: "Hello World",
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}
}

func main() {
	envCfg := LoadEnvConfig()

	// Register the handler function for the root URL path
	http.HandleFunc("/", helloHandler(envCfg.Version))

	// Start the HTTP server on the specified port
	fmt.Printf("Server is listening on port %s\n", envCfg.Port)
	if err := http.ListenAndServe(":"+envCfg.Port, nil); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to start server: %v\n", err)
		os.Exit(1)
	}
}
