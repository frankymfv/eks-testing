# Use the official Golang image as the base image
FROM golang:1.22-alpine

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Create a vendor directory and copy dependencies there
RUN go mod vendor -v

# Build the Go application
RUN go build -o main .


# Expose port 8080 to the outside world (you can choose to expose another port if you want)
EXPOSE $PORT

# Command to run the executable with default port and version arguments
CMD ["./main", "-port", "$PORT", "-version", "$VERSION"]
