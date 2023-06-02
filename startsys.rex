/*%NOCOMMENT rexx ******************************************************
*                                                                      *
* Program: STARTSYS                                                    *
*                                                                      *
* Syntax: STARTSYS                                                     *
*                                                                      *
* Function: Startdown applications in an orderly manner                *
*                                                                      *
* Calls: None                                                          *
*                                                                      *
* Called: Via batch job startdown                                      *
*                                                                      *
* Created: S.Welton                                                    *
*                                                                      *
* Notes: Change load_library to the library where the WTO modules are  *
*                                                                      *
************************************************************************
* Updates:                                                             *
* dd/mm/yyyy nnn -                                                     *
*                                                                      *
* Version 1.0.0 *******************************************************/
Arg options                                                             
/* ************************************************************ *       
 * We always come in here, call our main routines and if all    *       
 * goes according to plan we should exit from here              *       
 * ************************************************************ */      
Signal On Syntax                        /* Syntax Error              */ 
Signal On Novalue                       /* Novalue error             */ 
Signal On Halt                          /* Program halted            */ 
Signal On Error                         /* Program error             */ 
Call tool_init                          /* System and debug variables*/ 
Call tool_wrapup                        /* Lets go home|             */ 
                                                                        
/* ************************************************************ *       
 * Main routine, also set up a number of constants and          *       
 * variables that will be used during the run (if necessary).   *       
 * ************************************************************ */      
tool_start:                                                             
tool_start_adr = Address()                                              
sub_proc = 'TOOL_START'                                                 
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc': START...'           
Address Tso                                                             
pnum = '0'                                     /* Counter             */
jnum = '0'                                     /* Counter             */
snum = '0'                                     /* Counter             */
wnum = '0'                                     /* Counter             */
job = 1                                                                 
system = Mvsvar('sysname')                     /* System name         */
input_dataset = 'STARTUP.DATA'                 /* Input dataset       */
msgpfx = ts.rexexc                                                      
Call build_job_header                                                   
Call prompt_operator                                                    
Call open_and_read_dataset                                              
Call run_commands                                                       
Call submit_job                                                         
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc': ENDE. RC='ts.p_rc   
Address Value tool_start_adr                                            
Return                                                                  
                                                                        
/* -------------------------------------------------------------- *     
 * Build the job header                                           *     
 * -------------------------------------------------------------- */    
build_job_header:                                                       
build_job_header_adr = Address()                                        
sub_proc = 'BUILD_JOB_HEADER'                                           
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'             
j.job = '//STRT'||system  'JOB (EDV1),CLASS=G,MSGCLASS=T,'              
job = job + 1                                                           
j.job = '//        NOTIFY=&SYSUID,REGION=0M'                            
job = job + 1                                                           
j.job = '//*'                                                           
job = job + 1                                                           
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc 
Address Value build_job_header_adr                                     
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * Now submit our job                                             *    
 * -------------------------------------------------------------- */   
submit_job:                                                            
submit_job_adr = Address()                                             
sub_proc = 'SUBMIT_JOB'                                                
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
Do n = 1 To job - 1                                                    
  Queue j.n                                                            
End                                                                    
Queue ''                                                               
x = Outtrap('sub.')                                                    
'SUBMIT *'                                                             
x = Outtrap('OFF')                                                     
Do k = 1 To sub.0                                                      
  Parse Var sub.k                                                      
  If Word(sub.k,1) = 'IKJ56250I' Then Do                               
    Say 'Job:' Word(sub.k,3) 'has been successfully submitted.'        
  End                                                                  
End                                                                    
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value submit_job_adr                                           
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * Open and read the dataset containing data to startup  the      *    
 * system (commands, messages and wait times)                     *    
 * -------------------------------------------------------------- */   
open_and_read_dataset:                                                 
open_and_read_dataset_adr = Address()                                  
sub_proc = 'OPEN_AND_READ_DATASET'                                     
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
Address Tso                                                            
x = Outtrap('open.')                                                   
'ALLOC FI(INDD) DA('"'"input_dataset"'"') SHR'                         
'EXECIO * DISKR INDD (FINIS STEM CMD.'                                 
x = Outtrap('OFF')                                                     
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value open_and_read_dataset_adr                                
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * Execute all required commands                                  *    
 * -------------------------------------------------------------- */   
run_commands:                                                          
run_commands_adr = Address()                                           
sub_proc = 'RUN_COMMANDS'                                              
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
Do i = 1 To cmd.0                                                      
  Parse Var cmd.i command                                              
  type = Substr(command,1,1)                                           
  l = Length(command)                                                  
  command = Substr(command,2,l)                                        
  Select                                                               
    When type = '}' Then Do                                            
      Say command                                                      
      Call output_to_operator                                          
    End                                                                
    When type = '~' Then Do                                            
      Say 'Waiting for' command 'seconds before continuing.'           
      Call wait_to_continue                                            
    End                                                                
    When type = '*' Then Iterate                                       
    When type = '{' Then Do                                            
      Say 'Entering command:' command                                  
      Call enter_command                                               
    End                                                                
    Otherwise Nop                                                      
  End                                                                  
End                                                                    
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value run_commands_adr                                         
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * Output a message to the operator aksing them to continue       *    
 * -------------------------------------------------------------- */   
prompt_operator:                                                       
prompt_operator_adr = Address()                                        
sub_proc = 'PROMPT_OPERATOR'                                           
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
j.job = '//*'                                                          
job = job + 1                                                          
j.job = "//ASKOP"||pnum  "EXEC PGM=WTOR,PARM='*'"                      
job = job + 1                                                          
j.job = '//STEPLIB DD DSN=load_library,DISP=SHR'                       
job = job + 1                                                          
j.job = '//SYSPRINT DD SYSOUT=*'                                       
job = job + 1                                                          
j.job = '//*'                                                          
job = job + 1                                                          
pnum = pnum + 1                                                        
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value prompt_operator_adr                                      
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * Output a message to the operator telling them what is happening*    
 * -------------------------------------------------------------- */   
output_to_operator:                                                    
output_to_operator_adr = Address()                                     
sub_proc = 'OUTPUT_TO_OPERATOR'                                        
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
j.job = '//*'                                                          
job = job + 1                                                          
j.job = '//OPMSG'||jnum  'EXEC PGM=MSGTOOP,'                           
job = job + 1                                                          
command = Strip(command)                                               
j.job = '// PARM='||"'"command"'"                                      
job = job + 1                                                          
j.job = '//STEPLIB DD DSN=load_library,DISP=SHR'                       
job = job + 1                                                          
j.job = '//SYSPRINT DD SYSOUT=*'                                       
job = job + 1                                                          
j.job = '//*'                                                          
job = job + 1                                                          
jnum = jnum + 1                                                        
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value output_to_operator_adr                                   
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * Enter the command to startup  application                      *    
 * -------------------------------------------------------------- */   
enter_command:                                                         
enter_command_adr = Address()                                          
sub_proc = 'ENTER_COMMAND'                                             
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
j.job = '//*'                                                          
job = job + 1                                                          
j.job = '//START'||snum  'EXEC PGM=IEBGENER'                           
job = job + 1                                                          
command = Strip(command)                                               
j.job = '//SYSPRINT DD SYSOUT=*'                                       
job = job + 1                                                          
j.job = '//SYSIN    DD DUMMY'                                          
job = job + 1                                                          
j.job = '//SYSUT2   DD   SYSOUT=(*,INTRDR)'                            
job = job + 1                                                          
j.job = '//SYSUT1   DD   DATA,DLM=$$'                                  
job = job + 1                                                          
j.job = "/*$VS,'"command"'"                                            
job = job + 1                                                          
j.job = '$$'                                                           
job = job + 1                                                          
snum = snum + 1                                                        
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value enter_command_adr                                        
Return                                                                 
                                                                        
/* -------------------------------------------------------------- *     
 * Provide a bit of wait before continuing                        *     
 * -------------------------------------------------------------- */    
wait_to_continue:                                                       
wait_to_continue_adr = Address()                                        
sub_proc = 'WAIT_TO_CONTINUE'                                           
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'             
command = Strip(command)                                                
text = 'Waiting' command 'seconds before continuing.'                   
j.job = '//*'                                                           
job = job + 1                                                           
j.job = '//WAIT'||wnum   'EXEC PGM=WTO'||command||','                   
job = job + 1                                                           
j.job = '//     PARM='||"'"text"'"                                      
job = job + 1                                                           
j.job = '//STEPLIB  DD DSN=load_library,DISP=SHR'                       
job = job + 1                                                           
j.job = '//*'                                                           
job = job + 1                                                           
wnum = wnum + 1                                                         
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc 
Address Value wait_to_continue_adr                                      
Return                                                                  
                                                                        
/* -------------------------------------------------------------- *     
 * This is where we exit our program and perform some cleanup.    *     
 * -------------------------------------------------------------- */    
tool_wrapup:                                                            
tool_wrapup_adr = Address()                                             
sub_proc = 'TOOL_WRAPUP'                                                
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'             
result = ts.p_rc                        /* Set exit return code      */ 
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc': ENDE. RC='ts.p_rc   
Address Value tool_wrapup_adr                                           
Exit result                                                             
                                                                        
          /*-------------------------------------------------*          
          * Simple, very basic help. If the program is called*       
          * with HELP or ? after (( then this sections will  *       
          * be called (also used in error conditions)        *       
          *-------------------------------------------------*/       
tool_help:                                                           
tool_help_adr = Address()                                            
Call tool_saystart                                                   
/*                                                                   
See documentation for full details                                   
*/                                                                   
Call tool_sayend                                                     
Address Value tool_help_adr                                          
ts.p_rc = 1                                                          
Call tool_wrapup                                                     
                                                                     
tool_saystart:                                                       
tool_saystart_adr = Address()                                        
say_start = Sigl + 2                                                 
Address Value tool_saystart_adr                                      
Return                                                               
                                                                     
tool_sayend:                                                         
tool_sayend_adr = Address()                                          
say_end = Sigl - 2                                                   
Do i_i = say_start To say_end                                        
  Say Sourceline(i_i)                                                
End                                                                  
Address Value tool_sayend_adr                                        
Return                                                               
                                                                     
/* -------------------------------------------------------------- *  
 * N O V A L U E Error                                            *  
 * -------------------------------------------------------------- */ 
novalue:                                                             
novalue_adr = Address()                                              
sub_proc = 'NOVALUE'                                                 
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'          
If Words(Sigl) > 1 Then Do                                           
  sigl = Space(sigl,1,'_')                                              
  Call tool_msg '001' 'E' 'S' sigl                                      
End                                                                     
Else Call tool_msg '001' 'E' 'S' sigl                                   
var = Condition('D')                                                    
If Words(var) > 1 Then Do                                               
  var = Space(var,1,'_')                                                
  Call tool_msg '002' 'E' 'S' var                                       
End                                                                     
Else Call tool_msg '002' 'E' 'S' var                                    
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc 
Address Value novalue_adr                                               
Return                                                                  
                                                                        
/* -------------------------------------------------------------- *     
 * S Y N T A X Error                                              *     
 * -------------------------------------------------------------- */    
syntax:                                                                 
syntax_adr = Address()                                                  
sub_proc = 'SYNTAX'                                                     
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'             
abend_rc = rc                                                           
abend_rc = Errortext(abend_rc)                                          
line1 = sigl                                                            
line2 = Sourceline(line1)                                               
If Words(line1) > 1 Then Do                                             
  line1 = Space(line1,1,'_')                                            
  Call tool_msg '003' 'E' 'S' line1                                     
End                                                                     
Else Call tool_msg '003' 'E' 'S' line1                                  
Call tool_msg '004' 'E' 'A' abend_rc                                    
If Words(line2) > 1 Then Do                                             
  line2 = Space(line2,1,'_')                                            
  Call tool_msg '005' 'E' 'S' line2                                     
End                                                                     
Else Call tool_msg '005' 'E' 'S' line2                                  
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc 
Address Value syntax_adr                                                
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * E R R O R Error                                                *    
 * -------------------------------------------------------------- */   
error:                                                                 
error_adr = Address()                                                  
sub_proc = 'ERROR'                                                     
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'            
abend_rc = rc                                                          
line5 = sigl                                                           
line3 = line5||'. RC:' abend_rc                                        
line4 = Sourceline(line5)                                              
If Words(line3) > 1 Then Do                                            
  line3 = Space(line3,1,'_')                                           
  Call tool_msg '006' 'E' 'S' line3                                    
End                                                                    
Else Do                                                                
  Call tool_msg '006' 'E' 'S' line5                                    
End                                                                    
If Words(line4) > 1 Then Do                                            
  line4 = Space(line4,1,'_')                                           
  Call tool_msg '007' 'E' 'S' line4                                    
  Call tool_msg '008' 'I' 'S'                                          
End                                                                    
Else Do                                                                
  Call tool_msg '007' 'E' 'S' line4                                    
  Call tool_msg '008' 'I' 'S'                                          
End                                                                    
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value error_adr                                                
Return                                                                 
                                                                       
/* -------------------------------------------------------------- *    
 * H A L T Error                                                  *    
 * -------------------------------------------------------------- */   
halt:                                                                  
halt_adr = Address()                                                   
sub_proc = 'HALT'                                                       
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'             
Call tool_msg '009' 'I' 'S'                                             
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc 
Address Value halt_adr                                                  
Return                                                                  
                                                                        
                                                                        
          /*-------------------------------------------------*          
          * Set all debug and trace options                  *          
          *-------------------------------------------------*/          
tool_init:                                                              
tool_init_adr = Address()                                               
Address Tso                                                             
Parse Source ts.sys_id ts.how_invokt ts.rexexc ts.dd_nm ts.ds_nm ,      
 ts.as_invokt ts.cmd_env ts.addr_spc ts.usr_tokn                        
ts.rif = Sysvar('sysenv')               /* Check here to see if we   */ 
If ts.rif = 'FORE' Then ts.rif = 'Y'    /* are running FORE or BAT   */ 
Else ts.rif = 'N'                       /* or with ISPF and set a    */ 
ts.iia = Sysvar('sysispf')              /* few variables with it     */ 
If ts.iia = 'ACTIVE' Then ts.iia = 'Y'                                  
Else ts.iia = 'N'                                                       
ts.proc_tr = 'N'                      /* No tracing and no display */   
trace_level = 'O'                     /* of procedure statements   */   
If ts.proc_tr = 'Y' Then Trace Value trace_level                        
ts.p_rc = 0                             /* Standard return code      */ 
ts.msg_pfx = ts.rexexc                  /* Messages prefix           */ 
Call tool_start                                                         
Address Value tool_init_adr                                             
Return                                                                  
                                                                        
/* -------------------------------------------------------------- *     
 * Use this are for various different types of messages. The      *     
 * format to call this subproc is:                                *     
 *                                                                *     
 *        Call tool_msg 'num' 't' 's' arg1 - arg5                 *     
 *                                                                *     
 * where:                                                         *     
 *        num is the next number in sequence                      *   
 *        t is the type of message (standard IBM message suffix)  *   
 *        s is how to display the message:                        *   
 *                                                                *   
 *          S = ISPF long message when running ISPF in foreground *   
 *              otherwise just say it                             *   
 *          O = just say the message and send to master console   *   
 *                                                                *   
 * -------------------------------------------------------------- */  
tool_msg:                                                             
tool_msg_adr = Address()                                              
sub_proc = 'TOOL_MSG'                                                 
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc' - START'           
Parse Arg tool_msg_no severity where arg1 arg2 arg3 arg4 arg5         
Select                                                                
  When tool_msg_no = '001' Then ,                                     
   text = 'NOVALUE for data at:' arg1'.'                              
  When tool_msg_no = '002' Then ,                                     
   text = 'Variable' arg1 'has no value.'                             
  When tool_msg_no = '003' Then ,                                     
   text = ts.rexexc 'program has a syntax error at line:' arg1'.'     
  When tool_msg_no = '004' Then ,                                     
   text = 'The cause is:' arg1'.'                                     
  When tool_msg_no = '005' Then ,                                     
   text = 'And the code is:' arg1'.'                                  
  When tool_msg_no = '006' Then ,                                     
   text = ts.rexexc 'has an error at line' arg1'.'                    
  When tool_msg_no = '007' Then ,                                     
   text = 'And the code is:' arg1'.'                                  
  When tool_msg_no = '008' Then ,                                     
   text = 'Errors have possibly occurred (except EXECIO). Check.'     
  When tool_msg_no = '009' Then ,                                     
   text = ts.rexexc 'has been stopped by operator.'                   
  Otherwise text = 'No message text for this message.'                
End                                                                   
Select                                                                
  When where = 'S' Then Do                                            
    If ts.rif = 'Y' & ts.iia = 'Y' Then Do                            
      zedlmsg = ts.msg_pfx||tool_msg_no||severity text                 
      Address Ispexec 'SETMSG MSG(ISRZ001)'                            
    End                                                                
    Else Say ts.msg_pfx||tool_msg_no||severity text                    
    Return                                                             
  End                                                                  
  When where = 'O' Then Do                                             
    Say ts.msg_pfx||tool_msg_no||severity text                         
    'SEND' ts.msg_pfx||apk_msg_no||severity text ',BRDCST'             
    Return                                                             
  End                                                                  
  Otherwise Do                                                         
    Say ts.msg_pfx||tool_msg_no||severity text                         
    Return                                                             
  End                                                                  
End                                                                    
If ts.proc_tr = 'Y' Then Say ts.rexexc'-'sub_proc ': ENDE. RC=' ts.p_rc
Address Value tool_msg_adr                                             
Return                                                                 