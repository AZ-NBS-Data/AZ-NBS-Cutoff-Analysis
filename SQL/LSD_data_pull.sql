-- MPSI and POMPE Data Pull
WITH
TIMECORRECTION AS
    (SELECT DISTINCT
        SDV.LABNO,
            CASE
                WHEN (SUBSTR(TMCOLL,1,1) NOT IN ('0','1','2')
                    OR SUBSTR(TMCOLL, 1, 2) > 23
                    OR SUBSTR(TMCOLL, 3, 1) >'5'
                    OR LENGTH(TRIM(TMCOLL)) <> 4
                    ) THEN NULL
                ELSE TMCOLL
                END AS "COLLTM",
            CASE
                WHEN (SUBSTR(BIRTHTM, 1, 1) NOT IN ('0','1','2')
                    OR SUBSTR(BIRTHTM,1,2) > 23
                    OR SUBSTR(BIRTHTM,3,1) > '5'
                    OR LENGTH(TRIM(BIRTHTM)) <> 4
                    ) THEN NULL
                ELSE BIRTHTM
            END AS "BIRTHTM"
        FROM AZMSDS.sample_demog_view SDV
    )
SELECT DISTINCT
    SDV.LINK,
    DAV.LABNO,
    MAX(CASE WHEN DAV.testcode = 00165 AND DAV.reptcode = 90039 THEN DAV.value ELSE NULL END) "GAA",
    MAX(CASE WHEN DAV.testcode = 00164 AND DAV.reptcode = 90040 THEN DAV.value ELSE NULL END) "IDUA",
    MAX(CASE WHEN DV.reptcode = 90039 THEN DV.mnemonic ELSE NULL END) "POMPE",
    MAX(CASE WHEN DV.reptcode = 90040 THEN DV.mnemonic ELSE NULL END) "MPSI",
    TO_CHAR(SDV.dtrecv, 'YYYY-mm-dd') "RECVDT",
    TO_CHAR(SDV.birthdt, 'YYYY-mm-dd') "BIRTHDT",
    ROUND((( TRUNC(SDV.DTCOLL - SDV.BIRTHDT) + (TO_DATE(TC.COLLTM, 'HH24MI')-(TO_DATE(TC.BIRTHTM, 'HH24MI'))))*24),2) AS "AGECOLL_HRS",
    TRUNC(SDV.DTRECV - SDV.DTCOLL) "TRANSIT_TIME_DAYS",
    SDV.spectype,
    SDV.birthwt,
    SDV.gestage,
    SDV.NICU,
    SDV.feed
FROM azmsds.disorder_avg_view DAV
LEFT JOIN azmsds.disorder_view DV
    ON DV.labno = DAV.labno AND DV.reptcode = DAV.reptcode
LEFT JOIN azmsds.sample_demog_view SDV
    ON SDV.labno = DAV.labno
LEFT JOIN TIMECORRECTION TC
    ON TC.labno = SDV.labno
WHERE DAV.testcode IN (00164, 00165)
    AND DAV.reptcode IN (90039, 90040)
    AND SDV.dtrecv BETWEEN TO_DATE('06-01-2023', 'MM/DD/YYYY') AND TO_DATE('06-01-2024', 'MM/DD/YYYY')
GROUP BY SDV.link, DAV.labno, TO_CHAR(SDV.dtrecv, 'YYYY-mm-dd'), TO_CHAR(SDV.birthdt, 'YYYY-mm-dd'), 
ROUND((( TRUNC(SDV.DTCOLL - SDV.BIRTHDT) + (TO_DATE(TC.COLLTM, 'HH24MI')-(TO_DATE(TC.BIRTHTM, 'HH24MI'))))*24),2),
    TRUNC(SDV.DTRECV - SDV.DTCOLL), SDV.spectype, SDV.birthwt, SDV.gestage, SDV.nicu, SDV.feed
ORDER BY labno;
