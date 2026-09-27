-- 1. Dominios 
-- Identificador generico usado por todas las <<I>> del modelo
CREATE DOMAIN Tid AS INTEGER
    CHECK (VALUE > 0);

-- Resultado de una partida
CREATE DOMAIN Tresultado AS VARCHAR(20)
    CHECK (VALUE IN ('Victoria', 'Derrota', 'Empate'));

-- Tipo de premio que ofrece un torneo
CREATE DOMAIN Tpremio AS VARCHAR(20)
    CHECK (VALUE IN ('Dinero', 'Trofeo', 'Puntos', 'Objeto_fisico'));

-- Tipo o género del videojuego
CREATE DOMAIN Tvideojuego AS VARCHAR(20)
    CHECK (VALUE IN ('FPS', 'MOBA', 'Deportivo', 'Estrategia', 'Lucha', 'BattleRoyale'));

-- Modalidad del torneo
CREATE DOMAIN Ttorneo AS VARCHAR(20)
    CHECK (VALUE IN ('Individual', 'PorEquipos', 'Mixto'));

-- Correo del jugador
CREATE DOMAIN Tcorreo AS VARCHAR(100)
    CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Edad del jugador 
CREATE DOMAIN Tedad AS SMALLINT
    CHECK (VALUE BETWEEN 10 AND 99);
    

-- 2. Tablas y restricciones declarativas

CREATE TABLE Videojuegos (
    idVideojuego     Tid          NOT NULL,
    nombre           VARCHAR(20)  NOT NULL,
    tipoVideojuego   Tvideojuego  NOT NULL,
    CONSTRAINT pk_videojuegos PRIMARY KEY (idVideojuego)
);

CREATE TABLE Torneos (
    idTorneo         Tid       NOT NULL,
    participantes    INTEGER   NOT NULL CHECK (participantes > 0),
    fecha_inicio     DATE      NOT NULL,
    tipo_torneo      Ttorneo   NOT NULL,
    videojuego       Tid       NOT NULL,
    CONSTRAINT pk_torneos PRIMARY KEY (idTorneo),
    CONSTRAINT fk_torneos_videojuego FOREIGN KEY (videojuego)
        REFERENCES Videojuegos (idVideojuego)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Premios (
    idPremio     Tid      NOT NULL,
    tipoPremio   Tpremio  NOT NULL,
    idTorneo     Tid      NOT NULL,
    CONSTRAINT pk_premios PRIMARY KEY (idPremio),
    CONSTRAINT fk_premios_torneo FOREIGN KEY (idTorneo)
        REFERENCES Torneos (idTorneo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Partidas (
    idPartida    Tid          NOT NULL,
    resultado    Tresultado   NOT NULL,
    puntaje      INTEGER      NOT NULL CHECK (puntaje >= 0),
    fecha        DATE         NOT NULL,
    torneo       Tid          NOT NULL,
    CONSTRAINT pk_partidas PRIMARY KEY (idPartida),
    CONSTRAINT fk_partidas_torneo FOREIGN KEY (torneo)
        REFERENCES Torneos (idTorneo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Inscripciones (
    id_inscripcion   Tid    NOT NULL,
    fecha            DATE   NOT NULL,
    torneo           Tid    NOT NULL,
    CONSTRAINT pk_inscripciones PRIMARY KEY (id_inscripcion),
    CONSTRAINT fk_inscripciones_torneo FOREIGN KEY (torneo)
        REFERENCES Torneos (idTorneo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Clasificacion (
    idClasificacion   Tid   NOT NULL,
    torneo            Tid   NOT NULL,
    CONSTRAINT pk_clasificacion PRIMARY KEY (idClasificacion),
    CONSTRAINT fk_clasificacion_torneo FOREIGN KEY (torneo)
        REFERENCES Torneos (idTorneo)
        ON DELETE CASCADE ON UPDATE CASCADE
);
 
-- Inscripcion y clasificacion son UNIQUE porque cada inscripción/clasificación pertenece a un único participante.

CREATE TABLE Participantes (
    id_participante   Tid          NOT NULL,
    nombre            VARCHAR(20)  NOT NULL,
    inscripcion       Tid          NOT NULL,
    clasificacion     Tid,
    CONSTRAINT pk_participantes PRIMARY KEY (id_participante),
    CONSTRAINT uq_participantes_inscripcion UNIQUE (inscripcion),
    CONSTRAINT uq_participantes_clasificacion UNIQUE (clasificacion),
    CONSTRAINT fk_participantes_inscripcion FOREIGN KEY (inscripcion)
        REFERENCES Inscripciones (id_inscripcion)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_participantes_clasificacion FOREIGN KEY (clasificacion)
        REFERENCES Clasificacion (idClasificacion)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Equipo (
    id_participante   Tid       NOT NULL,
    no_integrantes    SMALLINT  NOT NULL CHECK (no_integrantes > 0),
    CONSTRAINT pk_equipo PRIMARY KEY (id_participante),
    CONSTRAINT fk_equipo_participante FOREIGN KEY (id_participante)
        REFERENCES Participantes (id_participante)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Un jugador puede no pertenecer a ningún equipo

CREATE TABLE Jugador (
    id_participante   Tid      NOT NULL,
    correo            Tcorreo  NOT NULL,
    edad              Tedad    NOT NULL,
    equipo            Tid,
    CONSTRAINT pk_jugador PRIMARY KEY (id_participante),
    CONSTRAINT uq_jugador_correo UNIQUE (correo),
    CONSTRAINT fk_jugador_participante FOREIGN KEY (id_participante)
        REFERENCES Participantes (id_participante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_jugador_equipo FOREIGN KEY (equipo)
        REFERENCES Equipo (id_participante)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabla de asociación Participantes y Partidas
CREATE TABLE PartidasHechas (
    participante   Tid   NOT NULL,
    partida        Tid   NOT NULL,
    CONSTRAINT pk_partidashechas PRIMARY KEY (participante, partida),
    CONSTRAINT fk_ph_participante FOREIGN KEY (participante)
        REFERENCES Participantes (id_participante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ph_partida FOREIGN KEY (partida)
        REFERENCES Partidas (idPartida)
        ON DELETE CASCADE ON UPDATE CASCADE
);
