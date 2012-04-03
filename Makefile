default:
	dmd -odbuild/ -ofbin/dbs -Isrc/ src/*.d

install:
	cp bin/dbs /usr/local/bin/
