       IDENTIFICATION DIVISION.
       PROGRAM-ID.  METERDB2.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TI01-METER-FILE  ASSIGN TO METERIN
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-METER-STATUS.

           SELECT TO01-METER-ERR   ASSIGN TO METERERR
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-ERR-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD TI01-METER-FILE
           RECORD CONTAINS         21  CHARACTERS.

       01 TI01-METER-RECORD.
          05 IN-METER-ID    PIC X(7).
          05 FILLER         PIC X(2).
          05 IN-INSTALL-DT  PIC X(10).
          05 FILLER         PIC X(1).
          05 IN-STATUS      PIC X(1).

       FD TO01-METER-ERR
           RECORDING MODE          IS F
           RECORD CONTAINS         20 CHARACTERS.

       01 TO01-METER-ERR-RECORD.
          05 ERR-CUST-ID    PIC X(9).
          05 ERR-INSTALL-ID PIC X(10).
          05 ERR-STATUS     PIC X(1).

       WORKING-STORAGE SECTION.

       01 WS-FILE-STATUS-CODES.
          05 WS-METER-STATUS       PIC X(02).
             88 METER-IO-STATUS    VALUE '00'.
             88 METER-EOF          VALUE '10'.
             88 METER-ROW-NOTFND   VALUE '23'.
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
          05 WS-CONSUMPTION      PIC 9(08) VALUE 0.
          05 WS-CURRENT-READING  PIC 9(08) VALUE 0.
          05 WS-PREV-READING     PIC 9(08) VALUE 0.
          05 WS-UNIT-RATE        PIC 9(03)V99 VALUE 8.50.
          05 WS-BILL-AMOUNT      PIC 9(08)V99 VALUE 0.
          05 WS-BILL-DISPLAY     PIC X(15).

       01 WS-RAND-NUM-GEN.
          05 WS-RAND-NUM           PIC 9(08).
          05 WS-SEED-VALUE         PIC 9(08).

       01 WS-SUBS.
          05 I                     PIC 9(04) VALUE 1.
          05 J                     PIC 9(04) VALUE 1.
          05 WS-RETRY-CTR          PIC 9(04) VALUE 0.

       01 WS-METER-ID-GEN.
          05 WS-MTR-PREFIX         PIC X(4) VALUE 'MTR-'.
          05 WS-MTR-SEQ            PIC 9(3) VALUE ZERO.
          05 WS-MTR-CUST-CH1       PIC X.
          05 WS-MTR-CUST-CH2       PIC X.
          05 WS-MTR-DD             PIC 99.
          05 WS-MTR-MM             PIC 99.
          05 WS-MTR-RAND           PIC 9999.

       01 WS-HARDCODED-METER-ID   PIC X(7).

       01 WS-ERROR-FLAGS.
          05 WS-ERROR-RECORD-FLAG  PIC 9.
             88 VALID-RECORD-FLAG  VALUE 1.
             88 ERROR-RECORD-FLAG  VALUE 2.

       01 WS-COUNTERS.
          05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
          05 WS-DUP-CTR            PIC 9(04) VALUE ZEROS.
          05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-UPDT-CTR           PIC 9(04) VALUE ZEROS.
          05 WS-PTR                PIC 9(02) VALUE ZEROS.

      *============================================================
      * DB2 SQL DECLARATION AREA
      *============================================================

      * DB2 COMMUNICATION AREA
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.

      * HOST VARIABLES FOR DB2 METER TABLE
       01 HV-METER-RECORD.
          05 HV-METER-ID           PIC X(14).
          05 HV-METER-CUST-ID      PIC X(12) VALUE SPACES.
          05 HV-METER-INSTALL-DT   PIC X(10).
          05 HV-METER-STATUS       PIC X(1).

       01 HV-DBNAME               PIC X(8) VALUE 'ELECTDB'.

       PROCEDURE DIVISION.
       0000-MAIN-LINE   SECTION.

           PERFORM 1000-INITIALIZE.

           PERFORM 2000-PROCESS.

           PERFORM 9000-TERMINATE.

       1000-INITIALIZE  SECTION.

           DISPLAY '----------------------------------------'
           DISPLAY 'METERDB2 EXECUTION BEGINS HERE .........'
           DISPLAY '----------------------------------------'

           ACCEPT WS-DATE FROM DATE YYYYMMDD.

           PERFORM 2150-DB2-CONNECT.

       2000-PROCESS     SECTION.

           PERFORM 2100-OPEN-FILES.

           PERFORM 2200-READ-METER-FILE UNTIL METER-EOF.

       2100-OPEN-FILES  SECTION.

           OPEN INPUT TI01-METER-FILE.
           IF NOT METER-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING METER INPUT FILE       '
              DISPLAY 'FILE  STATUS ', ' ',    WS-METER-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           OPEN OUTPUT TO01-METER-ERR.
           IF NOT ERR-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING METER ERR  FILE        '
              DISPLAY 'FILE  STATUS ', ' ',    WS-ERR-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           DISPLAY '----------------------------------------'
           DISPLAY 'METER INPUT FILE OPENED ..............'
           DISPLAY 'METER ERROR FILE IS OPENED ..........'
           DISPLAY '----------------------------------------'
           .

       2150-DB2-CONNECT SECTION.
      *    ------------------------------------------------------------
      *    CONNECT TO DB2 DATABASE
      *    Replace 'ELECTDB' with your actual database name
      *    ------------------------------------------------------------
           EXEC SQL
               CONNECT TO :HV-DBNAME
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR CONNECTING TO DB2: SQLCODE=' SQLCODE
              STOP RUN
           END-IF.

           DISPLAY 'DB2 CONNECTION ESTABLISHED SUCCESSFULLY'.

       2200-READ-METER-FILE  SECTION.

           READ TI01-METER-FILE

                AT END  SET METER-EOF TO TRUE
                DISPLAY '----------------------------------------'
                DISPLAY 'NO MORE RECORDS IN METER-FILE    --------'
                DISPLAY '----------------------------------------'

                NOT AT END  ADD 1  TO WS-READ-CTR
                            PERFORM 2300-VALIDATE-METER

           END-READ.

       2300-VALIDATE-METER SECTION.

           SET VALID-RECORD-FLAG       TO TRUE.

           IF IN-METER-ID IS EQUAL TO SPACES
              DISPLAY 'METER ID ERROR'
              SET ERROR-RECORD-FLAG         TO TRUE
              MOVE TI01-METER-RECORD      TO TO01-METER-ERR-RECORD
              WRITE TO01-METER-ERR-RECORD
           END-IF.

           IF VALID-RECORD-FLAG
              PERFORM 2400-WRITE-METER-DB2
           END-IF.

       2400-WRITE-METER-DB2 SECTION.
      *    ------------------------------------------------------------
      *    INSERT METER INTO DB2 METER TABLE
      *    ------------------------------------------------------------
           MOVE IN-METER-ID              TO WS-HARDCODED-METER-ID.
           MOVE IN-INSTALL-DT            TO HV-METER-INSTALL-DT.
           MOVE IN-STATUS                TO HV-METER-STATUS.
           MOVE 0                        TO WS-RETRY-CTR.

           PERFORM 2410-GENERATE-UNIQUE-METER-ID
               UNTIL SQLCODE = 0 OR WS-RETRY-CTR > 100.

           IF SQLCODE = 0
              ADD 1 TO WS-WRITE-CTR
              DISPLAY 'METER INSERTED SUCCESSFULLY: ' HV-METER-ID
              PERFORM 2420-CALCULATE-CONSUMPTION
           ELSE
              ADD 1 TO WS-ERROR-CTR
              DISPLAY 'ERROR: UNABLE TO INSERT METER FOR: '
                       IN-METER-ID ' SQLCODE: ' SQLCODE
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

           MOVE IN-METER-ID(1:1)  TO WS-MTR-CUST-CH1.
           MOVE IN-METER-ID(2:1)  TO WS-MTR-CUST-CH2.

           MOVE WS-DD                    TO WS-MTR-DD.
           MOVE WS-MM                    TO WS-MTR-MM.
           MOVE WS-ID-RAND               TO WS-MTR-RAND.
           STRING WS-MTR-PREFIX WS-MTR-CUST-CH1 WS-MTR-CUST-CH2
                  WS-MTR-DD WS-MTR-MM WS-MTR-RAND
                  DELIMITED BY SIZE
                  INTO HV-METER-ID
           END-STRING.
           DISPLAY 'ATTEMPTING METER ID : ' HV-METER-ID.

      *    INSERT INTO DB2 METER TABLE
           EXEC SQL
               INSERT INTO METER
               (METER_ID, METER_CUST_ID, METER_INSTALL_DT, METER_STATUS)
               VALUES
               (:HV-METER-ID, :HV-METER-CUST-ID,
                :HV-METER-INSTALL-DT, :HV-METER-STATUS)
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN -803
                   DISPLAY 'DUPLICATE KEY DETECTED: ' HV-METER-ID
                           ' - RETRYING...'
                   ADD 1 TO WS-DUP-CTR
                   ADD 1 TO WS-RETRY-CTR
               WHEN OTHER
                   DISPLAY 'DB2 INSERT ERROR: SQLCODE=' SQLCODE
                   ADD 1 TO WS-RETRY-CTR
           END-EVALUATE.

       2420-CALCULATE-CONSUMPTION SECTION.
      *    ------------------------------------------------------------
      *    CALCULATE BILL AMOUNT BASED ON CONSUMPTION
      *    Formula: Bill Amount = (Current - Prev) * Unit Rate
      *    ------------------------------------------------------------

      *    Generate random readings for simulation
           COMPUTE WS-CURRENT-READING =
               FUNCTION MOD((WS-RAND-SEED * 1664525 + 1013904223), 10000)
           COMPUTE WS-PREV-READING =
               FUNCTION MOD((WS-RAND-SEED * 1103515245 + 12345), 10000)

      *    Ensure current reading is greater than previous
           IF WS-PREV-READING > WS-CURRENT-READING
              MOVE WS-PREV-READING TO WS-CURRENT-READING
              ADD 500 TO WS-CURRENT-READING
           END-IF.

      *    Calculate consumption (units used)
           COMPUTE WS-CONSUMPTION = WS-CURRENT-READING - WS-PREV-READING

      *    Calculate bill amount
           COMPUTE WS-BILL-AMOUNT = WS-CONSUMPTION * WS-UNIT-RATE

           DISPLAY '  CONSUMPTION DATA FOR METER: ' HV-METER-ID
           DISPLAY '    Current Reading: ' WS-CURRENT-READING
           DISPLAY '    Previous Reading: ' WS-PREV-READING
           DISPLAY '    Units Consumed: ' WS-CONSUMPTION
           DISPLAY '    Unit Rate: ' WS-UNIT-RATE
           DISPLAY '    Bill Amount: ' WS-BILL-AMOUNT.

       9000-TERMINATE   SECTION.

           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' OUTPUT RECORDS WRITTEN   ',  WS-WRITE-CTR
           DISPLAY ' DUPLICATE KEY RETRIES    ',  WS-DUP-CTR
           DISPLAY ' ERROR RECORDS            ',  WS-ERROR-CTR
           DISPLAY '----------------------------------------'

      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE  TI01-METER-FILE,
                  TO01-METER-ERR.

           DISPLAY '----------------------------------------'
           DISPLAY 'METER FILE        IS CLOSED          '
           DISPLAY 'METER ERROR FILE  IS CLOSED          '
           DISPLAY '----------------------------------------'

           STOP RUN.
