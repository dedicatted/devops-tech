These are instructions to build Go binary to deploy new versions of code on Lambda (from https://github.com/aws/aws-lambda-go)

On Linux:
```
GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o main main.go
zip code.zip main
```

On Windows:

Get the tool
```
go.exe install github.com/aws/aws-lambda-go/cmd/build-lambda-zip@latest
```
in Powershell:
```
$env:GOOS = "linux"
$env:GOARCH = "amd64"
$env:CGO_ENABLED = "0"
go build -ldflags "-s -w" -o main main.go
~\Go\Bin\build-lambda-zip.exe -o code.zip main
```