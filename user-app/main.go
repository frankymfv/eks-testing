// File: user/main.go
package main

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
)

type User struct {
	ID       int    `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type Response struct {
	Message string `json:"message,omitempty"`
	Token   string `json:"token,omitempty"`
}

type InfoResponse struct {
	Hostname    string `json:"hostname"`
	OS          string `json:"os"`
	ClientIP    string `json:"client_ip"`
	Version     string `json:"version"`
	ServiceName string `json:"service_name"`
}

var (
	users  = []User{}
	mu     sync.Mutex
	nextID = 1
)

func getClientIP(r *http.Request) string {
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip, _, _ = net.SplitHostPort(r.RemoteAddr)
	}
	return ip
}

func getUsers(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	mu.Lock()
	defer mu.Unlock()
	json.NewEncoder(w).Encode(users)
}

func createUser(w http.ResponseWriter, r *http.Request) {
	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	mu.Lock()
	user.ID = nextID
	nextID++
	users = append(users, user)
	mu.Unlock()
	w.Header().Set("Content-Type", "application/json")
	response := Response{
		Message: "User created successfully",
	}
	json.NewEncoder(w).Encode(response)
}

func loginUser(helloWorldServiceURL string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var user User
		if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		fmt.Printf("User requesting info from helloworld service: %+v", user)
		
		// Call helloworld service instead of auth service
		helloEndpoint := fmt.Sprintf("%s/", helloWorldServiceURL)
		fmt.Printf("Hello World endpoint: %s\n", helloEndpoint)
		
		resp, err := http.Get(helloEndpoint)
		if err != nil || resp.StatusCode != http.StatusOK {
			http.Error(w, "Failed to get info from helloworld service", http.StatusInternalServerError)
			return
		}

		var helloResponse InfoResponse
		if err := json.NewDecoder(resp.Body).Decode(&helloResponse); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		response := Response{
			Message: fmt.Sprintf("Successfully connected to helloworld service. Hostname: %s", helloResponse.Hostname),
		}
		json.NewEncoder(w).Encode(response)
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
			ServiceName: "User Service",
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(infoResponse)
	}
}

func main() {
	envCfg := LoadEnvConfig()

	port := envCfg.Port
	version := envCfg.Version
	helloWorldServiceURL := envCfg.HelloWorldServiceURL
	http.HandleFunc("/users", getUsers)
	http.HandleFunc("/create", createUser)
	http.HandleFunc("/login", loginUser(helloWorldServiceURL))
	http.HandleFunc("/", getInfo(version))

	fmt.Printf("User service is listening on port %s\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		fmt.Println("Failed to start server:", err)
	}
}
