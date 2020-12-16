SET
    FOREIGN_KEY_CHECKS = 0;

DROP INDEX IF EXISTS Fattura;

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
    FOREIGN KEY (presidente) REFERENCES Presidente(cf) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Socio(
    CF CHAR(16) PRIMARY KEY,
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
    FOREIGN KEY(n_distretto, regione) REFERENCES Distretto(numero, regione) ON DELETE NO ACTION ON UPDATE
    /* se elimino un presidente non voglio cancellare il distretto*/
);

CREATE TABLE Presidente(
    cf CHAR(16) PRIMARY KEY,
    voto TINYINT NOT NULL,
    lode BIT NOT NULL,
    FOREIGN KEY (cf) REFERENCES Socio(cf) ON DELETE CASCADE ON UPDATE CASCADE
    /*se elimino un socio voglio elminare anche il presidente ez*/
);

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
    UNIQUE INDEX(regione, n_distretto, data)
    /* ????  no  ????*/
);

CREATE TABLE Presenza(
    socio CHAR(16) NOT NULL,
    riunione INT UNSIGNED NOT NULL,
    PRIMARY KEY (socio, riunione),
    FOREIGN KEY (socio) REFERENCES Socio(cf) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (riunione) REFERENCES Riunione(id) ON DELETE CASCADE ON UPDATE CASCADE,
);

CREATE TABLE Ente(
    nome VARCHAR(50) NOT NULL,
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
    indirizzo VARCHAR(100) NOT NULL,
    telefono VARCHAR(13) NOT NULL UNIQUE,
    descrizione VARCHAR(100) NOT NULL,
    PRIMARY KEY(nome, regione),
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
    /* apertura e chiusura vanno senza not null, possono essere null*/
    FOREIGN KEY(ente, regione) REFERENCES Ente(nome, regione) ON DELETE NO ACTION ON UPDATE CASCADE,
);

CREATE TABLE Valutazione(
    richiesta INT UNSIGNED,
    riunione INT UNSIGNED,
    PRIMARY KEY (richiesta, riunione),
    FOREIGN KEY (richiesta) REFERENCES Richiesta(id),
    FOREIGN KEY (riunione) REFERENCES Riunione(id),
);

CREATE TABLE Prodotto (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    modello VARCHAR(30) NOT NULL,
    descrizione VARCHAR(100),
);

CREATE TABLE VoceRichiesta (
    prodotto INT UNSIGNED NOT NULL,
    richiesta INT UNSIGNED NOT NULL,
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (prodotto, richiesta),
    FOREIGN KEY prodotto REFERENCES Prodotto(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY richiesta REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE,
);

CREATE TABLE Azienda (
    PIVA CHAR(11) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    telefono VARCHAR(13) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL
);

CREATE TABLE Preventivo (
    piva CHAR(11) NOT NULL,
    richiesta INT UNSIGNED NOT NULL,
    emissione DATE NOT NULL,
    PRIMARY KEY (piva, richiesta),
    FOREIGN KEY piva REFERENCES Azienda(piva) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY richiesta REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE,
);

CREATE TABLE VocePreventivo (
    piva CHAR(11) NOT NULL,
    /* lo richiamerei "azienda" mi descrive meglio secondo me*/
    prodotto INT UNSIGNED NOT NULL,
    richiesta INT UNSIGNED NOT NULL,
    quantita INT UNSIGNED NOT NULL,
    prezzo DECIMAL(8, 2) NOT NULL,
    PRIMARY KEY (piva, richiesta, quantita),
    FOREIGN KEY (piva, richiesta) REFERENCES Preventivo(piva, richiesta) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (richiesta, prodotto) REFERENCES VoceRichiesta(richiesta, prodotto) ON DELETE NO ACTION ON UPDATE CASCADE,
    /* OPPURE SET NULL ANCHE*/
);

CREATE TABLE Scheda(
    riunione INT UNSIGNED NOT NULL,
    numero INT UNSIGNED NOT NULL,
    /* qua ipoteticamente c'e' lo stesso problema di numero di distretto oppure ce ne freghiamo e facciamo un autoincrement e chi se ne fotte tanto non é importantissimo*/
    tipologia ENUM("BIANCA", "NULLA", "VALIDA") NOT NULL,
    preferenza INT UNSIGNED,
    /* qualche check qua nel caso tipologia sia valida  deve essere presente la prefenza (quindi non nulla) ????*/
    FOREIGN KEY preferenza REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY riunione REFERENCES Riunione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
);

CREATE TABLE Vincitore(
    piva CHAR(11) NOT NULL,
    richiesta INT UNSIGNED NOT NULL,
    dichiarazione DATE NOT NULL,
    PRIMARY KEY(piva, richiesta) FOREIGN KEY (piva, richiesta) REFERENCES Preventivo(piva, richiesta) ON DELETE CASCADE ON UPDATE CASCADE,
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
    FOREIGN KEY (regione, n_distretto) REFERENCES Distretto(regione, numero) ON DELETE NO ACTION ON UPDATE CASCADE,
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
    FOREIGN KEY donato_presso REFERENCES Occasione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
);

CREATE TABLE Spesa(
    transazione INT UNSIGNED NOT NULL PRIMARY KEY,
    occasione INT UNSIGNED NOT NULL,
    giustificazione VARCHAR(255) NOT NULL,
    FOREIGN KEY transazione REFERENCES Transazione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY occasione REFERENCES Occasione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
);

CREATE TABLE Fattura(
    transazione INT UNSIGNED NOT NULL PRIMARY KEY,
    progressivo INT UNSIGNED NOT NULL,
    piva CHAR(11) NOT NULL,
    richiesta INT UNSIGNED NOT NULL,
    FOREIGN KEY (piva, richiesta) REFERENCES Vincitore(piva, richiesta) ON DELETE NO ACTION ON UPDATE CASCADE,
);

-- Popolazione Distretto
INSERT INTO
    Distretto()
VALUES
    ("", "", "", "", "", "", ""),
    -- Popolazione Socio
INSERT INTO
    Socio(
        CF,
        nome,
        cognome,
        telefono,
        email,
        data_nascita,
        indirizzo
    )
VALUES
    ("", "", "", "", "", "", ""),
    -- Popolazione Presidente
INSERT INTO
    Presidente(CF, voto, lode)
VALUES
    ("", "", ""),
    -- Popolazione Riunione
INSERT INTO
    Riunione(id, regione, numero, data)
VALUES
    ("", "", "", "", "", "", ""),