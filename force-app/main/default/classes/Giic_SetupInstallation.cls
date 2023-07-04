public with sharing class Giic_SetupInstallation {
  @AuraEnabled(cacheable=true)
    public static List<salesOrderLineDetailWrapper> getSalesOrderLines(String soId) {
        system.debug('soId::::'+soId);
        List<gii__SalesOrderLine__c> lstSOLine = [SELECT Id,Name,giic_Product__c,gii__SalesOrder__r.gii__Account__c,
                                                  gii__SalesOrder__r.giic_Site__c ,gii__SalesOrder__r.giic_Notes__c,
                                                  gii__Product__c,gii__Site__c, gii__UpdateAsset__c,
                                                  gii__SalesOrder__c,gii__OpenQuantity__c,gii__Product__r.gii__SerialControlled__c,
                                                  gii__SalesOrder__r.giic_Site__r.name,
                                                  gii__Product__r.giic_New_Certification_Training_Required__c,
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c, 
                                                  gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.gii__Certification__c,
                                                  gii__Product__r.giic_Certification__c ,(SELECT Id, Name FROM Service_Ticket_Lines__r)
                                                  FROM gii__SalesOrderLine__c WHERE gii__SalesOrder__c =:soId
                                                  and gii__Product__r.gii__SerialControlled__c = true];
        system.debug('lstSOLine::12::'+lstSOLine);
         system.debug('lstSOLine::12::'+lstSOLine.size());
        List<salesOrderLineDetailWrapper> lstwrpSOLine = new List<salesOrderLineDetailWrapper>();
        for(gii__SalesOrderLine__c obj : lstSOLine){
                    system.debug('lstSOLine::::'+lstSOLine[0].gii__Product__r.gii__SerialControlled__c);

            system.debug('Service_Ticket_Lines::::'+obj.Service_Ticket_Lines__r);
            if(obj.Service_Ticket_Lines__r == null || obj.Service_Ticket_Lines__r.size() == 0){
                salesOrderLineDetailWrapper wrpSOLine = new salesOrderLineDetailWrapper();
                wrpSOLine.objSOLine = obj; 
                lstwrpSOLine.add(wrpSOLine);               
            }
        }
        return lstwrpSOLine;        
    }

    @AuraEnabled
    public static string createServiceTicket(List<salesOrderLineDetailWrapper> solList, date Serviceduedate) {
        system.debug('solList::::'+solList+'-------'+Serviceduedate);
        gii__ServiceTicket__c servTicket = new gii__ServiceTicket__c();
        if(solList != null && solList.size() > 0){
            list<gii__SalesOrder__c> listSO=[select id , giic_Notes__c from gii__SalesOrder__c  where id  =:solList[0].objSOLine.gii__SalesOrder__c];// Added by santosh
            system.debug('listSO List:'+ listSO);
            system.debug('listSO[0].giic_Notes__c List:'+listSO[0].giic_Notes__c);
            list<gii__ServiceTicketLine__c> lstservTicketline = new list<gii__ServiceTicketLine__c>();
            List<gii__InventoryReserve__c> invResList = [select id, gii__ProductSerial__c,gii__Product__c,gii__SalesOrderLine__c from gii__InventoryReserve__c where gii__SalesOrder__c =: solList[0].objSOLine.gii__SalesOrder__c and gii__Product__r.gii__SerialControlled__c = true ]; 
            system.debug('Inventory Reserve List:'+ invResList);
            Map<id, id> invResMap = new Map<id,id>();
           for(gii__InventoryReserve__c invRes : invResList)
           {
            invResMap.put(invRes.gii__SalesOrderLine__c, invRes.id);
           }
           system.debug('Inventory Reserve MAp:'+ invResMap);
            system.debug('SOL:'+ solList[0]);
           system.debug('NOTES-->:'+ solList[0].objSOLine.gii__SalesOrder__r.giic_Notes__c);
            servTicket.giic_SalesOrder__c = solList[0].objSOLine.gii__SalesOrder__c;
            servTicket.gii__Account__c = solList[0].objSOLine.gii__SalesOrder__r.gii__Account__c;
            servTicket.gii__ServiceDueDate__c = Serviceduedate;
           // servTicket.giic_Notes__c =  listSO[0].giic_Notes__c;  //Added by santosh
            servTicket.giic_Notes__c =solList[0].objSOLine.gii__SalesOrder__r.giic_Notes__c;  //Added by santosh
            //servTicket.gii__Site__c = solList[0].objSOLine.gii__Site__c;
            system.debug('servTicket:--'+servTicket);
            insert servTicket;
            system.debug('servTicket Id:--'+servTicket.id); 
            gii__ServiceType__c serviceType=[select id,name from gii__ServiceType__c where name='Installation'];     
            for(salesOrderLineDetailWrapper  solwrap: solList ){
                 if(solwrap.isSelected  ){
                    
                    
                
                    system.debug('Data::'+solwrap.objSOLine.gii__SalesOrder__c);
                    system.debug('Data::'+solwrap.objSOLine.gii__SalesOrder__r.name);
                    system.debug('Data::'+solwrap.objSOLine.gii__SalesOrder__r.gii__Account__c);
                    system.debug('Data::'+solwrap.objSOLine.gii__SalesOrder__r.giic_Site__c);
        
                    
                    gii__ServiceTicketLine__c servTicketline = new gii__ServiceTicketLine__c ();
                    
                    servTicketline.giic_SalesOrder__c = solwrap.objSOLine.gii__SalesOrder__c;
                    servTicketline.giic_SalesOrderLine__c = solwrap.objSOLine.Id;
                    servTicketline.gii__Product__c = solwrap.objSOLine.gii__Product__c;
                    servTicketline.giic_Priority__c = 'Standard';
                   
                    if((invResMap.get(solwrap.objSOLine.Id) != Null) && (!invResMap.isempty()))
                    {
                        system.debug('invResMap.get(solwrap)'+invResMap.get(solwrap.objSOLine.Id)); 
                        servTicketline.giic_InventoryReserve__c = invResMap.get(solwrap.objSOLine.Id);
                    }
                    servTicketline.gii__Site__c = solwrap.objSOLine.gii__SalesOrder__r.giic_Site__c;
                    servTicketline.gii__ServiceTicket__c = servTicket.id;
                    servTicketline.gii__ServiceDueDate__c = Serviceduedate;
                    servTicketline.giic_UpdateAsset__c = true;
                    if(serviceType!=null){
                        servTicketline.gii__Type__c = serviceType.id;
                    }
                    
                    //Manogna Start
                    /*String fseCertifications = solwrap.objSOLine.gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.gii__Certification__c;
                    String productCertification = solwrap.objSOLine.gii__Product__r.giic_Certification__c;
                    system.debug('+++fseCertifications'+fseCertifications);
                    system.debug('+++productCertification'+productCertification);
                    List<String> fseCertificationsList = fseCertifications.split(';');
                    system.debug('+++fseCertificationsList'+fseCertificationsList);
                   
                    //servTicketline.gii__FieldServiceEngineer__c= 'a203C000000jl9kQAA';
                   // gii__FieldServiceEngineer__c fse=[select id from gii__FieldServiceEngineer__c where id='a1x3C00000188MrQAI'];
                    //servTicketline.gii__FieldServiceEngineer__c=fse.id;
                
                    if(((solwrap.objSOLine.gii__Product__r.giic_New_Certification_Training_Required__c==true && solwrap.objSOLine.gii__Product__r.giic_New_Certification_Training_Required__c==solwrap.objSOLine.gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c) 
	                    || solwrap.objSOLine.gii__Product__r.giic_New_Certification_Training_Required__c==false)
	                    && solwrap.objSOLine.gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.gii__Certification__c.contains(solwrap.objSOLine.gii__Product__r.giic_Certification__c)){*/
                   /* if(((solwrap.objSOLine.gii__Product__r.giic_New_Certification_Training_Required__c==true && solwrap.objSOLine.gii__Product__r.giic_New_Certification_Training_Required__c==solwrap.objSOLine.gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c) 
                            || solwrap.objSOLine.gii__Product__r.giic_New_Certification_Training_Required__c==false)
                            && fseCertificationsList.contains(productCertification)){
	                    //assign fse
                        servTicketline.gii__FieldServiceEngineer__c = solwrap.objSOLine.gii__SalesOrder__r.giic_Site__r.gii__FieldServiceEngineer__r.Id;
                    }
                    else{
	                    //dont assign fse
                        servTicketline.gii__FieldServiceEngineer__c=null;
                    }*/
                    //Manogna End
                    lstservTicketline.add (servTicketline);
                 }
                
            }
            system.debug('lstservTicketline:--'+lstservTicketline);
            insert lstservTicketline;

            //giic_ServiceTicketLineTriggerHandler.assignFSEBasedOnCertification(lstservTicketline); // added by bhuvana
        }
        return servTicket.id;
    }

    // below method  return the site id from  sales order.
   @AuraEnabled(cacheable=true)
    public static String   getSite(String soId) { // getSite
        list<gii__SalesOrder__c> listSO=[select id , giic_Site__c, gii__Account__c, gii__SalesQuote__c from gii__SalesOrder__c  where id =:soId];
       String result ;
        if(listSO.size() > 0){
            result=listSO[0].giic_Site__c;
        }
        return result;
            }
    /*-----------Wrapper Class---------*/
    public class salesOrderLineDetailWrapper{
        @AuraEnabled
        public gii__SalesOrderLine__c objSOLine{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}

        public salesOrderLineDetailWrapper(){
            this.isSelected = false;
        }
    }
}