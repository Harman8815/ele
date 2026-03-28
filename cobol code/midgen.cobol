       IDENTIFICATION DIVISION.
       PROGRAM-ID.  MTR002.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TI01-CUSTOMER-FILE  ASSIGN TO CUSTIN
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-CUST-STATUS.

           SELECT MO01-METER-KSDS  ASSIGN TO MTRKSDS
           ORGANIZATION           IS INDEXED
           ACCESS MODE            IS RANDOM
           RECORD KEY             IS MTR-CUST-ID
           FILE STATUS            IS WS-KSDS-STATUS.

           SELECT TO01-METER-ERR   ASSIGN TO METERERR
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-ERR-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD TI01-CUSTOMER-FILE
           RECORD CONTAINS         80  CHARACTERS.

       01 TI01-CUSTOMER-RECORD.
          05 IN-CUST-ID       PIC X(9).
          05 IN-FIRST-NAME    PIC X(20).
          05 IN-LAST-NAME     PIC X(20).
          05 IN-AREA-CODE     PIC X(3).
          05 FILLER           PIC X(1).
          05 IN-ADDRESS       PIC X(25).
          05 FILLER           PIC X(1).
          05 IN-CITY          PIC X(10).

       FD MO01-METER-KSDS
           RECORD CONTAINS         35  CHARACTERS.

       01 MO01-METER-RECORD.
          05 MTR-CUST-ID      PIC X(9).
          05 MTR-METER-ID     PIC X(10).
          05 MTR-PREV-READ    PIC 9(08).
          05 MTR-CURR-READ    PIC 9(08).

       FD TO01-METER-ERR
           RECORDING MODE          IS F
           RECORD CONTAINS         80 CHARACTERS.

       01 TO01-METER-ERR-RECORD.
          05 ERR-CUST-ID      PIC X(9).
          05 ERR-FIRST-NAME   PIC X(20).
          05 ERR-LAST-NAME    PIC X(20).
          05 ERR-AREA-CODE    PIC X(3).
          05 FILLER           PIC X(1).
          05 ERR-ADDRESS      PIC X(25).
          05 FILLER           PIC X(1).
          05 ERR-CITY         PIC X(10).

       WORKING-STORAGE SECTION.

       01 WS-FILE-STATUS-CODES.
          05 WS-CUST-STATUS       PIC X(02).
             88 CUST-IO-STATUS    VALUE '00'.
             88 CUST-EOF          VALUE '10'.
             88 CUST-ROW-NOTFND   VALUE '23'.
          05 WS-KSDS-STATUS        PIC X(02).
             88 KSDS-IO-STATUS     VALUE '00'.
             88 KSDS-ROW-NOTFND    VALUE '23'.
          05 WS-ERR-STATUS         PIC X(02).
             88 ERR-IO-STATUS      VALUE '00'.

       01 WS-DATE-VARIABLES.
          05 WS-DATE               PIC 9(08).
          05 WS-DATE-ID REDEFINES WS-DATE.
             10 WS-CC              PIC 99.
             10 WS-YY              PIC 99.
             10 WS-MM              PIC 99.
             10 WS-DD              PIC 99.

       01  WS-RANDOM-NUMBER-GEN.
           05  WS-RAND-SEED        PIC S9(09) COMP-3 VALUE +0.
           05  WS-RAND-RESULT      PIC S9(09) COMP-3 VALUE +0.
           05  WS-RAND-4DIGIT      PIC 9(04)         VALUE 0.
           05  WS-RAND-DISPLAY     PIC X(04)         VALUE SPACES.
           05  WS-ID-RAND          PIC X(04).
           05  WS-RETRY-CTR        PIC 9(02)         VALUE 0.

       01 WS-CONSUMPTION-CALC.
          05 WS-PREV-READING     PIC 9(08) VALUE 0.
          05 WS-CURR-READING     PIC 9(08) VALUE 0.

       01 WS-SUBS.
          05 I                     PIC 9(04) VALUE 1.
          05 WS-RETRY-CTR          PIC 9(02) VALUE 0.

       01 WS-METER-ID-GEN.
          05 WS-MTR-PREFIX         PIC X(4) VALUE 'MTR-'.
          05 WS-MTR-CUST-CH1       PIC X.
          05 WS-MTR-CUST-CH2       PIC X.
          05 WS-MTR-DD             PIC 99.
          05 WS-MTR-MM             PIC 99.
          05 WS-MTR-RAND           PIC 9999.

       01 WS-HARDCODED-CUST-ID    PIC X(9).

       01 WS-ERROR-FLAGS.
          05 WS-ERROR-RECORD-FLAG  PIC 9.
             88 VALID-RECORD-FLAG  VALUE 1.
             88 ERROR-RECORD-FLAG  VALUE 2.

       01 WS-COUNTERS.
          05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
          05 WS-DUP-CTR            PIC 9(04) VALUE ZEROS.
          05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-SKIP-CTR           PIC 9(04) VALUE ZEROS.

       PROCEDURE DIVISION.
       0000-MAIN-LINE   SECTION.

           PERFORM 1000-INITIALIZE.

           PERFORM 2000-PROCESS.

           PERFORM 9000-TERMINATE.

       1000-INITIALIZE  SECTION.

           DISPLAY '----------------------------------------'
           DISPLAY 'MTR002 EXECUTION BEGINS HERE ..........'
           DISPLAY '  METER GENERATION PROGRAM               '
           DISPLAY '----------------------------------------'

           ACCEPT WS-DATE FROM DATE YYYYMMDD.

       2000-PROCESS     SECTION.

           PERFORM 2100-OPEN-FILES.

           PERFORM 2200-READ-CUSTOMER-FILE UNTIL CUST-EOF.

       2100-OPEN-FILES  SECTION.

           OPEN INPUT TI01-CUSTOMER-FILE.
           IF NOT CUST-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING CUSTOMER INPUT FILE       '
              DISPLAY 'FILE  STATUS ', ' ',    WS-CUST-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           OPEN OUTPUT MO01-METER-KSDS
           IF NOT KSDS-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING METER MASTER KSDS         '
              DISPLAY 'FILE  STATUS ', ' ',    WS-KSDS-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           OPEN OUTPUT TO01-METER-ERR
           IF NOT ERR-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING METER ERR FILE            '
              DISPLAY 'FILE  STATUS ', ' ',    WS-ERR-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           DISPLAY '----------------------------------------'
           DISPLAY 'CUSTOMER INPUT FILE OPENED ..............'
           DISPLAY 'METER MASTER KSDS IS OPENED ..........'
           DISPLAY 'METER ERROR FILE IS OPENED ..........'
           DISPLAY '----------------------------------------'
           .

       2200-READ-CUSTOMER-FILE  SECTION.

           READ TI01-CUSTOMER-FILE

                AT END  SET CUST-EOF TO TRUE
                DISPLAY '----------------------------------------'
                DISPLAY 'NO MORE RECORDS IN CUSTOMER-FILE --------'
                DISPLAY '----------------------------------------'

                NOT AT END  ADD 1  TO WS-READ-CTR
                            PERFORM 2300-VALIDATE-CUSTOMER

           END-READ.

       2300-VALIDATE-CUSTOMER SECTION.

           SET VALID-RECORD-FLAG       TO TRUE.

           IF IN-CUST-ID IS EQUAL TO SPACES
              DISPLAY 'CUSTOMER ID ERROR - CUST_ID REQUIRED FOR METER'
              SET ERROR-RECORD-FLAG         TO TRUE
              MOVE TI01-CUSTOMER-RECORD     TO TO01-METER-ERR-RECORD
              WRITE TO01-METER-ERR-RECORD
           END-IF.

           IF VALID-RECORD-FLAG
              PERFORM 2400-WRITE-METER-KSDS
           END-IF.

       2400-WRITE-METER-KSDS SECTION.

           MOVE IN-CUST-ID               TO WS-HARDCODED-CUST-ID.
           MOVE IN-CUST-ID               TO MTR-CUST-ID.
           MOVE 0                        TO WS-RETRY-CTR.
           MOVE 99                       TO WS-KSDS-STATUS.

           PERFORM 2410-GENERATE-UNIQUE-METER-ID
               UNTIL WS-KSDS-STATUS = '00' OR WS-RETRY-CTR > 100.

           IF WS-KSDS-STATUS = '00'
              ADD 1 TO WS-WRITE-CTR
              DISPLAY 'METER RECORD WRITTEN FOR CUST: ' MTR-CUST-ID
              DISPLAY '  METER ID: ' MTR-METER-ID
              DISPLAY '  PREV READ: ' MTR-PREV-READ
              DISPLAY '  CURR READ: ' MTR-CURR-READ
           ELSE
              ADD 1 TO WS-ERROR-CTR
              DISPLAY 'ERROR: UNABLE TO WRITE METER FOR CUST:'
                       IN-CUST-ID ' STATUS: ' WS-KSDS-STATUS
              DISPLAY 'MAX RETRIES EXCEEDED FOR THIS RECORD'
           END-IF.

       2410-GENERATE-UNIQUE-METER-ID SECTION.

           COMPUTE WS-RAND-SEED =
              FUNCTION MOD(
                 ( WS-RAND-SEED * 1103515245 + 12345 + WS-RETRY-CTR)
                 ,2147483647 )

           COMPUTE WS-RAND-RESULT =
               FUNCTION MOD((WS-RAND-SEED * 1664525
                             + 1013904223), 1000000)
           MOVE WS-RAND-RESULT     TO WS-RAND-4DIGIT
           MOVE WS-RAND-4DIGIT     TO WS-RAND-DISPLAY
           MOVE WS-RAND-DISPLAY    TO WS-ID-RAND.

           MOVE IN-CUST-ID(1:1)    TO WS-MTR-CUST-CH1.
           MOVE IN-CUST-ID(2:1)    TO WS-MTR-CUST-CH2.

           MOVE WS-DD                    TO WS-MTR-DD.
           MOVE WS-MM                    TO WS-MTR-MM.
           MOVE WS-ID-RAND               TO WS-MTR-RAND.

           STRING WS-MTR-PREFIX WS-MTR-CUST-CH1 WS-MTR-CUST-CH2
                  WS-MTR-DD WS-MTR-MM WS-MTR-RAND
                  DELIMITED BY SIZE
                  INTO MTR-METER-ID
           END-STRING.

      *    Generate random meter readings per ER diagram (prev_read, curr_read)
           COMPUTE WS-CURR-READING =
               FUNCTION MOD((WS-RAND-SEED * 1664525 + 1013904223), 10000)
           COMPUTE WS-PREV-READING =
               FUNCTION MOD((WS-RAND-SEED * 1103515245 + 12345), 10000)

      *    Ensure current reading is greater than previous
           IF WS-PREV-READING > WS-CURR-READING
              MOVE WS-PREV-READING TO WS-CURR-READING
              ADD 500 TO WS-CURR-READING
           END-IF.

           MOVE WS-PREV-READING          TO MTR-PREV-READ.
           MOVE WS-CURR-READING          TO MTR-CURR-READ.

           DISPLAY 'ATTEMPTING METER FOR CUST: ' MTR-CUST-ID
                   ' METER ID: ' MTR-METER-ID.

           WRITE MO01-METER-RECORD
               INVALID KEY
                   IF WS-KSDS-STATUS = '22'
                      DISPLAY 'DUPLICATE KEY DETECTED: ' MTR-CUST-ID
                              ' - RETRYING...'
                      ADD 1 TO WS-DUP-CTR
                      ADD 1 TO WS-RETRY-CTR
                   ELSE
                      DISPLAY 'WRITE ERROR - STATUS: ' WS-KSDS-STATUS
                   END-IF
               NOT INVALID KEY
                   MOVE '00' TO WS-KSDS-STATUS
           END-WRITE.

       9000-TERMINATE   SECTION.

           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' OUTPUT RECORDS WRITTEN   ',  WS-WRITE-CTR
           DISPLAY ' DUPLICATE KEY RETRIES    ',  WS-DUP-CTR
           DISPLAY ' ERROR RECORDS            ',  WS-ERROR-CTR
           DISPLAY '----------------------------------------'

           CLOSE  TI01-CUSTOMER-FILE,
                  TO01-METER-ERR,
                  MO01-METER-KSDS.

           DISPLAY '----------------------------------------'
           DISPLAY 'CUSTOMER FILE      IS CLOSED          '
           DISPLAY 'METER MASTER KSDS  IS CLOSED          '
           DISPLAY 'METER ERROR FILE   IS CLOSED          '
           DISPLAY '----------------------------------------'

           STOP RUN.