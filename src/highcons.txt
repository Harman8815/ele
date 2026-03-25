       IDENTIFICATION DIVISION.
       PROGRAM-ID.  HIGHCONS.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TI01-CUST-KSDS   ASSIGN TO CUSTKSDS
           ORGANIZATION           IS INDEXED
           ACCESS MODE            IS SEQUENTIAL
           RECORD KEY             IS CUST-ID
           FILE STATUS            IS WS-CUST-STATUS.

           SELECT TI01-METER-KSDS  ASSIGN TO METERKSDS
           ORGANIZATION           IS INDEXED
           ACCESS MODE            IS RANDOM
           RECORD KEY             IS METER-ID
           FILE STATUS            IS WS-METER-STATUS.

           SELECT TI01-READ-TXN    ASSIGN TO READTXN
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-TXN-STATUS.

           SELECT TO01-REPORT      ASSIGN TO HIGHRPT
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-REPORT-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD TI01-CUST-KSDS
           RECORD CONTAINS         146   CHARACTERS.

       01 TI01-CUST-RECORD.
          05 CUST-ID            PIC X(9).
          05 CUST-FNAME         PIC X(15).
          05 CUST-LNAME         PIC X(15).
          05 CUST-AREACODE      PIC X(7).
          05 CUST-ADDRESS1      PIC X(30).
          05 CUST-LOCALITY      PIC X(30).
          05 CUST-CITY          PIC X(20).
          05 CUST-UNITS         PIC X(10).
          05 CUST-STATUS        PIC X(10).

       FD TI01-METER-KSDS
           RECORD CONTAINS         34   CHARACTERS.

       01 TI01-METER-RECORD.
          05 METER-ID           PIC X(14).
          05 METER-CUST-ID      PIC X(9).
          05 METER-INSTALL-DT   PIC X(10).
          05 METER-STATUS       PIC X(1).

       FD TI01-READ-TXN
           RECORD CONTAINS         29   CHARACTERS.

       01 TI01-TXN-RECORD.
          05 TXN-METER-ID       PIC X(14).
          05 TXN-READ-DATE      PIC X(10).
          05 TXN-PREV-READ      PIC 9(7)V99.
          05 TXN-CURR-READ      PIC 9(7)V99.

       FD TO01-REPORT
           RECORDING MODE          IS F
           RECORD CONTAINS         133  CHARACTERS.

       01 TO01-REPORT-RECORD    PIC X(133).

       WORKING-STORAGE SECTION.

       01 WS-FILE-STATUS-CODES.
          05 WS-CUST-STATUS        PIC X(02).
             88 CUST-IO-STATUS     VALUE '00'.
             88 CUST-EOF           VALUE '10'.
          05 WS-METER-STATUS       PIC X(02).
             88 METER-IO-STATUS    VALUE '00'.
             88 METER-NOT-FOUND    VALUE '23'.
          05 WS-TXN-STATUS         PIC X(02).
             88 TXN-IO-STATUS      VALUE '00'.
             88 TXN-EOF            VALUE '10'.
          05 WS-REPORT-STATUS      PIC X(02).
             88 REPORT-IO-STATUS   VALUE '00'.

       01 WS-DATE-VARIABLES.
          05 WS-DATE               PIC 9(08).
          05 WS-DATE-FMT.
             10 WS-CC              PIC 99.
             10 FILLER              PIC X VALUE '-'.
             10 WS-YY              PIC 99.
             10 FILLER              PIC X VALUE '-'.
             10 WS-MM              PIC 99.
             10 FILLER              PIC X VALUE '-'.
             10 WS-DD              PIC 99.

       01 WS-PAGE-CONTROL.
          05 WS-PAGE-NUM           PIC 9(02) VALUE ZERO.
          05 WS-LINE-CNT           PIC 9(02) VALUE 60.
          05 WS-LINES-PER-PAGE     PIC 9(02) VALUE 55.
          05 WS-HEADER-LINES       PIC 9(02) VALUE 6.

       01 WS-TOP5-TABLE.
          05 WS-TOP5-ENTRY OCCURS 5 TIMES INDEXED BY WS-IDX.
             10 WS-TOP5-CUST-ID    PIC X(9).
             10 WS-TOP5-CUST-NAME  PIC X(30).
             10 WS-TOP5-AREACODE   PIC X(7).
             10 WS-TOP5-METER-ID   PIC X(14).
             10 WS-TOP5-CONSUMP    PIC 9(07)V99.
             10 WS-TOP5-BILL-AMT   PIC 9(09)V99.

       01 WS-CURRENT-RECORD.
          05 WS-CURR-CUST-ID      PIC X(9).
          05 WS-CURR-CUST-NAME    PIC X(30).
          05 WS-CURR-AREACODE     PIC X(7).
          05 WS-CURR-METER-ID     PIC X(14).
          05 WS-CURR-CONSUMP      PIC 9(07)V99.
          05 WS-CURR-BILL-AMT     PIC 9(09)V99.

       01 WS-CALCULATION-VARS.
          05 WS-CONSUMPTION        PIC 9(07)V99 VALUE ZERO.
          05 WS-BILL-AMOUNT        PIC 9(09)V99 VALUE ZERO.
          05 WS-RATE-LOW           PIC 9(03)V99 VALUE 3.50.
          05 WS-RATE-MEDIUM        PIC 9(03)V99 VALUE 5.50.
          05 WS-RATE-HIGH          PIC 9(03)V99 VALUE 7.50.
          05 WS-THRESHOLD-1        PIC 9(05) VALUE 100.
          05 WS-THRESHOLD-2        PIC 9(05) VALUE 300.
          05 WS-THRESHOLD-3        PIC 9(05) VALUE 500.
          05 WS-TEMP-CONSUMP       PIC 9(07)V99 VALUE ZERO.
          05 WS-TEMP-BILL          PIC 9(09)V99 VALUE ZERO.
          05 WS-INSERT-POS         PIC 9(02) VALUE ZERO.

       01 WS-COUNTERS.
          05 WS-PROCESSED-CNT      PIC 9(06) VALUE ZERO.
          05 WS-HIGH-CONS-CNT      PIC 9(06) VALUE ZERO.

       01 WS-FLAGS.
          05 WS-FIRST-RECORD       PIC X VALUE 'Y'.

       01 WS-REPORT-HEADERS.
          05 WS-REPORT-TITLE       PIC X(45) VALUE
             '  ABC ELECTRICITY - TOP 5 HIGHEST CONSUMING CUSTOMERS'.
          05 WS-DATE-STR           PIC X(10) VALUE SPACES.
          05 WS-PAGE-STR           PIC X(03) VALUE SPACES.

       01 WS-HEADER-LINE1.
          05 FILLER                PIC X(40) VALUE
             '----------------------------------------'.
          05 FILLER                PIC X(40) VALUE
             '----------------------------------------'.
          05 FILLER                PIC X(53) VALUE
             '---------------------------------------------'.

       01 WS-HEADER-LINE2.
          05 FILLER                PIC X(40) VALUE
             'RANK  CUSTOMER ID   CUSTOMER NAME        '.
          05 FILLER                PIC X(40) VALUE
             'AREA       METER ID        CONSUMPTION   '.
          05 FILLER                PIC X(53) VALUE
             'BILL AMOUNT      STATUS       '.

       01 WS-HEADER-LINE3.
          05 FILLER                PIC X(40) VALUE
             '----  -----------   -------------        '.
          05 FILLER                PIC X(40) VALUE
             '-----      --------        -----------   '.
          05 FILLER                PIC X(53) VALUE
             '-----------      --------       '.

       01 WS-DETAIL-LINE.
          05 WS-D-RANK             PIC Z9.
          05 FILLER                PIC X(4) VALUE SPACES.
          05 WS-D-CUSTID           PIC X(9).
          05 FILLER                PIC X(3) VALUE SPACES.
          05 WS-D-CUSTNAME         PIC X(20).
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-AREACODE         PIC X(7).
          05 FILLER                PIC X(3) VALUE SPACES.
          05 WS-D-METERID          PIC X(14).
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-CONSUMP          PIC ZZZ,ZZ9.99.
          05 FILLER                PIC X(3) VALUE SPACES.
          05 WS-D-AMOUNT           PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-STATUS           PIC X(10).

       01 WS-SUMMARY-LINE.
          05 FILLER                PIC X(40) VALUE
             '*** SUMMARY ***                          '.
          05 FILLER                PIC X(40) VALUE
             '                                        '.
          05 WS-S-PROCESSED        PIC ZZ,ZZZ9.
          05 FILLER                PIC X(15) VALUE ' PROCESSED    '.
          05 WS-S-HIGH             PIC ZZ,ZZZ9.
          05 FILLER                PIC X(12) VALUE ' HIGH >500  '.

       01 WS-THRESHOLD-LINE.
          05 FILLER                PIC X(40) VALUE
             'HIGH CONSUMPTION THRESHOLD: > 500 UNITS '.
          05 FILLER                PIC X(93) VALUE SPACES.

       PROCEDURE DIVISION.
       0000-MAIN-LINE   SECTION.

           PERFORM 1000-INITIALIZE.

           PERFORM 2000-PROCESS.

           PERFORM 9000-TERMINATE.

       1000-INITIALIZE  SECTION.

           ACCEPT WS-DATE FROM DATE YYYYMMDD.
           MOVE WS-CC TO WS-DATE-FMT(1:2).
           MOVE WS-YY TO WS-DATE-FMT(4:2).
           MOVE WS-MM TO WS-DATE-FMT(7:2).
           MOVE WS-DD TO WS-DATE-FMT(10:2).

           PERFORM 2100-OPEN-FILES.

           PERFORM 2200-INIT-TOP5.

       2100-OPEN-FILES  SECTION.

           OPEN INPUT TI01-CUST-KSDS.
           IF NOT CUST-IO-STATUS
              DISPLAY 'ERROR OPENING CUSTOMER KSDS: ' WS-CUST-STATUS
              STOP RUN
           END-IF.

           OPEN INPUT TI01-METER-KSDS.
           IF NOT METER-IO-STATUS
              DISPLAY 'ERROR OPENING METER KSDS: ' WS-METER-STATUS
              STOP RUN
           END-IF.

           OPEN INPUT TI01-READ-TXN.
           IF NOT TXN-IO-STATUS
              DISPLAY 'ERROR OPENING READING TXN: ' WS-TXN-STATUS
              STOP RUN
           END-IF.

           OPEN OUTPUT TO01-REPORT.
           IF NOT REPORT-IO-STATUS
              DISPLAY 'ERROR OPENING REPORT FILE: ' WS-REPORT-STATUS
              STOP RUN
           END-IF.

       2200-INIT-TOP5  SECTION.

           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 5
               MOVE SPACES TO WS-TOP5-CUST-ID(WS-IDX)
               MOVE SPACES TO WS-TOP5-CUST-NAME(WS-IDX)
               MOVE SPACES TO WS-TOP5-AREACODE(WS-IDX)
               MOVE SPACES TO WS-TOP5-METER-ID(WS-IDX)
               MOVE ZERO TO WS-TOP5-CONSUMP(WS-IDX)
               MOVE ZERO TO WS-TOP5-BILL-AMT(WS-IDX)
           END-PERFORM.

       2000-PROCESS     SECTION.

           PERFORM 2300-READ-ALL-TXNS.

           PERFORM 3000-PRINT-HEADERS.

           PERFORM 4000-PRINT-TOP5.

       2300-READ-ALL-TXNS  SECTION.

           PERFORM 2400-READ-TXN.

           PERFORM UNTIL TXN-EOF

               ADD 1 TO WS-PROCESSED-CNT

               MOVE TXN-METER-ID TO METER-ID

               READ TI01-METER-KSDS
                    KEY IS METER-ID
                    INVALID KEY
                        CONTINUE
                    NOT INVALID KEY
                        PERFORM 2500-PROCESS-METER
               END-READ

               PERFORM 2400-READ-TXN

           END-PERFORM.

       2400-READ-TXN  SECTION.

           READ TI01-READ-TXN
                AT END  SET TXN-EOF TO TRUE
                NOT AT END  CONTINUE
           END-READ.

       2500-PROCESS-METER  SECTION.

           MOVE METER-CUST-ID TO CUST-ID.

           READ TI01-CUST-KSDS
                KEY IS CUST-ID
                INVALID KEY
                    CONTINUE
                NOT INVALID KEY
                    PERFORM 2600-CALCULATE-AND-INSERT
           END-READ.

       2600-CALCULATE-AND-INSERT  SECTION.

           COMPUTE WS-CONSUMPTION = TXN-CURR-READ - TXN-PREV-READ.

           EVALUATE TRUE
               WHEN WS-CONSUMPTION <= WS-THRESHOLD-1
                   COMPUTE WS-BILL-AMOUNT = WS-CONSUMPTION * WS-RATE-LOW
               WHEN WS-CONSUMPTION <= WS-THRESHOLD-2
                   COMPUTE WS-BILL-AMOUNT = WS-CONSUMPTION * WS-RATE-MEDIUM
               WHEN WS-CONSUMPTION <= WS-THRESHOLD-3
                   COMPUTE WS-BILL-AMOUNT = WS-CONSUMPTION * WS-RATE-MEDIUM
               WHEN OTHER
                   COMPUTE WS-BILL-AMOUNT = WS-CONSUMPTION * WS-RATE-HIGH
                   ADD 1 TO WS-HIGH-CONS-CNT
           END-EVALUATE.

           IF WS-CONSUMPTION > WS-TOP5-CONSUMP(5)
               PERFORM 2700-INSERT-INTO-TOP5
           END-IF.

       2700-INSERT-INTO-TOP5  SECTION.

           MOVE 1 TO WS-INSERT-POS.

           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 5
               IF WS-CONSUMPTION > WS-TOP5-CONSUMP(WS-IDX)
                  MOVE WS-IDX TO WS-INSERT-POS
                  EXIT PERFORM
               END-IF
           END-PERFORM.

           IF WS-INSERT-POS <= 5
               PERFORM 2800-SHIFT-AND-INSERT
           END-IF.

       2800-SHIFT-AND-INSERT  SECTION.

           PERFORM VARYING WS-IDX FROM 5 BY -1 UNTIL WS-IDX <= WS-INSERT-POS

               IF WS-IDX > 1
                   MOVE WS-TOP5-ENTRY(WS-IDX - 1) TO WS-TOP5-ENTRY(WS-IDX)
               END-IF

           END-PERFORM.

           MOVE CUST-ID TO WS-TOP5-CUST-ID(WS-INSERT-POS).

           STRING CUST-FNAME DELIMITED BY SPACE
                  ' ' DELIMITED BY SIZE
                  CUST-LNAME DELIMITED BY SPACE
                  INTO WS-TOP5-CUST-NAME(WS-INSERT-POS)
           END-STRING.

           MOVE CUST-AREACODE TO WS-TOP5-AREACODE(WS-INSERT-POS).
           MOVE METER-ID TO WS-TOP5-METER-ID(WS-INSERT-POS).
           MOVE WS-CONSUMPTION TO WS-TOP5-CONSUMP(WS-INSERT-POS).
           MOVE WS-BILL-AMOUNT TO WS-TOP5-BILL-AMT(WS-INSERT-POS).

       3000-PRINT-HEADERS  SECTION.

           ADD 1 TO WS-PAGE-NUM.
           MOVE WS-PAGE-NUM TO WS-PAGE-STR.
           MOVE WS-DATE-FMT TO WS-DATE-STR.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           STRING WS-REPORT-TITLE '    DATE: ' WS-DATE-STR
                  '    PAGE: ' WS-PAGE-STR
                  DELIMITED BY SIZE
                  INTO TO01-REPORT-RECORD
           END-STRING.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-HEADER-LINE1 TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-THRESHOLD-LINE TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-HEADER-LINE2 TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-HEADER-LINE3 TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE 8 TO WS-LINE-CNT.

       4000-PRINT-TOP5  SECTION.

           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 5

               IF WS-TOP5-CONSUMP(WS-IDX) > ZERO

                   IF WS-LINE-CNT >= WS-LINES-PER-PAGE
                      PERFORM 3000-PRINT-HEADERS
                   END-IF

                   MOVE WS-IDX TO WS-D-RANK
                   MOVE WS-TOP5-CUST-ID(WS-IDX) TO WS-D-CUSTID
                   MOVE WS-TOP5-CUST-NAME(WS-IDX) TO WS-D-CUSTNAME
                   MOVE WS-TOP5-AREACODE(WS-IDX) TO WS-D-AREACODE
                   MOVE WS-TOP5-METER-ID(WS-IDX) TO WS-D-METERID
                   MOVE WS-TOP5-CONSUMP(WS-IDX) TO WS-D-CONSUMP
                   MOVE WS-TOP5-BILL-AMT(WS-IDX) TO WS-D-AMOUNT

                   IF WS-TOP5-CONSUMP(WS-IDX) > 500
                       MOVE 'HIGH ALERT' TO WS-D-STATUS
                   ELSE
                       IF WS-TOP5-CONSUMP(WS-IDX) > 300
                           MOVE 'MEDIUM' TO WS-D-STATUS
                       ELSE
                           MOVE 'NORMAL' TO WS-D-STATUS
                       END-IF
                   END-IF

                   MOVE WS-DETAIL-LINE TO TO01-REPORT-RECORD.
                   WRITE TO01-REPORT-RECORD.

                   ADD 1 TO WS-LINE-CNT

               END-IF

           END-PERFORM.

       5000-PRINT-SUMMARY  SECTION.

           IF WS-LINE-CNT >= WS-LINES-PER-PAGE - 3
              PERFORM 3000-PRINT-HEADERS
           END-IF.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-HEADER-LINE1 TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-PROCESSED-CNT TO WS-S-PROCESSED.
           MOVE WS-HIGH-CONS-CNT TO WS-S-HIGH.

           MOVE WS-SUMMARY-LINE TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

       9000-TERMINATE   SECTION.

           PERFORM 5000-PRINT-SUMMARY.

           CLOSE TI01-CUST-KSDS,
                 TI01-METER-KSDS,
                 TI01-READ-TXN,
                 TO01-REPORT.

           DISPLAY 'TOP 5 HIGHEST CONSUMING CUSTOMERS REPORT COMPLETE'.
           DISPLAY 'TOTAL PROCESSED: ' WS-PROCESSED-CNT.
           DISPLAY 'HIGH CONSUMERS (>500): ' WS-HIGH-CONS-CNT.
           DISPLAY ' '.
           DISPLAY 'TOP 5 CUSTOMERS:'.

           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 5
               IF WS-TOP5-CONSUMP(WS-IDX) > ZERO
                   DISPLAY 'RANK ' WS-IDX ': ' WS-TOP5-CUST-ID(WS-IDX)
                           ' - ' WS-TOP5-CONSUMP(WS-IDX) ' UNITS'
               END-IF
           END-PERFORM.

           STOP RUN.
