default: library runtime

library:
	dmd -lib -odlib/ -oflibdbs.a dbs/* 

runtime: library
	dmd -odbuild/ -ofbin/dbs -I. -L-Llib/ -L-ldbs main.d

install: runtime
	cp bin/dbs /usr/local/bin/
