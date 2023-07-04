/*******************************************************************************

* @description  Class that is used to retrieve the LogConfig custom settings of 
*               the current user profile. 
*******************************************************************************/
public class JMS_LogConfigSettings {
    
    private static JMS_Log_Config__c theSetting = JMS_Log_Config__c.getInstance(UserInfo.getUserId());
    
    private static Map<string, schema.recordtypeinfo> recordTypeInfo = Schema.getGlobalDescribe().get('JMS_Log__c').getDescribe().getRecordTypeInfosByName();
    
    
    public static Id getDebugRecordType(){
        
        if(recordTypeInfo.get(theSetting.JMS_Debug_Record_Type__c)!=null){
            
            return recordTypeInfo.get(theSetting.JMS_Debug_Record_Type__c).getRecordTypeId();
            
        }
        else{
            
            return null; 
            
        }  
        
    }
    
    
    public static Id getExceptionRecordType(){
        
        if(recordTypeInfo.get(theSetting.JMS_Exception_Record_Type__c)!=null){
            
            return recordTypeInfo.get(theSetting.JMS_Exception_Record_Type__c).getRecordTypeId();
            
        }
        else{
            
            return null; 
            
        }    
    }
    
    public static  Boolean loggingEnabled(){
        
        return theSetting.JMS_Logging_Enabled__c;
    }
    public static  Boolean exceptionEnabled(){
        
        return theSetting.JMS_Exceptions_Enabled__c;
    }
}