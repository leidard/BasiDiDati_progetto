--Svuota il database
DROP TABLE IF EXISTS Fattura CASCADE;
DROP TABLE IF EXISTS Spesa CASCADE;
DROP TABLE IF EXISTS Transazione CASCADE;
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
DROP TABLE IF EXISTS Distretto CASCADE;
DROP TABLE IF EXISTS Presidente CASCADE;
DROP TABLE IF EXISTS Socio;

--Eliminazione dei tipi
DROP TYPE IF EXISTS REGIONI;
DROP TYPE IF EXISTS TIPOLOGIADITRANSAZIONE;
DROP TYPE IF EXISTS TIPOLOGIADISCHEDA;



----------------CREAZIONE DATABASE----------------

--Creazione dei tipi
CREATE TYPE REGIONI AS ENUM ('VALLE D''AOSTA','PIEMONTE','LIGURIA','LOMBARDIA','TRENTINO-ALTO ADIGE','VENETO','FRIULI-VENEZIA GIULIA','EMILIA ROMAGNA','TOSCANA','UMBRIA','MARCHE','LAZIO','ABRUZZO','MOLISE','CAMPANIA','PUGLIA','BASILICATA','CALABRIA','SICILIA','SARDEGNA');
CREATE TYPE TIPOLOGIADITRANSAZIONE AS ENUM('DONAZIONE','SPESA','FATTURA'); 
CREATE TYPE TIPOLOGIADISCHEDA AS ENUM('VALIDA','BIANCA','NULLA'); 

--Creazione delle tabelle
CREATE TABLE Distretto(
    numero INT,
    regione REGIONI,
    nome VARCHAR(20) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL,
    presidente CHAR(16),
    PRIMARY KEY(numero, regione)
);

CREATE TABLE Socio(
    cf CHAR(16) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    telefono VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%_@__%.__%'),
    data_nascita DATE NOT NULL,
    indirizzo VARCHAR(100) NOT NULL,
    n_distretto INT NOT NULL,
    regione REGIONI NOT NULL,
    FOREIGN KEY(n_distretto, regione) REFERENCES Distretto(numero, regione) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Presidente(
    cf CHAR(16) PRIMARY KEY,
    voto SMALLINT NOT NULL,
    lode BOOLEAN DEFAULT FALSE,
    CHECK ((lode=TRUE AND voto=110) OR (lode=FALSE AND voto<=110)),
    FOREIGN KEY (cf) REFERENCES Socio(cf) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE Distretto ADD FOREIGN KEY (presidente) REFERENCES Presidente(cf) ON DELETE NO ACTION ON UPDATE CASCADE;

CREATE TABLE Riunione(
    id SERIAL PRIMARY KEY,
    regione REGIONI NOT NULL,
    n_distretto INT NOT NULL,
    data DATE NOT NULL,
    UNIQUE(regione, n_distretto, data),
    FOREIGN KEY (regione, n_distretto) REFERENCES Distretto(regione, numero) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Presenza(
    socio CHAR(16),
    riunione INT,
    PRIMARY KEY (socio, riunione),
    FOREIGN KEY (socio) REFERENCES Socio(cf) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (riunione) REFERENCES Riunione(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Ente(
    nome VARCHAR(50),
    regione REGIONI,
    indirizzo VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL UNIQUE,
    descrizione VARCHAR(100),
    PRIMARY KEY(nome, regione)
);

CREATE TABLE Richiesta(
    id SERIAL PRIMARY KEY,
    ente VARCHAR(50) NOT NULL,
    regione REGIONI NOT NULL,
    creazione DATE NOT NULL,
    apertura DATE,
    chiusura DATE,
    FOREIGN KEY(ente, regione) REFERENCES Ente(nome, regione) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Valutazione(
    richiesta INT,
    riunione INT,
    PRIMARY KEY (richiesta, riunione),
    FOREIGN KEY (richiesta) REFERENCES Richiesta(id),
    FOREIGN KEY (riunione) REFERENCES Riunione(id)
);

CREATE TABLE Prodotto(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    specifiche VARCHAR(150)
);

CREATE TABLE VoceRichiesta(
    prodotto INT,
    richiesta INT,
    quantita INT NOT NULL,
    PRIMARY KEY (prodotto, richiesta),
    FOREIGN KEY (prodotto) REFERENCES Prodotto(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (richiesta) REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Azienda(
    piva CHAR(11) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL
);

CREATE TABLE Preventivo(
    piva CHAR(11),
    richiesta INT,
    emissione DATE NOT NULL,
    PRIMARY KEY (piva, richiesta),
    FOREIGN KEY (piva) REFERENCES Azienda(piva) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (richiesta) REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE VocePreventivo(
    azienda CHAR(11),
    richiesta INT,
    prodotto INT,
    quantita INT NOT NULL,
    prezzo DECIMAL(8, 2) NOT NULL,
    PRIMARY KEY (azienda, richiesta, prodotto),
    FOREIGN KEY (azienda, richiesta) REFERENCES Preventivo(piva, richiesta) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (richiesta, prodotto) REFERENCES VoceRichiesta(richiesta, prodotto) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Scheda(
    numero SERIAL PRIMARY KEY,
    riunione INT NOT NULL,
    tipologia TIPOLOGIADISCHEDA NOT NULL,
    preferenza INT,
    CHECK ((tipologia = 'VALIDA' AND preferenza IS NOT NULL) OR ((tipologia = 'NULLA' OR tipologia = 'BIANCA') AND preferenza IS NULL)),
    FOREIGN KEY (preferenza) REFERENCES Richiesta(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (riunione) REFERENCES Riunione(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Vincitore(
    piva CHAR(11),
    richiesta INT,
    dichiarazione DATE NOT NULL,
    PRIMARY KEY(piva, richiesta), 
    FOREIGN KEY (piva, richiesta) REFERENCES Preventivo(piva, richiesta) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Occasione(
    id SERIAL PRIMARY KEY,
    indirizzo VARCHAR(100) NOT NULL,
    data DATE NOT NULL,
    descrizione VARCHAR(255) NOT NULL,
    regione REGIONI NOT NULL,
    n_distretto INT NOT NULL,
    FOREIGN KEY (regione, n_distretto) REFERENCES Distretto(regione, numero) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Transazione(
    id SERIAL PRIMARY KEY,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    importo DECIMAL(8, 2) NOT NULL,
    regione REGIONI NOT NULL,
    n_distretto INT NOT NULL,
    tipologia TIPOLOGIADITRANSAZIONE NOT NULL,
    donato_presso INT,
    FOREIGN KEY (regione, n_distretto) REFERENCES Distretto(regione, numero) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (donato_presso) REFERENCES Occasione(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Spesa(
    transazione INT PRIMARY KEY,
    occasione INT NOT NULL,
    giustificazione VARCHAR(255) NOT NULL,
    FOREIGN KEY (transazione) REFERENCES Transazione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (occasione) REFERENCES Occasione(id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Fattura(
    transazione INT PRIMARY KEY,
    progressivo SERIAL NOT NULL,
    piva CHAR(11) NOT NULL,
    richiesta INT NOT NULL,
    FOREIGN KEY (transazione) REFERENCES Transazione(id) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (piva, richiesta) REFERENCES Vincitore(piva, richiesta) ON DELETE NO ACTION ON UPDATE CASCADE
);





----------------POPOLAZIONE DATABASE----------------

-- Popolazione Distretto
INSERT INTO
    Distretto(numero, regione, nome, indirizzo)
VALUES
    (1, 'VENETO', 'Padova1', 'Via Roma 23, Padova 35140'),                    
    (2, 'VENETO', 'Padova2', 'Via Firenze 10, Padova 35139'),
    (3, 'VENETO', 'Venezia1', 'Piazza S. Marco 10, Venezia 30122'),                    
    (1, 'LAZIO', 'Roma1', 'Via Del Sole, Roma 00010');            
    
-- Popolazione Socio
INSERT INTO
    Socio(CF, nome, cognome, telefono, email, data_nascita, indirizzo, n_distretto, regione)
VALUES
    ('RSSMRA70S02G224K', 'Mario', 'Rossi', '+39 1234567890', 'mariorossi@mail.com', '1990-11-02', 'via Roma 1, Padova', 1, 'VENETO'),
    ('FJLTDP54A19C700X', 'Fabio', 'Del Santo', '+39 1234567891', 'fabiosanto@mail.com', '1974-04-22', 'via Borghese 12, Roma', 1, 'LAZIO'),
    ('MIRTRO11A50E142B', 'Mirella', 'La Torre', '+39 1234567892', 'mire.lato@gmail.com', '1982-10-30', 'via Ferro 8, Roma', 1, 'LAZIO'),
    ('PALZBE82E10V790H', 'Paolo', 'Zabarella', '+39 1234567893', 'paolo.zabarella@mail.com', '1982-02-02', 'via Borghese 36, Roma', 1, 'LAZIO'),
    ('MRODFA76U61V815A', 'Marco', 'Di Falco', '+39 1234567894', 'marco.difalco@mail.com', '1976-08-02', 'via Brigante 42, Roma', 1, 'LAZIO'),
    ('LGUBGO79S39G398K', 'Luigi', 'Brigo', '+39 1234567895', 'luigi.brigo@mail.com', '1979-04-02', 'via Sassari 22, Roma', 1, 'LAZIO'),
    ('MRAASS34A19C700X', 'Maria', 'Assunta', '+39 3335578910', 'mariaass@mail.com', '1990-10-22', 'via Bolla 3, Padova', 1, 'VENETO'),
    ('FFCFTE86V13V734O', 'Franca', 'Forte', '+39 3334921079', 'francyyy@mail.com', '1986-10-09', 'via Ghiberti 42 , Padova', 1, 'VENETO'),
    ('CHRSTA00P02A224K', 'Chiara', 'Stella', '+39 123567896', 'chiarastar@mail.com', '1990-01-01', 'via Dei Papaveri, 51, Padova', 2, 'VENETO'),
    ('LUASAT88B02H094F', 'Lucia', 'Santarelli', '+39 1234567897', 'santalucia@mail.com', '1988-05-28', 'via Roma 11, Padova', 2, 'VENETO'),
    ('SFNBNH91Q80E142P', 'Stefano', 'Bianchi', '+39 1234567898', 'biastef@gmail.com', '1991-02-20', 'via Calabresi 11, Roma', 1, 'LAZIO'),
    ('MRKSTP98M16O730F', 'Mirko', 'Stapella', '+39 0002573940', 'mirkstap@mail.com', '1998-12-25', 'via Plinio 04, Roma', 1, 'LAZIO'),
    ('ANDTRO69B42E700J', 'Andrea', 'Del Toro', '+39 9762385079', 'andretorodel@mail.com', '1969-11-12', 'via Barcaioli 89, Venezia', 3, 'VENETO'),
    ('ALSZNN85W14Z292A', 'Alessia', 'Zanon', '+39 3340129976', 'alezanna@mail.com', '1985-01-30', 'via Dei Santi 11, Padova', 1, 'VENETO'),
    ('ALCSNN54A19M784W', 'Alice', 'Sanno', '+39 3792224668', 'alicesanno@mail.com', '1984-07-06', 'via Settembre 09, Padova', 1, 'VENETO'),
    ('GLOCDI94V12E294X', 'Giulio', 'Casadei', '+39 3894672046', 'giuliocasad@mail.com', '1994-03-10', 'Piazza Delle Erbe 02, Venezia', 3, 'VENETO'),
    ('ALRLPO59D95N520B', 'Alberto', 'Lupo', '+39 3846750199', 'lupoalberto@mail.com', '1959-02-02', 'via Gerusalemme 19, Venezia', 3, 'VENETO'),
    ('DVDGLL99P88C724T', 'Davide', 'Gallo', '+39 3987200001', 'gallodave@mail.com', '1999-04-17', 'via Genova 22, Padova', 2, 'VENETO'),
    ('JNNSTH82B29C982T', 'Jennifer', 'Smith', '+39 3956444823', 'jennysmt@mail.com', '1982-03-11', 'via America 12, Padova', 2, 'VENETO'),
    ('LFACNA59U13P130U', 'Alfredo', 'Conaro', '+39 3268132022', 'alfecon@mail.com', '1959-12-17', 'via Peonia 03, Padova', 1, 'VENETO'),
    ('LCUSRE92F19Q700U', 'Luca', 'Servile', '+39 3333383340', 'luservile@mail.com', '1992-06-18', 'via Danubio 01, Padova', 2, 'VENETO'),
    ('SMASSA69D92I933A', 'Samuele', 'Sasso', '+39 3996558996', 'samusasso@mail.com', '1969-12-25', 'via Padova 30, Padova', 1, 'VENETO'),
    ('GNEGNI85M19E702E', 'Gennaro', 'Giunta', '+39 3987208901', 'gennagiunta@mail.com', '1985-04-02', 'via Distina 02, Venezia', 3, 'VENETO'),
    ('NDAGNE78A24E721X', 'Nadia', 'Gentile', '+39 3556552355', 'nadiagentile@mail.com', '1978-03-03', 'Piazza Duomo 14, Roma', 1, 'LAZIO'),
    ('CHIFRA91D01Q021E', 'Chiara', 'Ferragno', '+39 3596211118', 'chiaraferragno@mail.com', '1991-05-09', 'Via Dei Ruscelli 10, Roma', 1, 'LAZIO'),
    ('FBAFSU84E24W202R', 'Fabio', 'Fusto', '+39 3123699985', 'fustofabio@mail.com', '1984-10-23', 'Piazza Dei Vinti 06, Roma', 1, 'LAZIO'),
    ('MRACLA95F41R041T', 'Martina', 'Calle', '+39 3798874650', 'martycall@mail.com', '1995-03-16', 'Via Divina 18, Roma', 1, 'LAZIO'),
    ('LCUMBO67U35I721I', 'Luce', 'Ombrin', '+39 3222215669', 'luceombrin@mail.com', '1967-11-09', 'Via Rudale 07, Venezia', 3, 'VENETO'),
    ('LSETIL83E21E591V', 'Elisabetta', 'Italiano', '+39 3299855462', 'eliita@mail.com', '1983-01-20', 'Via Notte 23, Padova', 1, 'VENETO'),
    ('ZXOPSI77H35V509X', 'Ezio', 'Pisani', '+39 3666995230', 'eziopisani@mail.com', '1977-10-28', 'Via Politica 11, Venezia', 3, 'VENETO'),
    ('SLIPRO68D41H141R', 'Silvia', 'Opera', '+39 3009008007', 'silvope@mail.com', '1968-08-01', 'Via Degli Alberi 17, Roma', 1, 'LAZIO'),
    ('KRASMI90E71V291P', 'Karen', 'Smith', '+39 3687555544', 'karensmith@mail.com', '1990-10-31', 'Via Senna 07, Padova', 2, 'VENETO'),
    ('ALSMGA90E21N291I', 'Alfredo', 'Bianchi', '+39 3975449688', 'alfebianchi@mail.com', '1977-04-01', 'Via Sipario 22, Padova', 2, 'VENETO'),
    ('LGUBTE82E50H905W', 'Luigi', 'Bettin', '+39 3658765109', 'luigibetty@mail.com', '1982-06-11', 'Via Ghianda 07, Venezia', 3, 'VENETO'),
    ('OSVFRT66A19C700L', 'Osvaldo', 'Forte', '+39 33349210999', 'osvaldoforte@mail.com', '1966-04-19', 'via Dei Canti 18, Roma', 1, 'LAZIO'),
    ('SREFNO59D95N520B', 'Sergio', 'Fontana', '+39 3844700133', 'sergiofonta@mail.com', '1959-02-02', 'via Gerusalemme 11, Roma', 1, 'LAZIO'),
    ('NCIFRE88E08W345R', 'Nicola', 'Fredino', '+39 3299856000', 'nicolafredi@mail.com', '1988-05-16', 'via Pisani 04, Roma', 1, 'LAZIO'),
    ('ALEGRC89D42N520B', 'Alessandra', 'Greco', '+39 3985216223', 'alessandragre@mail.com', '1989-04-18', 'via Narina 31, Padova', 2, 'VENETO'),
    ('GRELVA84E43E042X', 'Greta', 'Lavigna', '+39 3232323232', 'gretalvign@mail.com', '1984-11-19', 'via Vino 07, Padova', 2, 'VENETO'),
    ('JSADNI78W30V420E', 'Jasmine', 'Dinzeo', '+39 3696969804', 'jasmdinz@mail.com', '1978-04-16', 'via Romolo 31, Padova', 1, 'VENETO'),
    ('SBIRSU59D20V501B', 'Isabella', 'Russo', '+39 3787596400', 'isarusso@mail.com', '1959-12-14', 'via Canali 03, Padova', 2, 'VENETO'),
    ('VLALFE66E44E993V', 'Valentino', 'Elfino', '+39 3641402872', 'valeelf@mail.com', '1966-06-06', 'via Peonia 10, Roma', 1, 'LAZIO'),
    ('VLADNE85A90V631U', 'Valentino', 'Denni', '+39 3898989574', 'valdenni@mail.com', '1985-06-18', 'via Padova 30, Venezia', 3, 'VENETO');


-- Popolazione Presidente
INSERT INTO
    Presidente(CF, voto, lode) 
VALUES
    ('FJLTDP54A19C700X', 108, FALSE), -- Lazio1
    ('RSSMRA70S02G224K', 99, FALSE), -- Veneto1
    ('CHRSTA00P02A224K', 110, TRUE), -- Veneto2
    ('ANDTRO69B42E700J', 110, FALSE); -- Veneto3
  
    
-- Popolazione Riunione
INSERT INTO
    Riunione(regione, n_distretto, data)
VALUES
    ('VENETO', 1, '2020-10-15'),    --1
    ('VENETO', 2, '2020-10-15'),    --2
    ('VENETO', 3, '2020-10-15'),    --3
    ('LAZIO', 1, '2020-10-15'),    --4
    
    ('VENETO', 1, '2020-11-01'),    --5
    ('VENETO', 2, '2020-11-01'),    --6
    ('VENETO', 3, '2020-11-01'),    --7
    ('LAZIO', 1, '2020-11-01'),    --8
    
    ('VENETO', 1, '2020-11-16'),    --9
    ('VENETO', 2, '2020-11-16'),    --10
    ('VENETO', 3, '2020-11-16'),    --11
    ('LAZIO', 1, '2020-11-16');    --12
    
    
-- Popolazione Presenza
INSERT INTO
    Presenza(socio, riunione)
VALUES
    --1 CICLO DI RIUNIONI
    ('RSSMRA70S02G224K', 1), --presidente ven1 
    ('FFCFTE86V13V734O', 1),
    ('ALSZNN85W14Z292A', 1),
    ('ALCSNN54A19M784W', 1),
    
    ('CHRSTA00P02A224K', 2), --presidente ven2
    ('JNNSTH82B29C982T', 2),
    ('LCUSRE92F19Q700U', 2),
    
    ('ANDTRO69B42E700J', 3), --presidente ven3
    ('GNEGNI85M19E702E', 3 ),
    ('LCUMBO67U35I721I', 3 ),
    ('ZXOPSI77H35V509X', 3 ),
    ('LGUBTE82E50H905W', 3 ),
    ('VLADNE85A90V631U', 3 ),
    
    ('FJLTDP54A19C700X', 4), --presidente laz1
    ('PALZBE82E10V790H', 4),
    ('MRODFA76U61V815A', 4),
    ('LGUBGO79S39G398K', 4),
    ('SFNBNH91Q80E142P', 4),

    -- 2 CICLO DI RIUNIONI
    ('RSSMRA70S02G224K', 5), --pres ven1 
    ('FJLTDP54A19C700X', 5),
    ('FFCFTE86V13V734O', 5),
    ('ALSZNN85W14Z292A', 5),
    
    ('CHRSTA00P02A224K', 6), --pres ven2
    ('KRASMI90E71V291P', 6),
    ('ALSMGA90E21N291I', 6),
    ('LUASAT88B02H094F', 6),
    ('DVDGLL99P88C724T', 6),
    
    ('ANDTRO69B42E700J', 7), --pres ven3
    ('GLOCDI94V12E294X', 7 ),
    ('LCUMBO67U35I721I', 7 ),
    ('ZXOPSI77H35V509X', 7 ),
    
    ('FJLTDP54A19C700X', 8), --pres laz1
    ('LGUBGO79S39G398K', 8),
    ('SFNBNH91Q80E142P', 8),
    ('MRKSTP98M16O730F', 8),
    ('NDAGNE78A24E721X', 8),
    
    -- 3 CICLO DI RIUNIONI
    ('RSSMRA70S02G224K', 9), --pres ven1 
    ('LFACNA59U13P130U', 9),
    ('LSETIL83E21E591V', 9),
    ('FJLTDP54A19C700X', 9),
    ('ALCSNN54A19M784W', 9),
    
    
    ('CHRSTA00P02A224K', 10), --pres ven2
    ('GRELVA84E43E042X', 10),
    ('JNNSTH82B29C982T', 10),
    ('SBIRSU59D20V501B', 10),
    
    ('ANDTRO69B42E700J', 11), --pres ven3
    ('GNEGNI85M19E702E', 11 ),
    ('LCUMBO67U35I721I', 11 ),
    
    ('FJLTDP54A19C700X', 12), --pres laz1
    ('FBAFSU84E24W202R', 12),  
    ('MRACLA95F41R041T', 12),
    ('NCIFRE88E08W345R', 12),
    ('SLIPRO68D41H141R', 12),
    ('MIRTRO11A50E142B', 12),
    ('PALZBE82E10V790H', 12),
    ('MRODFA76U61V815A', 12);
    

-- Popolazione Ente
INSERT INTO
    Ente(regione, nome, telefono, indirizzo, descrizione)
VALUES 
    ('VENETO', 'Casa di Riposo Santa Maria Padova', '+39 310874827', 'Via Marco Polo 3, 53530, Padova', 'Casa di riposo per anziani'),
    ('VENETO', 'Azienda Ospedaliera di Padova', '+39 350874827', 'Via Venezia 68, 78864, Padova', NULL),
    ('VENETO', 'Azienda Ospedaliera di Venezia', '+39 344405107', 'Via San Girolamo 56, 10637, Venezia', NULL),
    ('LAZIO', 'Mensa Papa Giovanni', '+39 355667963', 'Via Padre Pio 45, 24678, Roma', 'Mensa popolare per senzatetto'),
    ('LAZIO', 'Casa di Cura San Gennaro', '+39 372111710', 'Via Domenica 93, 25072, Roma', NULL),
    ('LAZIO', 'Caritas San Francesco', '+39 3855554620', 'Via Parma 08, 25072, Roma', NULL),
    ('VENETO', 'Opera San Giovanni', '+39 341315440', 'Via San Francesco 22, 21534, Padova', 'Residenza per senzatetto'),
    ('VENETO', 'Casa Elisabetta', '+39 300317963', 'Via Padre Pio 45, 24678, Venezia', 'Dimora per senzatetto'),
    ('VENETO', 'Canile di Padova', '+39 3048293029', 'Via Michelangelo 3, 23043, Padova', NULL),
    ('VENETO', 'Medici senza frontiere gruppo di Padova', '+39 392292896', 'Via Guizza 93, 32768, Roma', NULL), 
    ('LAZIO', 'Azienda Ospedaliera di Roma', '+39 316733072', 'Via 30 Febbraio 2, 62771, Roma', NULL),
    ('VENETO', 'Cucine Popolari S. Rita', '+39 3039872123', 'Via Padre Pio 45, 24678, Padova', NULL),
    ('VENETO', 'Istituto Oncologico di Padova', '+39 3333331092', 'Via Gattamelata 93, 32768, Padova', NULL),
    ('LAZIO', 'Caritas Roma', '+39 3333333847', 'Via Margherita 01, 32768, Roma', NULL);
    

-- Popolazione Richiesta
INSERT INTO
    Richiesta(ente, regione, creazione, apertura, chiusura)
VALUES
    ('Casa di Riposo Santa Maria Padova', 'VENETO', '2020-10-11', '2020-10-15', '2020-11-15'),    --1 
    ('Azienda Ospedaliera di Padova', 'VENETO', '2020-10-11', '2020-10-15', '2020-11-15'),            --2
    ('Azienda Ospedaliera di Venezia', 'VENETO', '2020-10-12', '2020-10-15', '2020-11-15'),            --3
    ('Mensa Papa Giovanni', 'LAZIO', '2020-10-14', '2020-10-15', '2020-11-15'),                        --4
    ('Casa di Cura San Gennaro', 'LAZIO', '2020-10-14', '2020-11-01', '2020-12-01'),            --5    --esempio di richiesta che è stata votata meno di un'altra e viene approvata alla riunione successiva (2 votazioni)
    ('Opera San Giovanni', 'VENETO', '2020-10-22', '2020-11-01', '2020-12-01'),                    --6 
    ('Casa Elisabetta', 'VENETO', '2020-10-27', '2020-11-01', '2020-12-01'),                        --7 
    ('Canile di Padova', 'VENETO', '2020-10-29', '2020-11-01', '2020-12-01'),                        --8
    ('Medici senza frontiere gruppo di Padova', 'VENETO', '2020-10-29', NULL, NULL),                  --9    --esempio di richiesta votata due volte (riunione 11-01 E 11-16), ma mai approvata 
    ('Azienda Ospedaliera di Roma', 'LAZIO', '2020-11-02', '2020-11-16', '2020-12-16'),                --10
    ('Cucine Popolari S. Rita', 'VENETO', '2020-11-02', '2020-11-16', '2020-12-16'),                --11
    ('Istituto Oncologico di Padova', 'VENETO', '2020-11-07', '2020-11-16', '2020-12-16'),            --12
    ('Azienda Ospedaliera di Venezia', 'VENETO', '2020-11-12', '2020-11-16', '2020-12-16'),            --13
    --richieste non ancora discusse:
    ('Caritas Roma', 'LAZIO', '2020-11-19', NULL, NULL),        --14  
    ('Caritas San Francesco', 'LAZIO', '2020-11-30', NULL, NULL);    --15   
   
             
-- Popolazione Valutazione
INSERT INTO
    Valutazione(richiesta, riunione)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 4),
    (6, 5),
    (8, 6),
    (9, 6),
    (7, 7),
    (5, 8),
    (11, 9),
    (9, 10),
    (13, 10),
    (12, 11),
    (10, 12);
   
     
-- Popolazione Prodotto
INSERT INTO
    Prodotto(nome, specifiche)
VALUES
    ('Mascherina', 'FFP2'),    --1
    ('Mascherina', 'FFP3'),    --2
    ('Letto singolo', 'Piegevole, con barre laterali, asta sollevammalati e ruote piroettanti con freno'),    --3
    ('Materasso', 'Ipoallergenico'),    --4
    ('Materasso', 'Antidecubito'),    --5
    ('Microonde', 'Potenza fino a 900W'), --6
    ('Piumone', '90x200, ipoallergenico'), --7
    ('Sacco a pelo', 'Comfort 0 gradi'), --8
    ('Antistaminico', 'Classe A'), --9
    ('Sedia a rotelle elettrica', 'Peso max 150Kg'), --10
    ('Pannoloni anziani', NULL), --11
    ('Pasta', 'Secca, 1Kg'), --12
    ('Fagioli', 'In lattina'), --13
    ('Latte', '1L, UHT'), --14
    ('Latte in polvere', 'per neonati, 6 mesi'), --15
    ('Pannolini per neonati', NULL), --16
    ('Stufa elettrica', 'Alogena a basso consumo'), --17
    ('Cibo per cani', 'Scatolette gastrointestinal'), --18
    ('Sollevatore pazienti', 'Elettrico, fino a 135Kg'), --19
    ('Camice operatorio', 'Taglia M'), --20
    ('Tuta protettiva integrale', 'Omologazione CE-DPI di I categoria, monouso in TNT di PP), 40 G/MQ'), --21
    ('Bombola ossigeno monouso', 'Ossigeno 99,5% compresso a 110 bar per ossigenoterapia da 0,95 lt'), --22
    ('Frigorifero', 'Classe A++, >200 litri'), --23
    ('Sanificatore ambienti a ozono', NULL), --24
    ('Defibrillatore DAE semiautomatico', 'Conforme alle linee guida 2010'), --25
    ('Vaccino', 'Meningococco B'), --26
    ('Vaccino', 'MPRV'), --27
    ('Crocchette Carne Cani', 'Secco Carne 1Kg'), --28
    ('Crocchette Pesce Cani', 'Secco Pesce 1Kg'), --29
    ('Sacco Patate', '1Kg'), --30
    ('Sedia a rotelle', NULL); --31
     
    
-- Popolazione VoceRichiesta
INSERT INTO
    VoceRichiesta(prodotto, richiesta, quantita)
VALUES
    (10, 1, 27), 
    (11, 1, 2000),
    
    (19,2,20), 
    (20,2,55),
    (21,2,500),
    
    (2,3,5000), 
    (21,3,3050),
    (22,3,1000),
    
    (12,4,300), 
    (23,4,3),
    (6, 4, 5),
    (13, 4, 400),
    
    (26, 5, 250),
    (27, 5, 250),
    (2, 5, 400),
    
    (8, 6, 50), 
    (4, 6, 14),
    (5, 6, 6),

    (25, 7, 1), 
    (24, 7, 2),
    (10, 7, 3),

    (18, 8, 800), 
    (17, 8, 3),
    (28, 8, 200),
    (29, 8, 200),

    (26, 9, 1200), 
    (27, 9, 1500),
    (22, 9, 450),
    
    (24, 10, 5), 
    (20, 10, 200),
    (3, 10, 56),

    (12, 11, 900), 
    (30, 11, 50),
    (13, 11, 300),

    (3, 12, 23),
    (20, 12, 150),

    (24, 13, 10), 
    (25, 13, 1),

    (7, 14, 46), 
    (6, 14, 5),
    (1, 14, 2000),
    
    (12, 15, 80), 
    (15, 15, 45),
    (13, 15, 40);
   
    
-- Popolazione Azienda
INSERT INTO
    Azienda(piva, nome, telefono, indirizzo)
VALUES
    ('8238401722', 'FarmaPh s.r.l.', '+39 310874827', 'Via Marco Polo 3, 53530, Padova'),
    ('6699331325', 'La casa degli amici', '+39 310820827', 'Via Napoli 68, 78864, Padova'),
    ('7607418259', 'Grandi Magazzini Ferrarin s.r.l.', '+39 340405107', 'Via San Girolamo 56, 10637, Roma'),
    ('8749297545', 'Supermercati Hello', '+39 355607963', 'Via Padre Pio 45, 24678, Roma'),
    ('1657677425', 'Bisognin s.p.a.', '+39 370138344', 'Via Cesare Beccaria 33, 94672, Venezia'),
    ('2979137105', 'Pronti S.p.A.', '+39 341315440', 'Via San Francesco 22, 21534, Venezia'),
    ('9416760333', 'Healthcare s.a.s.', '+39 343865550', 'Via Vandolmo 65, 87431, Milano'),
    ('9416294820', 'Foodish S.p.A.', '+39 3000055501', 'Via Parigi 36, 87431, Latina'),
    ('5735548958', 'Friulani Medical s.p.a.', '+39 392200116', 'Via Guizza 93, 32768, Trento'),
    ('1448068341', 'Smiling s.r.l.', '+39 391156326', 'Via Colombo 64, 31358, Padova'),
    ('9619512572', 'EscherMed s.p.a.', '+39 354289884', 'Via Primavera 37, 62456, Treviso'),
    ('1021583491', 'Grazie Inc. s.p.a.', '+39 372111710', 'Via Sicilia 93, 25072, Roma');
    
    
-- Popolazione Preventivo
INSERT INTO
    Preventivo(piva, richiesta, emissione)
VALUES
    ('1657677425', 1, '2020-10-27'), 
    ('8238401722', 1, '2020-10-29'),
    ('9416760333', 2, '2020-10-30'),
    ('5735548958', 3, '2020-10-30'), 
    ('9416294820', 4, '2020-11-06'),
    ('9619512572', 5, '2020-11-23'), 
    ('5735548958', 5, '2020-11-24'), 
    ('1657677425', 6, '2020-11-24'),
    ('9416760333', 7, '2020-11-29'),
    ('6699331325', 8, '2020-11-30'), 
    ('7607418259', 10, '2020-12-01'),
    ('8749297545', 11, '2020-12-06'),
    ('1021583491', 12, '2020-12-09'),
    ('1448068341', 13, '2020-12-12'),
    ('2979137105', 13, '2020-12-13'); 
    

-- Popolazione VocePreventivo
INSERT INTO
    VocePreventivo(azienda, prodotto, richiesta, quantita, prezzo)
VALUES
    ('1657677425', 10, 1, 27, 247),
    ('1657677425', 11, 1, 2000, 3), --perde
    
    ('8238401722', 10, 1, 27, 230),
    ('8238401722', 11, 1, 2000, 2), --vince, tot: 10.210 euro
    
    ('9416760333', 19, 2, 20, 320),
    ('9416760333', 20, 2, 55, 3),
    ('9416760333', 21, 2, 500, 3), --vince, tot: 8.065 euro
    
    ('5735548958', 2, 3, 5000, 0.60),
    ('5735548958', 21, 3, 2000, 0.60), 
    ('5735548958', 22, 3, 1000, 1.10), --vince, tot: 5.300 euro
    
    ('9416294820', 12, 4, 300, 0.15), 
    ('9416294820', 23, 4, 3, 399),
    ('9416294820', 6, 4, 5, 23),
    ('9416294820', 13, 4, 400, 0.09), --vince, tot: 1.717 euro
    
    ('9619512572', 26, 5, 250, 1.50),
    ('9619512572', 27, 5, 250, 1.50), --vince, tot: 750 euro
    
    ('5735548958', 26, 5, 250, 2.50),
    ('5735548958', 27, 5, 250, 2.50), --perde
    
    ('1657677425', 8, 6, 50, 4.30),
    ('1657677425', 4, 6, 14, 34),
    ('1657677425', 5, 6, 6, 60), --vince, tot: 1.051 euro
    
    ('9416760333', 25, 7, 1, 750),
    ('9416760333', 24, 7, 2, 320),
    ('9416760333', 10, 7, 3, 185), --vince, tot: 1.945 euro
    
    ('6699331325', 18, 8, 800, 0.15),
    ('6699331325', 17, 8, 3, 32),
    ('6699331325', 28, 8, 200, 0.80),
    ('6699331325', 29, 8, 200, 0.80), --vince, tot: 536 euro
    
    ('7607418259', 24, 10, 5, 315),
    ('7607418259', 20, 10, 200, 0.80), 
    ('7607418259', 3, 10, 56, 112), --vince, tot: 8.007 euro
     
    ('8749297545', 12, 11, 900, 0.18),
    ('8749297545', 30, 11, 50, 0.09),
    ('8749297545', 13, 11, 300, 0.09), -- vince, tot: 193,5 euro
    
    ('1021583491', 3, 12, 23, 110),
    ('1021583491', 20, 12, 120, 2.50), --vince, tot: 2.830 euro
        
    ('1448068341', 24, 13, 10, 216),    
    ('1448068341', 25, 13, 1, 680),  --vince, tot: 2.840 euro
    
    ('2979137105', 24, 13, 10, 239),    
    ('2979137105', 25, 13, 1, 700); --perde
    
    
    -- Popolazione Scheda
INSERT INTO
    Scheda(riunione, tipologia, preferenza)
VALUES
    (1, 'VALIDA', 1),
    (1, 'NULLA', NULL),
    (1, 'VALIDA', 1),
    (1, 'VALIDA', 1),
    
    (2, 'VALIDA', 2),
    (2, 'VALIDA', 2),
    (2, 'VALIDA', 2),
    
    (3, 'BIANCA', NULL),
    (3, 'NULLA', NULL),
    (3, 'VALIDA', 3),
    (3, 'VALIDA', 3),
    (3, 'VALIDA', 3),
    (3, 'VALIDA', 3),
    
    (4, 'BIANCA', NULL),
    (4, 'NULLA', NULL),
    (4, 'VALIDA', 4),
    (4, 'VALIDA', 4), 
    (4, 'VALIDA', 5),
    
    (5, 'VALIDA', 6),
    (5, 'VALIDA', 6),
    (5, 'VALIDA', 6),
    (5, 'NULLA', NULL),
    
    (6, 'VALIDA', 8),
    (6, 'VALIDA', 8),
    (6, 'VALIDA', 9),
    (6, 'BIANCA', NULL),
    (6, 'VALIDA', 8),
    
    (7, 'VALIDA', 7),
    (7, 'BIANCA', NULL),
    (7, 'VALIDA', 7),
    (7, 'VALIDA', 7),
    
    (8, 'VALIDA', 5),
    (8, 'VALIDA', 5),
    (8, 'VALIDA', 5),
    (8, 'BIANCA', NULL),
    (8, 'BIANCA', NULL),
    
    (9, 'NULLA', NULL),
    (9, 'VALIDA', 11),
    (9, 'VALIDA', 11),
    (9, 'VALIDA', 11),
    (9, 'VALIDA', 11),
    
    (10, 'VALIDA', 9),
    (10, 'VALIDA', 13),
    (10, 'VALIDA', 13),
    (10, 'VALIDA', 13),
    
    (11, 'VALIDA', 12),
    (11, 'VALIDA', 12),
    (11, 'VALIDA', 12),
    
    (12, 'VALIDA', 10),
    (12, 'VALIDA', 10),
    (12, 'NULLA', NULL),
    (12, 'BIANCA', NULL),
    (12, 'BIANCA', NULL),
    (12, 'VALIDA', 10),
    (12, 'VALIDA', 10),
    (12, 'VALIDA', 10);
    

-- Popolazione Vincitore 
INSERT INTO
    Vincitore(piva, richiesta, dichiarazione)
VALUES
    ('8238401722', 1, '2020-11-15'),
    ('9416760333', 2, '2020-11-15'),
    ('5735548958', 3, '2020-11-15'),
    ('9416294820', 4, '2020-11-15'),
    ('9619512572', 5, '2020-12-01'),
    ('1657677425', 6, '2020-12-01'),
    ('9416760333', 7, '2020-12-01'),
    ('6699331325', 8, '2020-12-01'),
    ('7607418259', 10, '2020-12-16'),
    ('8749297545', 11, '2020-12-16'),
    ('1021583491', 12, '2020-12-16'),
    ('1448068341', 13, '2020-12-16');
    
    
-- Popolazione Occasione
INSERT INTO
    Occasione(indirizzo, data, descrizione, regione, n_distretto)    
VALUES
    ('Via Torino, 14A', '2020-11-08', 'Fiera campionaria', 'LAZIO', 1),                            --1
    ('Via Padre Pio, 11 Padova', '2020-11-14', 'Fiera del volontariato', 'VENETO', 1),            --2    
    ('Via Roma, Padova', '2020-11-15', 'Banchetto promozionale', 'VENETO', 1),                    --3
    ('Prato della Valle, Padova', '2020-11-21', 'Banchetto promozionale', 'VENETO', 1),            --4
    ('Corso Milano, Roma', '2020-11-21', 'Banchetto promozionale', 'LAZIO', 1),                    --5
    ('Via Padre Pio, 11 Padova', '2020-11-22', 'Fiera del volontariato', 'VENETO', 1),            --6
    ('Via Padre Pio, 11 Padova', '2020-11-28', 'Fiera del volontariato', 'VENETO', 2),            --7
    ('Via Romagna, 41 Venezia', '2020-11-28', 'Polo Fieristico di Venezia', 'VENETO', 3),       --8
    ('San Pietro, Roma', '2020-11-28', 'Promozione in strada con volantinaggio', 'LAZIO', 1),    --9
    ('Via Romagna, 41 Venezia', '2020-11-29', 'Polo Fieristico di Venezia', 'VENETO', 3);        --10

    
-- Popolazione Transazione
INSERT INTO
    Transazione(time, importo, regione, n_distretto, tipologia, donato_presso)    
VALUES --tipologia: 'DONAZIONE', 'SPESA', 'FATTURA'
    ('2020-11-05 10:00:41', 50, 'LAZIO', 1, 'SPESA', NULL),                    --1
    ('2020-11-05 10:20:02', 80, 'LAZIO', 1, 'SPESA', NULL),                    --2
    ('2020-11-08 22:51:13', 223, 'LAZIO', 1, 'DONAZIONE', 1),            --3
    
    ('2020-11-10 09:41:20', 20, 'VENETO', 1, 'SPESA', NULL),                    --4
    ('2020-11-10 11:07:41', 55, 'VENETO', 1, 'SPESA', NULL),                    --5
    ('2020-11-14 21:34:05', 302.5, 'VENETO', 1, 'DONAZIONE', 2),        --6
    
    ('2020-11-15 20:57:12', 55.32, 'VENETO', 1, 'DONAZIONE', 3),        --7
    
    ('2020-11-21 21:11:20', 72.90, 'VENETO', 1, 'DONAZIONE', 4),        --8
    
    ('2020-11-21 21:37:49', 43, 'LAZIO', 1, 'DONAZIONE', 5),            --9
    
    ('2020-11-22 06:21:06', 62, 'VENETO', 1, 'SPESA', NULL),                    --10
    ('2020-11-22 06:30:30', 42, 'VENETO', 1, 'SPESA', NULL),                    --11
    ('2020-11-22 21:59:47', 113.20, 'VENETO', 1, 'DONAZIONE', 6),        --12
    
    ('2020-11-25 17:03:00', 122, 'VENETO', 2, 'SPESA', NULL),                    --13
    ('2020-11-25 17:07:03', 98, 'VENETO', 3, 'SPESA', NULL),                    --14
    ('2020-11-26 14:16:18', 38, 'VENETO', 2, 'SPESA', NULL),                    --15
    ('2020-11-28 22:41:03', 341, 'VENETO', 2, 'DONAZIONE', 7),        --16
    ('2020-11-28 22:48:38', 261.10, 'VENETO', 3, 'DONAZIONE', 8),        --17
    
    ('2020-11-28 23:05:11', 63, 'LAZIO', 1, 'DONAZIONE', 9),            --18
    
    ('2020-11-29 05:57:18', 45, 'VENETO', 3, 'SPESA', NULL),                    --19
    ('2020-11-29 06:45:32', 110, 'VENETO', 3, 'SPESA', NULL),                    --20
    ('2020-11-29 22:03:47', 143, 'VENETO', 3, 'DONAZIONE', 10),        --21
    
    ('2020-11-30 09:05:05', 10210, 'VENETO', 1, 'FATTURA', NULL),                --22
    ('2020-11-30 09:10:08', 8065, 'VENETO', 2, 'FATTURA', NULL),                --23
    ('2020-11-30 09:13:19', 5300, 'VENETO', 3, 'FATTURA', NULL),                --24
    ('2020-11-30 09:17:24', 1717, 'LAZIO', 1, 'FATTURA', NULL),                --25
    
    ('2020-12-04 11:34:08', 750, 'VENETO', 1, 'FATTURA', NULL),                --26
    ('2020-12-06 11:37:30', 1051, 'VENETO', 2, 'FATTURA', NULL),                --27
    ('2020-12-06 11:41:54', 1945, 'VENETO', 3, 'FATTURA', NULL),                --28
    ('2020-12-08 11:46:20', 536, 'LAZIO', 1, 'FATTURA', NULL),                    --29
    
    ('2020-12-18 10:32:01', 8007, 'VENETO', 1, 'FATTURA', NULL),                --30
    ('2020-12-19 09:14:00', 2830, 'VENETO', 2, 'FATTURA', NULL),                --31
    ('2020-12-23 12:46:08', 1945, 'VENETO', 3, 'FATTURA', NULL);                --32
 
    
-- Popolazione Spesa
INSERT INTO
    Spesa(transazione, occasione, giustificazione)
VALUES
    (1, 1, 'Quota di partecipazione fiera'),
    (2, 1, 'Costi di allestimento stand'),
    (4, 2, 'Quota di partecipazione fiera'),
    (5, 2, 'Costi di allestimento stand'),
    (10, 6, 'Contributo fiera'),
    (11, 6, 'Costi di stampa volantini'),
    (13, 7, 'Costi di allestimento stand'),
    (14, 8, 'Costi di allestimento stand'),
    (15, 7, 'Costi di stampa volantini'),
    (19, 10, 'Quota di partecipazione fiera'),
    (20, 10, 'Costi di noleggio bancarella');
    

-- Popolazione Fattura
INSERT INTO
    Fattura(transazione, piva, richiesta)
VALUES
    (22, '8238401722', 1),
    (23, '9416760333', 2),
    (24, '5735548958', 3),
    (25, '9416294820', 4),
    (26, '9619512572', 5),
    (27, '1657677425', 6),
    (28, '9416760333', 7),
    (29, '6699331325', 8),
    (30, '7607418259', 10),
    (31, '8749297545', 11),
    (32, '1021583491', 12);
    
    
    
    
    
    
----------------QUERY----------------

--1: Per ogni distretto mostrare il totale delle donazioni che ha ottenuto, il totale delle spese effettuate, 
--   il totale delle fatture emesse e il ricavato netto(donazioni-(fatture+spese)):
DROP VIEW IF EXISTS totaleFatt; DROP VIEW IF EXISTS totaleDonaz; DROP VIEW IF EXISTS totaleSpese; 
CREATE VIEW totaleFatt AS (SELECT Distretto.nome, SUM(importo) AS TOT_FATTURE
FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione
WHERE Transazione.tipologia = 'FATTURA'
GROUP BY Distretto.nome);

CREATE VIEW totaleDonaz AS (SELECT Distretto.nome, SUM(importo) AS TOT_DONAZIONI
FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione
WHERE Transazione.tipologia = 'DONAZIONE'
GROUP BY Distretto.nome);

CREATE VIEW totaleSpese AS (SELECT Distretto.nome, SUM(importo) AS TOT_SPESE
FROM Distretto JOIN Transazione on Distretto.numero = Transazione.n_distretto AND Distretto.regione = Transazione.regione
WHERE Transazione.tipologia = 'SPESA'
GROUP BY Distretto.nome);

SELECT DISTINCT totaleFatt.nome, TOT_DONAZIONI, TOT_SPESE, TOT_FATTURE, (TOT_DONAZIONI-(TOT_SPESE+TOT_FATTURE)) AS NETTO
FROM totaleFatt JOIN totaleDonaz on totaleFatt.nome=totaleDonaz.nome JOIN totaleSpese ON totaleDonaz.nome=totaleSpese.nome;


--2: Elencare in ordine crescente i distretti che hanno approvato più richieste contenenti il prodotto "Mascherina" 
--   nel periodo che va dal 15.10.2020 al 16.11.2020:
SELECT Riunione.regione, Riunione.n_distretto, COUNT(*) AS N_richiesteApprovate 
FROM Riunione JOIN Valutazione ON Riunione.id=Valutazione.riunione JOIN Richiesta ON Valutazione.richiesta = Richiesta.id JOIN VoceRichiesta ON Richiesta.id =VoceRichiesta.richiesta JOIN Prodotto ON VoceRichiesta.prodotto = Prodotto.id
WHERE Prodotto.nome='Mascherina' AND Richiesta.apertura >='2020.10.15' AND Richiesta.apertura <='2020.11.16'
GROUP BY (Riunione.regione, Riunione.n_distretto)
ORDER BY N_richiesteApprovate DESC;


--3: Elencare in ordine crescente le tre aziende che hanno ricevuto più soldi da parte di WeCare e, per ognuna, 
--   il numero di preventivi vincitori che detiene:
SELECT T2.PIVA, T1.Azienda, T1.N_Vincite, T2.Soldi_ricevuti 
FROM
(SELECT Azienda.piva AS PIVA, Azienda.nome AS Azienda, count(*) AS N_Vincite
FROM Azienda INNER JOIN Preventivo ON Azienda.piva = Preventivo.piva INNER JOIN Vincitore ON Preventivo.piva = Vincitore.piva
GROUP BY Azienda.piva) AS T1
JOIN
(SELECT Vincitore.piva AS PIVA, SUM(Transazione.importo) AS Soldi_ricevuti
FROM Vincitore INNER JOIN Fattura ON Vincitore.piva = Fattura.piva INNER JOIN Transazione ON Fattura.transazione = Transazione.id
GROUP BY Vincitore.piva) AS T2
ON T2.PIVA = T1.PIVA
ORDER BY Soldi_ricevuti DESC
LIMIT 3;


--4: Elencare per ciascuna regione il tempo (in giorni) minimo, medio e massimo impiegato per portare a termine le richieste, 
--   il numero di richieste portate a termine e quelle ancora aperte: 
DROP VIEW IF EXISTS RichiesteAperte;
CREATE VIEW RichiesteAperte AS ( 
	SELECT id, ente, regione, creazione, apertura, chiusura FROM Richiesta WHERE apertura IS NOT NULL AND chiusura IS NULL);
	
DROP VIEW IF EXISTS RichiestaConclusaTempoImpiegato;
CREATE VIEW RichiestaConclusaTempoImpiegato AS (
	SELECT id, ente, regione, EXTRACT(EPOCH FROM (chiusura::timestamp - apertura::timestamp))/86400::int AS tempo FROM Richiesta 
	WHERE apertura IS NOT NULL AND chiusura IS NOT NULL);
	
SELECT rcti.regione, MIN(rcti.tempo) AS minimo, MAX(rcti.tempo) AS massimo, AVG(rcti.tempo) AS medio, 
	COUNT(rcti.id) AS concluse, COUNT(ra.id) AS aperte
FROM RichiestaConclusaTempoImpiegato AS rcti
FULL OUTER JOIN RichiesteAperte AS ra
ON rcti.id = ra.id GROUP BY (rcti.regione);


--5: Per ogni richiesta (approvata o meno) trovare il distretto che l’ha approvata e determinare durante quale riunione 
--   e con quanti voti è passata:
DROP VIEW IF EXISTS VotiPerRichiesta CASCADE;
CREATE VIEW VotiPerRichiesta AS (
	SELECT riunione, preferenza, count(numero) AS num_voti FROM Scheda 
	WHERE preferenza IS NOT NULL GROUP BY (preferenza, riunione) ORDER BY riunione ASC
);

DROP VIEW IF EXISTS VincitorePerRiunione;
CREATE VIEW VincitorePerRiunione AS (
	SELECT * FROM VotiPerRichiesta a 
	WHERE num_voti = (SELECT MAX(num_voti) FROM VotiPerRichiesta WHERE riunione = a.riunione)
);

SELECT ric.id, riu.n_distretto, riu.regione, v.riunione, v.num_voti FROM Riunione AS riu FULL JOIN VincitorePerRiunione AS v 
ON riu.id = v.riunione
FULL JOIN Richiesta AS ric ON v.preferenza = ric.id
ORDER BY ric.id ASC;


--6: Per ciascun DISTRETTO all’interno della regione “VENETO” ricavare quante presenze ha totalizzato dall'inizio dell’anno “2020” 
--   (la somma di ogni “presenza”) e inoltre uno tra i soci meno presenti con il suo numero di presenze e 
--   lo stesso per uno tra i piú presenti.
DROP VIEW IF EXISTS PresenzePerDistretto; 
CREATE VIEW PresenzePerDistretto AS( SELECT s.n_distretto, s.regione, COUNT(p.socio) AS presenze, EXTRACT(YEAR FROM r.data) AS anno 
FROM Presenza AS p INNER JOIN Socio AS s ON p.socio = s.cf INNER JOIN Riunione AS r ON p.riunione = r.id 
GROUP BY (s.n_distretto, s.regione, anno)); 

DROP VIEW IF EXISTS PresenzaPerSocio; 
CREATE VIEW PresenzaPerSocio AS ( SELECT p.socio, n_distretto, regione, COUNT(p.socio) AS num_presenze 
FROM Presenza AS p INNER JOIN Socio AS s ON s.cf = p.socio 
GROUP BY (socio, n_distretto, regione) 
ORDER BY num_presenze ); 

SELECT ppd.regione, ppd.n_distretto, ppd.presenze, ppd.anno, pp.socio AS "piu presente", pp.num_presenze AS "presenze massime", mp.socio AS "meno presente", mp.num_presenze AS "presenze minime" 
FROM PresenzePerDistretto AS ppd 
FULL JOIN 
( SELECT DISTINCT ON (n_distretto, regione) * FROM PresenzaPerSocio AS p1 WHERE num_presenze = (SELECT MAX(num_presenze) FROM PresenzaPerSocio AS p2 
WHERE p1.regione = p2.regione AND p1.n_distretto = p2.n_distretto LIMIT 1) ) AS pp ON ppd.n_distretto = pp.n_distretto AND ppd.regione = pp.regione 
FULL JOIN 
( SELECT DISTINCT ON (n_distretto, regione) * 
FROM PresenzaPerSocio AS p1 
WHERE num_presenze = (SELECT MIN(num_presenze) FROM PresenzaPerSocio AS p2 
WHERE p1.regione = p2.regione AND p1.n_distretto = p2.n_distretto LIMIT 1) ) AS mp ON ppd.n_distretto = mp.n_distretto AND ppd.regione = mp.regione 
WHERE anno = 2020 AND ppd.regione = 'VENETO' 
ORDER BY (ppd.regione, ppd.n_distretto);




----------------INDICE----------------
DROP INDEX IF EXISTS idx_idProdotto;
CREATE INDEX idx_idProdotto ON Prodotto(id);

