#include <libpq-fe.h>

#include <iomanip>
#include <iostream>

#define PG_HOST "127.0.0.1"
#define PG_USER "nomeutente"
#define PG_DB "database"
#define PG_PASS "password"
#define PG_PORT 5432

void checkResults(PGresult* res, const PGconn* conn) {
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        std::cout << "Risultati inconsistenti " << PQerrorMessage(conn);
        PQclear(res);
        exit(1);
    }
}

template <typename T>
void printElement(T t, const int& width) {
    std::cout << std::left << std::setw(width) << std::setfill(' ') << t;
}

void printResults(PGresult* res) {
    int campi = PQnfields(res);
    std::cout << std::endl;
    for (int i = 0; i < campi; ++i) {
        printElement(PQfname(res, i), 18);
    }
    std::cout << std::endl;

    for (int i = 0; i < PQntuples(res); ++i) {
        for (int j = 0; j < campi; ++j) {
            printElement(PQgetvalue(res, i, j), 18);
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

const std::string descriptions[6] = {
    "Per ogni distretto mostrare il totale delle donazioni che ha ottenuto, il totale delle spese effettuate, il totale delle fatture emesse e il ricavato netto(donazioni-(fatture+spese))",
    "Elencare in ordine crescente i distretti che hanno approvato piu richieste contenenti il prodotto di nome x nel periodo che va dalla data y alla data z, dove x y e z sono parametri",
    "Elencare in ordine crescente le tre aziende che hanno ricevuto piu soldi da parte di WeCare e, per ognuna, il numero di preventivi vincitori che detiene",
    "Elencare per ciascuna regione il tempo (in giorni) minimo, medio e massimo impiegato per portare a termine le richieste, il numero di richieste portate a termine e quelle ancora aperte",
    "Per ogni richiesta (approvata o meno) trovare il distretto che l’ha approvata e determinare durante quale riunione e con quanti voti è passata",
    "Per ciascun DISTRETTO all’interno della regione “VENETO” ricavare quante presenze ha totalizzato dall'inizio dell’anno “2020” (la somma di ogni “presenza”) e inoltre uno tra i soci meno presenti con il suo numero di presenze e lo stesso per uno tra i piú presenti"};

const std::string queries[6] = {
    "DROP VIEW IF EXISTS totaleFatt; DROP VIEW IF EXISTS totaleDonaz; DROP VIEW IF EXISTS totaleSpese; CREATE VIEW totaleFatt AS (SELECT Distretto.nome, SUM(importo) AS TOT_FATTURE FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione WHERE Transazione.tipologia = 'FATTURA' GROUP BY Distretto.nome); CREATE VIEW totaleDonaz AS (SELECT Distretto.nome, SUM(importo) AS TOT_DONAZIONI FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione WHERE Transazione.tipologia = 'DONAZIONE' GROUP BY Distretto.nome); CREATE VIEW totaleSpese AS (SELECT Distretto.nome, SUM(importo) AS TOT_SPESE FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione WHERE Transazione.tipologia = 'SPESA' GROUP BY Distretto.nome); SELECT DISTINCT totaleFatt.nome, TOT_DONAZIONI, TOT_SPESE, TOT_FATTURE, (TOT_DONAZIONI-(TOT_SPESE+TOT_FATTURE)) AS NETTO FROM totaleFatt JOIN totaleDonaz on totaleFatt.nome=totaleDonaz.nome JOIN totaleSpese ON totaleDonaz.nome=totaleSpese.nome;",
    "SELECT Riunione.regione, Riunione.n_distretto, COUNT(*) AS N_richiesteApprovate FROM Riunione JOIN Valutazione ON Riunione.id=Valutazione.riunione JOIN Richiesta ON Valutazione.richiesta = Richiesta.id JOIN VoceRichiesta ON Richiesta.id =VoceRichiesta.richiesta JOIN Prodotto ON VoceRichiesta.prodotto = Prodotto.id WHERE Prodotto.nome=$1::VARCHAR AND Richiesta.apertura >=$2::DATE AND Richiesta.apertura <=$3::DATE GROUP BY (Riunione.regione, Riunione.n_distretto) ORDER BY N_richiesteApprovate DESC;",
    "SELECT T2.PIVA, T1.Azienda, T1.N_Vincite, T2.Soldi_ricevuti FROM (SELECT Azienda.piva AS PIVA, Azienda.nome AS Azienda, count(*) AS N_Vincite FROM Azienda INNER JOIN Preventivo ON Azienda.piva = Preventivo.piva INNER JOIN Vincitore ON Preventivo.piva = Vincitore.piva GROUP BY Azienda.piva) AS T1 JOIN (SELECT Vincitore.piva AS PIVA, SUM(Transazione.importo) AS Soldi_ricevuti FROM Vincitore INNER JOIN Fattura ON Vincitore.piva = Fattura.piva INNER JOIN Transazione ON Fattura.transazione = Transazione.id GROUP BY Vincitore.piva) AS T2 ON T2.PIVA = T1.PIVA ORDER BY Soldi_ricevuti DESC LIMIT 3;",
    "DROP VIEW IF EXISTS RichiesteAperte; CREATE VIEW RichiesteAperte AS ( SELECT id, ente, regione, creazione, apertura, chiusura FROM Richiesta WHERE apertura IS NOT NULL AND chiusura IS NULL); DROP VIEW IF EXISTS RichiestaConclusaTempoImpiegato; CREATE VIEW RichiestaConclusaTempoImpiegato AS ( SELECT id, ente, regione, EXTRACT(EPOCH FROM (chiusura::timestamp - apertura::timestamp))/86400::int AS tempo FROM Richiesta WHERE apertura IS NOT NULL AND chiusura IS NOT NULL); SELECT rcti.regione, MIN(rcti.tempo) AS minimo, MAX(rcti.tempo) AS massimo, AVG(rcti.tempo) AS medio, COUNT(rcti.id) AS concluse, COUNT(ra.id) AS aperte FROM RichiestaConclusaTempoImpiegato AS rcti FULL OUTER JOIN RichiesteAperte AS ra ON rcti.id = ra.id GROUP BY (rcti.regione);",
    "DROP VIEW IF EXISTS VotiPerRichiesta CASCADE; CREATE VIEW VotiPerRichiesta AS ( SELECT riunione, preferenza, count(numero) AS num_voti FROM Scheda WHERE preferenza IS NOT NULL GROUP BY (preferenza, riunione) ORDER BY riunione ASC); DROP VIEW IF EXISTS VincitorePerRiunione;CREATE VIEW VincitorePerRiunione AS (SELECT * FROM VotiPerRichiesta AS a WHERE num_voti = (SELECT MAX(num_voti) FROM VotiPerRichiesta WHERE riunione = a.riunione)); SELECT ric.id, riu.n_distretto, riu.regione, v.riunione, v.num_voti FROM Riunione AS riu FULL JOIN VincitorePerRiunione AS v ON riu.id = v.riunione FULL JOIN Richiesta AS ric ON v.preferenza = ric.id ORDER BY ric.id ASC;",
    "DROP VIEW IF EXISTS PresenzePerDistretto; CREATE VIEW PresenzePerDistretto AS( SELECT s.n_distretto, s.regione, COUNT(p.socio) AS presenze, EXTRACT(YEAR FROM r.data) AS anno FROM Presenza AS p INNER JOIN Socio AS s ON p.socio = s.cf INNER JOIN Riunione AS r ON p.riunione = r.id GROUP BY (s.n_distretto, s.regione, anno)); DROP VIEW IF EXISTS PresenzaPerSocio; CREATE VIEW PresenzaPerSocio AS ( SELECT p.socio, n_distretto, regione, COUNT(p.socio) AS num_presenze FROM Presenza AS p INNER JOIN Socio AS s ON s.cf = p.socio GROUP BY (socio, n_distretto, regione) ORDER BY num_presenze ); SELECT ppd.regione, ppd.n_distretto, ppd.presenze, ppd.anno, pp.socio AS \"piu presente\", pp.num_presenze AS \"presenze massime\", mp.socio AS \"meno presente\", mp.num_presenze AS \"presenze minime\" FROM PresenzePerDistretto AS ppd FULL JOIN ( SELECT DISTINCT ON (n_distretto, regione) * FROM PresenzaPerSocio AS p1 WHERE num_presenze = (SELECT MAX(num_presenze) FROM PresenzaPerSocio AS p2 WHERE p1.regione = p2.regione AND p1.n_distretto = p2.n_distretto LIMIT 1) ) AS pp ON ppd.n_distretto = pp.n_distretto AND ppd.regione = pp.regione FULL JOIN ( SELECT DISTINCT ON (n_distretto, regione) * FROM PresenzaPerSocio AS p1 WHERE num_presenze = (SELECT MIN(num_presenze) FROM PresenzaPerSocio AS p2 WHERE p1.regione = p2.regione AND p1.n_distretto = p2.n_distretto LIMIT 1) ) AS mp ON ppd.n_distretto = mp.n_distretto AND ppd.regione = mp.regione WHERE anno = 2020 AND ppd.regione = 'VENETO' ORDER BY (ppd.regione, ppd.n_distretto);"};

const unsigned int numQuery = 6;

int main(int argc, char* argv[]) {
    for (unsigned int i = 0; i < numQuery; i++) {
        std::cout << "[" << i << "]:" << std::endl
                  << descriptions[i] << std::endl
                  << std::endl;
    }

    int num;
    do {
        std::cout << "Scegli la query da eseguire: ";
        std::cin >> num;
    } while (num < 0 || num >= numQuery);

    char conninfo[250];
    sprintf(conninfo, " user =%s password =%s dbname =%s hostaddr =%s port =%d", PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);

    PGconn* conn = PQconnectdb(conninfo);

    if (PQstatus(conn) != CONNECTION_OK) {
        std::cout << "Errore di connessione \n"
                  << PQerrorMessage(conn);
        PQfinish(conn);
        exit(1);
    }
    std::cout << "Connessione avvenuta correttamente" << std::endl;

    if (num == 1) {
        PGresult* stmt = PQprepare(conn, "query2", queries[num].c_str(), 3, NULL);

        std::string prodotto;
        std::string dataI;
        std::string dataF;

        std::cout << "Inserire il nome del prodotto(es. Mascherina): ";
        std::cin >> prodotto;
        std::cout << "Inserire la data di inizio del periodo (es. 2020.10.15): ";
        std::cin >> dataI;
        std::cout << "Inserire la data di fine del periodo (es. 2020.11.16): ";
        std::cin >> dataF;

        const char* const* param = new const char* [3] { prodotto.c_str(), dataI.c_str(), dataF.c_str() };

        PGresult* res = PQexecPrepared(conn, "query2", 3, param, NULL, 0, 0);
        checkResults(res, conn);

        printResults(res);

        PQclear(res);
    } else {
        PGresult* res = PQexec(conn, queries[num].c_str());

        checkResults(res, conn);

        printResults(res);

        PQclear(res);
    }

    std::cout << "Complete" << std::endl;
    PQfinish(conn);
    return 0;
}
