;---------------------- Struct -------------------
PSP_header STRUC      ; PSP Header
  Int_20h_Instructions            dw ?
  Program_end_addr                dw ?
  Reserved                        db ?
  CallDosFunDsipatcher            db 5 dup (?)
  ProgramTherminationCodeAddr     dd ?
  BreakHandlerRoutineAddr         dd ?
  CriticalErrorHandlerRoutineAddr dd ?
  Reserved1                       db 22 dup (?)
  EnvironmentArea_addr            dw ?
  Reserved2                       db 34 dup (?)
  INT_21h_Instructions            db 3 dup (?)
  Reserved3                       db 9 dup (?)
  Default_FCB_1                   db 16 dup (?)
  Default_FCB_2                   db 20 dup (?)
  Command_Line_String_Length      db ?
  Command_Line_String             db 127 dup (?)
PSP_header ENDS


DTA_Structr STRUC      ; Disk transfer address Struct
  Reserved4                   db 21 dup (?)
  Attrib_Of_File_Found        db ?
  Time_Stamp_Of_File          dw ?
  Date_Stamp_Of_File          dw ?
  File_Size_in_Bytes          dd ?
  Filename_And_Extension_addr dw ?
DTA_Structr ENDS
