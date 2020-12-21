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
    numero INT UNSIGNED NOT NULL,
    regione ENUM(
        "VALLE D'AOSTA",
        "PIEMONTE",
        "LIGURIA",
        "LOMBARDIA",
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
    nome VARCHAR(20) NOT NULL,
    indirizzo VARCHAR(100) NOT NULL,
    presidente CHAR(16),
    PRIMARY KEY(numero, regione)
    /* il fatto che non ci sia il not null vuol dire che potrebbe non avere subito il presidente. Quindi risolto????*/
    /*FOREIGN KEY (presidente) REFERENCES Presidente(cf) ON DELETE NO ACTION ON UPDATE CASCADE*/
);

CREATE TABLE Socio(
    cf CHAR(16) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    telefono VARCHAR(15) NOT NULL UNIQUE,
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
    CHECK ((lode=1 AND voto=110) OR (lode=0 AND voto<=110)),
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
    telefono VARCHAR(15) NOT NULL UNIQUE,
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
    specifiche VARCHAR(100)
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
    telefono VARCHAR(15) NOT NULL,
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
    riunione INT UNSIGNED NOT NULL,
    tipologia ENUM("BIANCA", "NULLA", "VALIDA") NOT NULL,
    preferenza INT UNSIGNED,
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


-- Popolazione Distretto
INSERT INTO
    Distretto(numero, regione, nome, indirizzo, presidente)
VALUES
    ("1", "VENETO", "Padova1", "Via Roma 23, Padova 35140", ""),					
    ("2", "VENETO", "Padova2", "Via Firenze 10, Padova 35139", ""),
    ("3", "VENETO", "Venezia1", "Piazza S. Marco 10, Venezia 30122", ""),					
    ("1", "LAZIO" "Roma1", "Via Del Sole, Roma 00010", ""),					
    -- ("2", "LAZIO", "Latina1", "Via Battaglia 3 Latina 04010", ""),			
    -- ("1", "LOMBARDIA", "Bergamo1", "Via Rosa 52 Bergamo 24099", ""),				
    -- ("1", "TOSCANA", "Firenze1", "Via Leopardi 3 Firenze 50012", ""),			
    -- ("2", "TOSCANA", "Firenze2", "Via Roma 40 Firenze 50012", ""),				
    -- ("2", "LOMBARDIA", "Milano1", "Via Dante 22 Milano 20010", ""),				
    -- ("3", "LAZIO", "Roma2", "Via Venezia 9 Roma 00016", ""),						
    -- ("1", "CAMPANIA", "Salerno1", "Via Petrarca 6 Salerno 84070", ""),	!		
    -- ("1", "BASILICATA" "Matera1", "Via Dante 11 Matera 75062", ""),		!		
    
    3 veneto 8 per 1 8 per 2 8 per 3
    1 lazio 16
    
    1 lombardia
    1 toscana
    /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
    /*Riduciamo i distretti a 5/6 così possiamo fare più riunioni senza un listone infinito. Vanno sistemati i membri che avevo messo ufff*/
    
    -- Popolazione Socio
INSERT INTO
    Socio(CF, nome, cognome, telefono, email, data_nascita, indirizzo, n_distretto, regione)
VALUES
    ("RSSMRA70S02G224K", "Mario", "Rossi", "+39 1234567890", "mariorossi@mail.com", "1990-11-02", "via Roma 1, Padova", "1", "VENETO"),
    ("FJLTDP54A19C700X", "Fabio", "Del Santo", "+39 1234567891", "fabiosanto@mail.com", "1974-04-22", "via Borghese 12, Roma", "1", "LAZIO"),
    ("MIRTRO11A50E142B", "Mirella", "La Torre", "+39 1234567892", "mire.lato@gmail.com", "1982-10-30", "via Ferro 8, Roma", "1", "LAZIO"),
    ("PALZBE82E10V790H", "Paolo", "Zabarella", "+39 1234567893", "paolo.zabarella@mail.com", "1982-02-02", "via Borghese 36, Roma", "1", "LAZIO"),
    ("MRODFA76U61V815A", "Marco", "Di Falco", "+39 1234567894", "marco.difalco@mail.com", "1976-08-02", "via Brigante 42, Roma", "1", "LAZIO"),
    ("LGUBGO79S39G398K", "Luigi", "Brigo", "+39 1234567895", "luigi.brigo@mail.com", "1979-04-02", "via Sassari 22, Roma", "1", "LAZIO"),
    ("FJLTDP54A19C700X", "Maria", "Assunta", "+39 3335578910", "mariaass@mail.com", "1990-10-22", "via Bolla 3, Padova", "1", "VENETO"),
	("FFCFTE86V13V734O", "Franca", "Forte", "+39 3334921079", "francyyy@mail.com", "1986-10-09", "via Ghiberti 42 , Padova", "1", "VENETO"),
	("CHRSTA00P02A224K", "Chiara", "Stella", "+39 123567896", "chiarastar@mail.com", "1990-01-01", "via Dei Papaveri, 51, Padova", "2", "VENETO"),
    ("LUASAT88B02H094F", "Lucia", "Santarelli", "+39 1234567897", "santalucia@mail.com", "1988-05-28", "via Roma 11, Padova", "2", "VENETO"),
    ("SFNBNH91Q80E142P", "Stefano", "Bianchi", "+39 1234567898", "biastef@gmail.com", "1991-02-20", "via Calabresi 11, Roma", "1", "LAZIO"),
    ("MRKSTP98M16O730F", "Mirko", "Stapella", "+39 0002573940", "mirkstap@mail.com", "1998-12-25", "via Plinio 04, Roma", "1", "LAZIO"),
    ("ANDTRO69B42E700J", "Andrea", "Del Toro", "+39 9762385079", "andretorodel@mail.com", "1969-11-12", "via Barcaioli 89, Venezia", "3", "VENETO"),
    ("ALSZNN85W14Z292A", "Alessia", "Zanon", "+39 3340129976", "alezanna@mail.com", "1985-01-30", "via Dei Santi 11, Padova", "1", "VENETO"),
    ("ALCSNN54A19M784W", "Alice", "Sanno", "+39 3792224668", "alicesanno@mail.com", "1984-07-06", "via Settembre 09, Padova", "1", "VENETO"),
    ("GLOCDI94V12E294X", "Giulio", "Casadei", "+39 3894672046", "giuliocasad@mail.com", "1994-03-10", "Piazza Delle Erbe 02, Venezia", "3", "VENETO"),
    ("ALRLPO59D95N520B", "Alberto", "Lupo", "+39 3846750199", "lupoalberto@mail.com", "1959-02-02", "via Gerusalemme 19, Venezia", "3", "VENETO"),
    ("DVDGLL99P88C724T", "Davide", "Gallo", "+39 3987200001", "gallodave@mail.com", "1999-04-17", "via Genova 22, Padova", "2", "VENETO"),
    ("JNNSTH82B29C982T", "Jennifer", "Smith", "+39 3956444823", "jennysmt@mail.com", "1982-03-11", "via America 12, Padova", "2", "VENETO"),
    ("LFACNA59U13P130U", "Alfredo", "Conaro", "+39 3268132022", "alfecon@mail.com", "1959-12-17", "via Peonia 03, Padova", "1", "VENETO"),
    ("LCUSRE92F19Q700U", "Luca", "Servile", "+39 3333383340", "luservile@mail.com", "1992-06-18", "via Danubio 01, Padova", "2", "VENETO"),
    ("SMASSA69D92I933A", "Samuele", "Sasso", "+39 3996558996", "samusasso@mail.com", "1969-12-25", "via Padova 30, Padova", "1", "VENETO"),
    ("GNEGNI85M19E702E", "Gennaro", "Giunta", "+39 3987208901", "gennagiunta@mail.com", "1985-04-02", "via Distina 02, Venezia", "3", "VENETO"),
    ("NDAGNE78A24E721X", "Nadia", "Gentile", "+39 3556552355", "nadiagentile@mail.com", "1978-03-03", "Piazza Duomo 14, Roma", "1", "LAZIO"),
	("CHIFRA91D01Q021E", "Chiara", "Ferragno", "+39 3596211118", "chiaraferragno@mail.com", "1991-05-09", "Via Dei Ruscelli 10, Roma", "1", "LAZIO"),
	("FBAFSU84E24W202R", "Fabio", "Fusto", "+39 3123699985", "fustofabio@mail.com", "1984-10-23", "Piazza Dei Vinti 06, Roma", "1", "LAZIO"),
	("MRACLA95F41R041T", "Martina", "Calle", "+39 3798874650", "martycall@mail.com", "1995-03-16", "Via Divina 18, Roma", "1", "LAZIO"),
	("LCUMBO67U35I721I", "Luce", "Ombrin", "+39 3222215669", "luceombrin@mail.com", "1967-11-09", "Via Rudale 07, Venezia", "3", "VENETO"),
	("LSETIL83E21E591V", "Elisabetta", "Italiano", "+39 3299855462", "eliita@mail.com", "1983-01-20", "Via Notte 23, Padova", "1", "VENETO"),
	("ZXOPSI77H35V509X", "Ezio", "Pisani", "+39 3666995230", "eziopisani@mail.com", "1977-10-28", "Via Politica 11, Venezia", "3", "VENETO"),
	("SLIPRO68D41H141R", "Silvia", "Opera", "+39 3009008007", "silvope@mail.com", "1968-08-01", "Via Degli Alberi 17, Roma", "1", "LAZIO"),
	("KRASMI90E71V291P", "Karen", "Smith", "+39 3687555544", "karensmith@mail.com", "1990-10-31", "Via Senna 07, Padova", "2", "VENETO"),
	("ALSMGA90E21N291I", "Alfredo", "Bianchi", "+39 3975449688", "alfebianchi@mail.com", "1977-04-01", "Via Sipario 22, Padova", "2", "VENETO"),
	("LGUBTE82E50H905W", "Luigi", "Bettin", "+39 3658765109", "luigibetty@mail.com", "1982-06-11", "Via Ghianda 07, Venezia", "3", "VENETO"),
	("FJLTDP54A19C700X", "Osvaldo", "Forte", "+39 33349210999", "osvaldoforte@mail.com", "1966-04-19", "via Dei Canti 18, Roma", "1", "LAZIO"),
    ("SREFNO59D95N520B", "Sergio", "Fontana", "+39 3846750199", "sergiofonta@mail.com", "1959-02-02", "via Gerusalemme 11, Roma", "1", "LAZIO"),
    ("NCIFRE88E08W345R", "Nicola", "Fredino", "+39 3299856000", "nicolafredi@mail.com", "1988-05-16", "via Pisani 04, Roma", "1", "LAZIO"),
    ("ALRLPO59D95N520B", "Alessandra", "Greco", "+39 3985216223", "alessandragre@mail.com", "1989-04-18", "via Narina 31, Padova", "2", "VENETO"),
    ("GRELVA84E43E042X", "Greta", "Lavigna", "+39 3232323232", "gretalvign@mail.com", "1984-11-19", "via Vino 07, Padova", "2", "VENETO"),
    ("JSADNI78W30V420E", "Jasmine", "Dinzeo", "+39 3696969804", "jasmdinz@mail.com", "1978-04-16", "via Romolo 31, Padova", "1", "VENETO"),
    ("SBIRSU59D20V501B", "Isabella", "Russo", "+39 3787596400", "isarusso@mail.com", "1959-12-14", "via Canali 03, Padova", "2", "VENETO"),
	("VLALFE66E44E993V", "Valentino", "Elfino", "+39 3641402872", "valeelf@mail.com", "1966-06-06", "via Peonia 10, Roma", "1", "LAZIO"),
	("VLADNE85A90V631U", "Valentino", "Denni", "+39 3898989574", "valdenni@mail.com", "1985-06-18", "via Padova 30, Venezia", "3", "VENETO"),


    
 -- Popolazione Presidente
INSERT INTO
    Presidente(CF, voto, lode) 
VALUES
    ("FJLTDP54A19C700X", "108", "0"), -- Lazio1
    ("RSSMRA70S02G224K", "99", "0"), -- Veneto1
    ("CHRSTA00P02A224K", "110", "1"), -- Veneto2
    ("ANDTRO69B42E700J", "110", "0"); -- Veneto3
  
    
    
    -- Popolazione Riunione
INSERT INTO
    Riunione(regione, numero, data)
VALUES
	("VENETO", "1", "2020-09-01"),1
    ("VENETO", "2", "2020-09-01"),2
    ("VENETO", "3", "2020-09-01"),3
    ("LAZIO", "1", "2020-09-01"),4
    
    ("VENETO", "1", "2020-09-15"),5
    ("VENETO", "2", "2020-09-15"),6
    ("VENETO", "3", "2020-09-15"),7
    ("LAZIO", "1", "2020-09-15"),8
    
    ("VENETO", "1", "2020-10-01"),9
    ("VENETO", "2", "2020-10-01"),10
    ("VENETO", "3", "2020-10-01"),11
    ("LAZIO", "1", "2020-10-01"),12
    
    ("VENETO", "1", "2020-10-15"),13
    ("VENETO", "2", "2020-10-15"),14
    ("VENETO", "3", "2020-10-15"),15
    ("LAZIO", "1", "2020-10-15"),16
    
    ("VENETO", "1", "2020-11-01"),17
    ("VENETO", "2", "2020-11-01"),18
    ("VENETO", "3", "2020-11-01"),19
    ("LAZIO", "1", "2020-11-01"),20
    
    ("VENETO", "1", "2020-11-16"),21
    ("VENETO", "2", "2020-11-16"),22
    ("VENETO", "3", "2020-11-16"),23
    ("LAZIO", "1", "2020-11-16"),24
    
    ("VENETO", "1", "2020-12-01"),25
    ("VENETO", "2", "2020-12-01"),26
    ("VENETO", "3", "2020-12-01"),27
    ("LAZIO", "1", "2020-12-01"),28
    
    ("VENETO", "1", "2020-12-15"),29
    ("VENETO", "2", "2020-12-15"),30
    ("VENETO", "3", "2020-12-15"),31
    ("LAZIO", "1", "2020-12-15");32
    
    
    
    
    -- Popolazione Presenza
INSERT INTO
    Presenza(socio, riunione)
VALUES
-- 1 CICLO DI RIUNIONI
    ("RSSMRA70S02G224K", "1"), --pres ven1 
    ("FFCFTE86V13V734O", "1"),
	("ALSZNN85W14Z292A", "1"),
    ("ALCSNN54A19M784W", "1"),
    
	("CHRSTA00P02A224K", "2"), --pres ven2
	("JNNSTH82B29C982T", "2"),
    ("LCUSRE92F19Q700U", "2"),
    
	("ANDTRO69B42E700J", "3"), --pres ven3
	("GNEGNI85M19E702E", "3" ),
	("LCUMBO67U35I721I", "3" ),
	("ZXOPSI77H35V509X", "3" ),
	("LGUBTE82E50H905W", "3" ),
	("VLADNE85A90V631U", "3" ),
	
	("FJLTDP54A19C700X", "4"), --pres laz1
    ("PALZBE82E10V790H", "4"),
    ("MRODFA76U61V815A", "4"),
    ("LGUBGO79S39G398K", "4"),
    ("SFNBNH91Q80E142P", "4"),

-- 2 CICLO DI RIUNIONI
    ("RSSMRA70S02G224K", "5"), --pres ven1 
    ("FJLTDP54A19C700X", "5"),
	("FFCFTE86V13V734O", "5"),
	("ALSZNN85W14Z292A", "5"),
    
    ("CHRSTA00P02A224K", "6"), --pres ven2
    ("KRASMI90E71V291P", "6"),
	("ALSMGA90E21N291I", "6")
	("LUASAT88B02H094F", "6"),
    ("DVDGLL99P88C724T", "6"),
    
    ("ANDTRO69B42E700J", "7"), --pres ven3
    ("GLOCDI94V12E294X", "7" ),
    ("LCUMBO67U35I721I", "7" ),
	("ZXOPSI77H35V509X", "7" ),
    
    ("FJLTDP54A19C700X", "8"), --pres laz1
    ("LGUBGO79S39G398K", "8"),
    ("SFNBNH91Q80E142P", "8"),
    ("MRKSTP98M16O730F", "8"),
	("NDAGNE78A24E721X", "8"),
	
-- 3 CICLO DI RIUNIONI
	("RSSMRA70S02G224K", "9"), --pres ven1 
	("LFACNA59U13P130U", "9"),
	("LSETIL83E21E591V", "9"),
	("FJLTDP54A19C700X", "9"),
	("ALCSNN54A19M784W", "9"),
	
	
	("CHRSTA00P02A224K", "10"), --pres ven2
	("GRELVA84E43E042X", "10"),
	("JNNSTH82B29C982T", "10"),
	("SBIRSU59D20V501B", "10")
	
	("ANDTRO69B42E700J", "11"), --pres ven3
	("GNEGNI85M19E702E", "11" ),
	("LCUMBO67U35I721I", "11" ),
	
	("FJLTDP54A19C700X", "12"), --pres laz1
	("FBAFSU84E24W202R", "12"),  
	("MRACLA95F41R041T", "12"),
	("NCIFRE88E08W345R", "12"),
    ("SLIPRO68D41H141R", "12"),
    ("MIRTRO11A50E142B", "12"),
    ("PALZBE82E10V790H", "12"),
    ("MRODFA76U61V815A", "12");
    
    -- "LCUMBO67U35I721I" di VEN3 è il socio che ha partecipato a tutte e 3 le riunioni, pur non essendo un presidente. 
	
	-- 3x4= 12 richieste approvate
	

    -- Popolazione Ente
INSERT INTO
    Ente(regione, nome, telefono, indirizzo, descrizione)
VALUES 
    ("VENETO", "Casa di Riposo \"Santa Maria\" Padova", "+39 310874827", "Via Marco Polo 3, 53530, Padova", "Casa di riposo per anziani"),
    ("VENETO", "Azienda Ospedaliera di Padova", "+39 350874827", "Via Venezia 68, 78864, Padova"),
    ("VENETO", "Azienda Ospedaliera di Venezia", "+39 344405107", "Via San Girolamo 56, 10637, Venezia"),
    ("LAZIO", "Mensa Papa Giovanni", "+39 355667963", "Via Padre Pio 45, 24678, Roma", "Mensa popolare per senzatetto"),
    ("LAZIO", "Caritas San Francesco", "+39 370138344", "Via Cesare Beccaria 33, 94672, Roma"),
    ("VENETO", "Opera San Giovanni", "+39 341315440", "Via San Francesco 22, 21534, Padova", "Residenza per senzatetto"),
    ("LAZIO", "Azienda Ospedaliera di Roma", "+39 316733072", "Via 30 Febbraio 2, 62771, Roma"),
    ("LAZIO", "Medici senza frontiere gruppo di Roma", "+39 392292896", "Via Guizza 93, 32768, Roma"),
    ("LAZIO", "Caritas Roma", "+39 391156326", "Via Padova 64, 31358, Roma"),
    ("LAZIO", "Casa di Cura \"San Gennaro\"", "+39 372111710", "Via Domenica 93, 25072, Roma"),
    ("VENETO", "Cucine Popolari S. Rita", "+39 355667963", "Via Padre Pio 45, 24678, Padova"),
    ("VENETO", "Casa Elisabetta", "+39 355667963", "Via Padre Pio 45, 24678, Venezia", "Dimora per senzatetto"),
    ("VENETO", "Canile di Padova", "+39 3048293029", "Via Michelangelo 3, 23043, Padova"),
    ("VENETO", "Medici senza frontiere gruppo di Padova", "+39 392292896", "Via Guizza 93, 32768, Roma"),
    ("VENETO", "Istituto Oncologico di Padova", "+39 392292896", "Via Gattamelata 93, 32768, Padova");
    
    
    
    -- Popolazione Richiesta
INSERT INTO
    Richiesta(ente, regione, creazione, apertura, chiusura)
VALUES
    ("Casa di Riposo \"Santa Maria\" Padova", "VENETO", "2020-08-11", "", ""),
    ("Azienda Ospedaliera di Padova", "VENETO", "2020-08-11", "", ""),
    
    
    
    -- Popolazione Valutazione
INSERT INTO
    Valutazione(richiesta, riunione)
VALUES
    ("", "");
    
    
    
    -- Popolazione Prodotto
INSERT INTO
    Prodotto(nome, specifiche)
VALUES
    ("Mascherina filtrante", "FFP2"),
    ("Mascherina filtrante", "FFP3"),
    ("Letto", "singolo, piegevole, con barre laterali, asta sollevammalati e ruote piroettanti con freno"),
    ("Materasso", "Ipoallergenico"),
    ("Materasso", "Antidecubito"),
    ("Microonde", "Potenza fino a 900W"),
    ("Piumone", "90x200, ipoallergenico"),
    ("Sacco a pelo", "Comfort 0 gradi"),
    ("Antistaminico", "Classe A"),
    ("Sedia a rotelle elettrica", "Peso max 150Kg"),
    ("Pannoloni anziani"),
    ("Pasta", "Secca, in pacchi da 1KG"),
    ("Fagioli", "In lattina"),
    ("Latte", "UHT"),
    ("Latte in polvere", "per neonati, 6 mesi"),
    ("Pannolini per neonati"),
    ("Stufa elettrica", "Alogena a basso consumo"),
    ("Cibo per cani", "Scatolette gastrointestinal"),

    
    
    -- Popolazione VoceRichiesta
INSERT INTO
    VoceRichiesta(prodotto, richiesta, quantita)
VALUES
    ("", "", "");
    
    
    -- Popolazione Azienda
INSERT INTO
    Azienda(piva, nome, telefono, indirizzo)
VALUES
    ("8238401722", "FarmaPh s.r.l.", "+39 310874827", "Via Marco Polo 3, 53530, Padova"),
    ("6699331325", "Arcaplanet", "+39 310820827", "Via Venezia 68, 78864, Angri"),
    ("7607418259", "Grandi Magazzini Ferrarin s.r.l.", "+39 340405107", "Via San Girolamo 56, 10637, Roma"),
    ("8749297545", "Supermercati Hello", "+39 355667963", "Via Padre Pio 45, 24678, Roma"),
    ("1657677425", "Decathlon s.p.a.", "+39 370138344", "Via Cesare Beccaria 33, 94672, Milano"),
    ("2979137105", "Pam Panorama S.p.A.", "+39 341315440", "Via San Francesco 22, 21534, Venezia"),
    ("5121672285", "Plasmon S.p.A.", "+39 306733072", "Via 30 Febbraio 2, 62771, Verona"),
    ("9416760333", "Sassari Healthcare s.a.s.", "+39 343865550", "Via Vandolmo 65, 87431, Latina"),
    ("9416760333", "Foodish S.p.A.", "+39 3000055501", "Via Parigi 36, 87431, Latina"),
    ("5735548958", "Friulani Medical s.p.a.", "+39 392292896", "Via Guizza 93, 32768, Trento"),
    ("1448068341", "Trainspotting Foods s.r.l.", "+39 391156326", "Via Padova 64, 31358, Firenze"),
    ("9619512572", "Escher Bevande s.p.a.", "+39 354289884", "Via Emili 37, 62456, Treviso"),
    ("1021583491", "Hollywood Food Inc. s.p.a.", "+39 372111710", "Via Roma 93, 25072, Milano");
    
    
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
    ("Via Padre Pio, 11 Padova", "2020-10-11", "Fiera del volontariato", "VENETO", "1"),
    ("Via Roma, Padova", "2020-10-12", "Banchetto promozionale", "VENETO", "1"),
    ("Piazza Roma, Padova", "2020-10-14", "Banchetto promozionale", "VENETO", "1"),
    ("Via Padre Pio, 11 Padova", "2020-10-17", "Fiera del volontariato", "VENETO", "1"),
    ("Via Padre Pio, 11 Padova", "2020-10-18", "Fiera del volontariato", "VENETO", "1"),
    ("Via Duomo, 32 Padova", "2020-10-18", "Polo Fieristico di Venezia", "VENETO", "3"),
    ("Via Romagna, 41 Venezia", "2020-10-19", "Polo Fieristico di Venezia", "VENETO", "3"),
    ("Via Briosco, 17 Roma", "2020-10-19", "Polo Fieristico di Roma", "LAZIO", "3"),

    
    
    
    
    -- Popolazione Transazione
INSERT INTO
    Transazione(time, importo, regione, n_distretto, tipologia, donato_presso)    
VALUES
    ("2018-10-19 10:55:23", "", "VENETO", "1", "", ""),
    ("2018-10-19 10:55:23", "", "VENETO", "2", "", ""),
    ("2018-10-19 10:55:23", "", "VENETO", "3", "", ""),
    ("2018-10-19 10:55:23", "", "LAZIO", "1", "", ""),
    
    
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
