


all:
	g++ -c -I/usr/include/postgresql script1.cpp 
	g++ script1.o -lpq -o exe
	# g++ script.o -L/usr/include/postgresql/libpq/ -lpq -o exe
	rm *.o