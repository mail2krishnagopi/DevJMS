/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class giic_AddServiceTicketLine {
    
    
    @AuraEnabled(cacheable=true)
    public static parentRecordWrapper getParentRecordDetails(String recId) {
        system.debug('assetRecID::::'+recId +  Id.valueof(recId).getsobjecttype());
        system.debug('objName::::' +  Id.valueof(recId).getsobjecttype());
        Schema.SObjectType AssetReferenceObject = Schema.gii__AssetReference__c.getSObjectType();
        Schema.SObjectType siteObject = Schema.gii__Site__c.getSObjectType();
        Schema.SObjectType AccObject = Schema.Account.getSObjectType();
        Schema.SObjectType objName =  Id.valueof(recId).getsobjecttype();
        system.debug('objName::::'+ objName);

        List<gii__AssetReference__c> lstAssetReference = new List<gii__AssetReference__c>();
        parentRecordWrapper objRecWrapper = new parentRecordWrapper();
        string objectApiName;
        if(objName == AssetReferenceObject){
           lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c, 
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__Site__r.gii__FieldServiceEngineer__c,gii__Site__r.gii__FieldServiceEngineerGroup__r.Name,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c  
                                 FROM gii__AssetReference__c WHERE id =:recId]; 
           
                                 objRecWrapper.objApiName= string.valueof(objName);
                                 if(!String.isBlank(lstAssetReference[0].gii__Site__c))
                                 {
                                 objRecWrapper.recordId = lstAssetReference[0].gii__Site__c;
                                 }
                                 else
                                 {
                                    objRecWrapper.recordId = '';
                                 }

        system.debug('Asset Ref objName::::'+ objRecWrapper);
        }
        else if(objName == siteObject)
        {

            objRecWrapper.objApiName= string.valueof(objName);
            system.debug('Asset Ref objName::::'+ objRecWrapper);
        }
        else if(objName == AccObject)
        {
            objRecWrapper.objApiName= string.valueof(objName);
        }
       
        return objRecWrapper;      
    }
    
    @AuraEnabled
    public static string createServiceTicket(List<assetReferenceWrapper> assetRefList, String priority, String type, String trouble,String objName , List<typeWrapperClass> typeWrapperlist, List<troubleWrapperClass> troubleWrapperlist) {
        system.debug('assetRefList::::'+assetRefList);
        system.debug('priority::::'+priority);
        system.debug('type::::'+ type );
        system.debug('trouble::::'+trouble );
        system.debug('trouble::::'+objName);
        system.debug('typeWrapperlist::::'+typeWrapperlist);
        system.debug('troubleWrapperlist::::'+troubleWrapperlist);
        //system.debug('typetess::::'+typetess);
       //list<typeWrapperClass> listTypeWrapperAtual = (list<typeWrapperClass>)JSON.deserialize(typetess, typeWrapperClass.class);
      // System.debug('listTypeWrapperAtual::::'+listTypeWrapperAtual);
        list<gii__ServiceTicketLine__c> lstservTicketline = new list<gii__ServiceTicketLine__c>();
        gii__ServiceTicket__c servTicket = new gii__ServiceTicket__c();
        if(assetRefList != null && assetRefList.size() > 0){
        system.debug('typeWrapperlist::::'+typeWrapperlist);
            map<String , string>  mapOfType =new map<String , string>();
             for(typeWrapperClass  tw : typeWrapperlist){
               if( (!mapOfType.containsKey(tw.assestId)) &&  (tw.typeOfId != null ||tw.typeOfId != '' )){
                mapOfType.put(tw.assestId ,tw.typeOfId );
               }
             }
            system.debug('mapOfType::::'+mapOfType);
          system.debug('troubleWrapperlist::::'+troubleWrapperlist);
             map<String , string>  mapOfTrouble =new map<String , string>();
             for(troubleWrapperClass  tw : troubleWrapperlist){
               if( (!mapOfTrouble.containsKey(tw.assestId)) &&  (tw.troubleVal != null ||tw.troubleVal != '' )){
                mapOfTrouble.put(tw.assestId ,tw.troubleVal);
               }
             }
   system.debug('mapOfTrouble::::'+mapOfTrouble);
            servTicket.gii__Account__c = assetRefList[0].objAssetRef.gii__Account__c;
            servTicket.gii__Site__c = assetRefList[0].objAssetRef.gii__Site__c;
            servTicket.gii__ServiceDueDate__c = system.today() + 1;
            //servTicket.gii__DateTimeOpened__c = system.today();
            system.debug('servTicket:--'+servTicket);
            insert servTicket;
            system.debug('servTicket Id:--'+servTicket.id); 
            for(assetReferenceWrapper assetRef: assetRefList)
            {
                if(assetRef.isSelected){
                    gii__ServiceTicketLine__c servTicketline = new gii__ServiceTicketLine__c ();
                    servTicketline.gii__ServiceTicket__c = servTicket.id;
                    servTicketline.gii__Site__c =assetRef.objAssetRef.gii__Site__c;
                    servTicketline.gii__AssetReference__c = assetRef.objAssetRef.Id;
                    servTicketline.giic_Priority__c = priority;                    
                   // servTicketline.gii__Type__c = type;
                    servTicketline.gii__Type__c =mapOfType.get(assetRef.objAssetRef.id);
                    servTicketline.gii__ServiceDueDate__c = system.today() + 1; 
                    servTicketline.gii__TroubleComments__c = mapOfTrouble.get(assetRef.objAssetRef.id);
                    
                    
                
                    
                    lstservTicketline.add(servTicketline);
                }
                
                
            }
           // system.debug('lstservTicketline:--'+lstservTicketline);
           insert lstservTicketline;       
            
         //   giic_ServiceTicketLineTriggerHandler.assignFSEBasedOnCertification(lstservTicketline);
            
        }
        return servTicket.id;
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<assetReferenceWrapper> getAssetReferenceList(String recId) {
        system.debug('assetRecID::::'+recId);
        system.debug('objName::::' +  Id.valueof(recId).getsobjecttype());
        Schema.SObjectType assetReferenceObject = Schema.gii__AssetReference__c.getSObjectType();
        Schema.SObjectType siteObject = Schema.gii__Site__c.getSObjectType();
        Schema.SObjectType accountObject = Schema.Account.getSObjectType();
        //Schema.SObjectType siteObject = Schema.gii__Site__c.getSObjectType();
        Schema.SObjectType objName =  Id.valueof(recId).getsobjecttype();
        system.debug('objName::::'+ objName);
        List<gii__AssetReference__c> lstAssetReference = new List<gii__AssetReference__c>();
        List<gii__Site__c> siteList = new List<gii__Site__c>();
        set<id> siteId = new set<id>();
        if(objName == assetReferenceObject){
            lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c, 
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__ProductReference__r.giic_New_Certification_Training_Required__c,//Added by bhuvana for certification
                                 gii__ProductReference__r.giic_Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineer__c,
                                 gii__Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineer__r.gii__Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineerGroup__c,
                                 gii__Site__r.gii__FieldServiceEngineerGroup__r.Name,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c  ,
                                 gii__ServiceContract__r.Name,gii__ServiceContractLine__r.Name ,
                                 gii__Status__c
                                 FROM gii__AssetReference__c WHERE id =:recId 
                                 AND gii__Status__c !='Decommissioned']; 
        }
        else if(objName == siteObject)
        {
            lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c,
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__ProductReference__r.giic_New_Certification_Training_Required__c,//Added by bhuvana for certification
                                 gii__ProductReference__r.giic_Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineer__c,
                                 gii__Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineer__r.gii__Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineerGroup__c,
                                 gii__Site__r.gii__FieldServiceEngineerGroup__r.Name,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c ,
                                 gii__ServiceContract__r.Name,gii__ServiceContractLine__r.Name,
                                 gii__Status__c
                                 FROM gii__AssetReference__c WHERE gii__Site__c =:recId  
                                 AND gii__Status__c !='Decommissioned']; 
        }
        else if(objName == accountObject)
        {
            siteList = [select id from gii__Site__c where gii__Account__c =:recId];
            for (gii__Site__c site : siteList) 
            {
                siteId.add(site.Id);
            }

            lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c, 
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__ProductReference__r.giic_New_Certification_Training_Required__c, //Added by bhuvana for certification
                                 gii__ProductReference__r.giic_Certification__c, //Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineer__c,
                                 gii__Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c,//Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineer__r.gii__Certification__c, //Added by bhuvana for certification
                                 gii__Site__r.gii__FieldServiceEngineerGroup__c,
                                 gii__Site__r.gii__FieldServiceEngineerGroup__r.Name,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c,
                                 gii__ServiceContract__r.Name,gii__ServiceContractLine__r.Name ,
                                 gii__Status__c
                                 FROM gii__AssetReference__c WHERE gii__Site__c in : siteId 
                                 AND gii__Status__c !='Decommissioned']; 

        }
        system.debug('lstAssetReference'+ lstAssetReference);
        
        List<assetReferenceWrapper> lstwrpAFLine = new List<assetReferenceWrapper>();
        
        for(gii__AssetReference__c obj: lstAssetReference)
        {
           //Bhuvana Starts for certification logic
         /*  if ((obj.gii__ProductReference__r.giic_New_Certification_Training_Required__c == obj.gii__Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c ||
            obj.gii__ProductReference__r.giic_New_Certification_Training_Required__c != obj.gii__Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c) &&
               (obj.gii__Site__r.gii__FieldServiceEngineer__r.gii__Certification__c == null || obj.gii__ProductReference__r.giic_Certification__c == null ||
               !obj.gii__Site__r.gii__FieldServiceEngineer__r.gii__Certification__c.contains(obj.gii__ProductReference__r.giic_Certification__c))  || (
                   obj.gii__ProductReference__r.giic_New_Certification_Training_Required__c == true && obj.gii__Site__r.gii__FieldServiceEngineer__r.giic_Has_not_Completed_new_Certification__c == false &&
                    obj.gii__Site__r.gii__FieldServiceEngineer__r.gii__Certification__c.contains(obj.gii__ProductReference__r.giic_Certification__c)
                )) {
                    obj.gii__Site__r.gii__FieldServiceEngineer__c =  null;
            }//Bhuvana ends*/
            assetReferenceWrapper wrpAFLine = new assetReferenceWrapper();
            wrpAFLine.objAssetRef = obj; 
            wrpAFLine.objApiName= string.valueof(objName);
            if(obj.gii__Site__r.Name != null && obj.gii__Site__r.Name != '')
            {
                wrpAFLine.siteName = obj.gii__Site__r.Name;
            }
            else {
                wrpAFLine.siteName = '';
            }
            if(obj.gii__ServiceContract__r.Name != null && obj.gii__ServiceContract__r.Name != '')
            {
                wrpAFLine.contractName = obj.gii__ServiceContract__r.Name;
            }
            else {
                wrpAFLine.contractName = '';
            }
            if(obj.gii__ServiceContractLine__r.Name != null && obj.gii__ServiceContractLine__r.Name != '')
            {
                wrpAFLine.contractLineName = obj.gii__ServiceContractLine__r.Name;
            }
            else {
                wrpAFLine.contractLineName = '';
            }

            lstwrpAFLine.add(wrpAFLine);  
        }
        return lstwrpAFLine;      
    }

    @AuraEnabled
    public static List<assetReferenceWrapper> searchAssetReference(String siteRecId,String assetRecId) {
        system.debug('siteRecId::::'+siteRecId);
        system.debug('assetRecId::::'+assetRecId);
        List<gii__AssetReference__c> lstAssetReference = new List<gii__AssetReference__c>();
        if((siteRecId != '' && siteRecId != null) && (assetRecId != '' && assetRecId != null))
        {
            lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c, 
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__Site__r.gii__FieldServiceEngineer__c,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c,
                                 gii__ServiceContract__r.Name,gii__ServiceContractLine__r.Name  
                                 FROM gii__AssetReference__c WHERE id =:assetRecId and gii__Site__c =: siteRecId and gii__Status__c !='Decommissioned'];
        }
        else if((siteRecId != '' && siteRecId != null) && (assetRecId == '' || assetRecId == null))
        {
            lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c, 
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__Site__r.gii__FieldServiceEngineer__c,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c ,
                                 gii__ServiceContract__r.Name,gii__ServiceContractLine__r.Name
                                 FROM gii__AssetReference__c WHERE gii__Site__c =: siteRecId and gii__Status__c !='Decommissioned'];
        }
        else if((siteRecId == ''|| siteRecId == null) && (assetRecId != '' && assetRecId != null))
        {
            lstAssetReference = [SELECT Id,Name, gii__ProductReference__c,gii__Account__c, 
                                 gii__ProductReference__r.Name,gii__Site__c,gii__Site__r.Name,
                                 gii__Site__r.gii__FieldServiceEngineer__c,gii__ProductSerial__c,
                                 gii__ServiceContract__c,gii__ServiceContractLine__c ,
                                 gii__ServiceContract__r.Name,gii__ServiceContractLine__r.Name
                                 FROM gii__AssetReference__c WHERE id =:assetRecId and gii__Status__c !='Decommissioned'];
        }


        system.debug('lstAssetReference'+ lstAssetReference);
        
        List<assetReferenceWrapper> lstwrpAFLine = new List<assetReferenceWrapper>();
        if(lstAssetReference.size()>0)
        {
            system.debug('lstAssetReference' + lstAssetReference.size() + '::'+  lstAssetReference);
        for(gii__AssetReference__c obj: lstAssetReference)
        {
            assetReferenceWrapper wrpAFLine = new assetReferenceWrapper();
            wrpAFLine.objAssetRef = obj; 
           // wrpAFLine.objApiName= string.valueof(objName);
           if(obj.gii__Site__r.Name != null || obj.gii__Site__r.Name != '')
            {
                wrpAFLine.siteName = obj.gii__Site__r.Name;
            }
            else {
                wrpAFLine.siteName = '';
            }
           if(obj.gii__ServiceContract__r.Name != null || obj.gii__ServiceContract__r.Name != '')
           {
               wrpAFLine.contractName = obj.gii__ServiceContract__r.Name;
           }
           else {
               wrpAFLine.contractName = '';
           }
           if(obj.gii__ServiceContractLine__r.Name != null || obj.gii__ServiceContractLine__r.Name != '')
           {
               wrpAFLine.contractLineName = obj.gii__ServiceContractLine__r.Name;
           }
           else {
               wrpAFLine.contractLineName = '';
           }
            lstwrpAFLine.add(wrpAFLine);  
        }
    }
        return lstwrpAFLine;    

    }
    
    
    
    /*-----------Wrapper Class---------*/
    public class assetReferenceWrapper{
        
        @AuraEnabled
        public Boolean isSelected{get;set;}
        
        @AuraEnabled
        public gii__AssetReference__c objAssetRef{get;set;}
        
        @AuraEnabled public String prodCode;
        
        @AuraEnabled public String objApiName;

        @AuraEnabled public String contractName{get;set;}

        @AuraEnabled public String contractLineName{get;set;}

        @AuraEnabled public String siteName{get;set;}
        
        public assetReferenceWrapper(){
            this.isSelected = false;
        }
    }
    public class typeWrapperClass{

        @AuraEnabled public String assestId{get; set;}
         @AuraEnabled public String typeOfId{get; set;}

    }
    public class troubleWrapperClass{

        @AuraEnabled public String assestId{get; set;}
         @AuraEnabled public String troubleVal{get; set;}

    }

    public class parentRecordWrapper{

        @AuraEnabled public String objApiName;
        @AuraEnabled public String recordId;

    }
}