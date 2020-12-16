
SET FOREIGN_KEY_CHECKS=0;

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
	numero INT NOT NULL AUTO_INCREMENT,
	nome VARCHAR(20) NOT NULL,
	indirizzo VARCHAR(100) NOT NULL,
	regione ???
    presidente CHAR(16),
    FOREIGN KEY (presidente) REFERENCES Presidente(cf)
);

CREATE TABLE Socio(
	CF CHAR(16) PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	cognome VARCHAR(50) NOT NULL,
	telefono VARCHAR(13) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%_@__%.__%'),
	data_nascita DATE NOT NULL,
	indirizzo VARCHAR(100) NOT NULL,
    
);

CREATE TABLE Presidente(
	cf CHAR(16) PRIMARY KEY,
	voto TINYINT NOT NULL,
	lode BIT NOT NULL,
	
    FOREIGN KEY (cf) REFERENCES socio(cf) /*ON DELETE ??? ON UPDATE ???*/
);

CREATE TABLE Regione(
);



CREATE TABLE Riunione(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    regione ???
    nDistretto
    data DATE NOT NULL
);

CREATE TABLE Presenza(
    socio CHAR(16),
    riunione INT UNSIGNED,
    
    PRIMARY KEY(socio, riunione)
);

CREATE TABLE Ente(
    nome VARCHAR(50),
    regione 
    indirizzo VARCHAR(100) NOT NULL,
    telefono VARCHAR(13) NOT NULL UNIQUE,
    descrizione VARCHAR(100) NOT NULL,
    
    PRIMARY KEY(nome, regione)
);

CREATE TABLE Richiesta(
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ente VARCHAR(50) NOT NULL,
    regione,
    creazione DATE,
    apertura DATE,
    chiusura DATE,
);

CREATE TABLE Valutazione(
    richiesta INT UNSIGNED,
    riunione INT UNSIGNED,
    
    PRIMARY KEY(richiesta, riunione),
    FOREIGN KEY (richiesta) REFERENCES Richiesta(id),
    FOREIGN KEY (riunione) REFERENCES Riunione(id),  
);

CREATE TABLE Prodotto(
);

CREATE TABLE VoceRichiesta(
);

CREATE TABLE Azienda(
    PIVA CHAR(11) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    telefono VARCHAR(13) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL
);

CREATE TABLE Preventivo(
    
);

CREATE TABLE VocePreventivo(
);

CREATE TABLE Scheda(
);

CREATE TABLE Vincitore(
);

CREATE TABLE Occasione(
);

CREATE TABLE Transazione(
);

CREATE TABLE Spesa(
);

CREATE TABLE Fattura(
);


-- Popolazione Distretto
INSERT INTO Distretto() VALUES 
    ("", "", "", "", "", "", ""),


-- Popolazione Socio
INSERT INTO Socio(CF, nome, cognome, telefono, email, data_nascita, indirizzo) VALUES 
    ("", "", "", "", "", "", ""),
    



-- Popolazione Presidente
INSERT INTO Presidente(CF, voto, lode) VALUES 
    ("", "", ""),
    
    
-- Popolazione Riunione
INSERT INTO Riunione(id, regione, numero, data) VALUES 
    ("", "", "", "", "", "", ""),
