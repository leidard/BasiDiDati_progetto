


all:
	g++ -c -I/usr/include/postgresql script.cpp
	g++ script.o -lpq -o exe
	# g++ script.o -L/usr/include/postgresql/libpq/ -lpq -o exe
	rm *.o