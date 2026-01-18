build:
	mkdir -p bin
	go build -o bin/autosim ./cmd/autosim
run: build
	./bin/autosim
clean:
	rm -rf bin/
	go clean
