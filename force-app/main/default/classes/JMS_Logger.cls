/******************************************************************************

* @description    This class is part of the Logging Framework that handles the necessary 
*				  Logging methods to store the debug and exception information on the Log 
*				  custom object in Salesforce. 
*
*/
public class JMS_Logger {

	/******************************************************************************	
	** @return    StackTrace Wrapper class  
	******************************************************************************/
    /*******************************************************************
     * Codescan error :All methods are static. Consider using Singleton instead. Alternatively, you could add a private constructor or make the class abstract to silence this warning.
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/
    @testvisible
    private JMS_Logger(){
    } 
    /***************************************************************** */
    public class StackTrace{
        public integer level{get; private set;}
        private string function;
        private string objectName;
     
        
        public string getEntry(){
            return (objectName + ' : ' + function);
        }
        
        public StackTrace(integer level, string function, string objectName){
            this.level = level;
            this.function = function;
            this.objectName = objectName;
            //System.debug('objectName------'+objectName);
        }
    }
    //This public class should be used for creating exceptions from logical faults in the application
    public class CustomException extends Exception{}
    //Initialize static variables
	private static integer currentLevel = 0;
	private static integer sequence = 0;
	private static boolean inPageConstructor = false;
	private static List<StackTrace> stack = new List<StackTrace>();	
	private static List<JMS_Log__c> debugList = new List<JMS_Log__c>();
	private static List<JMS_Log__c> exceptionList = new List<JMS_Log__c>();
	private static Id idDebugRT = JMS_LogConfigSettings.getDebugRecordType();
	private static Id idExceptionRT = JMS_LogConfigSettings.getExceptionRecordType();
	private static boolean debugLogEnabled = JMS_LogConfigSettings.loggingEnabled();
	private static boolean exceptionLogEnabled = JMS_LogConfigSettings.exceptionEnabled();
	//Initialize constant variables
	public static final string STACKSTR = ' stack: ';
	//method that will be in the Constructor if it will be used in a page
	public static void setInConstuctor(){
        inPageConstructor = true;
    }
	/******************************************************************************
	* @param          functionName-String denoting the name of the method from which 
	                  this method was called
	* @param          objectName-String denoting the name of the class from which 
	                  the method was called
	* @return         null
	* @description    
	* This method should be called when entering every method in a class. The method 
	* will initiate a stacktrace which will have the level of debug info along with 
	* the function name and object name
	******************************************************************************/
	public static void push(string functionName, string objectName){        
        stack.add(new StackTrace(currentLevel, functionName, objectName));
        currentLevel++;       
    }
    
    public static void pop(){

        if(currentLevel > 0){
            currentLevel--;
            if(stack.size() > 0){
                stack.remove(stack.size() -1);
            }
        }
        
        if(currentLevel==0){
            String debugListString = JSON.serialize(debugList);
            String exptListString = JSON.serialize(exceptionList);
            writeLogsToDatabase(exptListString, debugListString);
            debugList = new List<JMS_Log__c>();
            exceptionList = new List<JMS_Log__c>(); 
        }  
        //System.debug('debugListString2-----'+debugListString);
        //System.debug('debugListParsed2-----'+debugListParsed);
        //System.debug('exptListString2-----'+exptListString);
        //System.debug('exceptListParsed2-----'+exceptListParsed);
    }   
    
    /******************************************************************************
	
	* @param          debug string is passed to add data to Message
	* @return         null
	* @description    
	* This method is called by methods which needs to capture a debug statment into 
	* Salesforce. The string that needs to be displayed in the debug log is passed to 
	* this method and is added to the list of debug logs that will be inserted into 
	* Salesforce
	******************************************************************************/
    public static void debug(string debugString){   
		if(idDebugRT != null){
			JMS_Log__c log = new JMS_Log__c(
				        JMS_StackTrace__c = getStackTrace(),
				        JMS_Limits__c = getLimits(),
				        JMS_Message__c = debugString,
				        RecordTypeId = idDebugRT,
				        JMS_Sequence__c = sequence);
			debugList.add(log);
			sequence++;
            //System.debug('log------'+log);
            //System.debug('debugList------'+debugList);
		}
        
    }
    /******************************************************************************
	
	* @param          string
	* @return         null
	* @description    
	* This method takes a string exception parameter and then passes it to the standard
	* debug exception method after translating the exception to an exception type.
	******************************************************************************/  
    public static void debugException(string exStr){
        CustomException ex = new CustomException(exStr);
        debugException(ex);
    }
    /******************************************************************************
	
	* @param          exception that will be logged
	* @return         null
	* @description    
	* Similar to the debug method, this method is called by methods which needs to 
	* capture a exception statment into Salesforce. The string that needs to be 
	* displayed in the debug log is passed to this method and is added to the list of 
	* exception logs that will be inserted into Salesforce
	******************************************************************************/
    public static void debugException(Exception ex){

        
        string exceptionInfo = ex.getMessage() + STACKSTR 
                               + ex.getStackTraceString();
        JMS_Log__c log = new JMS_Log__c(
            JMS_StackTrace__c = getStackTrace(),
            JMS_Limits__c = getLimits(),
            JMS_Message__c = exceptionInfo,
            recordTypeId = idExceptionRT,
            JMS_ExceptionLine__c = ex.getLineNumber(),
            JMS_ExceptionType__c = ex.getTypeName(),
            JMS_Sequence__c = sequence);

        exceptionList.add(log);
        sequence++;
        //System.debug('log------'+log);
        //System.debug('exceptionInfo-----'+exceptionInfo);
        //System.debug('JMS_ExceptionLine__c-----'+ex.getLineNumber());
        //System.debug('JMS_ExceptionLine__c-----'+ex.getTypeName());
        //System.debug('idExceptionRT-----'+idExceptionRT);
        //System.debug('exceptionList-----'+exceptionList);
    }
    
    /******************************************************************************
	
	* @param          exptListString - list string which contains the exception data
	* @param          debugListString - list string which contains the debug data
	* @return         null
	* @description    
	* The method will insert the Log record with debug info and exception info (if necessary) 
	* depending on the custom setting of the current user profile. 
	******************************************************************************/
    private static void writeLogsToDatabase(string exptListString, 
                                            string debugListString){
        
        List<JMS_Log__c> debugListParsed = (List<JMS_Log__c>)
        JSON.deserialize(debugListString,  List<JMS_Log__c>.class);
        List<JMS_Log__c> exceptListParsed = (List<JMS_Log__c>)
        JSON.deserialize(exptListString,  List<JMS_Log__c>.class);
              
        //Cannot make DML calls in a constructor of a visualforce page so if statement to prevent this from happening
        if(!inPageConstructor){
             //if debug custom setting is on  
            if(debugLogEnabled){
                insert debugListParsed;
                //System.debug('debugListString-----'+debugListString);
                //System.debug('debugListParsed-----'+debugListParsed);
            }
            //if exception custom setting is on
            if(exceptionLogEnabled){
                insert exceptListParsed;
                //System.debug('exptListString-----'+exptListString);
                //System.debug('exceptListParsed-----'+exceptListParsed);
            }
        } 
  
    }
    /******************************************************************************
	
	* @return         returns the stacktrace string that will contain the stack 
	*                 trace entries along with the trace level
	******************************************************************************/  
    private static string getStackTrace(){
        
        string retVal ='';

        if (stack != null && stack.size() >0){
            String spaces='                                                                ';       
            for (StackTrace se : stack)   {

                Integer endIndex = 3 * se.level;
                /*******************************************************************
     * Codescan error :Avoid using if statements without curly braces
     * Author:Krishna
     * Date:5/4/2022
     ********************************************************************/
                if (endIndex >= spaces.length()){
                    endIndex = spaces.length()-1;
                retVal += spaces.substring(0,endIndex)+se.getEntry()+'\n';
                }
            }
        }
        return retVal;
        /************************************************************ */
    }
    /******************************************************************************
	
	* @param          null
	* @return         limit string - string that will contains the actual values of 
	*                 the limits reached by the execution against the governor limits 
	*                 set by Salesforce.
	* @description    
	* This methods uses the Limit() method in Salesforce to call all the limits 
	* reached in the current execution context against the governor limits set by 
	* Salesforce. 
	******************************************************************************/  
    private static string getLimits(){        
        string limitstring = 'Query Limits: '+ Limits.getQueries() + '/' + Limits.getLimitQueries() +'\n' +
        					 'DML Rows Limits: '+Limits.getDMLRows()+'/' + Limits.getLimitDMLRows()+'\n' +
        					 'Heap Size Limits: '+Limits.getHeapSize()+'/' +Limits.getLimitHeapSize()+'\n' +
        					 'Query Return Limits: '+Limits.getQueryRows()+'/' + Limits.getLimitQueryRows()+'\n' +
        					 'Aggregate Queries: '+Limits.getAggregateQueries()+'/' + Limits.getLimitAggregateQueries() +
        					 'Callouts: '+Limits.getCallouts()+'/' +Limits.getLimitCallouts() +
        					 'CPU Time: '+Limits.getCpuTime()+'/' +Limits.getLimitCpuTime() +
        					 'DML Statements: '+Limits.getDMLStatements()+'/' +Limits.getLimitDMLStatements() +
        					 'Email Invocations: '+Limits.getEmailInvocations()+'/' +Limits.getLimitEmailInvocations() +
        					 'Future Calls: '+Limits.getFutureCalls()+'/' +Limits.getLimitFutureCalls()  +
        					 'Query Locator Rows: '+Limits.getQueryLocatorRows() +'/'+Limits.getLimitQueryLocatorRows() ;
        return limitstring;
    }
}