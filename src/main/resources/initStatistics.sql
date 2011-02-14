--Erstellen der Tabelle 'statistics_dimensions'
DROP TABLE IF EXISTS statistics_dimensions;
DROP SEQUENCE statistics_dimensions_seq;

CREATE SEQUENCE statistics_dimensions_seq
INCREMENT 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

CREATE TABLE statistics_dimensions (
    id                                  integer NOT NULL DEFAULT nextval('statistics_dimensions_seq'::regclass),
    gewaesserkategorie                  varchar(128),
    stalu                               varchar(128),
    fge                                 varchar(128),
    bg                                  varchar(128),
    tg                                  varchar(128),
    wk_k                                text,
    CONSTRAINT statistics_dimensions_pkey PRIMARY KEY (id)
);
CREATE INDEX statistics_dimensions_gewaesserkategorie ON statistics_dimensions (gewaesserkategorie);
CREATE INDEX statistics_dimensions_stalu ON statistics_dimensions (stalu);
CREATE INDEX statistics_dimensions_fge ON statistics_dimensions (fge);
CREATE INDEX statistics_dimensions_bg ON statistics_dimensions (bg);
CREATE INDEX statistics_dimensions_tg ON statistics_dimensions (tg);
CREATE INDEX statistics_dimensions_wk_k ON statistics_dimensions (wk_k);

--Erstellen der Tabelle 'statistics_measures'
DROP TABLE IF EXISTS statistics_measures;
DROP SEQUENCE statistics_measures_seq;

CREATE SEQUENCE statistics_measures_seq
INCREMENT 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

CREATE TABLE statistics_measures (
    id                                  integer NOT NULL DEFAULT nextval('statistics_measures_seq'::regclass),
    wk_k                                text,
    flaeche                             float,
    einfluss                            varchar(128),       -- (1=natürlich, 2=verändert, 3=künstlich)
    zustand_oeko                        integer,            -- (1=gut, 2=schlechter als gut, 3=unbekannt)
    zustand_chem                        integer,            -- (1=gut, 2=schlechter als gut, 3=unbekannt)
    zustand_menge                       integer,            -- (1=gut, 2=schlechter als gut, 3=unbekannt)
    klasse_oeko                         integer,            -- (1=gut und besser, 2=mäßig, 3=unbefriedigend und schlecht, 4=unbekannt)
    klasse_chem                         integer,            -- (1=gut und besser, 2=mäßig, 3=unbefriedigend und schlecht, 4=unbekannt)
    klasse_strukturguete                integer,               -- (1=gut und besser, 2=mäßig, 3=unbefriedigend und schlecht, 4=unbekannt)
    zustand_gen_cond                    integer,            -- (1=1, 2=2, 3=3, 4=4, 5=5, 6=U) (Physikalisch-chemischer Zustand)
    zustand_phyto                       integer,            -- (1=1, 2=2, 3=3, 4=4, 5=5, 6=U) (Biologischer Zustand, Phytoplankton)
    zustand_ben_inv                     integer,            -- (1=1, 2=2, 3=3, 4=4, 5=5, 6=U) (Biologischer Zustand, Makrozoobenthos)
    zustand_hydromorph                  integer,            -- (1=1, 2=2, 3=3, 4=4, 5=5, 6=U) (Hydromorphologischer Zustand)
    zustand_mac_algae                   integer,            -- (1=1, 2=2, 3=3, 4=4, 5=5, 6=U) (Biologischer Zustand, Makroalgen)
--    zustand_bewirtschaftung             integer,            -- (1=guter zustand, 2=mäßiger zustand, 3=usw.)
--    fristverlaengerung                  varchar(128),
    schneidet_landesgrenze              boolean,
    typ_lawa                            varchar(256),
    typ_see                             text,
    typ_grundwasser_leiter              text,
    typ_kuestengewaesserwasserkoerper   text,
    anzahl_messstellen                  integer,
    anzahl_messstellen_bio              integer,
    anzahl_messstellen_chem             integer,
--    anzahl_messstellen_wrrl_chem_phys   integer,
--    anzahl_messstellen_wrrl_chem_stoffe integer,
--    anzahl_messstellen_wrrl_chem_bio    integer,
--    anzahl_messstellen_wrrl_chem_menge  integer,
    querbau_stau                        integer,
    querbau_durchlass                   integer,
    querbau_sohlgleite                  integer,
    querbau_schleuse                    integer,
    querbau_talsperre                   integer,
    querbau_wasserkraft                 integer,
    querbau_schoepfwerk                 integer,
    querbau_andere                      integer,
    querbau_fischaufstieg               integer,
    rohrleitung_anzahl                  integer,
    rohrleitung_laenge                  float,
    --(rohrleitung_anteil_gewaesserlaenge,)
    --anzahl_wasserkraftwerke             integer,
    --einleitung_weniger_als_2000ew       integer,
    --einleitung_2000ew_und_mehr          integer,
    --anzahl_wasserwerke                  integer,
    --massnahmen_flaeche                  float,
    --massnahmen_anzahl                   integer,
    --massnahmen_anzahl_1_bis_99          integer,
    --massnahmen_anzahl_501_bis_508       integer,
    --massnahmen_wk                       boolean,            -- (0=keine massnahme, 1=massnahme)
    --massnahmen_wk_ohne_massnahme, (1=keine massnahme, 0=massnahme))
    massnahmen_geplant                  integer,
    massnahmen_umgesetzt                integer,
    CONSTRAINT statistics_measures_pkey PRIMARY KEY (id)
);
CREATE INDEX statistics_measures_wk_k ON statistics_measures (wk_k);

--Füllen der Tabelle 'statistics_dimensions'
INSERT INTO statistics_dimensions (gewaesserkategorie, wk_k, stalu, fge, bg, tg)
SELECT 'Fliessgewässer', max(wk_fg.wk_k), max(ogc.stalu_10_baum.id)::varchar(128), max(ogc.teilgebiete.fge_nr), max(ogc.teilgebiete.bg_k), max(ogc.teilgebiete.tg_k)
FROM
    wk_fg,
    wk_fg_teile,
    wk_teil,
    station,
    geom,
    ogc.teilgebiete,
    ogc.stalu_teilgebiete,
    ogc.stalu_10_baum
WHERE
    wk_fg.id = wk_fg_reference
    AND wk_teil.id = teil
    AND (station.id = von OR station.id = bis)
    AND station.real_point=geom.id
    AND ogc.teilgebiete.gid = ogc.stalu_teilgebiete.tg_id
    AND ogc.stalu_teilgebiete.st_id = ogc.stalu_10_baum.id
    AND geom.id IN (
        SELECT geom.id
        FROM
            wk_fg,
            wk_fg_teile,
            wk_teil,
            station,
            geom,
            ogc.teilgebiete,
            ogc.stalu_teilgebiete,
            ogc.stalu_10_baum
        WHERE
            wk_fg.id = wk_fg_reference
            AND wk_teil.id = teil
            AND (station.id = von OR station.id = bis)
            AND station.real_point=geom.id
            AND ogc.teilgebiete.gid = ogc.stalu_teilgebiete.tg_id
            AND ogc.stalu_teilgebiete.st_id = ogc.stalu_10_baum.id
            AND geo_field && (ogc.teilgebiete.the_geom)
    )
    AND distance(geo_field, ogc.teilgebiete.the_geom) = 0
GROUP BY wk_teil.id
LIMIT 100;

INSERT INTO statistics_dimensions (gewaesserkategorie, wk_k, stalu, fge, bg, tg)
SELECT 'Standgewässer', wk_sg.wk_k, ogc.stalu_10_baum.id::varchar(128), ogc.teilgebiete.fge_nr, ogc.teilgebiete.bg_k, ogc.teilgebiete.tg_k
FROM wk_sg, geom, ogc.teilgebiete, ogc.stalu_teilgebiete, ogc.stalu_10_baum
WHERE
    wk_sg.geom = geom.id
    AND ogc.teilgebiete.gid = ogc.stalu_teilgebiete.tg_id
    AND ogc.stalu_teilgebiete.st_id = ogc.stalu_10_baum.id
    AND geom.geo_field && envelope(ogc.teilgebiete.the_geom)
    AND intersects(geom.geo_field, ogc.teilgebiete.the_geom)
LIMIT 100;

INSERT INTO statistics_dimensions (gewaesserkategorie, wk_k, stalu)
SELECT 'Küstengewässer', wk_kg.eu_cd_cw, ogc.stalu_10_baum.id::varchar(128)
FROM wk_kg, geom, ogc.stalu_10_baum
WHERE
    wk_kg.the_geom = geom.id
    AND fast_intersects(geom.geo_field, envelope(ogc.stalu_10_baum.the_geom), ogc.stalu_10_baum.the_geom)
LIMIT 100;

INSERT INTO statistics_dimensions (gewaesserkategorie, wk_k, stalu)
SELECT 'Grundwasser', wk_gw.eu_cd_gb, ogc.stalu_10_baum.id
FROM wk_gw, geom, ogc.stalu_10_baum
WHERE
    wk_gw.the_geom = geom.id
    AND fast_intersects(geom.geo_field, envelope(ogc.stalu_10_baum.the_geom), ogc.stalu_10_baum.the_geom)
LIMIT 100;

--Einfügen der Längen/Flächen
INSERT INTO statistics_measures (wk_k, flaeche)
SELECT
    wk_fg.wk_k,
    sum(length(geom.geo_field))
FROM
    statistics_dimensions,
    wk_fg,
    wk_fg_teile,
    wk_teil,
    geom
WHERE
    statistics_dimensions.wk_k = wk_fg.wk_k
    AND wk_fg_teile.wk_fg_reference = wk_fg.teile
    AND wk_fg_teile.teil = wk_teil.id
    AND wk_teil.real_geom = geom.id
GROUP BY wk_fg.wk_k;

INSERT INTO statistics_measures (wk_k, flaeche)
SELECT
    distinct statistics_dimensions.wk_k,
    area(geom.geo_field)
FROM
    statistics_dimensions,
    wk_sg,
    geom
WHERE
    statistics_dimensions.wk_k = wk_sg.wk_k
    AND wk_sg.geom = geom.id;

INSERT INTO statistics_measures (wk_k, flaeche)
SELECT
    distinct statistics_dimensions.wk_k,
    area(geom.geo_field)
FROM
    statistics_dimensions,
    wk_kg,
    geom
WHERE
    statistics_dimensions.wk_k = wk_kg.eu_cd_cw
    AND wk_kg.the_geom = geom.id;

INSERT INTO statistics_measures (wk_k, flaeche)
SELECT
    distinct statistics_dimensions.wk_k,
    area(geom.geo_field)
FROM
    statistics_dimensions,
    wk_gw,
    geom
WHERE
    statistics_dimensions.wk_k = wk_gw.eu_cd_gb
    AND wk_gw.the_geom = geom.id;

--Einfügen der Spalte 'einfluss'
UPDATE statistics_measures
SET einfluss = (
    SELECT CASE
        WHEN wfd.yn_code.value = 'Y' THEN 2
        ELSE 1
        END
    FROM
        wk_fg,
        wfd.yn_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.yn_code.id = wk_fg.evk
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET einfluss = (
    SELECT CASE
        WHEN modified.value = 'Y' THEN 2
        WHEN artificial.value = 'Y' THEN 3
        ELSE 1
        END
    FROM
        wk_sg,
        wfd.yn_code modified,
        wfd.yn_code artificial
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND modified.id = wk_sg.modified
        AND artificial.id = wk_sg.artificial
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET einfluss = (
    SELECT CASE
        WHEN modified.value = 'Y' THEN 2
        WHEN artificial.value = 'Y' THEN 3
        ELSE 1
        END
    FROM
        wk_kg,
        wfd.yn_code modified,
        wfd.yn_code artificial
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND modified.id = wk_kg.modified
        AND artificial.id = wk_kg.artificial
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET einfluss = 1
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Bewertung des ökologischen, chemischen und mengenmäßigen Zustands
UPDATE statistics_measures
SET zustand_oeko = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.eco_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET zustand_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET zustand_oeko = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.eco_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET zustand_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET zustand_oeko = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.eco_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET zustand_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET zustand_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_gw,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND wfd.quality_status_code.id = wk_gw.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

UPDATE statistics_measures
SET zustand_menge = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" IN ('3', '4', '5') THEN 2
        ELSE 3
        END
    FROM
        wk_gw,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND wfd.quality_status_code.id = wk_gw.quant_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Einordnung des ökologischen und chemischen Zustands in Klassen
UPDATE statistics_measures
SET klasse_oeko = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.eco_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET klasse_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET klasse_strukturguete = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.morph_cond
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET klasse_oeko = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.eco_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET klasse_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET klasse_strukturguete = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.morph_cond
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET klasse_oeko = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.eco_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET klasse_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET klasse_strukturguete = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.morph_cond
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET klasse_chem = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_gw,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND wfd.quality_status_code.id = wk_gw.chem_stat
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Physikalisch-Chemische QK,
UPDATE statistics_measures
SET zustand_gen_cond = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.gen_cond
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET zustand_gen_cond = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.gen_cond
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET zustand_gen_cond = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.gen_cond
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

--Biologische QK (Phytoplankton, Makrozoobenthos, Makroalgen (KG))
UPDATE statistics_measures
SET zustand_phyto = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.phyto
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET zustand_phyto = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.phyto
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET zustand_phyto = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.phyto
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET zustand_ben_inv = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.ben_inv
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET zustand_ben_inv = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.ben_inv
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET zustand_ben_inv = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.ben_inv
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET zustand_mac_algae = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.mac_algae
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

--Hydromorpholigische QK (Hydromorphologie)
UPDATE statistics_measures
SET zustand_hydromorph = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_fg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wfd.quality_status_code.id = wk_fg.hydromorph
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET zustand_hydromorph = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_sg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.quality_status_code.id = wk_sg.hydromorph
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET zustand_hydromorph = (
    SELECT CASE
        WHEN wfd.quality_status_code."value" IN ('1', '2') THEN 1
        WHEN wfd.quality_status_code."value" = '3' THEN 2
        WHEN wfd.quality_status_code."value" IN ('4', '5') THEN 3
        ELSE 4
        END
    FROM
        wk_kg,
        wfd.quality_status_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.quality_status_code.id = wk_kg.hydromorph
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

--Geht über Landesgrenze hinaus?
UPDATE statistics_measures
SET schneidet_landesgrenze = (
    SELECT max(CASE WHEN isEmpty(difference(geom.geo_field, ogc.mv.the_geom)) THEN 0 ELSE 1 END)::boolean
    FROM
        wk_fg,
        wk_fg_teile,
        wk_teil,
        geom,
        ogc.mv
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND wk_fg_teile.wk_fg_reference = wk_fg.id
        AND wk_teil.id = wk_fg_teile.teil
        AND geom.id = wk_teil.real_geom
    GROUP BY
        wk_fg.wk_k
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET schneidet_landesgrenze = (
    SELECT NOT isEmpty(difference(geom.geo_field, ogc.mv.the_geom))
    FROM
        wk_sg,
        geom,
        ogc.mv
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND geom.id = wk_sg.geom
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET schneidet_landesgrenze = (
    SELECT NOT isEmpty(difference(geom.geo_field, ogc.mv.the_geom))
    FROM
        wk_kg,
        geom,
        ogc.mv
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wk_kg.the_geom = geom.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET schneidet_landesgrenze = (
    SELECT NOT isEmpty(difference(geom.geo_field, ogc.mv.the_geom))
    FROM
        wk_gw,
        geom,
        ogc.mv
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND wk_gw.the_geom = geom.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--LAWA-Typ -> Im Report zu ermitteln, da FG aus mehreren Abschnitten unterschiedlicher LAWA-Typen besteht
/*UPDATE statistics_measures
SET typ_lawa = (
    SELECT la_lawa_nr.description
    FROM
        lawa,
        la_lawa_nr
    WHERE
        statistics_measures.wk_k = lawa.wk_k
        AND la_lawa_nr.id = lawa.lawa_nr
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );*/

--See-Typ
UPDATE statistics_measures
SET typ_see = (
    SELECT wfd.lake_water_body_type_code."name"
    FROM
        wk_sg,
        wfd.lake_water_body_type_code
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND wfd.lake_water_body_type_code.id = wk_sg.ty_cd_lw
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

--Küstengewässertyp
UPDATE statistics_measures
SET typ_kuestengewaesserwasserkoerper = (
    SELECT wfd.de_coastal_water_type_code."name"
    FROM
        wk_kg,
        wfd.de_coastal_water_type_code
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND wfd.de_coastal_water_type_code.id = wk_kg.ty_cd_cw
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

--Grundwasserleitertyp
UPDATE statistics_measures
SET typ_grundwasser_leiter = (
    SELECT wfd.aquifer_type_code."name"
    FROM
        wk_gw,
        wfd.aquifer_type_code
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND wfd.aquifer_type_code.id = wk_gw.aqui_type
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Messtellen
UPDATE statistics_measures
SET anzahl_messstellen = (
    SELECT count(distinct swstn.id)
    FROM
        swstn
    WHERE
        swstn.ms_cd_wb = 'DEMV_'||statistics_measures.wk_k
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen = (
    SELECT count(distinct swstn.id)
    FROM
        wk_sg,
        swstn
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND swstn.ms_cd_wb = wk_sg.cd_ls
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen = (
    SELECT count(distinct swstn.id)
    FROM
        swstn
    WHERE
        statistics_measures.wk_k = swstn.ms_cd_wb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen = (
    SELECT count(distinct swstn.id)
    FROM
        swstn
    WHERE
        statistics_measures.wk_k = swstn.ms_cd_wb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Messstellen für bio. QK
UPDATE statistics_measures
SET anzahl_messstellen_bio = (
    SELECT count(distinct swstn.id)
    FROM
        swstn,
        swstn_qe_types
    WHERE
        swstn.ms_cd_wb = 'DEMV_'||statistics_measures.wk_k
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen_bio = (
    SELECT count(distinct swstn.id)
    FROM
        wk_sg,
        swstn,
        swstn_qe_types
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND swstn.ms_cd_wb = wk_sg.cd_ls
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen_bio = (
    SELECT count(distinct swstn.id)
    FROM
        swstn,
        swstn_qe_types
    WHERE
        swstn.ms_cd_wb = statistics_measures.wk_k
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen_bio = (
    SELECT count(distinct swstn.id)
    FROM
        swstn,
        swstn_qe_types
    WHERE
        swstn.ms_cd_wb = statistics_measures.wk_k
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Messstellen für chem. QK
UPDATE statistics_measures
SET anzahl_messstellen_chem = (
    SELECT count(distinct swstn.id)
    FROM
        swstn,
        swstn_qe_types
    WHERE
        swstn.ms_cd_wb = 'DEMV_'||statistics_measures.wk_k
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality NOT IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen_chem = (
    SELECT count(distinct swstn.id)
    FROM
        wk_sg,
        swstn,
        swstn_qe_types
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND swstn.ms_cd_wb = wk_sg.cd_ls
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality NOT IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen_chem = (
    SELECT count(distinct swstn.id)
    FROM
        swstn,
        swstn_qe_types
    WHERE
        swstn.ms_cd_wb = statistics_measures.wk_k
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality NOT IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET anzahl_messstellen_chem = (
    SELECT count(distinct swstn.id)
    FROM
        swstn,
        swstn_qe_types
    WHERE
        swstn.ms_cd_wb = statistics_measures.wk_k
        AND swstn_qe_types.swstn_reference = swstn.id
        AND swstn_qe_types.quality NOT IN (5, 6, 12)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Querbauwerke
UPDATE statistics_measures
SET querbau_stau = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '1'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_durchlass = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '2'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_sohlgleite = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '3'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_schleuse = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '4'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_talsperre = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '5'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_wasserkraft = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '6'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_schoepfwerk = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '7'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_andere = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '8'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_fischaufstieg = (
    SELECT
        COUNT(DISTINCT qb.id)
    FROM (
        SELECT
            *
        FROM (
            SELECT
                route.gwk AS gwk,
                querbauwerke.id AS id,
                stat09 AS station,
                station.route AS route_id
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station,
                route
            WHERE
                route.id = station.route
                AND station.id = querbauwerke.stat09
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '9'
        ) AS qb, (
            SELECT
                von.route AS route_id,
                von.wert AS von,
                bis.wert AS bis
            FROM
                wk_fg,
                wk_fg_teile,
                wk_teil,
                station AS von,
                station AS bis
            WHERE
                wk_fg.wk_k = statistics_measures.wk_k
                AND wk_fg.id = wk_fg_teile.wk_fg_reference
                AND wk_teil.id = wk_fg_teile.teil
                AND von.id = wk_teil.von
                AND bis.id = wk_teil.bis
        ) AS wk
        WHERE
            qb.route_id = wk.route_id
            AND (
                (qb.station >= wk.von AND qb.station <= wk.bis)
                OR (qb.station >= wk.bis AND qb.station <= wk.von)
            )
    ) AS qb
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET querbau_stau = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '1'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '1'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_durchlass = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '2'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '2'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_sohlgleite = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '3'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '3'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_schleuse = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '4'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '4'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_talsperre = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '5'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '5'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_wasserkraft = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '6'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '6'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_schoepfwerk = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '7'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '7'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_andere = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '8'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '8'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET querbau_fischaufstieg = (
    SELECT
        COUNT(DISTINCT line.id)
    FROM
        wk_sg,
        geom AS geom_sg,
        (
            SELECT
                querbauwerke.id AS id,
                station_von.wert AS wert,
                route.gwk AS gwk,
                ST_Line_Substring(
                    geom_route.geo_field,
                    (case when station_von.wert < station_bis.wert then station_von.wert else station_bis.wert end ) / length2d(geom_route.geo_field),
                    (case when station_von.wert < station_bis.wert then station_bis.wert else station_von.wert end ) / length2d(geom_route.geo_field)
                ) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                station AS station_bis,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND querbauwerke.stat09_bis = station_bis.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '9'
        ) AS line,
        (
            SELECT
                querbauwerke.id,
                ST_Extent(geom_route.geo_field) AS realgeom
            FROM
                querbauwerke,
                querbauwerke_type_code,
                station AS station_von,
                route,
                geom AS geom_route
            WHERE
                querbauwerke.stat09 = station_von.id
                AND station_von.route = route.id
                AND route.geom = geom_route.id
                AND querbauwerke.bauwerk = querbauwerke_type_code.id
                AND querbauwerke_type_code.value LIKE '9'
            GROUP BY
                querbauwerke.id
        ) AS ext
    WHERE
        wk_sg.wk_k = statistics_measures.wk_k
        AND wk_sg.geom = geom_sg.id
        AND line.id = ext.id
        AND geom_sg.geo_field && ext.realgeom
        AND ST_Intersects(
            geom_sg.geo_field,
            line.realgeom)
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

--Rohrleitungen
UPDATE statistics_measures
SET rohrleitung_anzahl = (
    SELECT
        COUNT(DISTINCT rl.id)
    FROM
        (
            SELECT
                *
            FROM
                (
                    SELECT
                        max(wert) AS rl_maximum,
                        min(wert) AS rl_minimum,
                        s.route AS rl_rid,
                        r.id,
                        min(x.gwk) AS route
                    FROM
                        rohrleitung r,
                        station s,
                        route x
                    WHERE
                        x.id = s.route
                        AND (
                            s.id = r.station_von
                            OR s.id = r.station_bis)
                    GROUP BY
                        s.route,
                        r.id
                ) AS rl,
                (
                    SELECT
                        max(wert) AS wk_maximum,
                        min(wert) AS wk_minimum,
                        route.id AS wk_rid
                    FROM
                        wk_fg,
                        wk_fg_teile,
                        wk_teil,
                        station,
                        route
                    WHERE
                        wk_fg.wk_k = statistics_measures.wk_k
                        AND wk_fg.id = wk_fg_reference
                        AND wk_teil.id = teil
                        AND route.id = route
                        AND (
                            station.id = von
                            OR station.id = bis)
                    GROUP BY
                        wk_rid
                ) AS wk
            WHERE
                rl_rid = wk_rid
                AND (rl_minimum >= wk_minimum
                    AND rl_maximum <= wk_maximum)
        ) AS rl
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET rohrleitung_laenge = (
    SELECT
        SUM(rl.laenge_m)
    FROM
        (
            SELECT
                *
            FROM
                (
                    SELECT
                        max(wert) AS rl_maximum,
                        min(wert) AS rl_minimum,
                        s.route AS rl_rid,
                        r.id,
                        min(x.gwk) AS route,
                        sum(r.laenge_m) as laenge_m
                    FROM
                        rohrleitung r,
                        station s,
                        route x
                    WHERE
                        x.id = s.route
                        AND (
                            s.id = r.station_von
                            OR s.id = r.station_bis)
                    GROUP BY
                        s.route,
                        r.id
                ) AS rl,
                (
                    SELECT
                        max(wert) AS wk_maximum,
                        min(wert) AS wk_minimum,
                        route.id AS wk_rid
                    FROM
                        wk_fg,
                        wk_fg_teile,
                        wk_teil,
                        station,
                        route
                    WHERE
                        wk_fg.wk_k = statistics_measures.wk_k
                        AND wk_fg.id = wk_fg_reference
                        AND wk_teil.id = teil
                        AND route.id = route
                        AND (
                            station.id = von
                            OR station.id = bis)
                    GROUP BY
                        wk_rid
                ) AS wk
            WHERE
                rl_rid = wk_rid
                AND (rl_minimum >= wk_minimum
                    AND rl_maximum <= wk_maximum)
        ) AS rl
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

--Massnahmen (Anzahl)
/*UPDATE statistics_measures
SET massnahmen_anzahl = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_fg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND massnahmen.wk_fg = wk_fg.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET massnahmen_anzahl = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_sg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND massnahmen.wk_sg = wk_sg.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET massnahmen_anzahl = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_kg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND massnahmen.wk_kg = wk_kg.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET massnahmen_anzahl = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_gw,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND massnahmen.wk_gw = wk_gw.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Massnahmen (Fläche/Länge)
UPDATE statistics_measures
SET massnahmen_flaeche = (
    SELECT area(geom.geo_field)
    FROM
        wk_fg,
        massnahmen,
        geom
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND massnahmen.wk_fg = wk_fg.id
        AND geom.id = massnahmen.real_geom
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET massnahmen_flaeche = (
    SELECT area(geom.geo_field)
    FROM
        wk_sg,
        massnahmen,
        geom
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND massnahmen.wk_sg = wk_sg.id
        AND geom.id = massnahmen.real_geom
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET massnahmen_flaeche = (
    SELECT area(geom.geo_field)
    FROM
        wk_kg,
        massnahmen,
        geom
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND massnahmen.wk_kg = wk_kg.id
        AND geom.id = massnahmen.real_geom
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET massnahmen_flaeche = (
    SELECT area(geom.geo_field)
    FROM
        wk_gw,
        massnahmen,
        geom
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND massnahmen.wk_gw = wk_gw.id
        AND geom.id = massnahmen.real_geom
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );*/

--Geplante Massnahmen
UPDATE statistics_measures
SET massnahmen_geplant = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_fg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND massnahmen.wk_fg = wk_fg.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET massnahmen_geplant = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_sg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND massnahmen.wk_sg = wk_sg.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET massnahmen_geplant = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_kg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND massnahmen.wk_kg = wk_kg.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET massnahmen_geplant = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_gw,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND massnahmen.wk_gw = wk_gw.id
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );

--Umgesetzte Massnahmen
UPDATE statistics_measures
SET massnahmen_umgesetzt = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_fg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_fg.wk_k
        AND massnahmen.wk_fg = wk_fg.id
        AND massnahmen.massn_fin = TRUE
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Fliessgewässer'
    );

UPDATE statistics_measures
SET massnahmen_umgesetzt = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_sg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_sg.wk_k
        AND massnahmen.wk_sg = wk_sg.id
        AND massnahmen.massn_fin = TRUE
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Standgewässer'
    );

UPDATE statistics_measures
SET massnahmen_umgesetzt = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_kg,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_kg.eu_cd_cw
        AND massnahmen.wk_kg = wk_kg.id
        AND massnahmen.massn_fin = TRUE
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Küstengewässer'
    );

UPDATE statistics_measures
SET massnahmen_umgesetzt = (
    SELECT count(distinct massnahmen.id)
    FROM
        wk_gw,
        massnahmen
    WHERE
        statistics_measures.wk_k = wk_gw.eu_cd_gb
        AND massnahmen.wk_gw = wk_gw.id
        AND massnahmen.massn_fin = TRUE
)
WHERE
    statistics_measures.wk_k IN (
        SELECT statistics_dimensions.wk_k
        FROM statistics_dimensions
        WHERE statistics_dimensions.gewaesserkategorie='Grundwasser'
    );
