public class testSenarioa {

    public static void updateProtest(){
         list<gii__SalesQuote__c>   listProcessedRecords = new  list<gii__SalesQuote__c>();
        listProcessedRecords =[SELECT Id , giic_Account_Type__c, giic_Is_Approval_For_EI__c,
                                                           giic_Is_Approval_For_NAM__c , giic_Is_Approval_For_Non_NAM__c,
                                                           giic_Is_Attachment_Added__c, giic_NAM_approval_Status__c ,
                                                           giic_RSM_Approved__c, giic_Sub_Status__c ,
                                                           giic_NAM_Approved__c , giic_Overall_Status__c ,
                                                           giic_Equipment_Cost__c, giic_Ancillary_Cost__c ,
                                                           giic_SQ_Integrity_Approval_Status__c, giic_quipment_Integrity_Approved__c,
                                                           giic_RSM_approval_Status__c , giic_Customer_State__c,
                                                           giic_Placement_Reason__c,Owner.name ,
                                                           owner.Email,CreatedBy.Name,gii__Account__c,
                                                           gii__Account__r.Name,gii__Account__r.BillingState,
                                                           giic_Manager_Details__c
                                                           FROM gii__SalesQuote__c 
                                                           WHERE Id ='a4D3C000000YwFAUA0'];
         system.debug(listProcessedRecords);
        boolean result1 = ( listProcessedRecords[0].giic_NAM_Approved__c == true && listProcessedRecords[0].giic_Is_Approval_For_EI__c == false) ;
        boolean result2 =  ( listProcessedRecords[0].giic_RSM_Approved__c == true && listProcessedRecords[0].giic_Is_Approval_For_Non_NAM__c == true) ;
        boolean result3 = ( listProcessedRecords[0].giic_Is_Approval_For_EI__c == true || 
                           ( listProcessedRecords[0].giic_NAM_Approved__c == true && listProcessedRecords[0].giic_Is_Approval_For_EI__c == false) ||
                           ( listProcessedRecords[0].giic_RSM_Approved__c == true && listProcessedRecords[0].giic_Is_Approval_For_Non_NAM__c == true)
                           ) ;
        system.debug(result1);
        system.debug(result2);
        system.debug(result2);
        
         boolean result4 = (listProcessedRecords[0].giic_Overall_Status__c != 'Completed' &&  listProcessedRecords[0].giic_RSM_Approved__c == true && result3) ;
          system.debug(result4);
    }
    
     public static void updateProdInv(){
        
             Datetime todayDate = System.now();
            system.debug('todayDate>> '+ todayDate);
            DateTime newTodayDate = todayDate.addMonths(-1);
            system.debug('numberOfMonth>> '+ newTodayDate);
         Date myDateToday = date.newinstance(todayDate.year(), todayDate.month(), todayDate.day());
        Date myDateDuw = date.newinstance(newTodayDate.year(), newTodayDate.month(), newTodayDate.day());
        system.debug('myDateToday>> '+ myDateToday);
         system.debug('myDateDuw>> '+ myDateDuw);
           Integer numberDaysDue = myDateToday.daysBetween(myDateDuw);
            system.debug('numberDaysDue>> '+ numberDaysDue);
           Integer numberDaysDue11 = myDateDuw.daysBetween(myDateToday);
            system.debug('numberDaysDue11>> '+ numberDaysDue11);
          Decimal demans= 17.00;
        system.debug('demans>> '+demans);
        system.debug('Rate '+ (demans/numberDaysDue));
         system.debug('Rate1 '+ (demans/numberDaysDue11));
        
        
       /* Decimal tt=13.97;
        system.debug('tt '+ tt);
        Integer i1 = Math.round(tt);
        system.debug('i1>> '+ i1);
        
        Decimal aa=13.49;
        system.debug('aa'+ aa);
        Integer i12 = Math.round(tt);
        system.debug('i12>> '+ i12);*/
        
    }
    
    public static void test111(){
        
        
        list<id> locBinId = new list<id>();
        
        locBinId.add('a2P3C000000bk4YUAQ');
        locBinId.add('a2P3C000000bk6AUAQ');
        locBinId.add('a2P3C000000bk6jUAA');
        locBinId.add('a2P3C000000bk4iUAA');
        locBinId.add('a2P3C000000bk65UAA');
        locBinId.add('a2P3C000000bk8kUAA');
        locBinId.add('a2P3C000000bk4dUAA');
        locBinId.add('a2P3C000000bk8pUAA');
        system.debug('locBinId>>'+locBinId);
        
        list<id> locId = new list<id>();
        
        locId.add('a2Q3C000001QamGUAS');
        locId.add('a2Q3C000001Qam6UAC');
        locId.add('a2Q3C000001QamaUAC');
        
        map<id ,gii__Location__c> mapOfLoc= new map<id ,gii__Location__c> ([select id ,name ,
                                             giic_Picklist_Sequence__c 
                                             from gii__Location__c 
                                            where id In: locId]);
         system.debug('mapOfLoc>>'+mapOfLoc);
        system.debug('mapOfLoc>size>'+mapOfLoc.size());
        
        
      
        list<gii__LocationBin__c> listOfLocBin=[select id ,name , 
                                                gii__Location__c , 
                                                gii__Location__r.giic_Picklist_Sequence__c,
                                                gii__Location__r.gii__Sequence__c
                                                from  gii__LocationBin__c
                                                where id In: locBinId
                                                order by gii__Location__r.giic_Picklist_Sequence__c  ASC NULLS LAST ];
        system.debug('listOfLocBin>>'+listOfLocBin);
        system.debug('listOfLocBin>size>'+listOfLocBin.size());
        
        map<Decimal , list<gii__LocationBin__c> >  PKSeqLocBin = new map<Decimal , list<gii__LocationBin__c >>();
         for(gii__LocationBin__c  PlD1 :listOfLocBin ){
             system.debug('mapOfLoc.get(PlD1.gii__Location__c).id>>'+mapOfLoc.get(PlD1.gii__Location__c).id);
             system.debug('PlD1.gii__Location__c>>'+PlD1.gii__Location__c);
             if(mapOfLoc.get(PlD1.gii__Location__c).id ==  PlD1.gii__Location__c){
                 system.debug('mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c'+mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c);
             if(!PKSeqLocBin.containsKey(mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c)){
                 PKSeqLocBin.put(mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c, new list<gii__LocationBin__c>());
             }}
              PKSeqLocBin.get(mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c).add(PlD1);
         }
        system.debug('PKSeqLocBin>>1'+PKSeqLocBin);
        system.debug('PKSeqLocBin>size>1'+PKSeqLocBin.size());
        
        
        
        //Start
         list<id> locWOBinId = new list<id>();
        locWOBinId.add('a2Q3C000001QamBUAS');
          system.debug('locWOBinId>>'+locWOBinId);
        
        list<gii__Location__c> listLocWObin= [select id ,name ,
                                             giic_Picklist_Sequence__c ,
                                              gii__BinControlled__c
                                             from gii__Location__c 
                                            where id In: locWOBinId
                                             AND
                                             gii__BinControlled__c = false
                                             order by giic_Picklist_Sequence__c  ASC NULLS LAST];
        
         system.debug('listLocWObin>>'+listLocWObin);
        system.debug('listLocWObin>size>'+listLocWObin.size());
        
         map<decimal , gii__Location__c> mapOfSeqLocWb   = new map<decimal , gii__Location__c>();
        for(gii__Location__c lWOB :listLocWObin ){
            //containsKey
            if((!PKSeqLocBin.containsKey(lWOB.giic_Picklist_Sequence__c)) && lWOB.gii__BinControlled__c == false){
                PKSeqLocBin.put(lWOB.giic_Picklist_Sequence__c, new list<gii__LocationBin__c>());
             
            }
            if((!mapOfSeqLocWb.containsKey(lWOB.giic_Picklist_Sequence__c)) && lWOB.gii__BinControlled__c == false){
                mapOfSeqLocWb.put(lWOB.giic_Picklist_Sequence__c, lWOB);
             
            }
        }
        
        system.debug('PKSeqLocBin>>2'+PKSeqLocBin);
        system.debug('PKSeqLocBin>size>2'+PKSeqLocBin.size());
        
        
        set<Decimal> PKSeqNuSet = PKSeqLocBin.keySet();   //new set<id>();
        system.debug('PKSeqNuSet>>'+PKSeqNuSet);
        system.debug('PKSeqNuSet>size>'+PKSeqNuSet.size());
        
        List<Decimal> PKSeqNuList = new List<Decimal>(PKSeqNuSet);
        system.debug('PKSeqNuList>>'+PKSeqNuList);
        system.debug('PKSeqNuList>size>'+PKSeqNuList.size());

        
         map<Decimal , list<gii__LocationBin__c> >  PKSeqLocBinAndLocWB = new map<Decimal , list<gii__LocationBin__c >>();
        //PKSeqLocBin.get(mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c).add(PlD1);
        for(decimal dd1 : PKSeqNuList){
            if( PKSeqLocBin.get(dd1).size() < 0){
                PKSeqLocBinAndLocWB.put(dd1 ,new list<gii__LocationBin__c>());
            }else{
                PKSeqLocBin.get(dd1).sort();
                PKSeqLocBinAndLocWB.put(dd1 ,PKSeqLocBin.get(dd1));
            }
        }
       
        system.debug('PKSeqLocBinAndLocWB>>'+PKSeqLocBinAndLocWB);
        system.debug('PKSeqLocBinAndLocWB>size>'+PKSeqLocBinAndLocWB.size());
        
        
        //End
 
        
        
        list<gii__LocationBin__c>  finalListOfLocBin  = new list<gii__LocationBin__c>();
        for(Decimal ddd: PKSeqLocBin.keySet()){
            list<gii__LocationBin__c> listOFLocBinForSort =PKSeqLocBin.get(ddd);
            listOFLocBinForSort.sort();
            finalListOfLocBin.addAll(listOFLocBinForSort);
        }
        
         system.debug('finalListOfLocBin>>'+finalListOfLocBin);
        system.debug('finalListOfLocBin>size>'+finalListOfLocBin.size());
        
        map<id ,gii__LocationBin__c> finalMapOfLocBin = new  map<id ,gii__LocationBin__c>(finalListOfLocBin);
         system.debug('finalMapOfLocBin>>'+finalMapOfLocBin);
        system.debug('finalMapOfLocBin>size>'+finalMapOfLocBin.size());
        
        
         
        // id is gii__LocationBin__c and decimal means number
            map<id , Decimal>  mapOfLocBinSeq= new  map<id , Decimal>();
            decimal count = 1;
            for(gii__LocationBin__c locbin2 : finalListOfLocBin){
                if(!mapOfLocBinSeq.containsKey(locbin2.id)){
                    
                    mapOfLocBinSeq.put(locbin2.id ,count);  
                    count = count+1;
                }
            } 
             system.debug('mapOfLocBinSeq>>'+mapOfLocBinSeq);
        system.debug('mapOfLocBinSeq>size>'+mapOfLocBinSeq.size());    
        
    }
}