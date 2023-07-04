public class giic_createFollowUpServiceRecords {
    
    @InvocableMethod(label = 'create Service Records')
    public static void createServiceRecords(List<InputVariables> inputVariables){
        System.debug('Records to insert ->Top1 '+inputVariables);
        // System.debug('Records to insert ->'+inputVariables);

        List<gii__ServiceTicketLine__c> finalRecordToProcess= new List<gii__ServiceTicketLine__c>();
        ID serviceTicketRecordID;
        ID stAccountID = inputVariables.get(0).accountID;
        gii__ServiceTicket__c serviceTicketRecord = new gii__ServiceTicket__c();
        Map<String , List<gii__ServiceTicketLine__c>> mapOfServiceLines = new Map<String , List<gii__ServiceTicketLine__c>>();
        Schema.DescribeFieldResult fieldDetail =gii__ServiceTicketLine__c.giic_Followup_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldDetail.getPicklistValues();
        System.debug('Records to insert ->'+inputVariables);
        
        List<gii__ServiceTicketLine__c> processServiceRecords = inputVariables.get(0).serviceTicketLine;
        System.debug('Process Records ->'+processServiceRecords);
        System.debug('Size Records ->'+processServiceRecords.size());
        
        for(gii__ServiceTicketLine__c serviceTicket : processServiceRecords){
            serviceTicketRecordID = serviceTicket.gii__ServiceTicket__c;
            if(mapOfServiceLines.containsKey(serviceTicket.giic_Followup_Reason__c)){
                List<gii__ServiceTicketLine__c> myList = mapOfServiceLines.get(serviceTicket.giic_Followup_Reason__c);
                myList.add(serviceTicket);               
            }
            else {
                List<gii__ServiceTicketLine__c> myList = new List<gii__ServiceTicketLine__c>{serviceTicket};
                    mapOfServiceLines.put(serviceTicket.giic_Followup_Reason__c, myList);
            }
        }
        System.Debug('This is Map ->'+mapOfServiceLines);
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get('gii__ServiceTicket__c').getDescribe().fields.getMap().keySet());
        String query  = 'SELECT '+String.join(fields, ',')+' FROM gii__ServiceTicket__c  WHERE ID =:serviceTicketRecordID';
        System.Debug('Query is ->'+query);
        serviceTicketRecord = Database.query(query);
        System.Debug('Output is ->'+serviceTicketRecord);
        
        for(String key : mapOfServiceLines.keySet()){
            gii__ServiceTicket__c followUpServiceTicket = new gii__ServiceTicket__c();
            followUpServiceTicket =    serviceTicketRecord.clone(false, false, false, false);
            followUpServiceTicket.gii__ServiceTicketStatus__c = 'Open';
            followUpServiceTicket.gii__DateTimeClosed__c = null;
            followUpServiceTicket.giic_Parent_Service_Ticket__c = serviceTicketRecord.Id;
            followUpServiceTicket.gii__DateTimeOpened__c = DateTime.now();
            insert followUpServiceTicket;
            System.Debug('Record inserted is ->'+followUpServiceTicket);
            
            for(gii__ServiceTicketLine__c stl : mapOfServiceLines.get(key)){
                System.debug('Records Returned for STL ->'+stl);
                gii__ServiceTicketLine__c stlToProcess = new gii__ServiceTicketLine__c();
                if(stl.giic_Followup_Reason__c == 'Tech Recommends Replacement'){
                    System.Debug('Checking the count here');
                finalRecordToProcess.addAll(createFollowUpServiceLineRecords(followUpServiceTicket.id , stl,stAccountID));
                }
                else {

                stlToProcess.giic_Priority__c = stl.giic_Priority__c;
                stlToProcess.gii__FieldServiceEngineer__c = stl.gii__FieldServiceEngineer__c;
                stlToProcess.gii__AssetReference__c = stl.gii__AssetReference__c;
                stlToProcess.gii__Product__c = stl.gii__Product__c;
                stlToProcess.gii__Quantity__c = stl.gii__Quantity__c;
                stlToProcess.gii__Site__c = stl.gii__Site__c;
                stlToProcess.gii__ServiceDueDate__c = stl.gii__ServiceDueDate__c;
                stlToProcess.gii__TroubleComments__c = stl.gii__TroubleComments__c;
                // Populate Type field
                
                stlToProcess.gii__ServiceTicket__c = followUpServiceTicket.id;
                finalRecordToProcess.add(stlToProcess);
            }
                //        System.Debug('Cloned Record is ->'+clonedRecord);

            }
            followUpServiceTicket = null;
        }
        
        if(finalRecordToProcess.size() > 0){
            System.Debug('Size of final is ->'+finalRecordToProcess.size());
            System.Debug('Final records to process ->'+finalRecordToProcess);
            try {
                insert finalRecordToProcess;
                System.Debug('Records of final are ->'+finalRecordToProcess);
            }
            Catch(Exception e){
                System.debug('Error is ->'+e);
            }
        }
        
    }
    
    public static List<gii__ServiceTicketLine__c> createFollowUpServiceLineRecords(ID followUpServiceTicket,gii__ServiceTicketLine__c stl , ID stAccountID){
        	System.debug('Checking This Method');
        		List<gii__ServiceTicketLine__c> stlToProcess = new List<gii__ServiceTicketLine__c>();
        	List<gii__ServiceTicketLine__c> passSTLToProcess = new List<gii__ServiceTicketLine__c>();
       			gii__ServiceTicketLine__c followupReturnSTL = new gii__ServiceTicketLine__c();
      			followupReturnSTL.gii__EngineerAssignmentStatus__c = 'To be Determined';
        		followupReturnSTL.gii__LineStatus__c = 'Open - Followup Ticket';
                followupReturnSTL.giic_Priority__c = stl.giic_Priority__c;
                followupReturnSTL.gii__FieldServiceEngineer__c = stl.gii__FieldServiceEngineer__c;
                followupReturnSTL.gii__AssetReference__c = stl.gii__AssetReference__c;
                followupReturnSTL.gii__Product__c = stl.gii__Product__c;
                followupReturnSTL.gii__Quantity__c = stl.gii__Quantity__c;
                followupReturnSTL.gii__Site__c = stl.gii__Site__c;
                followupReturnSTL.gii__ServiceDueDate__c = stl.gii__ServiceDueDate__c;
                followupReturnSTL.gii__TroubleComments__c = stl.gii__TroubleComments__c;
        		followupReturnSTL.gii__ServiceTicketLineStatus__c = 'Open';
       			gii__ServiceType__c gst = [select id from gii__ServiceType__c WHERE Name = 'Removal' LIMIT 1];
        		followupReturnSTL.gii__Type__c = gst.id;                
                followupReturnSTL.gii__ServiceTicket__c = followUpServiceTicket;
        System.debug('Processing new STL'+followupReturnSTL);
        		stlToProcess.add(followupReturnSTL);
        System.debug('New Records To Process'+stlToProcess);
      passSTLToProcess = createFollowUpInstallationServiceLineRecords(followUpServiceTicket , stl,stlToProcess,stAccountID );
        System.Debug('Lets pass this list ->'+passSTLToProcess);
        System.Debug('Lets pass this size ->'+passSTLToProcess.size());
        return passSTLToProcess;
    }
    
    public static List<gii__ServiceTicketLine__c> createFollowUpInstallationServiceLineRecords(ID followUpServiceTicket,gii__ServiceTicketLine__c stl, List<gii__ServiceTicketLine__c> stlToProcess,ID stAccountID){
       	
        System.Debug('Check Account'+stAccountID);
        gii__SalesOrder__c salesOrder = new gii__SalesOrder__c();
        salesOrder.gii__Account__c = stAccountID;
        salesOrder.gii__OrderDate__c = Date.today();
        salesOrder.gii__OrderType__c = 'Transfer';
        salesOrder.giic_PlacementReason__c = 'Existing Customer - Replacement';
        insert salesOrder;
        System.Debug('Sales order ->'+salesOrder);
        
        gii__SalesOrderLine__c salesOrderLine = new gii__SalesOrderLine__c();
        salesOrderLine.gii__SalesOrder__c = salesOrder.id;
        salesOrderLine.gii__OrderQuantity__c = 1;
        salesOrderLine.gii__Product__c = stl.gii__Product__c;
        insert salesOrderLine;
        System.Debug('Sales order ->'+salesOrderLine);
        
                List<gii__ServiceTicketLine__c> installationstlToProcess = new List<gii__ServiceTicketLine__c>();
        		installationstlToProcess.addAll(stlToProcess);
       			gii__ServiceTicketLine__c followupInstallationSTL = new gii__ServiceTicketLine__c();
      			followupInstallationSTL.gii__EngineerAssignmentStatus__c = 'To be Determined';
        		followupInstallationSTL.gii__LineStatus__c = 'Open - Followup Ticket';
                followupInstallationSTL.giic_Priority__c = stl.giic_Priority__c;
                followupInstallationSTL.gii__FieldServiceEngineer__c = stl.gii__FieldServiceEngineer__c;
               // followupInstallationSTL.gii__AssetReference__c = stl.gii__AssetReference__c;
                followupInstallationSTL.gii__Product__c = stl.gii__Product__c;
                followupInstallationSTL.gii__Quantity__c = stl.gii__Quantity__c;
                followupInstallationSTL.gii__Site__c = stl.gii__Site__c;
                followupInstallationSTL.gii__ServiceDueDate__c = stl.gii__ServiceDueDate__c;
                followupInstallationSTL.gii__TroubleComments__c = stl.gii__TroubleComments__c;
        		followupInstallationSTL.gii__ServiceTicketLineStatus__c = 'Open';
       			gii__ServiceType__c gst = [select id from gii__ServiceType__c WHERE Name = 'Installation' LIMIT 1];
        		followupInstallationSTL.gii__Type__c = gst.id;                
                followupInstallationSTL.gii__ServiceTicket__c = followUpServiceTicket;
       			followupInstallationSTL.giic_SalesOrderLine__c = salesOrderLine.id;
        		followupInstallationSTL.giic_SalesOrder__c = salesOrder.id;
     		   installationstlToProcess.add(followupInstallationSTL);
        
        		System.Debug('Here is my final list ->'+installationstlToProcess);
        return installationstlToProcess;
        		
    }
    
    public class InputVariables{
        
        @InvocableVariable
        public List<gii__ServiceTicketLine__c> serviceTicketLine;
        
        @InvocableVariable
        public ID accountID;
        
        @InvocableVariable
        public ID productID;
        
    }
    
    
}