#include <libpq-fe.h>

#include <cstdio>
#include <fstream>
#include <iostream>

using namespace std;

#define PG_HOST "127.0.0.1"
#define PG_USER "socio"
#define PG_DB "wecare"
#define PG_PASS "password"
#define PG_PORT 5432

void checkResults(PGresult* res, const PGconn* conn) {
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Risultati inconsistenti " << PQerrorMessage(conn);
        PQclear(res);
        exit(1);
    }
}

int main(int argc, char* argv[]) {
    cout << "Start " << endl;
    char conninfo[250];
    sprintf(conninfo, " user =%s password =%s dbname =%s hostaddr =%s port =%d", PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);

    PGconn* conn = PQconnectdb(conninfo);

    if (PQstatus(conn) != CONNECTION_OK) {
        cout << "Errore di connessione \n"
             << PQerrorMessage(conn);
        PQfinish(conn);
        exit(1);
    }

    cout << " Connessione avvenuta correttamente" << endl;

    string query1 = "DROP VIEW IF EXISTS totaleFatt; DROP VIEW IF EXISTS totaleDonaz; DROP VIEW IF EXISTS totaleSpese; CREATE VIEW totaleFatt AS (SELECT Distretto.nome, SUM(importo) AS TOT_FATTURE FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione WHERE Transazione.tipologia = 'FATTURA' GROUP BY Distretto.nome); CREATE VIEW totaleDonaz AS (SELECT Distretto.nome, SUM(importo) AS TOT_DONAZIONI FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione WHERE Transazione.tipologia = 'DONAZIONE' GROUP BY Distretto.nome); CREATE VIEW totaleSpese AS (SELECT Distretto.nome, SUM(importo) AS TOT_SPESE FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione WHERE Transazione.tipologia = 'SPESA' GROUP BY Distretto.nome); SELECT DISTINCT totaleFatt.nome, TOT_DONAZIONI, TOT_SPESE, TOT_FATTURE, (TOT_DONAZIONI-(TOT_SPESE+TOT_FATTURE)) AS NETTO FROM totaleFatt JOIN totaleDonaz on totaleFatt.nome=totaleDonaz.nome JOIN totaleSpese ON totaleDonaz.nome=totaleSpese.nome;";
    string query2 = "SELECT Riunione.regione, Riunione.n_distretto, COUNT(*) AS N_richiesteApprovate FROM Riunione JOIN Valutazione ON Riunione.id=Valutazione.riunione JOIN Richiesta ON Valutazione.richiesta = Richiesta.id JOIN VoceRichiesta ON Richiesta.id =VoceRichiesta.richiesta JOIN Prodotto ON VoceRichiesta.prodotto = Prodotto.id WHERE Prodotto.nome=$1::VARCHAR AND Richiesta.apertura >=$2::DATE AND Richiesta.apertura <=$3::DATE GROUP BY (Riunione.regione, Riunione.n_distretto) ORDER BY N_richiesteApprovate DESC;";
    string query3 = "SELECT T2.PIVA, T1.Azienda, T1.N_Vincite, T2.Soldi_ricevuti FROM (SELECT Azienda.piva AS PIVA, Azienda.nome AS Azienda, count(*) AS N_Vincite FROM Azienda INNER JOIN Preventivo ON Azienda.piva = Preventivo.piva INNER JOIN Vincitore ON Preventivo.piva = Vincitore.piva GROUP BY Azienda.piva) AS T1 JOIN (SELECT Vincitore.piva AS PIVA, SUM(Transazione.importo) AS Soldi_ricevuti FROM Vincitore INNER JOIN Fattura ON Vincitore.piva = Fattura.piva INNER JOIN Transazione ON Fattura.transazione = Transazione.id GROUP BY Vincitore.piva) AS T2 ON T2.PIVA = T1.PIVA ORDER BY Soldi_ricevuti DESC LIMIT 3;";
    string query4 = "DROP VIEW IF EXISTS RichiesteAperte; CREATE VIEW RichiesteAperte AS ( SELECT id, ente, regione, creazione, apertura, chiusura FROM Richiesta WHERE apertura IS NOT NULL AND chiusura IS NULL); DROP VIEW IF EXISTS RichiestaConclusaTempoImpiegato; CREATE VIEW RichiestaConclusaTempoImpiegato AS ( SELECT id, ente, regione, EXTRACT(EPOCH FROM (chiusura::timestamp - apertura::timestamp))/86400::int AS tempo FROM Richiesta WHERE apertura IS NOT NULL AND chiusura IS NOT NULL); SELECT rcti.regione, MIN(rcti.tempo) AS minimo, MAX(rcti.tempo) AS massimo, AVG(rcti.tempo) AS medio, COUNT(rcti.id) AS concluse, COUNT(ra.id) AS aperte FROM RichiestaConclusaTempoImpiegato AS rcti FULL OUTER JOIN RichiesteAperte AS ra ON rcti.id = ra.id GROUP BY (rcti.regione);";
    string query5 = "DROP VIEW IF EXISTS VotiPerRichiesta CASCADE; CREATE VIEW VotiPerRichiesta AS ( SELECT riunione, preferenza, count(numero) AS num_voti FROM Scheda WHERE preferenza IS NOT NULL GROUP BY (preferenza, riunione) ORDER BY riunione ASC); DROP VIEW IF EXISTS VincitorePerRiunione;CREATE VIEW VincitorePerRiunione AS (SELECT * FROM VotiPerRichiesta AS a WHERE num_voti = (SELECT MAX(num_voti) FROM VotiPerRichiesta WHERE riunione = a.riunione)); SELECT ric.id, riu.n_distretto, riu.regione, v.riunione, v.num_voti FROM Riunione AS riu FULL JOIN VincitorePerRiunione AS v ON riu.id = v.riunione FULL JOIN Richiesta AS ric ON v.preferenza = ric.id ORDER BY ric.id ASC;";
    string query6 = "DROP VIEW IF EXISTS PresenzePerDistretto; CREATE VIEW PresenzePerDistretto AS( SELECT s.n_distretto, s.regione, COUNT(p.socio) AS presenze, EXTRACT(YEAR FROM r.data) AS anno FROM Presenza AS p INNER JOIN Socio AS s ON p.socio = s.cf INNER JOIN Riunione AS r ON p.riunione = r.id GROUP BY (s.n_distretto, s.regione, anno)); DROP VIEW IF EXISTS PresenzaPerSocio; CREATE VIEW PresenzaPerSocio AS ( SELECT p.socio, n_distretto, regione, COUNT(p.socio) AS num_presenze FROM Presenza AS p INNER JOIN Socio AS s ON s.cf = p.socio GROUP BY (socio, n_distretto, regione) ORDER BY num_presenze ); SELECT ppd.regione, ppd.n_distretto, ppd.presenze, ppd.anno, pp.socio AS 'piu presente', pp.num_presenze AS 'presenze massime', mp.socio AS 'meno presente', mp.num_presenze AS 'presenze minime' FROM PresenzePerDistretto AS ppd FULL JOIN ( SELECT DISTINCT ON (n_distretto, regione) * FROM PresenzaPerSocio AS p1 WHERE num_presenze = (SELECT MAX(num_presenze) FROM PresenzaPerSocio AS p2 WHERE p1.regione = p2.regione AND p1.n_distretto = p2.n_distretto LIMIT 1) ) AS pp ON ppd.n_distretto = pp.n_distretto AND ppd.regione = pp.regione FULL JOIN ( SELECT DISTINCT ON (n_distretto, regione) * FROM PresenzaPerSocio AS p1 WHERE num_presenze = (SELECT MIN(num_presenze) FROM PresenzaPerSocio AS p2 WHERE p1.regione = p2.regione AND p1.n_distretto = p2.n_distretto LIMIT 1) ) AS mp ON ppd.n_distretto = mp.n_distretto AND ppd.regione = mp.regione WHERE anno = 2020 AND ppd.regione = 'VENETO' ORDER BY (ppd.regione, ppd.n_distretto);";
    //QUERY 1
    cout << "Query 1: Per ogni distretto mostrare il totale delle donazioni che ha ottenuto, il totale delle spese effettuate, il totale delle fatture emesse e il ricavato netto(donazioni-(fatture+spese)):" << endl;
    PGresult* res;
    res = PQexec(conn, query1.c_str());

    checkResults(res, conn);
    int tuple = PQntuples(res);
    int campi = PQnfields(res);

    for (int i = 0; i < campi; ++i) {
        cout << PQfname(res, i) << "\t\t";
    }
    cout << endl;

    //Stampa risultati
    for (int i = 0; i < tuple; ++i) {
        for (int j = 0; j < campi; ++j) {
            cout << PQgetvalue(res, i, j) << "\t\t";
        }
        cout << endl;
    }
    PQclear(res);

    //QUERY 2
    cout << "Query 2: Elencare in ordine crescente i distretti che hanno approvato pi� richieste contenenti il prodotto di nome x nel periodo che va dalla data y alla data z, dove x y e z sono parametri: " << endl;
    PGresult* stmt = PQprepare(conn, "query2", query2.c_str(), 3, NULL);

    string prodotto;
    string dataI;
    string dataF;

    cout << "Inserire il nome del prodotto(es. Mascherina filtrante): ";
    cin >> prodotto;
    cout << "Inserire la data di inizio del periodo (es. 2020.10.15): ";
    cin >> dataI;
    cout << "Inserire la data di fine del periodo (es. 2020.11.16): ";
    cin >> dataF;

    const char* const* param = new const char* [3] { prodotto.c_str(), dataI.c_str(), dataF.c_str() };

    res = PQexecPrepared(conn, "query2", 3, param, NULL, 0, 0);
    checkResults(res, conn);
    tuple = PQntuples(res);
    campi = PQnfields(res);

    for (int i = 0; i < campi; ++i) {
        cout << PQfname(res, i) << "\t\t";
    }
    cout << endl;

    //Stampa risultati
    for (int i = 0; i < tuple; ++i) {
        for (int j = 0; j < campi; ++j) {
            cout << PQgetvalue(res, i, j) << "\t\t";
        }
        cout << endl;
    }
    PQclear(res);

    //QUERY 3
    cout << "Query 3: Elencare in ordine crescente le tre aziende che hanno ricevuto pi� soldi da parte di WeCare e, per ognuna, il numero di preventivi vincitori che detiene:" << endl;

    res = PQexec(conn, query3.c_str());
    checkResults(res, conn);
    tuple = PQntuples(res);
    campi = PQnfields(res);

    for (int i = 0; i < campi; ++i) {
        cout << PQfname(res, i) << "\t\t";
    }
    cout << endl;

    //Stampa risultati
    for (int i = 0; i < tuple; ++i) {
        for (int j = 0; j < campi; ++j) {
            cout << PQgetvalue(res, i, j) << "\t\t";
        }
        cout << endl;
    }
    PQclear(res);

    //QUERY 4
    cout << "Query 4: Elencare per ciascuna regione il tempo (in giorni) minimo, medio e massimo impiegato per portare a termine le richieste, il numero di richieste portate a termine e quelle ancora aperte: " << endl;

    res = PQexec(conn, query4.c_str());
    checkResults(res, conn);
    tuple = PQntuples(res);
    campi = PQnfields(res);

    for (int i = 0; i < campi; ++i) {
        cout << PQfname(res, i) << "\t\t";
    }
    cout << endl;

    //Stampa risultati
    for (int i = 0; i < tuple; ++i) {
        for (int j = 0; j < campi; ++j) {
            cout << PQgetvalue(res, i, j) << "\t\t";
        }
        cout << endl;
    }
    PQclear(res);

    //QUERY 5

    //QUERY 6

    cout << "Complete" << endl;
    PQfinish(conn);
    return 0;
}
