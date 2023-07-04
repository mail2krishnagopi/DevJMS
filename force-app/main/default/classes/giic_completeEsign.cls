public with sharing class giic_completeEsign {
    @AuraEnabled(cacheable=true)
    public static List<ServiceTicketLineWrapper> getServiceTicketLineList(String recId) {
        List<ServiceTicketLineWrapper> lststlWrapper = new List<ServiceTicketLineWrapper>();
        List<gii__ServiceTicketLine__c> stlList = [SELECT Id, Name,giic_SignedBy__c,giic_Signed_Date__c, gii__IsClosed__c,gii__LineStatus__c,gii__Type__c,gii__Type__r.Name, gii__ServiceTicket__c,gii__FieldServiceEngineer__c , gii__AssetReference__c,gii__AssetReference__r.Name,gii__Site__r.Name FROM gii__ServiceTicketLine__c Where gii__ServiceTicket__c =: recId and gii__IsClosed__c= true];
        system.debug('List of ServiceTicket Line'+stlList);
       

        for(gii__ServiceTicketLine__c stl : stlList)
        {
            ServiceTicketLineWrapper stlWrapper = new ServiceTicketLineWrapper();
            if(stl.gii__AssetReference__r.Name != null || stl.gii__AssetReference__r.Name != '')
            {
                stlWrapper.assetRefName = stl.gii__AssetReference__r.Name;
            }
            else {
                stlWrapper.assetRefName = '';
            }
            stlWrapper.objSTLRef = stl;
            lststlWrapper.add(stlWrapper);
        }

        return lststlWrapper;
    }

    @AuraEnabled
    public static void saveSignature(String signElement,Id recId,List<ServiceTicketLineWrapper> stlSelectedList,String signedBy){
        system.debug('RecIDD:'+ recId + '==> ' + signedBy);
        system.debug('Selected STL List'+ stlSelectedList.size()+' ==> '+ stlSelectedList );
       
        DateTime todayDate = system.now();
        String todayMonth=todayDate.format('MM');
        system.debug(todayDate + ' --- '+ todayMonth);
        
        List<Attachment> attList = new List<Attachment>();
        List<gii__ServiceTicketLine__c> stlUpdateList = new List<gii__ServiceTicketLine__c>();


        for(ServiceTicketLineWrapper stl : stlSelectedList)
        {
            if(stl.isSelected){
        Attachment objAttachment = new Attachment();
        objAttachment.Name = stl.objSTLRef.Name+'-03.png';
        objAttachment.ParentId = stl.objSTLRef.Id;
        objAttachment.ContentType = 'image/png';
        objAttachment.Body = EncodingUtil.base64Decode(signElement);        
        attList.add(objAttachment);
        }
    }

        if(attList.size()>0)
        {
            system.debug(' Attachment List'+ attList.size()+' ==> '+ attList);
            Database.Insert(attList);
        }
      
        for(ServiceTicketLineWrapper stl : stlSelectedList)
        {
            if(stl.isSelected){
            gii__ServiceTicketLine__c stlUpdate = new gii__ServiceTicketLine__c();
           // stlUpdate.giic_Signed_Date__c = todayDate;
            stlUpdate.id = stl.objSTLRef.id;
            stlUpdate.giic_SignedBy__c = signedBy;
            stlUpdateList.add(stlUpdate);
            }
        }
        if(stlUpdateList.size()>0)
        {
            system.debug('Selected STL List'+ stlUpdateList.size()+' ==> '+ stlUpdateList);
            Database.Update(stlUpdateList);
        }
      /* 
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce.
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.Title = 'Signature-'+recId+'-'+System.now() +'.png';//Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(signElement);//File content
        Insert cVersion;
        


        //Get the Uploaded doc ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
         system.debug('conDocument:' + conDocument);
       //Insert ContentDocumentLink to share 
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = recId;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        Insert cDocLink;

        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(gii__ServiceTicketLine__c stl : stlSelectedList)
        {
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = conDocument;
        conDocLink.LinkedEntityId = stl.id;
        conDocLink.ShareType = 'I';
        conDocLink.Visibility = 'AllUsers';
        cdlList.add(conDocLink);
        }
        if(cdlList.size()>0)
        {
            system.debug('Selected STL List'+ cdlList.size()+' ==> '+ cdlList);
            Database.Insert(cdlList);
        }*/
    }
    public class ServiceTicketLineWrapper
    { 
        @AuraEnabled
        public gii__ServiceTicketLine__c objSTLRef{get;set;}

        @AuraEnabled
        public Boolean isSelected{get;set;}

        public ServiceTicketLineWrapper(){
            this.isSelected = false;
        }
       
        @AuraEnabled
        public string assetRefName{get;set;}
    

    }
}