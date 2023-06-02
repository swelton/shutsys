         PRINT OFF                                                    
         IEFZB4D0                                                     
         IEFZB4D2                                                     
         PRINT ON                                                     
         PRINT NOGEN                                                  
WTO10    CSECT                                                        
R0       EQU   0                                                      
R1       EQU   1                                                      
R2       EQU   2        ADDRESS OF PARM FIELD                         
R3       EQU   3        LENGTH OF PARM FIELD/INPUT AREA ADDRESS       
R4       EQU   4        WORK REGISTER FOR LENGTH OF PARM/OUTPUT AREA  
R5       EQU   5        DCB DSECT USING REGISTER                      
R6       EQU   6        RECORD LENGTH REGISTER                        
R7       EQU   7                                                      
R8       EQU   8                                                      
R9       EQU   9                                                      
R10      EQU   10       BAL REGISTER                                  
R11      EQU   11       LENGTH WORK REISTER                           
R12      EQU   12                                                     
R13      EQU   13                                                     
R14      EQU   14                                                     
R15      EQU   15                                                     
ML       EQU   70                                                     
         SAVE  (14,12)                                                
         LR    R12,R15                                                
         USING WTO10,R12                                              
         ST    R13,SAVE+4              SAVE CALLERS SAVE AREA ADDR    
         LA    R11,SAVE                                               
         ST    R11,8(R13)              MY SAVE AREA ADDR IN CALLERS   
         LR    R13,R11                 NOW 13 POINTS TO MY SAVE AREA  
* END OF STANDARD ENTRY STRUCTURE                                     
         EJECT                                                        
         L     R3,0(R1)                LOAD PARM ADDR                 
         SR    R4,R4                                                  
         LH    R4,0(R3)                                               
         LA    R3,2(R3)                                                 
         MVC   IPOWTOL+4(70),SP                                         
         BCTR  R4,0                                                     
         EX    R4,MSGMOVE                                               
         MVC   IPOWTOL+4(70),MSG                                        
         SR    R1,R1                                                    
         WTO   MF=(E,IPOWTOL)                                           
         LR    R3,R1                                                    
         STIMER WAIT,DINTVL=TIME1                                       
         DOM   MSG=(R3)                                                 
         STIMER WAIT,DINTVL=TIME2                                       
         LA    R10,0                                                    
         L     R13,SAVE+4                                               
         RETURN (14,12),RC=(15)                                         
         EJECT                                                          
*********************************************************               
*     CONSTANTS AND VARIABLES                           *               
*********************************************************               
     LTORG                                                              
SAVE     DS    18F                                                      
*                                                                       
MSGMOVE  MVC   MSG(0),0(R3)                                             
SP       DC    CL1' '                                                   
IPOWTOL  WTO   '                                                       X
                              ',ROUTCDE=(1,2),DESC=(1),MF=L             
*                                                                       
MSG      DC    CL70' '                                                  
         DS    0D                                                       
TIME1    DC    CL8'00002000'                                            
TIME2    DC    CL8'00000100'                                            
         END                                                            