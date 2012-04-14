default: library runtime

library:
	dmd -lib -odlib/ -oflibdbs.a dbs/*.d

runtime: library
	dmd -odbuild/ -ofbin/dbs -I. -L-Llib/ -L-ldbs main.d

install: runtime
	cp bin/dbs /usr/local/bin/

test: library
	dmd -odbuild/ -ofbin/test -I. -L-Llib/ -L-ldbs test.d

runtest: test
	bin/test
