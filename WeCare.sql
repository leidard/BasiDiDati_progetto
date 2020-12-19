SET
    FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Fattura;

DROP TABLE IF EXISTS Spesa;

DROP TABLE IF EXISTS Transazione;

DROP TABLE IF EXISTS Occasione;

DROP TABLE IF EXISTS Vincitore;

DROP TABLE IF EXISTS Scheda;

DROP TABLE IF EXISTS VocePreventivo;

DROP TABLE IF EXISTS Preventivo;

DROP TABLE IF EXISTS Azienda;

DROP TABLE IF EXISTS VoceRichiesta;

DROP TABLE IF EXISTS Prodotto;

DROP TABLE IF EXISTS Valutazione;

DROP TABLE IF EXISTS Richiesta;

DROP TABLE IF EXISTS Ente;

DROP TABLE IF EXISTS Presenza;

DROP TABLE IF EXISTS Riunione;

DROP TABLE IF EXISTS Distretto;

DROP TABLE IF EXISTS Regione;

DROP TABLE IF EXISTS Presidente;

DROP TABLE IF EXISTS Socio;

CREATE TABLE Distretto(
    numero INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(20) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ) NOT NULL,
    presidente CHAR(16),
    /* il fatto che non ci sia il not null vuol dire che potrebbe non avere subito il presidente. Quindi risolto????*/
    /*FOREIGN KEY (presidente) REFERENCES Presidente(cf) ON DELETE NO ACTION ON UPDATE CASCADE*/
);

CREATE TABLE Socio(
    cf CHAR(16) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    telefono VARCHAR(13) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%_@__%.__%'),
    data_nascita DATE NOT NULL,
    indirizzo VARCHAR(100) NOT NULL,
    n_distretto INT UNSIGNED NOT NULL,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ) NOT NULL,
    FOREIGN KEY(n_distretto, regione) REFERENCES Distretto(numero, regione) ON DELETE NO ACTION ON UPDATE CASCADE
    /*non posso cancellare un distretto se ci sono soci ancora iscritti, devo prima spostare tutti i soci.
     se sposto un distretto di regione (perché dovrei farlo, wtf?) tengo i soci associati(?)*/
);

CREATE TABLE Presidente(
    cf CHAR(16) PRIMARY KEY,
    voto TINYINT NOT NULL,
    lode BIT DEFAULT 0,
    FOREIGN KEY (cf) REFERENCES Socio(cf) ON DELETE CASCADE ON UPDATE CASCADE
    /*se elimino un socio che fa il presidente lo elimino anche qua*/
);

ALTER TABLE Distretto ADD FOREIGN KEY (presidente) REFERENCES Presidente(cf) ON DELETE NO ACTION ON UPDATE CASCADE;

CREATE TABLE Riunione(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ) NOT NULL,
    n_distretto INT UNSIGNED NOT NULL,
    data DATE NOT NULL,
    UNIQUE(regione, n_distretto, data)
    /*senza index*/
);

CREATE TABLE Presenza(
    socio CHAR(16),
    riunione INT UNSIGNED,
    PRIMARY KEY (socio, riunione),
    FOREIGN KEY (socio) REFERENCES Socio(cf) ON DELETE CASCADE ON UPDATE CASCADE,
    /*se in Socio cancello un socio ne cancello anche la lista delle presenze */
    FOREIGN KEY (riunione) REFERENCES Riunione(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Ente(
    nome VARCHAR(50),
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ),
    indirizzo VARCHAR(100) NOT NULL,
    telefono VARCHAR(13) NOT NULL UNIQUE,
    descrizione VARCHAR(100) NOT NULL,
    PRIMARY KEY(nome, regione)
);

CREATE TABLE Richiesta(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ente VARCHAR(50) NOT NULL,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ) NOT NULL,
    creazione DATE NOT NULL,
    apertura DATE,
    chiusura DATE,
    FOREIGN KEY(ente, regione) REFERENCES Ente(nome, regione) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Valutazione(
    richiesta INT UNSIGNED,
    riunione INT UNSIGNED,
    PRIMARY KEY (richiesta, riunione),
    FOREIGN KEY (richiesta) REFERENCES Richiesta(id),
    FOREIGN KEY (riunione) REFERENCES Riunione(id)
);

CREATE TABLE Prodotto(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    modello VARCHAR(30) NOT NULL,
    descrizione VARCHAR(100)
);

CREATE TABLE VoceRichiesta(
    prodotto INT UNSIGNED,
    richiesta INT UNSIGNED,
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (prodotto, richiesta),
    FOREIGN KEY prodotto REFERENCES Prodotto(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY richiesta REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Azienda(
    piva CHAR(11) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    telefono VARCHAR(13) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL
);

CREATE TABLE Preventivo(
    piva CHAR(11),
    richiesta INT UNSIGNED,
    emissione DATE NOT NULL,
    PRIMARY KEY (piva, richiesta),
    FOREIGN KEY piva REFERENCES Azienda(piva) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY richiesta REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE VocePreventivo(
    azienda CHAR(11),
    richiesta INT UNSIGNED,
    quantita INT UNSIGNED,
    prodotto INT UNSIGNED NOT NULL,
    prezzo DECIMAL(8, 2) NOT NULL,
    PRIMARY KEY (azienda, richiesta, quantita),
    FOREIGN KEY (azienda, richiesta) REFERENCES Preventivo(piva, richiesta) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (richiesta, prodotto) REFERENCES VoceRichiesta(richiesta, prodotto) ON DELETE NO ACTION ON UPDATE CASCADE,
    /* OPPURE SET NULL ANCHE*/
);

CREATE TABLE Scheda(
    numero INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*tanto vale farla PK da sola, allora*/
    riunione INT UNSIGNED NOT NULL,
    tipologia ENUM("BIANCA", "NULLA", "VALIDA") NOT NULL,
    preferenza INT UNSIGNED,
    /* qualche check qua nel caso tipologia sia valida  deve essere presente la prefenza (quindi non nulla) ????*/
    CHECK (
        (
            tipologia = 'VALIDA'
            AND preferenza NOT NULL
        )
        OR (
            (
                tipologia = 'NULLA'
                OR tipologia = 'BIANCA'
            )
            AND preferenza NULL
        )
    )
    /* così? */
    FOREIGN KEY preferenza REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY riunione REFERENCES Riunione(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Vincitore(
    piva CHAR(11),
    richiesta INT UNSIGNED,
    dichiarazione DATE NOT NULL,
    PRIMARY KEY(piva, richiesta) FOREIGN KEY (piva, richiesta) REFERENCES Preventivo(piva, richiesta) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Occasione(
    id INT UNSIGNED PRIMARY KEY,
    indirizzo VARCHAR(100) NOT NULL,
    data DATE NOT NULL,
    descrizione VARCHAR(255) NOT NULL,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ) NOT NULL,
    n_distretto INT UNSIGNED NOT NULL,
    FOREIGN KEY (regione, n_distretto) REFERENCES Distretto(regione, numero) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Transazione(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    importo DECIMAL(8, 2) NOT NULL,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        'LOMBARDIA',
        "TRENTINO-ALTO ADIGE",
        "VENETO",
        "FRIULI-VENEZIA GIULIA",
        "EMILIA ROMAGNA",
        "TOSCANA",
        "UMBRIA",
        "MARCHE",
        "LAZIO",
        "ABRUZZO",
        "MOLISE",
        "CAMPANIA",
        "PUGLIA",
        "BASILICATA",
        "CALABRIA",
        "SICILIA",
        "SARDEGNA"
    ) NOT NULL,
    n_distretto INT UNSIGNED NOT NULL,
    tipologia ENUM("DONAZIONE", "SPESA", "FATTURA") NOT NULL,
    donato_presso INT UNSIGNED,
    FOREIGN KEY (regione, n_distretto) REFERENCES Distretto(regione, numero) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (donato_presso) REFERENCES Occasione(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Spesa(
    transazione INT UNSIGNED PRIMARY KEY,
    occasione INT UNSIGNED NOT NULL,
    giustificazione VARCHAR(255) NOT NULL,
    FOREIGN KEY transazione REFERENCES Transazione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY occasione REFERENCES Occasione(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Fattura(
    transazione INT UNSIGNED PRIMARY KEY,
    progressivo INT UNSIGNED AUTO_INCREMENT NOT NULL,
    piva CHAR(11) NOT NULL,
    richiesta INT UNSIGNED NOT NULL,
    FOREIGN KEY (piva, richiesta) REFERENCES Vincitore(piva, richiesta) ON DELETE NO ACTION ON UPDATE CASCADE
);

/*  NON PROVARE A CAMBIARE LA FORMATTAZIONE SOTTO O CAVARE SPAZI CHE TI MANGIO!!!!!!!!!!!!!!!!!!! SISTEMO DOPO, PER ORA LASCIA RESPIRARE CHE MI DAVA L'ANSIA.
 SOPRATTUTTO NON METTERE IN COLONNA GLI ATTRIBUTI, MANNAGGIA A TE >_________< */
-- Popolazione Distretto
INSERT INTO
    Distretto(nome, indirizzo, regione, presidente)
VALUES
    ("Padova1", "Via Roma 23 Padova 35140", "VENETO", ""),
    ("Padova2", "Via Firenze 10 Padova 35139", "VENETO", ""),
    ("Roma1", "Piazza S. Marco 2 Roma 00010", "LAZIO", ""),
    ("Latina1", "Via Battaglia 3 Latina 04010", "LAZIO", ""),
    ("Bergamo1", "Via Rosa 52 Bergamo 24099", "LOMBARDIA", ""),
    ("Firenze1", "Via Leopardi 3 Firenze 50012", "TOSCANA", ""),
    ("Firenze2", "Via Roma 40 Firenze 50012", "TOSCANA", ""),
    ("Milano1", "Via Dante 22 Milano 20010", "LOMBARDIA", ""),
    ("Roma2", "Via Venezia 9 Roma 00016", "LAZIO", ""),
    ("Salerno1", "Via Petrarca 6 Salerno 84070", "CAMPANIA", ""),
    ("Matera1", "Via Dante 11 Matera 75062", "BASILICATA", ""),
    
    -- Popolazione Socio
INSERT INTO
    Socio(CF, nome, cognome, telefono, email, data_nascita, indirizzo, n_distretto, regione)
VALUES
    ("RSSMRA70S02G224K", "Mario", "Rossi", "1234567890", "mariorossi@mail.com", "1990-11-02", "via Roma 1, Padova", "1", "VENETO"),
    ("FJLTDP54A19C700X", "Fabio", "Del Santo", "1234567891", "fabiosanto@mail.com", "1974-04-22", "via Borghese 12 Roma", "3", "LAZIO"),
    ("LTRMLL11A50E142B", "Mirella", "La Torre", "1234567892", "mire.lato@gmail.com", "1982-10-30", "via Ferro 8 Roma", "3-", "LAZIO"),
    ("FJLTDP54A19C700X", "Paolo", "Zabarella", "1234567891", "paolo.zabarella@mail.com", "1982-02-02", "via Borghese 36 Roma", "3", "LAZIO"),
    ("FJLTDP54A19C700X", "Marco", "Di Falco", "1234567891", "marco.difalco@mail.com", "1976-8-02", "via Brigante 42 Latina", "3", "LAZIO"),
    ("FJLTDP54A19C700X", "Luigi", "Brigo", "1234567891", "luigi.brigo@mail.com", "1979-04-02", "via Sassari 22 Latina", "3", "LAZIO");
    
 -- Popolazione Presidente
INSERT INTO
    Presidente(CF, voto, lode) 
VALUES
    ("", "", "");
    -- Popolazione Riunione

INSERT INTO
    Riunione(regione, numero, data)
VALUES
    ("", "", "");
    -- Popolazione Presenza
INSERT INTO
    Presenza(socio, riunione)
VALUES
    ("", "");
    -- Popolazione Ente
INSERT INTO
    Ente(regione, nome, telefono, indirizzo, descrizione)
VALUES 
    ("VENETO", "Casa Riposo Padova", "+39 110874827", "Via Marco Polo 3, 53530, Padova", ""),
    ("LOMBARDIA", "Azienda Ospedaliera Milano", "+39 110874827", "Via Venezia 68, 78864, Angri"),
    ("EMILIA ROMAGNA", "Azienda Ospedaliera Ferrara", "+39 640405107", "Via San Girolamo 56, 10637, Trieste"),
    ("LAZIO", "Mensa Papa Giovanni", "+39 655667963", "Via Padre Pio 45, 24678, Pordenone"),
    ("ABRUZZO", "Caritas San Francesco", "+39 970138344", "Via Cesare Beccaria 33, 94672, Trento"),
    ("MOLISE", "Opera San Giovanni", "+39 541315440", "Via San Francesco 22, 21534, Cortina"),
    ("CALABRIA", "Azienda Ospedaliera Catanzaro", "+39 506733072", "Via 30 Febbraio 2, 62771, Camposampiero"),
    ("CAMPANIA", "Progetto Ripartenza", "+39 843865550", "Via Vandolmo 65, 87431, Olmo"),
    ("SICILIA", "Med.senz.f. Siculi", "+39 592292896", "Via Guizza 93, 32768, Anguillara"),
    ("SARDEGNA", "Caritas Sardegna", "+39 991156326", "Via Padova 64, 31358, Ferrara"),
    ("PUGLIA", "Azienda Ospedaliera Bari", "+39 654289884", "Via Emili 37, 62456, Villa del Conte"),
    ("UMBRIA", "Casa di Cura Perugina", "+39 272111710", "Via Roma 93, 25072, Feriole");
    -- Popolazione Richiesta
INSERT INTO
    Richiesta(ente, regione, creazione, apertura, chiusura)
VALUES
    ("", "", "", "", "");
    -- Popolazione Valutazione
INSERT INTO
    Valutazione(richiesta, riunione)
VALUES
    ("", "");
    -- Popolazione Prodotto
INSERT INTO
    Prodotto(nome, modello, descrizione)
VALUES
    ("", "", "");
    -- Popolazione VoceRichiesta
INSERT INTO
    VoceRichiesta(prodotto, richiesta, quantita)
VALUES
    ("", "", "");
    -- Popolazione Azienda
INSERT INTO
    Azienda(piva, nome, telefono, indirizzo)
VALUES
    ("8238401722", "Tronchi s.r.l.", "+39 110874827", "Via Marco Polo 3, 53530, Padova"),
    ("6699331325", "Paoletti s.a.s.", "+39 110874827", "Via Venezia 68, 78864, Angri"),
    ("7607418259", "Grandi Magazzini Ferraresi s.r.l.", "+39 640405107", "Via San Girolamo 56, 10637, Trieste"),
    ("8749297545", "Zorzetti & Co. s.p.a.", "+39 655667963", "Via Padre Pio 45, 24678, Pordenone"),
    ("1657677425", "Vodafone s.p.a.", "+39 970138344", "Via Cesare Beccaria 33, 94672, Trento"),
    ("2979137105", "Tesla s.a.s.", "+39 541315440", "Via San Francesco 22, 21534, Cortina"),
    ("5121672285", "Gruppo D.C.P.M. Parma Sud", "+39 506733072", "Via 30 Febbraio 2, 62771, Camposampiero"),
    ("9416760333", "Sassari Soluzioni s.a.s.", "+39 843865550", "Via Vandolmo 65, 87431, Olmo"),
    ("5735548958", "Friulani Medical s.p.a.", "+39 592292896", "Via Guizza 93, 32768, Anguillara"),
    ("1448068341", "Trainspotting Foods s.r.l.", "+39 991156326", "Via Padova 64, 31358, Ferrara"),
    ("9619512572", "Escher Bevande s.p.a.", "+39 654289884", "Via Emili 37, 62456, Villa del Conte"),
    ("1021583491", "Hollywood Food Inc. s.p.a.", "+39 272111710", "Via Roma 93, 25072, Feriole");
    -- Popolazione Preventivo
INSERT INTO
    Preventivo(piva, richiesta, emissione)
VALUES
    ("", "", "");
    -- Popolazione VocePreventivo
INSERT INTO
    VocePreventivo(azienda, prodotto, richiesta, quantita, prezzo)
VALUES
    ("", "", "", "", "");
    -- Popolazione Scheda
INSERT INTO
    Scheda(riunione, tipologia, preferenza)
VALUES
    ("", "", "");
    -- Popolazione Vincitore
INSERT INTO
    Vincitore(piva, richiesta, dichiarazione)
VALUES
    ("", "", "");
    -- Popolazione Occasione
INSERT INTO
    Occasione(indirizzo, data, descrizione, regione, n_distretto)    
VALUES
    ("", "", "", "", "");
    -- Popolazione Transazione
INSERT INTO
    Transazione(time, importo, regione, n_distretto, tipologia, donato_presso)    
VALUES
    ("2018-10-19 10:55:23", "", "", "", "", "");
    -- Popolazione Spesa
INSERT INTO
    Spesa(transazione, occasione, giustificazione)
VALUES
    ("", "", "");
    -- Popolazione Fattura
INSERT INTO
    Fattura(transazione, piva, richiesta)
VALUES
    ("", "", "");