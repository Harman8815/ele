       IDENTIFICATION DIVISION.
       PROGRAM-ID.  BILLPAYDB2.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TI01-PAYMENT     ASSIGN TO PAYMENT
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-PAY-STATUS.

           SELECT TO01-PAY-REPORT  ASSIGN TO PAYRPT
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-RPT-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD TI01-PAYMENT
           RECORD CONTAINS         33   CHARACTERS.

       01 TI01-PAY-RECORD.
          05 PAY-PAYMENT-ID     PIC X(8).
          05 PAY-BILL-ID        PIC X(14).
          05 PAY-AMOUNT         PIC 9(7)V99.
          05 PAY-DATE           PIC X(10).

       FD TO01-PAY-REPORT
           RECORDING MODE          IS F
           RECORD CONTAINS         133  CHARACTERS.

       01 TO01-PAY-RPT-RECORD   PIC X(133).

       WORKING-STORAGE SECTION.

       01 WS-FILE-STATUS-CODES.
          05 WS-PAY-STATUS         PIC X(02).
             88 PAY-IO-STATUS      VALUE '00'.
             88 PAY-EOF            VALUE '10'.
          05 WS-RPT-STATUS         PIC X(02).
             88 RPT-IO-STATUS      VALUE '00'.

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

       01 WS-PAYMENT-TOTALS.
          05 WS-CURR-BILL-ID       PIC X(14) VALUE SPACES.
          05 WS-CURR-AMOUNT        PIC 9(9)V99 VALUE ZERO.
          05 WS-TOTAL-PAID         PIC 9(9)V99 VALUE ZERO.
          05 WS-BALANCE            PIC 9(9)V99 VALUE ZERO.
          05 WS-PAY-CNT            PIC 9(03) VALUE ZERO.

       01 WS-COUNTERS.
          05 WS-BILL-CNT           PIC 9(06) VALUE ZERO.
          05 WS-DUE-CNT            PIC 9(06) VALUE ZERO.
          05 WS-PP-CNT             PIC 9(06) VALUE ZERO.
          05 WS-PAID-CNT           PIC 9(06) VALUE ZERO.
          05 WS-PAY-PROC-CNT       PIC 9(06) VALUE ZERO.
          05 WS-TOTAL-AMOUNT       PIC 9(11)V99 VALUE ZERO.
          05 WS-TOTAL-PAID-ALL     PIC 9(11)V99 VALUE ZERO.
          05 WS-TOTAL-BALANCE      PIC 9(11)V99 VALUE ZERO.

       01 WS-FLAGS.
          05 WS-FIRST-PAY          PIC X VALUE 'Y'.

       01 WS-REPORT-HEADERS.
          05 WS-REPORT-TITLE       PIC X(40) VALUE
             '  ABC ELECTRICITY - BILL PAYMENT STATUS REPORT'.
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
             'BILL ID       CUSTOMER ID   BILL AMOUNT     '.
          05 FILLER                PIC X(40) VALUE
             'PAID AMOUNT   BALANCE DUE    STATUS       '.
          05 FILLER                PIC X(53) VALUE
             'PAYMENTS  '.

       01 WS-HEADER-LINE3.
          05 FILLER                PIC X(40) VALUE
             '------------- -----------   -----------     '.
          05 FILLER                PIC X(40) VALUE
             '-----------   -----------    --------      '.
          05 FILLER                PIC X(53) VALUE
             '--------  '.

       01 WS-DETAIL-LINE.
          05 WS-D-BILLID           PIC X(14).
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-CUSTID           PIC X(14).
          05 FILLER                PIC X(3) VALUE SPACES.
          05 WS-D-BILL-AMT         PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(3) VALUE SPACES.
          05 WS-D-PAID             PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(3) VALUE SPACES.
          05 WS-D-BALANCE          PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-D-STATUS           PIC X(2).
          05 FILLER                PIC X(5) VALUE SPACES.
          05 WS-D-PAY-CNT          PIC Z9.

       01 WS-SUMMARY-LINE1.
          05 FILLER                PIC X(40) VALUE
             '*** PAYMENT STATUS SUMMARY ***           '.
          05 FILLER                PIC X(93) VALUE SPACES.

       01 WS-SUMMARY-LINE2.
          05 FILLER                PIC X(20) VALUE 'DUE (D):        '.
          05 WS-S-DUE              PIC ZZ,ZZZ9.
          05 FILLER                PIC X(20) VALUE '    PARTIAL (PP): '.
          05 WS-S-PP               PIC ZZ,ZZZ9.
          05 FILLER                PIC X(15) VALUE '    PAID (P): '.
          05 WS-S-PAID             PIC ZZ,ZZZ9.

       01 WS-TOTAL-LINE.
          05 FILLER                PIC X(40) VALUE
             '*** GRAND TOTAL ***                      '.
          05 WS-T-BILLS            PIC ZZ,ZZZ9.
          05 FILLER                PIC X(10) VALUE ' BILLS   '.
          05 WS-T-AMOUNT           PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-T-PAID            PIC $$,$$$,$$9.99.
          05 FILLER                PIC X(2) VALUE SPACES.
          05 WS-T-BALANCE          PIC $$,$$$,$$9.99.

      *============================================================
      * DB2 SQL DECLARATION AREA
      *============================================================

      * DB2 BILL TABLE CURSOR - FETCH ALL BILLS
           EXEC SQL
               DECLARE BILL_CURSOR CURSOR FOR
               SELECT BILL_ID, CUST_ID, FIRST_NAME, LAST_NAME,
                      UNITS, AMOUNT, STATUS
               FROM BILL
               ORDER BY BILL_ID
           END-EXEC.

      * DB2 COMMUNICATION AREA
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.

      * HOST VARIABLES FOR DB2 BILL TABLE (112 bytes)
       01 HV-BILL-RECORD.
          05 HV-BILL-ID            PIC X(14).
          05 HV-BILL-CUST-ID       PIC X(14).
          05 HV-BILL-FIRST-NAME    PIC X(15).
          05 HV-BILL-LAST-NAME     PIC X(15).
          05 HV-BILL-UNITS         PIC 9(10).
          05 HV-BILL-AMOUNT        PIC 9(10).
          05 HV-BILL-STATUS        PIC X(4).

      * HOST VARIABLES FOR DB2 BILL_UPDATE TABLE (121 bytes)
       01 HV-BILL-UPD-RECORD.
          05 HV-UPD-BILL-ID        PIC X(14).
          05 HV-UPD-CUST-ID        PIC X(14).
          05 HV-UPD-FIRST-NAME     PIC X(15).
          05 HV-UPD-LAST-NAME      PIC X(15).
          05 HV-UPD-UNITS          PIC 9(10).
          05 HV-UPD-AMOUNT         PIC 9(10).
          05 HV-UPD-PAID           PIC 9(10).
          05 HV-UPD-BALANCE        PIC 9(10).
          05 HV-UPD-STATUS         PIC X(4).

       01 HV-DBNAME               PIC X(8) VALUE 'ELECTDB'.

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

           PERFORM 2150-DB2-CONNECT.

       2100-OPEN-FILES  SECTION.

           OPEN INPUT TI01-PAYMENT.
           IF NOT PAY-IO-STATUS
              DISPLAY 'ERROR OPENING PAYMENT FILE: ' WS-PAY-STATUS
              STOP RUN
           END-IF.

           OPEN OUTPUT TO01-PAY-REPORT.
           IF NOT RPT-IO-STATUS
              DISPLAY 'ERROR OPENING REPORT FILE: ' WS-RPT-STATUS
              STOP RUN
           END-IF.

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

       2000-PROCESS     SECTION.

           PERFORM 3000-PRINT-HEADERS.

           PERFORM 2200-READ-PAYMENT.

      *    OPEN BILL CURSOR BEFORE FETCHING
           EXEC SQL
               OPEN BILL_CURSOR
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR OPENING BILL CURSOR: SQLCODE=' SQLCODE
              STOP RUN
           END-IF.

           PERFORM 2300-READ-BILL.

           PERFORM UNTIL SQLCODE = 100

               ADD 1 TO WS-BILL-CNT
               MOVE HV-BILL-ID TO WS-CURR-BILL-ID
               MOVE HV-BILL-AMOUNT TO WS-CURR-AMOUNT
               MOVE ZERO TO WS-TOTAL-PAID
               MOVE ZERO TO WS-PAY-CNT

               PERFORM 2400-PROCESS-PAYMENTS
                   UNTIL PAY-EOF
                       OR PAY-BILL-ID NOT = WS-CURR-BILL-ID

               COMPUTE WS-BALANCE = WS-CURR-AMOUNT - WS-TOTAL-PAID

               PERFORM 2500-UPDATE-BILL-STATUS

               PERFORM 2600-WRITE-UPDATED-BILL

               PERFORM 2700-PRINT-DETAIL

               PERFORM 2300-READ-BILL

           END-PERFORM.

           PERFORM 4000-PRINT-SUMMARY.

       2200-READ-PAYMENT  SECTION.

           READ TI01-PAYMENT
                AT END  SET PAY-EOF TO TRUE
                NOT AT END  CONTINUE
           END-READ.

       2300-READ-BILL  SECTION.
      *    ------------------------------------------------------------
      *    FETCH BILL ROW FROM DB2 BILL TABLE
      *    ------------------------------------------------------------
           EXEC SQL
               FETCH BILL_CURSOR
               INTO :HV-BILL-ID,
                    :HV-BILL-CUST-ID,
                    :HV-BILL-FIRST-NAME,
                    :HV-BILL-LAST-NAME,
                    :HV-BILL-UNITS,
                    :HV-BILL-AMOUNT,
                    :HV-BILL-STATUS
           END-EXEC.

           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
              DISPLAY 'ERROR FETCHING BILL: SQLCODE=' SQLCODE
           END-IF.

       2400-PROCESS-PAYMENTS  SECTION.

           ADD PAY-AMOUNT TO WS-TOTAL-PAID
           ADD 1 TO WS-PAY-CNT
           ADD 1 TO WS-PAY-PROC-CNT

           PERFORM 2200-READ-PAYMENT.

       2500-UPDATE-BILL-STATUS  SECTION.

           EVALUATE TRUE
               WHEN WS-TOTAL-PAID = ZERO
                   MOVE 'D' TO HV-UPD-STATUS
                   ADD 1 TO WS-DUE-CNT
               WHEN WS-TOTAL-PAID < WS-CURR-AMOUNT
                   MOVE 'PP' TO HV-UPD-STATUS
                   ADD 1 TO WS-PP-CNT
               WHEN OTHER
                   MOVE 'P' TO HV-UPD-STATUS
                   ADD 1 TO WS-PAID-CNT
           END-EVALUATE.

       2600-WRITE-UPDATED-BILL  SECTION.
      *    ------------------------------------------------------------
      *    INSERT UPDATED BILL INTO BILL_UPDATE TABLE
      *    ------------------------------------------------------------
           MOVE HV-BILL-ID TO HV-UPD-BILL-ID
           MOVE HV-BILL-CUST-ID TO HV-UPD-CUST-ID
           MOVE HV-BILL-FIRST-NAME TO HV-UPD-FIRST-NAME
           MOVE HV-BILL-LAST-NAME TO HV-UPD-LAST-NAME
           MOVE HV-BILL-UNITS TO HV-UPD-UNITS
           MOVE HV-BILL-AMOUNT TO HV-UPD-AMOUNT
           MOVE WS-TOTAL-PAID TO HV-UPD-PAID
           MOVE WS-BALANCE TO HV-UPD-BALANCE

           EXEC SQL
               INSERT INTO BILL_UPDATE
               (BILL_ID, CUST_ID, FIRST_NAME, LAST_NAME,
                UNITS, AMOUNT, PAID, BALANCE, STATUS)
               VALUES
               (:HV-UPD-BILL-ID, :HV-UPD-CUST-ID,
                :HV-UPD-FIRST-NAME, :HV-UPD-LAST-NAME,
                :HV-UPD-UNITS, :HV-UPD-AMOUNT, :HV-UPD-PAID,
                :HV-UPD-BALANCE, :HV-UPD-STATUS)
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR INSERTING BILL_UPDATE: SQLCODE=' SQLCODE
           END-IF.

           ADD HV-BILL-AMOUNT TO WS-TOTAL-AMOUNT
           ADD WS-TOTAL-PAID TO WS-TOTAL-PAID-ALL
           ADD WS-BALANCE TO WS-TOTAL-BALANCE.

       2700-PRINT-DETAIL  SECTION.

           IF WS-LINE-CNT >= WS-LINES-PER-PAGE
              PERFORM 3000-PRINT-HEADERS
           END-IF.

           MOVE HV-BILL-ID TO WS-D-BILLID
           MOVE HV-BILL-CUST-ID TO WS-D-CUSTID
           MOVE HV-BILL-AMOUNT TO WS-D-BILL-AMT
           MOVE WS-TOTAL-PAID TO WS-D-PAID
           MOVE WS-BALANCE TO WS-D-BALANCE
           MOVE HV-UPD-STATUS TO WS-D-STATUS
           MOVE WS-PAY-CNT TO WS-D-PAY-CNT

           MOVE WS-DETAIL-LINE TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           ADD 1 TO WS-LINE-CNT.

       3000-PRINT-HEADERS  SECTION.

           ADD 1 TO WS-PAGE-NUM
           MOVE WS-PAGE-NUM TO WS-PAGE-STR
           MOVE WS-DATE-FMT TO WS-DATE-STR.

           MOVE SPACES TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           STRING WS-REPORT-TITLE '    DATE: ' WS-DATE-STR
                  '    PAGE: ' WS-PAGE-STR
                  DELIMITED BY SIZE
                  INTO TO01-PAY-RPT-RECORD
           END-STRING.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-HEADER-LINE1 TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-HEADER-LINE2 TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-HEADER-LINE3 TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE 6 TO WS-LINE-CNT.

       4000-PRINT-SUMMARY  SECTION.

           IF WS-LINE-CNT >= WS-LINES-PER-PAGE - 4
              PERFORM 3000-PRINT-HEADERS
           END-IF.

           MOVE SPACES TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-HEADER-LINE1 TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-SUMMARY-LINE1 TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-DUE-CNT TO WS-S-DUE
           MOVE WS-PP-CNT TO WS-S-PP
           MOVE WS-PAID-CNT TO WS-S-PAID

           MOVE WS-SUMMARY-LINE2 TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE SPACES TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

           MOVE WS-BILL-CNT TO WS-T-BILLS
           MOVE WS-TOTAL-AMOUNT TO WS-T-AMOUNT
           MOVE WS-TOTAL-PAID-ALL TO WS-T-PAID
           MOVE WS-TOTAL-BALANCE TO WS-T-BALANCE

           MOVE WS-TOTAL-LINE TO TO01-PAY-RPT-RECORD.
           WRITE TO01-PAY-RPT-RECORD.

       9000-TERMINATE   SECTION.

      *    CLOSE DB2 CURSOR
           EXEC SQL
               CLOSE BILL_CURSOR
           END-EXEC.

      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE TI01-PAYMENT,
                 TO01-PAY-REPORT.

           DISPLAY 'BILL PAYMENT STATUS PROCESSING COMPLETE'.
           DISPLAY 'TOTAL BILLS: ' WS-BILL-CNT.
           DISPLAY 'DUE: ' WS-DUE-CNT.
           DISPLAY 'PARTIALLY PAID: ' WS-PP-CNT.
           DISPLAY 'FULLY PAID: ' WS-PAID-CNT.
           DISPLAY 'PAYMENTS PROCESSED: ' WS-PAY-PROC-CNT.
           DISPLAY 'TOTAL BILL AMOUNT: ' WS-TOTAL-AMOUNT.
           DISPLAY 'TOTAL PAID: ' WS-TOTAL-PAID-ALL.
           DISPLAY 'TOTAL BALANCE: ' WS-TOTAL-BALANCE.

           STOP RUN.
