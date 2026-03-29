IDENTIFICATION DIVISION.
       PROGRAM-ID.  arearpt.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT MI01-METER-KSDS   ASSIGN TO MTRKSDS
           ORGANIZATION           IS INDEXED
           ACCESS MODE            IS SEQUENTIAL
           RECORD KEY             IS MTR-CUST-ID
           FILE STATUS            IS WS-MTR-STATUS.

           SELECT MI01-CUSTOMER-KSDS ASSIGN TO CUSTKSDS
           ORGANIZATION           IS INDEXED
           ACCESS MODE            IS RANDOM
           RECORD KEY             IS CUST-KEY
           FILE STATUS            IS WS-CUST-STATUS.

           SELECT TO01-AREA-RPT    ASSIGN TO AREARPT
           ORGANIZATION           IS SEQUENTIAL
           ACCESS MODE            IS SEQUENTIAL
           FILE STATUS            IS WS-RPT-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD MI01-METER-KSDS
           RECORD CONTAINS         38  CHARACTERS.
       01 MI01-METER-RECORD.
          05 MTR-ID           PIC X(14).
          05 MTR-CUST-ID      PIC X(12).
          05 MTR-PREV-READ    PIC 9(06).
          05 MTR-CURR-READ    PIC 9(06).

       FD MI01-CUSTOMER-KSDS
           RECORD CONTAINS         83  CHARACTERS.
       01 MI01-CUSTOMER-RECORD.
          05 CUST-KEY         PIC X(12).
          05 CUST-FIRST-NAME  PIC X(10).
          05 CUST-LAST-NAME  PIC X(10).
          05 CUST-AREA-CODE  PIC X(6).
          05 CUST-SPACE      PIC X.
          05 CUST-ADDRESS     PIC X(29).
          05 CUST-CITY        PIC X(10).
          05 CUST-UNITS       PIC X(5).

       FD TO01-AREA-RPT
           RECORDING MODE          IS F
           RECORD CONTAINS         139 CHARACTERS.

       01 TO01-AREA-RPT-RECORD PIC X(139).

       WORKING-STORAGE SECTION.

       01 WS-FILE-STATUS-CODES.
          05 WS-MTR-STATUS       PIC X(02).
             88 MTR-IO-STATUS    VALUE '00'.
             88 MTR-EOF          VALUE '10'.
          05 WS-CUST-STATUS      PIC X(02).
             88 CUST-IO-STATUS   VALUE '00'.
             88 CUST-NOT-FOUND   VALUE '23'.
          05 WS-RPT-STATUS       PIC X(02).
             88 RPT-IO-STATUS    VALUE '00'.

       01 WS-DATE-VARIABLES.
          05 WS-DATE               PIC 9(08).
          05 WS-DATE-FORMAT.
             10 WS-CC              PIC 99.
             10 WS-YY              PIC 99.
             10 WS-MM              PIC 99.
             10 WS-DD              PIC 99.
          05 WS-REPORT-DATE        PIC X(10).

       01 WS-CALC-VARIABLES.
          05 WS-PREV-READ-NUM      PIC 9(06) VALUE 0.
          05 WS-CURR-READ-NUM      PIC 9(06) VALUE 0.
          05 WS-UNITS-CONSUMED     PIC 9(06) VALUE 0.

       01 WS-REPORT-VARIABLES.
          05 WS-PAGE-NUM           PIC 9(03) VALUE 1.
          05 WS-LINE-COUNT         PIC 9(03) VALUE 0.
          05 WS-MAX-LINES          PIC 9(03) VALUE 15.

       01 WS-COUNTERS.
          05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
          05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-TOTAL-CUSTOMERS    PIC 9(04) VALUE ZEROS.
          05 WS-TOTAL-UNITS        PIC 9(08) VALUE ZEROS.

       01 WS-AREA-STORAGE.
          05 WS-AREA-TABLE.
             10 WS-AREA-RECORD OCCURS 100 TIMES
                                 INDEXED BY WS-AREA-IDX.
                15 WS-A-AREA-CODE        PIC X(6).
                15 WS-A-CUSTOMER-COUNT   PIC 9(04) VALUE ZEROS.
                15 WS-A-TOTAL-UNITS      PIC 9(08) VALUE ZEROS.
          05 WS-AREA-COUNT         PIC 9(04) VALUE ZEROS.
          05 WS-MAX-AREAS          PIC 9(04) VALUE 100.

       01 WS-TEMP-VARIABLES.
          05 WS-TEMP-AREA-CODE     PIC X(6).
          05 WS-AREA-FOUND         PIC X(1) VALUE 'N'.
             88 AREA-FOUND         VALUE 'Y'.
             88 AREA-NOT-FOUND     VALUE 'N'.
          05 WS-LOOP-CTR           PIC 9(04).
          05 WS-SORT-LOOP-CTR1     PIC 9(04).
          05 WS-SORT-LOOP-CTR2     PIC 9(04).
          05 WS-TEMP-AREA-RECORD.
             10 WS-T-AREA-CODE        PIC X(6).
             10 WS-T-CUSTOMER-COUNT   PIC 9(04).
             10 WS-T-TOTAL-UNITS      PIC 9(08).

       01 WS-REPORT-HEADER1.
          05 FILLER               PIC X(35) VALUE SPACES.
          05 FILLER               PIC X(40) VALUE 'AREA WISE CONSUMPTION REPORT'.
          05 FILLER               PIC X(44) VALUE SPACES.
          05 FILLER               PIC X(5)  VALUE 'PAGE'.
          05 WS-RPT-PAGE-NUM      PIC ZZ9.

       01 WS-REPORT-HEADER2.
          05 FILLER               PIC X(35) VALUE SPACES.
          05 FILLER               PIC X(40) VALUE '----------------------------'.
          05 FILLER               PIC X(54) VALUE SPACES.

       01 WS-REPORT-HEADER3.
          05 FILLER               PIC X(5)  VALUE SPACES.
          05 FILLER               PIC X(4)  VALUE 'AREA'.
          05 FILLER               PIC X(8)  VALUE SPACES.
          05 FILLER               PIC X(15) VALUE 'TOTAL CUSTOMERS'.
          05 FILLER               PIC X(8)  VALUE SPACES.
          05 FILLER               PIC X(10) VALUE 'TOTAL UNITS'.
          05 FILLER               PIC X(89) VALUE SPACES.

       01 WS-REPORT-HEADER4.
          05 FILLER               PIC X(5)  VALUE SPACES.
          05 FILLER               PIC X(4)  VALUE '----'.
          05 FILLER               PIC X(8)  VALUE SPACES.
          05 FILLER               PIC X(15) VALUE '---------------'.
          05 FILLER               PIC X(8)  VALUE SPACES.
          05 FILLER               PIC X(10) VALUE '-----------'.
          05 FILLER               PIC X(89) VALUE SPACES.

       01 WS-REPORT-DETAIL.
          05 FILLER               PIC X(5)  VALUE SPACES.
          05 WS-RPT-AREA-CODE     PIC X(6).
          05 FILLER               PIC X(6)  VALUE SPACES.
          05 WS-RPT-CUST-COUNT    PIC Z,ZZ9.
          05 FILLER               PIC X(8)  VALUE SPACES.
          05 WS-RPT-TOTAL-UNITS   PIC ZZZ,ZZZ,ZZ9.
          05 FILLER               PIC X(89) VALUE SPACES.

       01 WS-REPORT-TOTAL.
          05 FILLER               PIC X(5)  VALUE SPACES.
          05 FILLER               PIC X(4)  VALUE 'TOTAL'.
          05 FILLER               PIC X(6)  VALUE SPACES.
          05 WS-RPT-TOTAL-CUST    PIC Z,ZZ9.
          05 FILLER               PIC X(8)  VALUE SPACES.
          05 WS-RPT-TOTAL-UNITS   PIC ZZZ,ZZZ,ZZ9.
          05 FILLER               PIC X(89) VALUE SPACES.

       01 WS-REPORT-FOOTER.
          05 FILLER               PIC X(120) VALUE SPACES.
          05 FILLER               PIC X(5)   VALUE 'PAGE:'.
          05 WS-FTR-PAGE          PIC ZZ9.

       PROCEDURE DIVISION.
       0000-MAIN-LINE   SECTION.

           PERFORM 1000-INITIALIZE.
           PERFORM 2000-PROCESS.
           PERFORM 9000-TERMINATE.

       1000-INITIALIZE  SECTION.

           DISPLAY '----------------------------------------'
           DISPLAY 'AREARPT EXECUTION BEGINS HERE ........'
           DISPLAY '  AREA WISE CONSUMPTION REPORT PROGRAM   '
           DISPLAY '----------------------------------------'

           ACCEPT WS-DATE FROM DATE YYYYMMDD.
           MOVE WS-DD TO WS-REPORT-DATE(1:2)
           MOVE '/'   TO WS-REPORT-DATE(3:1)
           MOVE WS-MM TO WS-REPORT-DATE(4:2)
           MOVE '/'   TO WS-REPORT-DATE(6:1)
           MOVE WS-YY TO WS-REPORT-DATE(7:2).

           INITIALIZE WS-AREA-TABLE.
           MOVE ZEROS TO WS-AREA-COUNT.

       2000-PROCESS     SECTION.

           PERFORM 2100-OPEN-FILES.
           PERFORM 2200-PROCESS-METER-RECORDS.
           PERFORM 2300-SORT-AREA-REPORT.
           PERFORM 2400-WRITE-AREA-REPORT.
           PERFORM 2500-CLOSE-FILES.

       2100-OPEN-FILES SECTION.

           OPEN INPUT MI01-METER-KSDS.
           IF NOT MTR-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING METER MASTER KSDS         '
              DISPLAY 'FILE  STATUS ', ' ',    WS-MTR-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           OPEN INPUT MI01-CUSTOMER-KSDS.
           IF NOT CUST-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING CUSTOMER MASTER KSDS      '
              DISPLAY 'FILE  STATUS ', ' ',    WS-CUST-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           OPEN OUTPUT TO01-AREA-RPT.
           IF NOT RPT-IO-STATUS
              DISPLAY '----------------------------------------'
              DISPLAY 'ERROR OPENING AREA REPORT FILE          '
              DISPLAY 'FILE  STATUS ', ' ',    WS-RPT-STATUS
              DISPLAY '----------------------------------------'
              STOP RUN
           END-IF.

           DISPLAY '----------------------------------------'
           DISPLAY 'METER KSDS    OPENED ..............'
           DISPLAY 'CUSTOMER KSDS OPENED ..............'
           DISPLAY 'AREA RPT      OPENED .............'
           DISPLAY '----------------------------------------'.

       2200-PROCESS-METER-RECORDS  SECTION.
           PERFORM 2210-READ-METER-KSDS UNTIL MTR-EOF.

       2210-READ-METER-KSDS  SECTION.

           READ MI01-METER-KSDS
                AT END  SET MTR-EOF TO TRUE
                DISPLAY '----------------------------------------'
                DISPLAY 'NO MORE METER RECORDS FOR AREA REPORT ---'
                DISPLAY '----------------------------------------'

                NOT AT END  ADD 1  TO WS-READ-CTR
                            PERFORM 2220-READ-CUSTOMER

           END-READ.

       2220-READ-CUSTOMER SECTION.

           MOVE MTR-CUST-ID TO CUST-KEY.

           READ MI01-CUSTOMER-KSDS
                INVALID KEY
                   DISPLAY 'CUSTOMER NOT FOUND: ' CUST-KEY
                   ADD 1 TO WS-ERROR-CTR
                NOT INVALID KEY
                   PERFORM 2230-CALCULATE-UNITS
           END-READ.

       2230-CALCULATE-UNITS SECTION.

           COMPUTE WS-PREV-READ-NUM = MTR-PREV-READ
           COMPUTE WS-CURR-READ-NUM = MTR-CURR-READ

           IF WS-CURR-READ-NUM < WS-PREV-READ-NUM
              DISPLAY 'ERROR: CURR < PREV FOR CUST ' CUST-KEY
              ADD 1 TO WS-ERROR-CTR
           ELSE
              COMPUTE WS-UNITS-CONSUMED =
                      WS-CURR-READ-NUM - WS-PREV-READ-NUM

              PERFORM 2240-UPDATE-AREA-DATA
           END-IF.

       2240-UPDATE-AREA-DATA SECTION.

           MOVE CUST-AREA-CODE TO WS-TEMP-AREA-CODE.
           SET AREA-NOT-FOUND TO TRUE.

           IF WS-AREA-COUNT = ZEROS
              PERFORM 2250-ADD-NEW-AREA
           ELSE
              PERFORM 2260-FIND-AREA
              IF AREA-NOT-FOUND
                 PERFORM 2250-ADD-NEW-AREA
              ELSE
                 PERFORM 2270-UPDATE-EXISTING-AREA
              END-IF
           END-IF.

           ADD 1 TO WS-TOTAL-CUSTOMERS.
           ADD WS-UNITS-CONSUMED TO WS-TOTAL-UNITS.

       2250-ADD-NEW-AREA SECTION.

           IF WS-AREA-COUNT >= WS-MAX-AREAS
              DISPLAY 'ERROR: AREA STORAGE FULL - MAX ' WS-MAX-AREAS
              ADD 1 TO WS-ERROR-CTR
           ELSE
              COMPUTE WS-AREA-COUNT = WS-AREA-COUNT + 1
              SET WS-AREA-IDX TO WS-AREA-COUNT

              MOVE WS-TEMP-AREA-CODE TO WS-A-AREA-CODE(WS-AREA-IDX)
              MOVE 1 TO WS-A-CUSTOMER-COUNT(WS-AREA-IDX)
              MOVE WS-UNITS-CONSUMED TO WS-A-TOTAL-UNITS(WS-AREA-IDX)
           END-IF.

       2260-FIND-AREA SECTION.

           PERFORM VARYING WS-LOOP-CTR FROM 1 BY 1
                     UNTIL WS-LOOP-CTR > WS-AREA-COUNT
             OR AREA-FOUND
              SET WS-AREA-IDX TO WS-LOOP-CTR
              IF WS-A-AREA-CODE(WS-AREA-IDX) = WS-TEMP-AREA-CODE
                 SET AREA-FOUND TO TRUE
              END-IF
           END-PERFORM.

       2270-UPDATE-EXISTING-AREA SECTION.

           ADD 1 TO WS-A-CUSTOMER-COUNT(WS-AREA-IDX)
           ADD WS-UNITS-CONSUMED TO WS-A-TOTAL-UNITS(WS-AREA-IDX).

       2300-SORT-AREA-REPORT SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY 'SORTING ' WS-AREA-COUNT ' AREAS BY TOTAL UNITS ......'
           DISPLAY '----------------------------------------'

           PERFORM VARYING WS-SORT-LOOP-CTR1 FROM 1 BY 1
                     UNTIL WS-SORT-LOOP-CTR1 >= WS-AREA-COUNT
              PERFORM VARYING WS-SORT-LOOP-CTR2 FROM WS-SORT-LOOP-CTR1 + 1 BY 1
                        UNTIL WS-SORT-LOOP-CTR2 > WS-AREA-COUNT
                 SET WS-AREA-IDX TO WS-SORT-LOOP-CTR1
                 IF WS-A-TOTAL-UNITS(WS-SORT-LOOP-CTR1) < 
                    WS-A-TOTAL-UNITS(WS-SORT-LOOP-CTR2)
                    
                    MOVE WS-A-AREA-CODE(WS-SORT-LOOP-CTR1) 
                        TO WS-T-AREA-CODE
                    MOVE WS-A-CUSTOMER-COUNT(WS-SORT-LOOP-CTR1) 
                        TO WS-T-CUSTOMER-COUNT
                    MOVE WS-A-TOTAL-UNITS(WS-SORT-LOOP-CTR1) 
                        TO WS-T-TOTAL-UNITS
                    
                    MOVE WS-A-AREA-CODE(WS-SORT-LOOP-CTR2) 
                        TO WS-A-AREA-CODE(WS-SORT-LOOP-CTR1)
                    MOVE WS-A-CUSTOMER-COUNT(WS-SORT-LOOP-CTR2) 
                        TO WS-A-CUSTOMER-COUNT(WS-SORT-LOOP-CTR1)
                    MOVE WS-A-TOTAL-UNITS(WS-SORT-LOOP-CTR2) 
                        TO WS-A-TOTAL-UNITS(WS-SORT-LOOP-CTR1)
                    
                    MOVE WS-T-AREA-CODE 
                        TO WS-A-AREA-CODE(WS-SORT-LOOP-CTR2)
                    MOVE WS-T-CUSTOMER-COUNT 
                        TO WS-A-CUSTOMER-COUNT(WS-SORT-LOOP-CTR2)
                    MOVE WS-T-TOTAL-UNITS 
                        TO WS-A-TOTAL-UNITS(WS-SORT-LOOP-CTR2)
                 END-IF
              END-PERFORM
           END-PERFORM.

       2400-WRITE-AREA-REPORT SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY 'WRITING AREA WISE CONSUMPTION REPORT .....'
           DISPLAY '----------------------------------------'

           PERFORM 2750-WRITE-PAGE-HEADERS

           PERFORM VARYING WS-LOOP-CTR FROM 1 BY 1
                     UNTIL WS-LOOP-CTR > WS-AREA-COUNT
              SET WS-AREA-IDX TO WS-LOOP-CTR
              PERFORM 2410-WRITE-AREA-RECORD
           END-PERFORM

           PERFORM 2800-WRITE-REPORT-TOTALS
           PERFORM 2760-WRITE-FOOTER.

       2410-WRITE-AREA-RECORD SECTION.

           IF WS-LINE-COUNT >= WS-MAX-LINES
               PERFORM 2760-WRITE-FOOTER
               PERFORM 2750-WRITE-PAGE-HEADERS
           END-IF

           MOVE WS-A-AREA-CODE(WS-AREA-IDX) TO WS-RPT-AREA-CODE
           MOVE WS-A-CUSTOMER-COUNT(WS-AREA-IDX) TO WS-RPT-CUST-COUNT
           MOVE WS-A-TOTAL-UNITS(WS-AREA-IDX) TO WS-RPT-TOTAL-UNITS

           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-DETAIL

           ADD 1 TO WS-LINE-COUNT
           ADD 1 TO WS-WRITE-CTR.

       2500-CLOSE-FILES  SECTION.

           CLOSE MI01-METER-KSDS,
                 MI01-CUSTOMER-KSDS,
                 TO01-AREA-RPT.

           DISPLAY '----------------------------------------'
           DISPLAY 'METER KSDS    CLOSED ........................'
           DISPLAY 'CUSTOMER KSDS CLOSED ........................'
           DISPLAY 'AREA RPT      CLOSED ........................'
           DISPLAY '----------------------------------------'.

       2750-WRITE-PAGE-HEADERS SECTION.

           MOVE WS-PAGE-NUM TO WS-RPT-PAGE-NUM

           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-HEADER1
           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-HEADER2
           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-HEADER3
           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-HEADER4

           MOVE 4 TO WS-LINE-COUNT

           ADD 1 TO WS-PAGE-NUM.

       2760-WRITE-FOOTER SECTION.

           MOVE WS-PAGE-NUM TO WS-FTR-PAGE
           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-FOOTER.

       2800-WRITE-REPORT-TOTALS SECTION.

           MOVE WS-TOTAL-CUSTOMERS TO WS-RPT-TOTAL-CUST
           MOVE WS-TOTAL-UNITS TO WS-RPT-TOTAL-UNITS
           WRITE TO01-AREA-RPT-RECORD FROM WS-REPORT-TOTAL.

       9000-TERMINATE   SECTION.

           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' AREAS PROCESSED         ',  WS-AREA-COUNT
           DISPLAY ' TOTAL CUSTOMERS         ',  WS-TOTAL-CUSTOMERS
           DISPLAY ' TOTAL UNITS             ',  WS-TOTAL-UNITS
           DISPLAY ' ERRORS                  ',  WS-ERROR-CTR
           DISPLAY '----------------------------------------'

           STOP RUN.
