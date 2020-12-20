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
    ("1", "VENETO", "Padova1", "Via Roma 23 Padova 35140", ""),					
    ("2", "VENETO", "Padova2", "Via Firenze 10 Padova 35139", ""),				
    ("1", "LAZIO" "Roma1", "Piazza S. Marco 2 Roma 00010", ""),					
    ("2", "LAZIO", "Latina1", "Via Battaglia 3 Latina 04010", ""),				
    ("1", "LOMBARDIA", "Bergamo1", "Via Rosa 52 Bergamo 24099", ""),				
    ("1", "TOSCANA", "Firenze1", "Via Leopardi 3 Firenze 50012", ""),			
    ("2", "TOSCANA", "Firenze2", "Via Roma 40 Firenze 50012", ""),				
    ("2", "LOMBARDIA", "Milano1", "Via Dante 22 Milano 20010", ""),				
    ("3", "LAZIO", "Roma2", "Via Venezia 9 Roma 00016", ""),						
    ("1", "CAMPANIA", "Salerno1", "Via Petrarca 6 Salerno 84070", ""),			
    ("1", "BASILICATA" "Matera1", "Via Dante 11 Matera 75062", ""),				
    
    /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
    /*Riduciamo i distretti a 5/6 così possiamo fare più riunioni senza un listone infinito. Vanno sistemati i membri che avevo messo ufff*/
    
    -- Popolazione Socio
INSERT INTO
    Socio(CF, nome, cognome, telefono, email, data_nascita, indirizzo, n_distretto, regione)
VALUES
    ("RSSMRA70S02G224K", "Mario", "Rossi", "1234567890", "mariorossi@mail.com", "1990-11-02", "via Roma 1, Padova", "1", "VENETO"),
    ("FJLTDP54A19C700X", "Fabio", "Del Santo", "1234567891", "fabiosanto@mail.com", "1974-04-22", "via Borghese 12, Roma", "1", "LAZIO"),
    ("MIRTRO11A50E142B", "Mirella", "La Torre", "1234567892", "mire.lato@gmail.com", "1982-10-30", "via Ferro 8, Roma", "1", "LAZIO"),
    ("PALZBE82E10V790H", "Paolo", "Zabarella", "1234567893", "paolo.zabarella@mail.com", "1982-02-02", "via Borghese 36, Roma", "1", "LAZIO"),
    ("MRODFA76U61V815A", "Marco", "Di Falco", "1234567894", "marco.difalco@mail.com", "1976-08-02", "via Brigante 42, Latina", "2", "LAZIO"),
    ("LGUBGO79S39G398K", "Luigi", "Brigo", "1234567895", "luigi.brigo@mail.com", "1979-04-02", "via Sassari 22, Latina", "2", "LAZIO"),
    ("FJLTDP54A19C700X", "Maria", "Assunta", "3335578910", "mariaass@mail.com", "1990-10-22", "via Bolla 3, Bergamo", "1", "LOMBARDIA"),
	("FFCFTE00V13V734O", "Franca", "Forte", "3334921079", "francyyy@mail.com", "2000-10-09", "via Ghiberti 42 ,Begamo", "1", "LOMBARDIA"),
	("CHRSTA00P02A224K", "Chiara", "Stella", "123567896", "chiarastar@mail.com", "1990-01-01", "via Dei Papaveri, 51, Padova", "2", "VENETO"),
    ("LUASAT88B02H094F", "Lucia", "Santarelli", "1234567897", "santalucia@mail.com", "1988-05-28", "via Roma 11, Milano", "2", "LOMBARDIA"),
    ("SFNBNH91Q80E142P", "Stefano", "Bianchi", "1234567898", "biastef@gmail.com", "1991-02-20", "via Calabresi 11, Roma", "3", "LAZIO"),
    ("MRKSTP98M16O730F", "Mirko", "Stapella", "0002573940", "mirkstap@mail.com", "1998-12-25", "via Plinio 04, Firenze", "1", "TOSCANA"),
    ("ANDTRO69B42E700J", "Andrea", "Del Toro", "9762385079", "andretorodel@mail.com", "1969-11-12", "via Barcaioli 89, Firenze", "1", "TOSCANA"),
    ("ALSZNN01W14Z292A", "Alessia", "Zanon", "3340129976", "alezanna@mail.com", "2001-01-30", "via Dei Santi 11, Firenze", "1", "TOSCANA"),
    ("ALCSNN54A19M784W", "Alice", "Sanno", "3792224668", "alicesanno@mail.com", "1984-07-06", "via Settembre 09, Firenze", "1", "TOSCANA"),
    ("GLOCDI94V12E294X", "Giulio", "Casadei", "3894672046", "giuliocasad@mail.com", "1994-03-10", "Piazza Delle Erbe 02, Firenze", "1", "TOSCANA"),
    ("ALRLPO59D95N520B", "Alberto", "Lupo", "3846750199", "lupoalberto@mail.com", "1959-02-02", "via Gerusalemme 19, Firenze", "1", "TOSCANA"),
    ("DVDGLL99P88C724T", "Davide", "Gallo", "3987200001", "gallodave@mail.com", "1999-04-17", "via Genova 22, Padova", "2", "VENETO"),
    ("JNNSTH82B29C982T", "Jennifer", "Smith", "3956444823", "jennysmt@mail.com", "1982-03-11", "via America 12, Padova", "2", "VENETO"),
    ("LFACNA59U13P130U", "Alfredo", "Conaro", "3268132022", "alfecon@mail.com", "1959-12-17", "via Peonia 03, Padova", "2", "VENETO"),
    ("LCUSRE00F19Q700U", "Luca", "Servile", "3333383340", "luservile@mail.com", "2000-06-18", "via Danubio 01, Padova", "2", "VENETO"),
    ("SMASSA69D92I933A", "Samuele", "Sasso", "3996558996", "samusasso@mail.com", "1969-12-25", "via Padova 30, Padova", "2", "VENETO"),
    ("GNEGNI85M19E702E", "Gennaro", "Giunta", "3987208901", "gennagiunta@mail.com", "1985-04-02", "via Distina 02, Padova", "2", "VENETO"),
    ("NDAGNE78A24E721X", "Nadia", "Gentile", "3556552355", "nadiagentile@mail.com", "1978-03-03", "Piazza Duomo 14, Matera", "1", "BASILICATA"),
	("NDAGNE78A24E721X", "Chiara", "Ferragno", "3596211118", "chiaraferragno@mail.com", "1991-05-09", "Via Dei Ruscelli 10, Matera", "1", "BASILICATA"),
	("FBAFSU84E24W202R", "Fabio", "Fusto", "3123699985", "fustofabio@mail.com", "1984-10-23", "Piazza Dei Vinti 06, Matera", "1", "BASILICATA"),
	("MRACLA95F41R041T", "Martina", "Calle", "3798874650", "martycall@mail.com", "1995-03-16", "Via Divina 18, Matera", "1", "BASILICATA"),
	("LCUMBO67U35I721I", "Luce", "Ombrin", "3222215669", "luceombrin@mail.com", "1967-11-09", "Via Rudale 07, Matera", "1", "BASILICATA"),
	("LSETIL83E21E591V", "Elisabetta", "Italiano", "3299855462", "eliita@mail.com", "1983-01-20", "Via Notte 23, Salerno", "1", "CAMPANIA"),
	("ZXOPSI77H35V509X", "Ezio", "Pisani", "3666995230", "eziopisani@mail.com", "1977-10-28", "Via Politica 11, Salerno", "1", "CAMPANIA"),
	("SLIPRO68D41H141R", "Silvia", "Opera", "3009008007", "silvope@mail.com", "1968-08-01", "Via Degli Alberi 17, Salerno", "1", "CAMPANIA"),
	("KRASMI90E71V291P", "Karen", "Smith", "3687555544", "karensmith@mail.com", "1990-10-31", "Via Senna 07, Salerno", "1", "CAMPANIA"),
	("ALSMGA90E21N291I", "Alfredo", "Bianchi", "3975449688", "alfebianchi@mail.com", "1977-04-01", "Via Sipario 22, Salerno", "1", "CAMPANIA"),
	("LGUBTE82E50H905W", "Luigi", "Bettin", "3658765109", "luigibetty@mail.com", "1982-06-11", "Via Ghianda 07, Salerno", "1", "CAMPANIA"),
	("FJLTDP54A19C700X", "Osvaldo", "Forte", "33349210999", "osvaldoforte@mail.com", "1966-04-19", "via Dei Canti 18, Begamo", "5", "LOMBARDIA"),
    ("SREFNO59D95N520B", "Sergio", "Fontana", "3846750199", "sergiofonta@mail.com", "1959-02-02", "via Gerusalemme 11, Firenze", "1", "TOSCANA"),
    ("NCIFRE88E08W345R", "Nicola", "Fredino", "3299856000", "nicolafredi@mail.com", "1988-05-16", "via Pisani 04, Firenze", "1", "TOSCANA"),
    ("ALRLPO59D95N520B", "Alessandra", "Greco", "3985216223", "alessandragre@mail.com", "1989-04-18", "via Narina 31, Firenze", "2", "TOSCANA"),
    ("GRELVA84E43E042X", "Greta", "Lavigna", "3232323232", "gretalvign@mail.com", "1984-11-19", "via Vino 07, Firenze", "2", "TOSCANA"),
    ("JSADNI78W30V420E", "Jasmine", "Dinzeo", "3696969804", "jasmdinz@mail.com", "1978-04-16", "via Romolo 31, Firenze", "2", "TOSCANA"),
    ("SBIRSU59D20V501B", "Isabella", "Russo", "3787596400", "isarusso@mail.com", "1959-12-14", "via Canali 03, Firenze", "2", "TOSCANA"),
	("VLALFE66E44E993V", "Valentino", "Elfino", "3641402872", "valeelf@mail.com", "1966-06-06", "via Peonia 10, Firenze", "2", "TOSCANA"),
	("SBIRSU59D20V501B", "Valentino", "Denni", "3898989574", "valdenni@mail.com", "1985-06-18", "via Padova 03, Firenze", "2", "TOSCANA"),


    
 -- Popolazione Presidente
INSERT INTO
    Presidente(CF, voto, lode) 
VALUES
    ("FJLTDP54A19C700X", "108", "0"), -- Lazio1
    ("RSSMRA70S02G224K", "99", "0"), -- Veneto1
    ("ALRLPO59D95N520B", "110", "1"), -- Toscana1
    ("MRODFA76U61V815A", "110", "1"), -- Lazio2
    ("FJLTDP54A19C700X", "104", "0"), -- Lombardia1
    ("CHRSTA00P02A224K", "108", "0"), -- Veneto2
    ("SFNBNH91Q80E142P", "110", "0"), -- Lazio3
    ("NDAGNE78A24E721X", "106", "0"), -- Basilicata1
    ("LSETIL83E21E591V", "110", "1"), -- Campania1
    ("LUASAT88B02H094F", "108", "0"), -- Lombardia2
    ("ALRLPO59D95N520B", "109", "0"), -- Toscana2

    

    
    
    -- Popolazione Riunione
INSERT INTO
    Riunione(regione, numero, data)
VALUES
    ("VENETO", "1", "2020-01-01"),
    ("VENETO", "2", "2020-01-01"),
    ("LAZIO", "1", "2020-01-01"),
    ("TOSCANA", "1", "2020-01-01"),
    ("LAZIO", "2", "2020-01-01"),
    ("CAMPANIA", "1", "2020-01-01"),
    ("LAZIO", "3", "2020-01-01"),
    ("LOMBARDIA", "1", "2020-01-01"),
    ("LOMBARDIA", "2", "2020-01-01"),
    ("BASILICATA", "1", "2020-01-01"),
    ("TOSCANA", "2", "2020-01-01"),
    
    ("VENETO", "1", "2020-01-15"),
    ("VENETO", "2", "2020-01-15"),
    ("LAZIO", "2", "2020-01-15"),
    ("TOSCANA", "2", "2020-01-15"),
    ("LAZIO", "1", "2020-01-15"),
    ("CAMPANIA", "1", "2020-01-15"),
    ("LAZIO", "3", "2020-01-15"),
    ("LOMBARDIA", "2", "2020-01-15"),
    ("LOMBARDIA", "1", "2020-01-15"),
    ("BASILICATA", "1", "2020-01-15"),
    ("TOSCANA", "1", "2020-01-15"),
    
    
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
    ("mascherina", "ffp2", ""),
    ("mascherina", "ffp3", ""),
    ("letto", "", "piegevole, con barre laterali, asta sollevammalati e ruote piroettanti con freno."),
    ("materasso", "memory", ""),
    ("materasso", "antidecubito", ""),
    ("mascherina", "ffp2", ""),
    ("mascherina", "ffp2", ""),
    ("mascherina", "ffp2", ""),
    
    
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
