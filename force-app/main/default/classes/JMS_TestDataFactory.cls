/*********************************************************************************************************************
**********************************************************************************************************************    
*  Class            : JMS_TestDataFactory
*  Author           : Sachin Awati
*  Version History  : 1.0
*  Creation         : 03/25/2022
*  Description      : Data factory for test classes
**********************************************************************************************************************
**********************************************************************************************************************/

@IsTest(SeeAllData=false)
public class JMS_TestDataFactory {
    public static final String STR_TEST_PRODUCT = 'Test product';
    public static final String STR_EN_US = 'en_US';
    public static final String STR_AMERICAN_LOS_ANGELES ='America/Los_Angeles';
    public static final String STR_NEW_CAMPAIGN ='New Campaign';
    /**
    * @Description: Method to create Account data for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */   
    public static Account createAccountByName(String name) {
        try{
            Account ret = new Account() ; 
            ret.name = name;
            
            ret.BillingStreet='3940 Main Rd';
            ret.BillingCity='Tiverton';
            ret.BillingState='Alaska';
            ret.BillingPostalCode='06787';
            ret.BillingCountry='United States';
            ret.JMS_Plan_to_Code__c='12345';
            //insert and return
            insert ret;
            return ret ;
        }   
        catch(Exception ex){
            throw ex;
        }//End of catch block      
    }//end of method
    
    /**
    * @Description: Method to create Account data for test classes
    * @Author     : Sumit
    * @Date       : 14/04/2022
    */   
    public static Account createAccountWithFireflyId(String name) {
        try{
            Account ret = new Account() ; 
            ret.name = name;
            
            ret.BillingStreet='33234 New Main Rd';
            ret.BillingCity='Milwaukee';
            ret.BillingState='Wisconsin';
            ret.BillingPostalCode='53263';
            ret.BillingCountry='United States';
            ret.JMS_FireFly_Id__c = '1234';
            return ret;
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
    
     /**
    * @Description: Method to create Lead data for test classes
    * @Author     : Sumit
    * @Date       : 14/04/2022
    */   
    public static Lead createLeadByName(String name) {
        try{
            Lead ret = new Lead() ; 
            ret.LastName = name;
            ret.PostalCode = '12345';
            ret.Status='New';
            ret.pi__campaign__c='Pardot Campaign';
            ret.Company='Test Company';
            INSERT ret;
            return ret ;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    /**
    * @Description: Method to create Lead data for test classes
    * @Author     : Krishna
    * @Date       : 25/04/2022
    */   
    public static Group createGroup() {
        try{
            Group ret = new Group() ; 
            ret.Name = 'IAC Queue';
            ret.DeveloperName = 'ABC';
            ret.Type='Queue';
            INSERT ret;
            return ret ;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
    /**
    * @Description: Method to create Contact data for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */    
    public static Contact createContact(String name , String accId) {
        try{
            Contact ret=new Contact();
            ret.Lastname=name;
            ret.AccountId = accId;
            //insert and return
            insert ret;
            return ret ;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
     /**
    * @Description: Method to validate primary Contact data for test classes
    * @Author     : Krishna
    * @Date       : 04/04/2022
    */    
    public static Contact createContactForValidatingPrimaryContact(String name , String accId) {
        try{
            Contact ret=new Contact();
            ret.Lastname=name;
            ret.AccountId = accId;
            return ret ;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
     /**
    * @Description: Method to create Opportunity data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */    
    public static Opportunity createOpportunity(String name,String accId) {
        try{
            Opportunity opp = new Opportunity();
            opp.Name = name;
            opp.AccountId = accId;
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.TODAY();
            //insert and return
            insert opp;
            return opp;
        }   
        catch(Exception ex){
            throw ex;
        }//End of catch block      
    }//end of method
     /**
    * @Description: Method to create JMS_Broker_Call_Landing__c data for test classes
    * @Author     : Krishna Tarun
    * @Date       : 05/7/2022
      */
    public static JMS_Broker_Call_Landing__c createBrokerCallStaging() {
        try{
            JMS_Broker_Call_Landing__c brkCall = new JMS_Broker_Call_Landing__c();
            brkCall.JMS_Item_Status__c = 'SALE';
            brkCall.JMS_Call_Distributor_Code__c = '12323';
            brkCall.JMS_Campaign_Name__c = STR_NEW_CAMPAIGN;
            brkCall.JMS_Item_Number__c = STR_TEST_PRODUCT;
            //insert and return
            insert brkCall;
            return brkCall;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    /**
    * @Description: Method to create JMS_Broker_Call_Staging__c data for test classes
    * @Author     : Krishna Tarun
    * @Date       : 05/7/2022
      */
    
    public static JMS_Broker_Call_Staging__c createBrokerCallStagingObj() {
        try{
            JMS_Broker_Call_Staging__c brkCall = new JMS_Broker_Call_Staging__c();
            brkCall.JMS_Item_Status__c = 'SALE';
            brkCall.JMS_Call_distributor_code__c = '12323';
            brkCall.JMS_Campaign_Name__c = STR_NEW_CAMPAIGN;
            brkCall.JMS_Item_Number__c = STR_TEST_PRODUCT;
            brkCall.JMS_Broker_Name__c = 'IAC';
            brkCall.JMS_Record_Processed__c = True;
            //insert and return
            insert brkCall;
            return brkCall;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
    /**
    * @Description: Method to create JMS_Campaign_Target_Landing__c data for test classes
    * @Author     : Krishna Tarun
    * @Date       : 05/7/2022
       */
    public static JMS_Campaign_Target_Landing__c createcampaignLanding() {
        try{
            JMS_Campaign_Target_Landing__c cmpTarget = new JMS_Campaign_Target_Landing__c();
            cmpTarget.JMS_Operator_Contact_Email_Address__c = 'campaignmember@jms.com';
            //cmpTarget.JMS_Smucker_SKU__c = '12323';
            cmpTarget.JMS_Campaign_Name__c = STR_NEW_CAMPAIGN;
            //insert and return
            insert cmpTarget;
            return cmpTarget;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
     /**
    * @Description: Method to create JMS_Campaign_Target_Staging__c data for test classes
    * @Author     : Krishna Tarun
    * @Date       : 05/7/2022
       */
    public static JMS_Campaign_Target_Staging__c createCampaignStaging() {
        try{
            JMS_Campaign_Target_Staging__c cmpTarget = new JMS_Campaign_Target_Staging__c();
            cmpTarget.JMS_Operator_Contact_Email_Address__c = 'campaignmember@jms.com';
            cmpTarget.JMS_Smucker_SKU__c = '12323';
            cmpTarget.JMS_Campaign_Name__c = STR_NEW_CAMPAIGN;
            cmpTarget.JMS_FireFlyId__c = '233568';
            //insert and return
            insert cmpTarget;
            return cmpTarget;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    public static JMS_Broker_Call_XREF__c createBrokerCallXREF() {
        try{
            //RecordType salesProfile = [select id, Name from RecordType where Name = 'JMS_FREEMAN_SIGNATURE' Limit 1];
            //String recType = Schema.SObjectType.JMS_Broker_Call_XREF__c.getRecordTypeInfosByName().get('JMS_FREEMAN_SIGNATURE').getRecordTypeId();
            JMS_Broker_Call_XREF__c BrokerCallXREF = new JMS_Broker_Call_XREF__c();
            BrokerCallXREF.JMS_Source_Key__c = 'Broker Opp Stage';
            BrokerCallXREF.JMS_Is_Active__c = TRUE;
            BrokerCallXREF.JMS_Target_Key__c = 'opportunity_stage';
            BrokerCallXREF.JMS_Field_API_Name__c = 'JMS_Opportunity_stage__c';
            insert BrokerCallXREF;
            return BrokerCallXREF;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    /**
    * @Description: Method to create template data for test classes
    * @Author     : Krishna
    * @Date       : 03/30/2022
    */    
    public static EmailTemplate createEmailTemplate(String name,String folderId) {
        try{
            EmailTemplate emailtemp = new EmailTemplate();
            emailtemp.Name = name;
            emailtemp.isActive = true;
            emailtemp.DeveloperName = 'JMS';
            emailtemp.TemplateType = 'text';
            emailtemp.FolderId = folderId;
            //insert and return
            insert emailtemp;
            return emailtemp;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method

    
    /**
    * @Description: Method to create the products for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static list<Product2>  createProductRecds(integer recCount){
        list<Product2> prodList = new List<Product2>();
        //for loop for iterating record count
        for(integer iter= 0; iter<recCount;iter++){
            product2 prd = new product2();
            prd.Name=STR_TEST_PRODUCT;
            prd.ProductCode='326423462';
            prd.IsActive = TRUE;
            prodList.add(prd);
        }
          //insert and return
        insert prodList;
        return prodList;
    }
        /**
    * @Description: Method to create the products for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static Product2 createProduct() {
        try{
            Product2 prd = new Product2();
            prd.Name=STR_TEST_PRODUCT;
            prd.ProductCode='326423462';
            prd.IsActive = TRUE;
            prd.StockKeepingUnit = '23456';
        
          //insert and return
        insert prd;
        return prd;
            
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
     /**
    * @Description: Method to create the products for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static OpportunityLineItem createOpportunityLineItem(String OppId,String PrdId,String priceBookEntryId) {
        try{
            OpportunityLineItem prd = new OpportunityLineItem();
            prd.Product2Id=PrdId;
            prd.OpportunityId=OppId;
            prd.Quantity = 2;
            prd.PricebookEntryId = priceBookEntryId;
            prd.TotalPrice = 0;

            //prd.IsActive = TRUE;
            //prd.StockKeepingUnit = '23456';
        
          //insert and return
        insert prd;
        return prd;
            
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
    /**
    * @Description: Method to create Direct shipments data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */    
    public static JMS_Direct_Shipment__c createDirectShipments(String Name) {
        try{
            JMS_Direct_Shipment__c dirShip = new JMS_Direct_Shipment__c();
        
            dirShip.JMS_Plan_To_Name__c = 'test Account';
            dirShip.JMS_Order_Item_Number__c = STR_TEST_PRODUCT;
            dirShip.JMS_Invoice_Date__c = Date.TODAY();
            //insert and return
            insert dirShip;
            return dirShip;
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
    /**
    * @Description: Method to create Order Volume data for test classes
    * @Author     : Anil
    * @Date       : 17/05/2022
    */
    public static JMS_Order_Volume__c createOrderVolume(String name) {
        try{
            JMS_Order_Volume__c orderVolume = new JMS_Order_Volume__c();
            orderVolume.Name = name;
            orderVolume.JMS_Plan_to_Code__c = '12345';
            orderVolume.JMS_Item_Number__c = '23456';	
            //insert and return
            insert orderVolume;
            return orderVolume;
            
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
     /**
    * @Description: Method to create Campagin data for test classes
    * @Author     : Krishna
    * @Date       : 03/25/2022
    */    
    public static Campaign createCampaign(String name) {
        try{
            Campaign ret=new Campaign();
            ret.IsActive= TRUE;
            ret.Name = name;
            ret.StartDate = Date.TODAY();
            //insert and return
            insert ret;
            return ret ;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
    /**
    * @Description: Method to create Campagin data for test classes
    * @Author     : Krishna
    * @Date       : 03/25/2022
    */    
    public static CampaignMember createCampaignMember(String accId,String campId) {
        try{
            CampaignMember ret=new CampaignMember();
            ret.AccountId = accId;
            ret.Status = 'Sent'; 
            ret.CampaignId= campId;
            //insert and return
            insert ret;
            return ret;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
    /**
    * @Description: Method to create the pricebooks for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static list<Pricebook2> createPricebookRecds(integer recCount){
        list<Pricebook2> pbList = new List<Pricebook2>();
        //for loop for iterating record count
        for(integer iter= 0; iter<recCount;iter++){
            Pricebook2 pb = new Pricebook2();
            pb.Name='JMS PriceBook '+iter;
            pb.IsActive = TRUE;
            pbList.add(pb);
        }
          //insert and return
        insert pbList;
        return pbList;
    }
     /**
    * @Description: Method to create the pricebooks for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static Pricebook2 createPricebook(){
            Pricebook2 pb = new Pricebook2();
            pb.Name='JMS PriceBook ';
            pb.IsActive = TRUE;
            //insert and return
        insert pb;
        return pb;
    }
        
    
     /**
    * @Description: Method to create the pricebooks for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static PriceBookEntry createPricebookEntry(String prdId,String pricebookId){
            PriceBookEntry pb = new PriceBookEntry();
            pb.IsActive = TRUE;
            pb.Product2Id = prdId;
            pb.Pricebook2Id = pricebookId;
            pb.UnitPrice = 144;
          //insert and return
        insert pb;
        return pb;
    }

    /**
    * @Description: Method to create Task data for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */    
    public static list<task> createTaskRecds(integer recCount,id relatedId){
        //List of task
        list<task> taskList = new list<task>();
        for(integer iter= 0; iter<recCount;iter++){
            task taskRec = new task();
            taskRec.Status = 'Call';
            taskRec.Priority='Normal';
            taskRec.Status = 'Open';
            taskRec.WhatId= relatedId;
            taskRec.ActivityDate=system.today()+1;
            taskList.add(taskRec);
        }
          //insert and return
        insert taskList;
        return taskList;
    }
    
    /**
    * @Description: Method to create ContentVersion data for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */ 
    public static List<ContentVersion> createContentVersionRecs(integer recCount){
        //List of ContentVersion
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        for(integer iter= 0; iter<recCount;iter++){
            ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='TEST';
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            contentVersionList.add(cv);
        }
        insert contentVersionList;
        return contentVersionList;
    }
    
    /**
    * @Description: Method to create User data for test classes
    * @Author     : Sachin Awati
    * @Date       : 03/25/2022
    */  
    public static User createUser(){
        try{
            Profile salesProfile = [SELECT id, Name FROM Profile WHERE Name = 'Sales Users' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User usr = new User();
            usr.profileId = salesProfile.id;
            usr.alias = 'standt';
            usr.email='standarduser6@testorg.com';
            usr.emailencodingkey='UTF-8';
            usr.firstname='fake';
            usr.lastname='Testing';
            usr.languagelocalekey=STR_EN_US;
            usr.localesidkey=STR_EN_US;
            usr.timezonesidkey=STR_AMERICAN_LOS_ANGELES;
            usr.username=uniqueName +'standarduser6@testorg.com';
            INSERT usr;
            return usr;
        }   
        catch(Exception ex){
            throw ex;
        }//End of catch block      
    }//end of method
    /**
    * @Description: Method to create User data for test classes
    * @Author     : Krishna
    * @Date       : 03/25/2022
    */  
    public static User createIntUser(){
        try{
            Profile IntegProfile = [SELECT id, name FROM Profile WHERE name = 'Integration User' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User usr = new User();
            usr.profileId = IntegProfile.id;
            usr.alias = 'standt';
            usr.email='IntegUser6@testorg.com';
            usr.emailencodingkey='UTF-8';
            usr.firstname='fake';
            usr.lastname='Testing';
            usr.languagelocalekey=STR_EN_US;
            usr.localesidkey=STR_EN_US;
            usr.timezonesidkey=STR_AMERICAN_LOS_ANGELES;
            usr.username=uniqueName +'standarduser6@testorg.com';
            return usr;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
    /**
    * @Description: Test method for creating Admin User 
    * @Author     : Sumit
    * @Date       : 8/8/2022
    */  
    public static User createAdminUser(){
        try{
            Profile adminProfile = [SELECT id, name FROM Profile WHERE name = 'System Administrator' LIMIT 1];
            User admin = new User();
            admin.firstName = 'test1';
            admin.lastName = 'test22';
            admin.profileId = adminProfile.id;
            admin.username = 'testngdev1@test.com';
            admin.email = 'test1@test.com';
            admin.Alias = 'test1';
            admin.TimeZoneSidKey = STR_AMERICAN_LOS_ANGELES;
            admin.LocaleSidKey = STR_EN_US;
            
            admin.EmailEncodingKey = 'ISO-8859-1';
            admin.LanguageLocaleKey = STR_EN_US;
        
            INSERT admin;
            
            return admin;
        }
        catch(Exception ex){
            throw ex;
        }//End of catch block      
    }//end of method
  
     /**
    * @Description: Method to create ReadOnly User data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/31/2022
    */   
    public static User createReadOnlyUser(){
        try{
            Profile readOnlyProfile = [SELECT id, name FROM Profile WHERE name = 'Read Only' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User usr = new User();
            usr.profileId = readOnlyProfile.id;
            usr.alias = 'readO';
            usr.email='readonly@testorg.com';
            usr.emailencodingkey='UTF-8';
            usr.firstname='ReadOnly';
            usr.lastname='TestingReadOnly';
            usr.languagelocalekey=STR_EN_US;
            usr.localesidkey=STR_EN_US;
            usr.timezonesidkey=STR_AMERICAN_LOS_ANGELES;
            usr.username=uniqueName +'readonlyuser8@testorg.com';
            INSERT usr;
            return usr;
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
    
    
     /**
    * @Description: Method to create ZipCode data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
    public static JMS_ZipCodes__c createZipcodes(String name){
        try{
            JMS_ZipCodes__c zip = new JMS_ZipCodes__c() ; 
            zip.JMS_Zip_Code__c = name;
            zip.JMS_Territory_Name__c = 'AFH SOUTH EAST-2';
            //zip.JMS_Is_Active__c = TRUE;
            zip.JMS_Zip_Code__c = '06787';
            INSERT zip;
            return zip;
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
    
     /**
    * @Description: Method to create ZipCode data for test classes
    * @Author     : Sumit
    * @Date       : 12/07/2022
    */   
    public static JMS_ZipCodes__c createZipcodesBasedOnNewZip(String name, String zipcode, String territoryName){
        try{
            JMS_ZipCodes__c zip = new JMS_ZipCodes__c() ; 
            zip.JMS_Zip_Code__c = name;
            zip.JMS_Territory_Name__c = territoryName;
            zip.JMS_Zip_Code__c = zipcode;
            INSERT zip;
            return zip;
        }   
        catch(Exception ex){
            throw ex;
        }  //End of catch block      
    }//end of method
    
     /*
    * @Description: Method to create Territory2Model data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
     public static Territory2Model createTerritory2Model(){
        try{
            Territory2Model model = new Territory2Model(); 
            model.Name = 'JMS Territory';
            model.DeveloperName = 'XJMSTerritory';
            INSERT model;
            return model;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
           
     /*
    * @Description: Method to create Territory data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
   public static Territory2 createTerritory(String modelID) {
        try{
            List<Territory2Type> terriType   = [SELECT id, DeveloperName FROM Territory2Type LIMIT 1];            
            Territory2 ter = new Territory2() ; 
            ter.Name = 'Test Territory';
            ter.Territory2TypeId = terriType[0].id;
            ter.Territory2ModelId = modelID;
            ter.DeveloperName = 'ATest_Territory';
            INSERT ter;
            return ter;
        }   
        catch(Exception ex){
            throw ex;
        }//End of catch block      
    }//end of method
    
     /*
    * @Description: Method to create ObjectTerritory2Association data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
   public static ObjectTerritory2Association createTeritoryAssociation(String accId,String terId){
        try{
            ObjectTerritory2Association obj = new ObjectTerritory2Association(); 
            obj.ObjectId = accId;
            obj.Territory2Id = terId;
            obj.AssociationCause = 'Territory2Manual';
            insert obj;
            return obj;
        }   
        catch(Exception ex){
            throw ex;
        }//End of catch block      
    }//end of method
     /*
    * @Description: Method to create ObjectTerritory2Association data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
   public static UserTerritory2Association createUserTeritoryAssociation(String userId,String terId){
        try{
            UserTerritory2Association obj = new UserTerritory2Association(); 
            obj.UserId = userId;
            obj.Territory2Id = terId;
            insert obj;
            return obj;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
      
     /*
    * @Description: Method to create ObjectTerritory2Association data for test classes
    * @Author     : Sumit
    * @Date       : 14/04/2022
    */   
    public static JMS_Territory_Assignment__c createJMSTeritoryAssignment(String terId,String accId){
        try{
            JMS_Territory_Assignment__c obj = new JMS_Territory_Assignment__c(); 
            obj.JMS_TerritoryID__c = terId;
            obj.JMS_ZipCodeAssignment__c = '1234';
            obj.JMS_Account_ID__c = accId;
            INSERT obj;
            return obj;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
     /*
    * @Description: Method to create JMS_Equipment_Request__c data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
   public static JMS_Equipment_Request__c createEquipmentRequest(String oppId){
        try{
            JMS_Equipment_Request__c equip = new JMS_Equipment_Request__c(); 
            equip.JMS_Opportunity__c = oppId;
            equip.JMS_Equipment_Cost__c = 738473;
            equip.JMS_Ancillary_Cost__c = 100;
            equip.JMS_Account_Type__c = 'HPSI';
            equip.JMS_Parent_Contract_Name__c = 'Contract Test';
            equip.JMS_Placement_Reason__c = 'Ancillary Order';
            equip.JMS_Machine_Count__c = 968;
            INSERT equip;
            return equip;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
     /*
    * @Description: Method to create ContentVersion data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
     public static ContentVersion createContentVersion(String Title){
        try{
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        INSERT content;
        return content;                       
        }
         catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
     /*
    * @Description: Method to create ContentVersion data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
     public static ContentVersion createContentVersiontwo(String Title){
        try{
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture2'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        INSERT content;
        return content;                       
        }
         catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
     /*
    * @Description: Method to create ContentDocumentLink data for test classes
    * @Author     : Archana Mohapatra
    * @Date       : 03/30/2022
    */   
    public static ContentDocumentLink createContentDocumentLink(String equipId,String contentDocumentId){
        try{
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId = equipId;
            contentlink.contentdocumentid = contentDocumentId;//[select contentdocumentid from contentversion where id =: contentId].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            INSERT contentlink;
            return contentlink;  
        }
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    public static ContentDocumentLink createContentDocumentLink2(String equipId,String contentDocumentId){
        try{
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId = equipId;
            contentlink.contentdocumentid = contentDocumentId;//[select contentdocumentid from contentversion where id =: contentId].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            INSERT contentlink;
            return contentlink;  
        }
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    /**
    * @Description: Method to create JMS_Broker_Call_Staging__c data for test classes
    * @Author     : Krishna Tarun
    * @Date       : 05/7/2022
      */
    
    public static JMS_Broker_Call_Staging__c createAWSBrokerCallStagingObj() {
        try{
            JMS_Broker_Call_Staging__c brkCall = new JMS_Broker_Call_Staging__c();
            
            brkCall.JMS_Kickout_Location__c = 'AWS';
            //insert and return
            insert brkCall;
            return brkCall;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
    
    /**
    * @Description: Method to create JMS_Campaign_Target_Staging__c data for test classes
    * @Author     : Krishna Tarun
    * @Date       : 05/7/2022
       */
    public static JMS_Campaign_Target_Staging__c createAWSCampaignStaging() {
        try{
            JMS_Campaign_Target_Staging__c cmpTarget = new JMS_Campaign_Target_Staging__c();
            cmpTarget.JMS_Kickout_Location__c = 'AWS';
            //insert and return
            insert cmpTarget;
            return cmpTarget;
        }   
        catch(Exception ex){
            throw ex;
        } //End of catch block      
    }//end of method
}