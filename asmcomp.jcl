//ASM      EXEC PGM=ASMA90,                                            
//   PARM='BATCH,OBJ,NODECK,XREF(FULL),LIST,RENT'                      
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR                                 
//         DD DSN=SYS1.MODGEN,DISP=SHR                                 
//         DD DSN=ITC.SHUTSYS,DISP=SHR                                 
//SYSUT1   DD DSN=&&SYSUT1,UNIT=SYSDA,SPACE=(2700,(900,900)),          
//         SEP=(SYSLIB)                                                
//SYSUT2   DD DSN=&&SYSUT2,UNIT=SYSDA,SPACE=(2700,(900,900)),          
//         SEP=(SYSLIB,SYSUT1)                                         
//SYSUT3   DD DSN=&&SYSUT3,UNIT=SYSDA,SPACE=(2700,(900,900))           
//SYSPRINT DD SYSOUT=*                                                 
//SYSPUNCH DD DUMMY                                                    
//SYSLIN   DD DSN=&&OBJSET,UNIT=SYSDA,SPACE=(80,(200,50)),             
//         DISP=(MOD,PASS)                                             
//SYSIN DD DSN=USER.SHUTSYS(MSGTOOP),DISP=SHR                           
//LKED     EXEC PGM=IEWL,PARM=(LIST,MAP,LET,XREF,AC(1),RENT),          
//         COND=(8,LT,ASM)                                                                               
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR                                 
//         DD DSN=SYS1.MODGEN,DISP=SHR                                 
//         DD DSN=USER.SHUTSYS,DISP=SHR                                 
//SYSLIN   DD DSN=&&OBJSET,DISP=(OLD,DELETE)                           
//         DD DDNAME=SYSIN                                             
//SYSUT1   DD DSN=&&SYSUT1,UNIT=(SYSDA,SEP=(SYSLIN,SYSLMOD)),          
//         SPACE=(1024,(50,20))                                        
//SYSPRINT DD SYSOUT=*                                                 
//SYSTERM  DD SYSOUT=*                                                 
//SYSLMOD  DD DSNAME=USER.LINKLIB,DISP=SHR                        
//SYSIN  DD  *                                                         
   NAME MSGTOOP(R)                                                     
/*                                                                     