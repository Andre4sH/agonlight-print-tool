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
 3059 debugEnabled = 0
 3060 textColor = 7
 3110 REM ---------------------------------------------------------
 3111 REM PROGRAM START HERE
 3112 REM ---------------------------------------------------------
 3120 PROC_InitConfigFile(filename$)
 3130 PROC_LoadConfigFile(filename$)
 3140 COLOUR textColor
 3500 PROC_PrintMenu
 3510 PRINT "Select option: ";
 3515 IN = INKEY(0)
 3516 IF IN = -1 THEN IN = 0
 3517 IF IN = 0 THEN GOTO 3515
 3518 IF IN = 17 THEN CLS:END
 3519 IF IN = 3 THEN CLS:END
 3520 PRINT:PRINT
 3521 IF CHR$(IN)="1" THEN PROC_ChangePrinterIP
 3530 IF CHR$(IN)="2" THEN PROC_ChangePrinterPort
 3540 IF CHR$(IN)="3" THEN PROC_ChangePrinterPath
 3550 IF CHR$(IN)="4" THEN PROC_ChangeOutputFormat  
 3560 IF CHR$(IN)="5" THEN PROC_ChangeFileToPrint
 3570 IF CHR$(IN)="6" THEN PROC_ChangeVerbose 
 3571 IF CHR$(IN)="V" THEN PROC_ChangeVerbose
 3575 IF CHR$(IN)="s" THEN PROC_SaveConfig(filename$, FMT$, IP$, PORT$, PATH$)
 3576 IF CHR$(IN)="S" THEN PROC_SaveConfig(filename$, FMT$, IP$, PORT$, PATH$)
 3580 IF CHR$(IN)="p" THEN PROC_PrintFile   
 3581 IF CHR$(IN)="P" THEN PROC_PrintFile
 3585 IF CHR$(IN)="q" THEN CLS:END 
 3586 IF CHR$(IN)="Q" THEN CLS:END
 3590 GOTO 3500 
 3599 END
 3600 DEF PROC_Debug(lineNo%, functionName$, message$)
 3605 COLOUR 1
 3610 PRINT "*** DEBUG   LineNo: " + STR$(lineNo%)
 3620 PRINT "*** DEBUG     PROC: " + functionName$  
 3630 PRINT "*** DEBUG  Message: " + message$
 3640 COLOUR textColor
 3649 ENDPROC
 4000 DEF PROC_PrintMenu
 4005 IF debugEnabled = 1 THEN PROC_Debug(4005, "PROC_PrintMenu", "")
 4010 CLS
 4011 PRINT "--------------------------------------------------------------------------------"
 4012 PRINT "                        AgonLight printing tool version 1.1" : PRINT
 4013 PRINT "--------------------------------------------------------------------------------"
 4014 PRINT : PRINT "  Configuration" 
 4015 PRINT : PRINT "    Printer IP      : " + IP$ 
 4016 PRINT : PRINT "    Port            : " + PORT$ 
 4018 PRINT : PRINT "    Path            : " + PATH$ 
 4019 PRINT : PRINT "    Format          : " + FMT$ 
 4020 PRINT : PRINT "    File to print   : " + FILEPATH$ 
 4021 PRINT : PRINT "    Verbose         : " ;:IF VERBOSE=0 THEN PRINT "FALSE" ELSE PRINT "TRUE" 
 4022 PRINT : PRINT "--------------------------------------------------------------------------------" 
 4023 PRINT : PRINT "  Options:" 
 4024 PRINT : PRINT "    1. Change printer IP" 
 4025 PRINT : PRINT "    2. Change printer port" 
 4026 PRINT : PRINT "    3. Change printer path" 
 4027 PRINT : PRINT "    4. Change format" 
 4028 PRINT : PRINT "    5. Specify file to print" 
 4029 PRINT : PRINT "    6. Change verbose mode" 
 4030 PRINT : PRINT "    S. Save configuration" 
 4031 PRINT : PRINT "    P. Send file to printer" 
 4032 PRINT : PRINT "    Q. Quit" 
 4033 PRINT : PRINT "--------------------------------------------------------------------------------"
 4035 PRINT
 4099 ENDPROC
 4100 DEF PROC_ChangePrinterIP
 4105 IF debugEnabled = 1 THEN PROC_Debug(4105, "PROC_ChangePrinterIP", "")
 4120 INPUT "Enter printer IP: ", IP$
 4130 ENDPROC
 4150 DEF PROC_ChangePrinterPort
 4155 IF debugEnabled = 1 THEN PROC_Debug(4155, "PROC_ChangePrinterPort", "")
 4160 INPUT "Enter printr port (default 631): ", PORT$
 4169 ENDPROC
 4170 DEF PROC_ChangePrinterPath
 4180 INPUT "Enter printer path (default /ipp/printer): ", PATH$
 4190 ENDPROC
 4200 DEF PROC_ChangeOutputFormat
 4205 IF debugEnabled = 1 THEN PROC_Debug(4205, "PROC_ChangeOutputFormat", "")
 4210 LOCAL valid  : REM Declare a local variable to track validity
 4220 valid = FALSE
 4230 REPEAT
 4240   PRINT "Valid values A, P, R (where A)scii, P)etscii, or R)aw):" : PRINT
 4250   INPUT "Enter format code: ", FMT$
 4260   IF FMT$="A" OR FMT$="P" OR FMT$="R" THEN valid = TRUE 
 4270 UNTIL valid
 4299 ENDPROC
 4300 DEF PROC_ChangeFileToPrint
 4305 IF debugEnabled = 1 THEN PROC_Debug(4305, "PROC_ChangeFileToPrint", "")
 4310 LOCAL fileExists
 4320 REPEAT
 4330   INPUT "Enter the file path: ", FILEPATH$
 4340   file% = OPENIN(FILEPATH$)      : REM Attempt to open the file
 4350   PRINT:PRINT "No file with that name, try again": PRINT
 4360 UNTIL file%<>0
 4375 CLOSE #file%                   : REM Close the file if it was opened
 4399 ENDPROC
 4500 DEF PROC_ChangeVerbose
 4505 IF debugEnabled = 1 THEN PROC_Debug(4505, "PROC_ChangeVerbose", "")
 4510 VERBOSE = NOT VERBOSE
 4549 ENDPROC
 5000 DEF PROC_SendUART(string$)
 5005 IF debugEnabled = 1 THEN PROC_Debug(5005, "PROC_SendUART", "string:"+string$)
 5010 length = LEN(string$)
 5020 FOR i = 1 TO length
 5030   character$ = MID$(string$, i, 1)
 5050   ?A = ASC(character$)
 5060   CALL senduart% 
 5080 NEXT
 5090 ENDPROC
 5100 DEF PROC_ConfigurePrinter(Ip$, Port$, Path$, Format$)
 5105 IF debugEnabled = 1 THEN PROC_Debug(5105, "PROC_ConfigurePrinter", "Ip:"+Ip$+" Port:"+Port$+" Path: "+Path$+" Format:"+Format$)
 5110 CONFIG$="AT+PRINT"+Format$+":"+Ip$+":"+Port$+Path$
 5120 IF VERBOSE=1 THEN PRINT "Printer configuration: " + CONFIG$
 5130 PROC_SendUART(CONFIG$)
 5140 ?A=13
 5150 CALL senduart%
 5199 ENDPROC
 5200 DEF PROC_WaitForKey
 5205 IF debugEnabled = 1 THEN PROC_Debug(5205, "PROC_WaitForKey", "")
 5210 PRINT "Press any key to continue...";
 5220 REPEAT
 5230   key% = INKEY(0)   : REM Wait for a key press
 5240 UNTIL key% <> -1    : REM Loop until a key is pressed
 5250 PRINT               : REM Move to the next line after key press
 5260 ENDPROC
 5300 DEF PROC_ProcesLine(Line$)
 5305 IF debugEnabled = 1 THEN PROC_Debug(5305, "PROC_ProcesLine", "Line: "+Line$)
 5310 IF VERBOSE=TRUE THEN PRINT Line$
 5320 PROC_SendUART(Line$)
 5330 ENDPROC
 5400 DEF PROC_SendFileToPrinter(FilePath$)
 5405 IF debugEnabled = 1 THEN PROC_Debug(5405, "PROC_SendFileToPrinter", "FilePath: "+FilePath$)
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
 5605 IF debugEnabled = 1 THEN PROC_Debug(5605, "PROC_PrintFile", "")
 5610 IF FILEPATH$="<Configure>" THEN PRINT "You need to specify a file to print" : PROC_WaitForKey : ENDPROC
 5615 PRINT "Pringting ..." 
 5620 PROC_ConfigurePrinter(IP$, PORT$, PATH$, FMT$)
 5630 PROC_SendFileToPrinter(FILEPATH$)
 5640 IF VERBOSE=TRUE THEN PROC_WaitForKey
 5649 ENDPROC
 6100 DEF PROC_InitConfigFile(filename$)
 6105 IF debugEnabled = 1 THEN PROC_Debug(6135, "PROC_InitConfigFile", "filename: "+filename$)
 6110 fileHandle% = OPENIN(filename$) : REM Attempt to open the file
 6120 IF fileHandle%=0 THEN PROC_SaveConfig(filename$, "A", "192.168.0.?", "631", "/ipp/printer")
 6130 CLOSE#fileHandle%
 6149 ENDPROC
 6200 DEF PROC_LoadConfigFile(filename$)
 6205 IF debugEnabled = 1 THEN PROC_Debug(6205, "PROC_LoadConfigFile", "filename: "+filename$)
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
 6465 IF debugEnabled = 1 THEN PROC_Debug(6465, "PROC_ParseConfigurationString", "line: "+line$)
 6470 FMT$ = MID$(line$, 9, 1) : REM Extract the FMT (previously FORMAT)
 6490 colon1% = INSTR(line$, ":")
 6500 colon2% = INSTR(MID$(line$, colon1% + 1), ":") + colon1%
 6510 slash% = INSTR(MID$(line$, colon2% + 1), "/") + colon2%
 6530 IP$ = MID$(line$, colon1% + 1, colon2% - colon1% - 1) : REM Extract IP
 6550 PORT$ = MID$(line$, colon2% + 1, slash% - colon2% - 1) : REM Extract PORT
 6570 PATH$ = MID$(line$, slash%) : REM Extract PATH
 6580 ENDPROC
 6600 DEF PROC_SaveConfig(newFilename$, newFMT$, newIP$, newPort$, newPath$)
 6605 IF debugEnabled = 1 THEN PROC_Debug(6605, "PROC_SaveConfig", "newFilename: "+newFilename$+" newFMT: "+newFMT$+" newIP: "+newIP$+ " newPort: "+newPort$+" newPath:"+newPath$)
 6610 REM IF VERBOSE=1 THEN PRINT "Saving configuration..."
 6620 file%=OPENOUT newFilename$
 6630 PRINT#file%, "AT+PRINT"+newFMT$+":"+newIP$+":"+newPort$+newPath$
 6640 CLOSE#file%
 6645 REM IF VERBOSE=1 THEN PRINT "Done"
 6650 ENDPROC
