#include <libpq-fe.h>

#include <cstdio>
#include <fstream>
#include <iostream>

using namespace std;

# define PG_HOST "127.0.0.1"
# define PG_USER "socio"
# define PG_DB "filesystem"
# define PG_PASS "password"
# define PG_PORT 5432


int main(int argc, char** argv) {
    PGconn* conn = PQconnectdb("dbname");



    PQfinish(conn);
    return 0;
}