DROP TABLE UTENTE cascade constraints;
DROP TABLE VALUTAZIONE_RISCHIO;
DROP TABLE CARTA_DI_CREDITO cascade constraints;
DROP TABLE CRYPTO cascade constraints;
DROP TABLE PIATTAFORMA_EXCHANGE cascade constraints;
DROP TABLE CONTO_VIRTUALE cascade constraints;
DROP TABLE COLLEGATO;
DROP TABLE MOVIMENTO;
DROP TABLE REWARDS;
DROP TABLE WALLET_DECENTRALIZZATO cascade constraints;
DROP TABLE BLOCKCHAIN;
DROP TABLE ASSOCIATO;
DROP TABLE EXCHANGE_DECENTRALIZZATO cascade constraints;
DROP TABLE UNITO;
DROP TABLE SCAMBIO;

CREATE TABLE UTENTE(
    CF              CHAR(16)    NOT NULL PRIMARY KEY,
    DATA_DI_NASCITA DATE        NOT NULL,
    NAZIONALITA     VARCHAR(20) NOT NULL,
    NOME            VARCHAR(20) NOT NULL,
    COGNOME         VARCHAR(20) NOT NULL
);

CREATE TABLE VALUTAZIONE_RISCHIO(
    CATEGORIA       VARCHAR(15) NOT NULL, 
    BUDGET          NUMBER(9,0) NOT NULL,
    RISCHIO         NUMBER(2,0) NOT NULL,
    CF_UTENTE       CHAR(16)    NOT NULL,
    AUMENTO_RISCHIO NUMBER(2,1) NOT NULL, -- CHECK NECESSARIO

    CONSTRAINT  PK_VALUTAZIONE_RISCHIO PRIMARY KEY(CATEGORIA,CF_UTENTE),
    CONSTRAINT  FK_UTENTE FOREIGN KEY (CF_UTENTE) REFERENCES UTENTE(CF) ON DELETE CASCADE,

    CONSTRAINT  CATEGORIE_AMMESSE CHECK ( LOWER (CATEGORIA) IN ('intraday','scalper','buy & hold') ),
    CONSTRAINT  COMP_AUMENTO_RISCHIO CHECK (AUMENTO_RISCHIO BETWEEN 0.1 AND 2.0),
    CONSTRAINT  BUDGET_POS CHECK (BUDGET > 0),
    CONSTRAINT  RISCHIO_POS CHECK (RISCHIO > 0)
);

CREATE TABLE CARTA_DI_CREDITO(
    NUMERO_CARTA        CHAR(16)    NOT NULL PRIMARY KEY,
    CVV                 CHAR(3)     NOT NULL UNIQUE,
    DATA_DI_SCADENZA    DATE        NOT NULL,
    BANCA               VARCHAR(20) NOT NULL,
    CF_UTENTE           CHAR(16)    NOT NULL,

    CONSTRAINT  FK_UTENTE2 FOREIGN KEY (CF_UTENTE) REFERENCES UTENTE(CF) ON DELETE CASCADE
);

CREATE TABLE CRYPTO(
    NOME_C          VARCHAR(20)  NOT NULL PRIMARY KEY,
    CONTRATTO_C     CHAR(42)     NOT NULL,
    BLOCKCHAIN_C    VARCHAR(20)  NOT NULL
);

CREATE TABLE PIATTAFORMA_EXCHANGE(
    NOME_PIATTAFORMA    VARCHAR(20)     NOT NULL PRIMARY KEY,
    TOKEN_RIFERIMENTO   VARCHAR(20)     NOT NULL,
    
    CONSTRAINT FK_TOKEN_RIFERIMENTO FOREIGN KEY (TOKEN_RIFERIMENTO) REFERENCES CRYPTO(NOME_C) ON DELETE CASCADE
);

CREATE TABLE CONTO_VIRTUALE(
    ID_CONTO_VIRTUALE   VARCHAR(30) NOT NULL,
    NOME_PIATTAFORMA_CV VARCHAR(20) NOT NULL,
    DATA_CREAZIONE      DATE        NOT NULL,
    VALUTA              VARCHAR(10) NOT NULL,

    CONSTRAINT PK_CONTO_VIRTUALE PRIMARY KEY (ID_CONTO_VIRTUALE,NOME_PIATTAFORMA_CV),
    CONSTRAINT FK_PIATTAFORMA FOREIGN KEY (NOME_PIATTAFORMA_CV) REFERENCES PIATTAFORMA_EXCHANGE(NOME_PIATTAFORMA) ON DELETE CASCADE,
    CONSTRAINT VALUTE_DISPONIBILI CHECK (LOWER (VALUTA) IN ('eur','usd','chf'))
);

CREATE TABLE COLLEGATO(
    ID_CONTO_VIRTUALE_C   VARCHAR(30)   NOT NULL, 
    NOME_PIATTAFORMA_C    VARCHAR(20)   NOT NULL,
    NUMERO_CARTA_C        CHAR(16)      NOT NULL, 

    CONSTRAINT  PK_COLLEGATO PRIMARY KEY (ID_CONTO_VIRTUALE_C,NUMERO_CARTA_C,NOME_PIATTAFORMA_C),
    CONSTRAINT  FK_ID FOREIGN KEY (ID_CONTO_VIRTUALE_C,NOME_PIATTAFORMA_C) REFERENCES CONTO_VIRTUALE(ID_CONTO_VIRTUALE,NOME_PIATTAFORMA_CV) ON DELETE CASCADE,
    CONSTRAINT  FK_NUMERO_CONTO FOREIGN KEY (NUMERO_CARTA_C) REFERENCES CARTA_DI_CREDITO(NUMERO_CARTA) ON DELETE CASCADE
);

CREATE TABLE MOVIMENTO(
    ID_ORDINE               CHAR(20)        NOT NULL PRIMARY KEY,
    QUANTITA_M              NUMBER(9,2)     NOT NULL,
    DATA_M                  DATE            NOT NULL, -- NON E' UNIQUE
    FEE_M                   NUMBER(4,2)     NOT NULL, -- INUTILE CHECK
    TIPO_MOVIMENTO          NUMBER(2,0)     NOT NULL,
    ID_CONTO_VIRTUALE_M     VARCHAR(30)     NOT NULL, 
    NUMERO_CARTA_M          CHAR(16)        NOT NULL, 
    NOME_PIATTAFORMA_M      VARCHAR(30)     NOT NULL,

    CONSTRAINT  FK_ID_CONTO_VIRTUALE FOREIGN KEY (ID_CONTO_VIRTUALE_M,NOME_PIATTAFORMA_M) REFERENCES CONTO_VIRTUALE(ID_CONTO_VIRTUALE,NOME_PIATTAFORMA_CV) ON DELETE CASCADE,
    CONSTRAINT  FK_CARTA_DI_CREDITO FOREIGN KEY (NUMERO_CARTA_M) REFERENCES CARTA_DI_CREDITO(NUMERO_CARTA) ON DELETE CASCADE,

    CONSTRAINT  MOVIMENTO_CONSENTITO CHECK ( QUANTITA_M > 0 ),
    CONSTRAINT  TIPO_MOVIMENTO_CONSENTITO CHECK ( (TIPO_MOVIMENTO = 1) OR (TIPO_MOVIMENTO = 2) )
);

CREATE TABLE REWARDS(
    CODICE              NUMBER          GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    QUANTITA_R          NUMBER(9,0)     NOT NULL, -- INUTILE CHECK
    DATA_RILASCIO       DATE            NOT NULL,
    NOME_R              VARCHAR(20)     NOT NULL,
    ID_CONTO_VIRTUALE_R VARCHAR(30)     NOT NULL,
    NOME_PIATTAFORMA_R  VARCHAR(20)     NOT NULL,

    CONSTRAINT  FK_NOME_R FOREIGN KEY (NOME_R) REFERENCES CRYPTO (NOME_C) ON DELETE CASCADE,
    CONSTRAINT  FK_ID_CONTO_VIRTUALE_R FOREIGN KEY (ID_CONTO_VIRTUALE_R,NOME_PIATTAFORMA_R) REFERENCES CONTO_VIRTUALE(ID_CONTO_VIRTUALE,NOME_PIATTAFORMA_CV) ON DELETE CASCADE,
    CONSTRAINT  QUANTITA_POS CHECK (QUANTITA_R > 0)
);

CREATE TABLE WALLET_DECENTRALIZZATO(
    INDIRIZZO    CHAR(42)    NOT NULL PRIMARY KEY,
    NOME_WALLET  VARCHAR(20) NOT NULL
);

CREATE TABLE BLOCKCHAIN(
    NOME        CHAR(29)    NOT NULL,
    INDIRIZZO_B CHAR(42)    NOT NULL,

    CONSTRAINT PK_BLOCKCHAIN PRIMARY KEY (NOME,INDIRIZZO_B),
    CONSTRAINT FK_BLOCKCHAIN FOREIGN KEY (INDIRIZZO_B) REFERENCES WALLET_DECENTRALIZZATO(INDIRIZZO) ON DELETE CASCADE
);

CREATE TABLE ASSOCIATO(
    ID_CONTO_VIRTUALE_A   VARCHAR(30)   NOT NULL, 
    NOME_PIATTAFORMA_A    VARCHAR(20)   NOT NULL,
    INDIRIZZO_A           CHAR(42)      NOT NULL,

    CONSTRAINT  PK_ASSOCIATO PRIMARY KEY (ID_CONTO_VIRTUALE_A,NOME_PIATTAFORMA_A,INDIRIZZO_A),
    CONSTRAINT  FK_CV FOREIGN KEY (ID_CONTO_VIRTUALE_A,NOME_PIATTAFORMA_A) REFERENCES CONTO_VIRTUALE(ID_CONTO_VIRTUALE,NOME_PIATTAFORMA_CV) ON DELETE CASCADE,
    CONSTRAINT  FK_WALLET FOREIGN KEY (INDIRIZZO_A) REFERENCES WALLET_DECENTRALIZZATO(INDIRIZZO) ON DELETE CASCADE
);

CREATE TABLE EXCHANGE_DECENTRALIZZATO(
    NOME_EXCHANGE    VARCHAR(20)    NOT NULL PRIMARY KEY,
    BLOCKCHAIN       VARCHAR(20)    NOT NULL
);

CREATE TABLE UNITO(
    INDIRIZZO_U     CHAR(42)    NOT NULL,
    NOME_EXCHANGE_U VARCHAR(20) NOT NULL,

    CONSTRAINT PK_UNITO PRIMARY KEY(INDIRIZZO_U,NOME_EXCHANGE_U),
    CONSTRAINT FK_WALLET_U FOREIGN KEY (INDIRIZZO_U) REFERENCES WALLET_DECENTRALIZZATO(INDIRIZZO) ON DELETE CASCADE,
    CONSTRAINT FK_DEX FOREIGN KEY (NOME_EXCHANGE_U) REFERENCES EXCHANGE_DECENTRALIZZATO(NOME_EXCHANGE) ON DELETE CASCADE
);

CREATE TABLE SCAMBIO(
    TX_HASH             CHAR(66)        NOT NULL PRIMARY KEY,
    QUANTITA_SCAMBIATA  NUMBER(18,4)    NOT NULL,
    FEE_S               NUMBER(4,2)     NOT NULL,
    CONTRATTO_S         CHAR(42)        NOT NULL,
    DATA_S              DATE            NOT NULL, -- NON E' UNIQUE
    QUANTITA_OTTENUTA   NUMBER(18,4)    NOT NULL,
    VALUTA_OTTENUTA     VARCHAR(20)     NOT NULL,
    VALUTA_SCAMBIATA    VARCHAR(20)     NOT NULL,
    ID_CONTO_VIRTUALE_S VARCHAR(30)     NOT NULL,
    NOME_PIATTAFORMA_S  VARCHAR(30)     NOT NULL,
    NOME_EXCHANGE_DEX   VARCHAR(20)     NOT NULL,

    CONSTRAINT FK_ID_CONTO_VIRTUALE_S FOREIGN KEY (ID_CONTO_VIRTUALE_S,NOME_PIATTAFORMA_S) REFERENCES CONTO_VIRTUALE(ID_CONTO_VIRTUALE,NOME_PIATTAFORMA_CV) ON DELETE CASCADE,
    CONSTRAINT FK_DEX_S FOREIGN KEY (NOME_EXCHANGE_DEX) REFERENCES EXCHANGE_DECENTRALIZZATO(NOME_EXCHANGE) ON DELETE CASCADE
);