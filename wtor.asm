         PRINT ON                                    
WTOR     CSECT                                       
R0       EQU   0                                     
R1       EQU   1                                     
R2       EQU   2                                     
R3       EQU   3                                     
R4       EQU   4                                     
R5       EQU   5                                     
R6       EQU   6                                     
R7       EQU   7                                     
R8       EQU   8                                     
R9       EQU   9                                     
R10      EQU   10                                    
R11      EQU   11                                    
R12      EQU   12                                    
R13      EQU   13                                    
R14      EQU   14                                    
R15      EQU   15                                    
         SAVE  (14,12)               STANDARD H/K    
         LR    R12,R15               STANDARD H/K    
         USING WTOR,R12              STANDARD H/K    
         ST    13,SAVE+4             STANDARD H/K    
         LA    R11,SAVE              STANDARD H/K    
         ST    R11,8(R13)            STANDARD H/K    
         LR    R13,R11               STANDARD H/K    
         EJECT                                       
* INSTRUCTIONS GO HERE                               
         L      R2,0(R1)                             
         LA     R3,72                                
LOOP     LR     R4,R2                                
         AR     R4,R3                                
         BCTR   R3,0                                                    
         CLI    0(R4),X'00'                                             
         BNE    OK#                                                     
         BCT    R3,LOOP                                                 
         LA     R10,16                                                  
         B      END#                                                    
OK#      EX     R3,WTOMOVE                                              
         LA     R10,0                                                   
MSG#1    MVI    WTOECB,0                                                
         WTOR   MF=(E,WTORMSG)                                          
         WAIT   1,ECB=WTOECB                                            
         CLI    WTOREPLY,C'C'                                           
         BE     END#                                                    
         B      MSG#1                                                   
END#     LR     R15,R10                                                 
         L      R13,SAVE+4                                              
         RETURN (14,12),RC=(15)                                         
         EJECT                                                          
*********************************************************               
*     CONSTANTS AND VARIABLES                           *               
*********************************************************               
*                                                                       
         LTORG                                                          
SAVE     DS    9D                                                       
WTOECB   DS    F'0'                                                     
*                                                                       
WTOMOVE  MVC   WTORMSG+12(0),0(R2)                                      
*                                                                       
WTORMSG  WTOR  'REPLY C TO CONTINUE WITH SYSTEM PROCEDURE.             X
                                ',WTOREPLY,1,WTOECB,ROUTCDE=(1,2),MF=L  
*                                                                       
WTOREPLY DS CL1                                                         
         END                                                            