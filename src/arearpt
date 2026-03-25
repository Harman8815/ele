       IDENTIFICATION DIVISION.
       PROGRAM-ID.  AREARPT.

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

           SELECT TO01-REPORT      ASSIGN TO REPORTDD
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

       01 WS-AREA-TOTALS.
          05 WS-CURR-AREACODE      PIC X(7) VALUE SPACES.
          05 WS-AREA-CUST-CNT      PIC 9(05) VALUE ZERO.
          05 WS-AREA-UNITS         PIC 9(09)V99 VALUE ZERO.
          05 WS-AREA-AMOUNT        PIC 9(09)V99 VALUE ZERO.

       01 WS-GRAND-TOTALS.
          05 WS-TOTAL-CUST         PIC 9(06) VALUE ZERO.
          05 WS-TOTAL-UNITS        PIC 9(11)V99 VALUE ZERO.
          05 WS-TOTAL-AMOUNT       PIC 9(11)V99 VALUE ZERO.

       01 WS-CALCULATION-VARS.
          05 WS-CONSUMPTION        PIC 9(07)V99 VALUE ZERO.
          05 WS-UNIT-RATE          PIC 9(03)V99 VALUE 5.50.
          05 WS-BILL-AMOUNT        PIC 9(09)V99 VALUE ZERO.

       01 WS-FLAGS.
          05 WS-FIRST-RECORD       PIC X VALUE 'Y'.
          05 WS-AREA-CHANGED       PIC X VALUE 'N'.

       01 WS-COUNTERS.
          05 WS-READ-CTR           PIC 9(06) VALUE ZEROS.
          05 WS-WRITE-CTR          PIC 9(06) VALUE ZEROS.

       01 WS-REPORT-HEADERS.
          05 WS-REPORT-TITLE       PIC X(40) VALUE
             '     ABC ELECTRICITY - AREA WISE CONSUMPTION REPORT'.
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
             'AREA CODE   CUSTOMER ID  CUSTOMER NAME     '.
          05 FILLER                PIC X(40) VALUE
             'METER ID      CONSUMPTION    BILL AMOUNT   '.
          05 FILLER                PIC X(53) VALUE
             'STATUS      '.

       01 WS-HEADER-LINE3.
          05 FILLER                PIC X(40) VALUE
             '---------   -----------  -------------     '.
          05 FILLER                PIC X(40) VALUE
             '--------      ---------    -----------   '.
          05 FILLER                PIC X(53) VALUE
             '--------    '.

       01 WS-DETAIL-LINE.
          05 WS-D-AREACODE         PIC X(7).
          05 FILLER                PIC X(4) VALUE SPACES.
          05 WS-D-CUSTID           PIC X(9).
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-CUSTNAME         PIC X(20).
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-METERID          PIC X(14).
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-CONSUMPTION      PIC ZZ,ZZ9.99.
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-AMOUNT           PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-STATUS           PIC X(10).

       01 WS-TOTAL-LINE.
          05 FILLER                PIC X(40) VALUE
             '*** AREA TOTAL ***                     '.
          05 WS-T-CUST-CNT         PIC ZZ,ZZ9.
          05 FILLER                PIC X(10) VALUE ' CUSTOMERS'.
          05 FILLER                PIC X(10) VALUE SPACES.
          05 WS-T-UNITS            PIC Z,ZZZ,ZZ9.99.
          05 FILLER                PIC X(5) VALUE SPACES.
          05 WS-T-AMOUNT           PIC $$$,$$$,$$9.99.

       01 WS-GRAND-TOTAL-LINE.
          05 FILLER                PIC X(40) VALUE
             '*** GRAND TOTAL ***                    '.
          05 WS-GT-CUST-CNT        PIC ZZ,ZZZ9.
          05 FILLER                PIC X(10) VALUE ' CUSTOMERS'.
          05 FILLER                PIC X(10) VALUE SPACES.
          05 WS-GT-UNITS           PIC ZZ,ZZZ,ZZ9.99.
          05 FILLER                PIC X(5) VALUE SPACES.
          05 WS-GT-AMOUNT          PIC $$$,$$$,$$9.99.

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

       2000-PROCESS     SECTION.

           PERFORM 2200-READ-CUSTOMER.

           PERFORM UNTIL CUST-EOF

               IF WS-FIRST-RECORD = 'Y'
                  MOVE CUST-AREACODE TO WS-CURR-AREACODE
                  MOVE 'N' TO WS-FIRST-RECORD
                  PERFORM 3000-PRINT-HEADERS
               END-IF

               IF CUST-AREACODE NOT = WS-CURR-AREACODE
                  PERFORM 4000-PRINT-AREA-TOTAL
                  MOVE CUST-AREACODE TO WS-CURR-AREACODE
                  PERFORM 3000-PRINT-HEADERS
               END-IF

               PERFORM 2300-PROCESS-CUSTOMER

               PERFORM 2200-READ-CUSTOMER

           END-PERFORM.

           IF WS-AREA-CUST-CNT > 0
              PERFORM 4000-PRINT-AREA-TOTAL
           END-IF.

           PERFORM 5000-PRINT-GRAND-TOTAL.

       2200-READ-CUSTOMER  SECTION.

           READ TI01-CUST-KSDS
                AT END  SET CUST-EOF TO TRUE
                NOT AT END  ADD 1  TO WS-READ-CTR
           END-READ.

       2300-PROCESS-CUSTOMER  SECTION.

           MOVE CUST-AREACODE TO METER-ID.

           READ TI01-METER-KSDS
                KEY IS METER-ID
                INVALID KEY
                    MOVE 'NO METER ' TO WS-D-STATUS
                NOT INVALID KEY
                    PERFORM 2400-PROCESS-METER
           END-READ.

       2400-PROCESS-METER  SECTION.

           PERFORM 2500-FIND-READING.

       2500-FIND-READING  SECTION.

           PERFORM 2600-READ-TXN UNTIL TXN-EOF
                     OR TXN-METER-ID = METER-ID.

           IF TXN-METER-ID = METER-ID
              COMPUTE WS-CONSUMPTION = TXN-CURR-READ - TXN-PREV-READ
              COMPUTE WS-BILL-AMOUNT = WS-CONSUMPTION * WS-UNIT-RATE

              ADD 1 TO WS-AREA-CUST-CNT
              ADD WS-CONSUMPTION TO WS-AREA-UNITS
              ADD WS-BILL-AMOUNT TO WS-AREA-AMOUNT

              ADD 1 TO WS-TOTAL-CUST
              ADD WS-CONSUMPTION TO WS-TOTAL-UNITS
              ADD WS-BILL-AMOUNT TO WS-TOTAL-AMOUNT

              PERFORM 3100-PRINT-DETAIL
           ELSE
              MOVE 'NO READING' TO WS-D-STATUS
              PERFORM 3100-PRINT-DETAIL
           END-IF.

       2600-READ-TXN  SECTION.

           READ TI01-READ-TXN
                AT END  SET TXN-EOF TO TRUE
           END-READ.

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

           MOVE WS-HEADER-LINE2 TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-HEADER-LINE3 TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE 6 TO WS-LINE-CNT.

       3100-PRINT-DETAIL  SECTION.

           IF WS-LINE-CNT >= WS-LINES-PER-PAGE
              PERFORM 3000-PRINT-HEADERS
           END-IF.

           MOVE CUST-AREACODE TO WS-D-AREACODE.
           MOVE CUST-ID TO WS-D-CUSTID.

           STRING CUST-FNAME DELIMITED BY SPACE
                  ' ' DELIMITED BY SIZE
                  CUST-LNAME DELIMITED BY SPACE
                  INTO WS-D-CUSTNAME
           END-STRING.

           IF TXN-METER-ID = METER-ID
              MOVE METER-ID TO WS-D-METERID
              MOVE WS-CONSUMPTION TO WS-D-CONSUMPTION
              MOVE WS-BILL-AMOUNT TO WS-D-AMOUNT
              MOVE 'BILLED' TO WS-D-STATUS
           ELSE
              MOVE 'N/A' TO WS-D-METERID
              MOVE ZERO TO WS-D-CONSUMPTION
              MOVE ZERO TO WS-D-AMOUNT
              MOVE 'NO READING' TO WS-D-STATUS
           END-IF.

           MOVE WS-DETAIL-LINE TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           ADD 1 TO WS-LINE-CNT.
           ADD 1 TO WS-WRITE-CTR.

       4000-PRINT-AREA-TOTAL  SECTION.

           IF WS-LINE-CNT >= WS-LINES-PER-PAGE - 2
              PERFORM 3000-PRINT-HEADERS
           END-IF.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.
           ADD 1 TO WS-LINE-CNT.

           MOVE WS-AREA-CUST-CNT TO WS-T-CUST-CNT.
           MOVE WS-AREA-UNITS TO WS-T-UNITS.
           MOVE WS-AREA-AMOUNT TO WS-T-AMOUNT.

           MOVE WS-TOTAL-LINE TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           ADD 1 TO WS-LINE-CNT.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.
           ADD 1 TO WS-LINE-CNT.

           MOVE ZERO TO WS-AREA-CUST-CNT.
           MOVE ZERO TO WS-AREA-UNITS.
           MOVE ZERO TO WS-AREA-AMOUNT.

       5000-PRINT-GRAND-TOTAL  SECTION.

           IF WS-LINE-CNT >= WS-LINES-PER-PAGE - 2
              PERFORM 3000-PRINT-HEADERS
           END-IF.

           MOVE SPACES TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

           MOVE WS-TOTAL-CUST TO WS-GT-CUST-CNT.
           MOVE WS-TOTAL-UNITS TO WS-GT-UNITS.
           MOVE WS-TOTAL-AMOUNT TO WS-GT-AMOUNT.

           MOVE WS-GRAND-TOTAL-LINE TO TO01-REPORT-RECORD.
           WRITE TO01-REPORT-RECORD.

       9000-TERMINATE   SECTION.

           CLOSE TI01-CUST-KSDS,
                 TI01-METER-KSDS,
                 TI01-READ-TXN,
                 TO01-REPORT.

           DISPLAY 'AREA WISE CONSUMPTION REPORT COMPLETE'.
           DISPLAY 'TOTAL CUSTOMERS: ' WS-TOTAL-CUST.
           DISPLAY 'TOTAL UNITS: ' WS-TOTAL-UNITS.
           DISPLAY 'TOTAL AMOUNT: ' WS-TOTAL-AMOUNT.

           STOP RUN.
