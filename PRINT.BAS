1 REM AGONLIGHT PRINTING TOOL
2 REM WRITTEN BY ANDREAS HENNINGSSON
3 REM REQUIRE A ESP8266 WITH THE ZiMODEM FIRMWARE 
4 REM AND A NETWORK CONNECTED PRINTER
5 REM ---------------------------------------------------------
10 REM SERIAL SEND EXAMPLE
20 REM RICHARD TURNNIDGE 2023
21 REM This version is for 16-bit basic but you could adapt
22 REM Check if we are running in 24-bit BASIC
24 :
25 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
30 :
31 REM ---------------------------------------------------------
32 REM This is the user assembly code 
33 REM ---------------------------------------------------------
36 :
38 REM allocate plenty of memory spaces for the three machine code commands
39 :
40 DIM openuart% 64
50 DIM closeuart% 64
60 DIM senduart% 64
70 :
90 REM This routine is for opening the uart
100 FOR I%=0 TO 3 STEP 3
110   P%=openuart%
120   [
130   OPT I%
140   :
150   LD IX, uartstruct ; Address of the uart struct
160   ld a, &15
170   RST &08 ; mos_uopen
180   RET
190   .uartstruct
200   DEFB &80 ; LONG (3 bytes) to store baud rate (9600)
210   DEFB &25
220   DEFB &00
230   DEFB 8 ; data bits
240   DEFB 1 ; stop bits
250   DEFB 0 ; parity bits
260   DEFB 0 ; flow control
270   DEFB 0 ; interrupt bits
280   ]
290 NEXT
1000 :
1010 REM This routine is to close the uart
1080 FOR I%=0 TO 3 STEP 3
1090   P%=closeuart%
1100   [
1110   OPT I%
1120   :
1210   ld a, &16
1220   RST &08 ; mos_uclose
1330   RET
1370   ]
1480 NEXT
1500 :
2000 REM This routine is to send uart data
2080 FOR I%=0 TO 3 STEP 3
2090   P%=senduart%
2100   [
2110   OPT I%
2120   :
2210   ld c, 65 ; char to send is stored here
2215   ld a, &18
2220   RST &08 ; mos_uputc
2330   RET
2370   ]
2480 NEXT
2999 :
3000 REM ---------------------------------------------------------
3001 REM This is the user Basic program
3002 REM ---------------------------------------------------------
3003 :
3005 CLS : REM Just to make screen clear
3010 REM ---------------------------------------------------------
3011 REM VARIABLES
3012 REM ---------------------------------------------------------
3040 A = senduart% +1 : REM this is second byte into the routine, store char to send here
3050 CALL openuart%
3051 IP$="192.168.0.?" : REM IP ADDRESS TO PRINTER
3052 PORT$="631" : REM DEFAULT VALUE
3053 PATH$="/ipp/printer" : REM DEFAULT VALUE
3054 FMT$="A" : REM OUTPUT FORMAT
3055 FILEPATH$ = "<Configure>" : REM PATH TO THE FILE TO PRINT
3056 VERBOSE = 0 : REM SET TO 1 TO PRINT MORE DEBUG INFORMATION
3057 SELECTION$ = "" : REM MENU SELECTIONS
3058 filename$ = "printer.ini"  : REM CONFIGURATION FILE

3110 REM ---------------------------------------------------------
3111 REM PROGRAM START HERE
3112 REM ---------------------------------------------------------
3120 PROC_InitConfigFile(filename$)
3130 PROC_LoadConfigFile(filename$)

3500 PROC_PrintMenu
3510 INPUT "Select option: ", SELECTION$
3520 IF SELECTION$="1" THEN PROC_ChangePrinterIP
3530 IF SELECTION$="2" THEN PROC_ChangePrinterPort
3540 IF SELECTION$="3" THEN PROC_ChangePrinterPath
3550 IF SELECTION$="4" THEN PROC_ChangeOutputFormat
3560 IF SELECTION$="5" THEN PROC_ChangeFileToPrint
3570 IF SELECTION$="6" THEN PROC_ChangeVerbose
3575 IF SELECTION$="7" THEN PROC_SaveConfig(filename$, FMT$, IP$, PORT$, PATH$)
3580 IF SELECTION$="10" THEN PROC_PrintFile
3590 GOTO 3500 
3600 END

4000 DEF PROC_PrintMenu
4001 CLS
4002 PRINT "----------------------------------------------------------"
4003 PRINT "AgonLight printing tool version 1"
4004 PRINT "----------------------------------------------------------"
4005 PRINT : PRINT "Configuration" 
4006 PRINT : PRINT "  Printer IP      : " + IP$ 
4007 PRINT : PRINT "  Port            : " + PORT$ 
4008 PRINT : PRINT "  Path            : " + PATH$ 
4009 PRINT : PRINT "  Format          : " + FMT$ 
4010 PRINT : PRINT "  File to print   : " + FILEPATH$ 
4011 PRINT : PRINT "  Verbose         : " ;:IF VERBOSE=0 THEN PRINT "FALSE" ELSE PRINT "TRUE" 
4012 PRINT : PRINT "----------------------------------------------------------" 
4013 PRINT : PRINT "Options:" 
4014 PRINT : PRINT "   1. Change printer IP" 
4015 PRINT : PRINT "   2. Change printer port" 
4016 PRINT : PRINT "   3. Change printer path" 
4017 PRINT : PRINT "   4. Change format" 
4018 PRINT : PRINT "   5. Change filepath" 
4019 PRINT : PRINT "   6. Change verbose mode" 
4020 PRINT : PRINT "   7. Save configuration" 
4021 PRINT : PRINT "  10. Send file to printer" 
4022 PRINT : PRINT "----------------------------------------------------------"
4023 PRINT
4024 ENDPROC

4110 DEF PROC_ChangePrinterIP
4120 INPUT "Enter printer IP: ", IP$
4130 ENDPROC

4140 DEF PROC_ChangePrinterPort
4150 INPUT "Enter printr port (default 631): ", PORT$
4160 ENDPROC

4170 DEF PROC_ChangePrinterPath
4180 INPUT "Enter printer path (default /ipp/printer): ", PATH$
4190 ENDPROC

4210 DEF PROC_ChangeOutputFormat
4220 LOCAL valid  : REM Declare a local variable to track validity
4230 valid = FALSE
4240 REPEAT
4250   PRINT "Valid values A, P, R (where A)scii, P)etscii, or R)aw):" : PRINT
4260   INPUT "Enter format code: ", FMT$
4280   IF FMT$="A" OR FMT$="P" OR FMT$="R" THEN valid = TRUE 
4290 UNTIL valid
4300 ENDPROC

4310 DEF PROC_ChangeFileToPrint
4320 LOCAL fileExists
4330 REPEAT
4340   INPUT "Enter the file path: ", FILEPATH$
4350   ON ERROR GOTO file_not_found   : REM Enable error handling
4360   file% = OPENIN(FILEPATH$)      : REM Attempt to open the file
4390   ON ERROR OFF                   : REM Disable error handling
4400 UNTIL file%<>0
4405 CLOSE #file%                   : REM Close the file if it was opened
4410 ENDPROC
4420 REM Error handling for file not found
4430 file_not_found:
4440 PRINT "File not found. Please try again."
4445 PROC_WaitForKey
4446 FILEPATH$ = ""
4450 fileExists = FALSE
4460 RESUME NEXT                    : REM Resume from the next line after the error

4510 DEF PROC_ChangeVerbose
4520 VERBOSE = NOT VERBOSE
4530 ENDPROC

5000 DEF PROC_SendUART(string$)
5010 length = LEN(string$)
5020 FOR i = 1 TO length
5030   character$ = MID$(string$, i, 1)
5050   ?A = ASC(character$)
5060   CALL senduart% 
5080 NEXT
5090 ENDPROC

5100 DEF PROC_ConfigurePrinter(Ip$, Port$, Path$, Format$)
5105 CONFIG$="AT+PRINT"+Format$+":"+Ip$+":"+Port$+Path$
5106 IF VERBOSE=1 THEN PRINT "Printer configuration: " + CONFIG$
5110 PROC_SendUART(CONFIG$)
5120 ?A=13
5130 CALL senduart%
5140 ENDPROC

5200 DEF PROC_WaitForKey
5210    PRINT "Press any key to continue...";
5220    REPEAT
5230        key% = INKEY(0)   : REM Wait for a key press
5240    UNTIL key% <> -1    : REM Loop until a key is pressed
5250    PRINT               : REM Move to the next line after key press
5260 ENDPROC

5300 DEF PROC_ProcesLine(Line$)
5310    IF VERBOSE=TRUE THEN PRINT Line$
5320    PROC_SendUART(Line$)
5330 ENDPROC

5400 DEF PROC_SendFileToPrinter(FilePath$)
5410 file%=1:line$=""
5420 ON ERROR GOTO row_file_error   : REM Enable error handling
5430 file% = OPENIN(FilePath$)  : REM Open the file for input
5440 ON ERROR OFF              : REM Disable error handling after file is opened 
5450 REPEAT  
5460   INPUT#file%, line$        : REM Read a line from the file
5470   PROC_ProcesLine(line$) 
5480 UNTIL EOF#(file%) 
5490 CLOSE#file%                 : REM Close the file
5500 ENDPROC
5510 REM Error handling if the file cannot be opened
5520 row_file_error:
5530 PRINT "Error: Unable to open file. Please check the file path."
5540 PROC_WaitForKey
5550 1160 ENDPROC

5600 DEF PROC_PrintFile
5605    IF FILEPATH$="<Configure>" THEN PRINT "You need to specify a file to print" : PROC_WaitForKey : ENDPROC
5610    PROC_ConfigurePrinter(IP$, PORT$, PATH$, FMT$)
5620    PROC_SendFileToPrinter(FILEPATH$)
5625    IF VERBOSE=TRUE THEN PROC_WaitForKey
5630 ENDPROC

6130 DEF PROC_InitConfigFile(filename$)
6150    fileHandle% = OPENIN(filename$) : REM Attempt to open the file
6151    IF fileHandle%=0 THEN PROC_SaveConfig(filename$, "A", "192.168.0.?", "631", "/ipp/printer")
6165    CLOSE#fileHandle%
6166 ENDPROC

6200 DEF PROC_LoadConfigFile(filename$)
6210 fileHandle% = OPENIN(filename$)
6230 REPEAT
6240   INPUT#fileHandle%, line$
6250   REM Check for "AT+PRINT" line
6260   IF LEFT$(line$, 8) = "AT+PRINT" THEN PROC_ParseConfigurationString(line$)
6270 UNTIL EOF#fileHandle%
6280 CLOSE #fileHandle%
6290 ENDPROC

6450 REM Procedure to process the line and extract the values
6460 DEF PROC_ParseConfigurationString(line$)
6470   FMT$ = MID$(line$, 9, 1) : REM Extract the FMT (previously FORMAT)
6490   colon1% = INSTR(line$, ":")
6500   colon2% = INSTR(MID$(line$, colon1% + 1), ":") + colon1%
6510   slash% = INSTR(MID$(line$, colon2% + 1), "/") + colon2%
6530   IP$ = MID$(line$, colon1% + 1, colon2% - colon1% - 1) : REM Extract IP
6550   PORT$ = MID$(line$, colon2% + 1, slash% - colon2% - 1) : REM Extract PORT
6570   PATH$ = MID$(line$, slash%) : REM Extract PATH
6580 ENDPROC

6610 DEF PROC_SaveConfig(newFilename$, newFMT$, newIP$, newPort$, newPath$)
6615   REM IF VERBOSE=1 THEN PRINT "Saving configuration..."
6620   file%=OPENOUT newFilename$
6630   PRINT#file%, "AT+PRINT"+newFMT$+":"+newIP$+":"+newPort$+newPath$
6640   CLOSE#file%
6645   REM IF VERBOSE=1 THEN PRINT "Done"
6650 ENDPROC
