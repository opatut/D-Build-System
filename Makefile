default: library runtime

library:
	dmd -lib -odlib/ -oflibdbs.a dbs/* 

runtime:
	dmd -odbuild/ -ofbin/dbs -I. -L-Llib/ -L-ldbs main.d

install:
	cp bin/dbs /usr/local/bin/
