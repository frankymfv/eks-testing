// File: auth/main.go
package main

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"
)

type AuthRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Message string `json:"message"`
	Token   string `json:"token,omitempty"`
}

type InfoResponse struct {
	ServiceName string `json:"service_name"`
	Hostname    string `json:"hostname"`
	OS          string `json:"os"`
	ClientIP    string `json:"client_ip"`
	Version     string `json:"version"`
}

var users = map[string]string{
	"user1": "password1",
	"user2": "password2",
}

func getClientIP(r *http.Request) string {
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip, _, _ = net.SplitHostPort(r.RemoteAddr)
	}
	return ip
}

func authenticate(version string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req AuthRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		//password, ok := users[req.Username]
		//if !ok || password != req.Password {
		//	http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		//	return
		//}
		hostname, _ := os.Hostname()
		token := fmt.Sprintf("token_for_%s_%s_%s", strings.ToLower(req.Username), hostname, version)
		resp := AuthResponse{
			Message: "Authentication successful",
			Token:   token,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	}
}

func getInfo(version string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		osName := strings.Title(strings.ToLower(os.Getenv("OSTYPE")))
		if osName == "" {
			osName = "Unknown"
		}
		clientIP := getClientIP(r)
		infoResponse := InfoResponse{
			Hostname:    hostname,
			OS:          osName,
			ClientIP:    clientIP,
			Version:     version,
			ServiceName: "Authentication Service",
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(infoResponse)
	}
}

func main() {
	envCfg := LoadEnvConfig()
	port := envCfg.Port
	version := envCfg.Version

	http.HandleFunc("/authenticate", authenticate(version))
	http.HandleFunc("/", getInfo(version))

	fmt.Printf("Authentication service is listening on port %s\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		fmt.Println("Failed to start server:", err)
	}
}
