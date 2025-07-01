# Install libfaketime first
brew install libfaketime

# Then use faketime directly
faketime "2020-07-15 10:00:00" open -a "Google Chrome" "https://192.168.1.23"