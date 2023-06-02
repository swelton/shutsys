# shutsys
 
## Preamble                                                                
                                                                        
Our operators required a way of shutting down the systems so that they didn't have many commands (with a lot of DB2 systems this could take a while.) As I didn't have a lot of time I knocked up this little system which although isn't fantastic, it does do the job for us and the system comes up and down much quicker.                                  
                                                                        
## Contents

- SHUTSYS - REXX exec to perform system shutdown                     
- STARTSYS - REXX exec to perform system startup                     
- SHUTDOWN.DATA - Example parameter file (read the start carefully)  
- STARTUP.DATA - Example parameter file (read the start carefully)   
- MSGTOOP - Assembler source for outputting messages to the console  
- WTOR - Assembler source for getting operator response              
- WTO5 - Assembler source for 5 second wait                          
- WTO10 - Assembler source for 10 second wait                        
- WTO20 - Assembler source for 20 second wait                        
- WTO30 - Assembler source for 30 second wait                        
- WTO60 - Assembler source for 60 second wait                        

## Instructions                                                           
                                                                       
1. Assemble and link the assembler programs into a library of your choice                                                       
2. Copy the SHUTSYS and STARTSYS REXX execs into a library of your choice and change load_library to the library into where you compiled the assembler programs                                   
3. Modify the SHUTDOWN and STARTUP files to reflect your startup and shutdown procedures. Copy them into sequential files called STARTUP.DATA and SHUTDOWN.DATA (if you use different names you will have to change the REXX execs)                           
4. Get the operators to run the SHUTJOB or STARTJOB after modifying the rexx_library statement to where you copied the REXX execs.    
                                                                       
**Thats all!**                                                             