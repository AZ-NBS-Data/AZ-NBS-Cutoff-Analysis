/* ============================================================
   TEMPLATE SQL SCRIPT FOR CUTOFF ANALYSIS
   ------------------------------------------------------------
   This script retrieves analyte values, demographics, and 
   collection/processing metrics for cutoff analyses.

   MODIFY ONLY the following sections (Duplicate lines for additional TESTCODEs and REPTCODEs):
     - <TESTCODE_1>, <TESTCODE_2>  → Replace with desired TESTCODEs
     - <REPTCODE_1>, <REPTCODE_2>  → Replace with desired REPTCODEs
     - <START_DATE>, <END_DATE>    → Replace with desired date range
   ============================================================ */

/* CTE for correcting birth/collection time format */
WITH TIMECORRECTION AS (
    SELECT DISTINCT
        SDV.LABNO,
        CASE
            WHEN (SUBSTR(TMCOLL,1,1) NOT IN ('0','1','2')
                  OR SUBSTR(TMCOLL, 1, 2) > 23
                  OR SUBSTR(TMCOLL, 3, 1) > '5'
                  OR LENGTH(TRIM(TMCOLL)) <> 4
                ) THEN NULL
            ELSE TMCOLL
        END AS "COLLTM",

        CASE
            WHEN (SUBSTR(BIRTHTM,1,1) NOT IN ('0','1','2')
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

    /* Replace test/rept codes as needed */
    MAX(CASE WHEN DAV.testcode = <TESTCODE_1> AND DAV.reptcode = <REPTCODE_1> THEN DAV.value ELSE NULL END) AS "Analyte_1",
    MAX(CASE WHEN DAV.testcode = <TESTCODE_2> AND DAV.reptcode = <REPTCODE_2> THEN DAV.value ELSE NULL END) AS "Analyte_2",

    /* Disorder names (mnemonics) */
    MAX(CASE WHEN DV.reptcode = <REPTCODE_1> THEN DV.mnemonic ELSE NULL END) AS "Disorder_1",
    MAX(CASE WHEN DV.reptcode = <REPTCODE_2> THEN DV.mnemonic ELSE NULL END) AS "Disorder_2",

    /* Demographic and timing variables */
    TO_CHAR(SDV.dtrecv, 'YYYY-MM-DD') AS "RECVDT",
    TO_CHAR(SDV.birthdt, 'YYYY-MM-DD') AS "BIRTHDT",
    ROUND(((TRUNC(SDV.DTCOLL - SDV.BIRTHDT) + (TO_DATE(TC.COLLTM,'HH24MI') - TO_DATE(TC.BIRTHTM,'HH24MI'))) * 24), 2) AS "AGECOLL_HRS",
    TRUNC(SDV.DTRECV - SDV.DTCOLL) AS "TRANSIT_TIME_DAYS",
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

/* =======================================
   MODIFY DATE RANGE HERE
   ======================================= */
WHERE DAV.testcode IN (<TESTCODE_1>, <TESTCODE_2>)
  AND DAV.reptcode IN (<REPTCODE_1>, <REPTCODE_2>)
  AND SDV.dtrecv BETWEEN TO_DATE('<START_DATE>', 'MM/DD/YYYY') AND TO_DATE('<END_DATE>', 'MM/DD/YYYY')

GROUP BY SDV.link,
         DAV.labno,
         TO_CHAR(SDV.dtrecv, 'YYYY-MM-DD'),
         TO_CHAR(SDV.birthdt, 'YYYY-MM-DD'),
         ROUND((
             (TRUNC(SDV.DTCOLL - SDV.BIRTHDT)
              + (TO_DATE(TC.COLLTM,'HH24MI') - TO_DATE(TC.BIRTHTM,'HH24MI'))
             ) * 24
         ), 2),
         TRUNC(SDV.DTRECV - SDV.DTCOLL),
         SDV.spectype,
         SDV.birthwt,
         SDV.gestage,
         SDV.nicu,
         SDV.feed

ORDER BY DAV.labno;

