//SHATSYSA JOB (EDV1),STOP.SYSA,                             
//             CLASS=B,MSGCLASS=T                            
//*                                                          
//* STARTUP SYSA SYSTEM. CALLS REXX PROCEDURE SHUTSYS IN     
//* rexx_library. ALL COMMANDS ARE IN STARTUP.DATA           
//*                                                          
//STEP1    EXEC  PGM=IKJEFT01,DYNAMNBR=50                    
//SYSIN    DD DUMMY                                          
//SYSPRINT DD SYSOUT=Z                                       
//SYSTSPRT DD SYSOUT=*                                       
//$RSOUT   DD SYSOUT=Z                                       
//SYSPROC  DD DISP=SHR,DSN=rexx_library                      
//SYSEXEC  DD DISP=SHR,DSN=rexx_library                      
//SYSTSIN  DD *                                              
 %STARTSYS                                                   