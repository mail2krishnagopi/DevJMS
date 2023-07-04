public class giic_PickListController {
    
    @InvocableMethod(label='Update PickList Detail' description='PickList Detail')
    public static list<String> updatePicklistDetailsObj(list<gii__PickList__c> listPKList) { 
        list<String> returnResult =  new list<String>();
        
            system.debug('listPKList>>'+listPKList);
            system.debug('listPKList>size()>'+listPKList.size());
        
        // Decimal  means Picklist Sequence
        map<Decimal , list<gii__LocationBin__c> >  PKSeqLocBin = new map<Decimal , list<gii__LocationBin__c >>();
        map<Decimal , list<gii__LocationBin__c> >  PKSeqLocBinAndLocWB = new map<Decimal , list<gii__LocationBin__c >>();
        map<decimal , gii__Location__c> mapOfSeqLocWb   = new map<decimal , gii__Location__c>();
        map<Decimal , list<gii__LocationBin__c> >  FinalMapPKSeqLocBinAndLocWB = new map<Decimal , list<gii__LocationBin__c >>();
        try{
            
            set<id>  pkId = new set<id>();
            for(gii__PickList__c pkl : listPKList){
                pkId.add(pkl.id);
            }
            system.debug('pkId>>'+pkId);
            system.debug('pkId>size()>'+pkId.size());
            
            /* list<gii__PickListDetail__c> listPKDForAll = [select id ,gii__PickList__c ,Name,
                                                            gii__ReserveSequence__c,
                                                            gii__ReserveSequence__r.gii__Location__c,
                                                            gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c,
                                                            gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c,
                                                            gii__ReserveSequence__r.gii__Location__r.gii__Sequence__c,
                                                            gii__ReserveSequence__r.gii__LocationBin__c
                                                            from gii__PickListDetail__c
                                                            where gii__PickList__c =:pkId];
            
            system.debug('listPKForLocBin>>'+listPKDForAll);
            system.debug('listPKForLocBin>size()>'+listPKDForAll.size());*/
            
            // this logic for location with bin
            list<gii__PickListDetail__c> listPKForLocBin = [select id ,gii__PickList__c ,Name,
                                                            gii__ReserveSequence__c,
                                                            gii__ReserveSequence__r.gii__Location__c,
                                                            gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c,
                                                            gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c,
                                                            gii__ReserveSequence__r.gii__Location__r.gii__Sequence__c,
                                                            gii__ReserveSequence__r.gii__LocationBin__c
                                                            from gii__PickListDetail__c
                                                            where gii__PickList__c =:pkId 
                                                            AND
                                                            gii__ReserveSequence__r.gii__Location__c != null
                                                            AND
                                                            gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c = True
                                                            AND
                                                            gii__ReserveSequence__r.gii__LocationBin__c != null
                                                            AND
                                                            gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c != null
                                                            order by gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c  ASC NULLS LAST ];
            system.debug('listPKForLocBin>>'+listPKForLocBin);
            system.debug('listPKForLocBin>size()>'+listPKForLocBin.size());
            if(listPKForLocBin.size() > 0){
                
                system.debug('Inside With  Bin');
                set<id>  locId = new set<id>();
                set<id>  locBinId = new set<id>();
                map<id ,gii__PickListDetail__c> mapOfPKForLocBin= new map<id ,gii__PickListDetail__c>();
                for(gii__PickListDetail__c  PlD1 :listPKForLocBin ){
                    locId.add(PlD1.gii__ReserveSequence__r.gii__Location__c);
                    locBinId.add(PlD1.gii__ReserveSequence__r.gii__LocationBin__c);
                    mapOfPKForLocBin.put(PlD1.id , PlD1);
                }
                system.debug('locId>>'+locId);
                system.debug('locBinId>>'+locBinId);
                
                map<id ,gii__Location__c> mapOfLoc= new map<id ,gii__Location__c> ([select id ,name ,
                                                                                    giic_Picklist_Sequence__c 
                                                                                    from gii__Location__c 
                                                                                    where id In: locId
                                                                                   
                                                                                   ]);
                
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
                /*for(gii__LocationBin__c  PlD1 :listOfLocBin ){
if(PKSeqLocBin.containsKey(PlD1.gii__Location__r.giic_Picklist_Sequence__c)){
PKSeqLocBin.put(PlD1.gii__Location__r.giic_Picklist_Sequence__c, new list<gii__LocationBin__c>());
}
PKSeqLocBin.get(PlD1.gii__Location__r.giic_Picklist_Sequence__c).add(PlD1);
}*/
                
                system.debug('PKSeqLocBin>>'+PKSeqLocBin);
                system.debug('PKSeqLocBin>size>'+PKSeqLocBin.size());
                
                /*
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
list<gii__PickListDetail__c>  result  = new list<gii__PickListDetail__c>();
for(gii__PickListDetail__c  PlD12 :listPKForLocBin ){
system.debug('mapOfLocBinSeq>Va>'+mapOfLocBinSeq.get(PlD12.gii__ReserveSequence__r.gii__LocationBin__c));
PlD12.gii__PickListPickSequence__c =mapOfLocBinSeq.get(PlD12.gii__ReserveSequence__r.gii__LocationBin__c);
result.add(PlD12);
}
update result;
*/
                
            }
            
            
            
            // this logic for location without bin
            list<gii__PickListDetail__c> listPKForNotLocBin = [select id ,gii__PickList__c ,Name,
                                                               gii__ReserveSequence__c,
                                                               gii__ReserveSequence__r.gii__Location__c,
                                                               gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c,
                                                               gii__ReserveSequence__r.gii__LocationBin__c
                                                               from gii__PickListDetail__c
                                                               where gii__PickList__c =:pkId 
                                                               AND
                                                               gii__ReserveSequence__r.gii__Location__c != null
                                                               AND
                                                               gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c = False
                                                               AND
                                                               gii__ReserveSequence__r.gii__LocationBin__c = null
                                                               AND
                                                               gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c != null
                                                               order by gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c  ASC NULLS LAST ];
            
            system.debug('listPKForNotLocBin>>'+listPKForNotLocBin);
            system.debug('listPKForNotLocBin>size()>'+listPKForNotLocBin.size());
            if(listPKForNotLocBin.size() > 0){
                system.debug('Inside With out Bin');
                set<id>  locWOBinId = new set<id>();
                
                for(gii__PickListDetail__c  PlD1 :listPKForNotLocBin ){
                    locWOBinId.add(PlD1.gii__ReserveSequence__r.gii__Location__c);
                    
                }
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
                
                // adding the same sequence in location bin map
                for(gii__Location__c lWOB :listLocWObin ){
                    //containsKey
                    if((!PKSeqLocBin.containsKey(lWOB.giic_Picklist_Sequence__c)) && lWOB.gii__BinControlled__c == false){
                        PKSeqLocBin.put(lWOB.giic_Picklist_Sequence__c, new list<gii__LocationBin__c>());
                        
                    }
                    // this is fatching the location 
                    if((!mapOfSeqLocWb.containsKey(lWOB.giic_Picklist_Sequence__c)) && lWOB.gii__BinControlled__c == false){
                        mapOfSeqLocWb.put(lWOB.giic_Picklist_Sequence__c, lWOB);
                        
                    }
                }
                
                system.debug('PKSeqLocBin>>2'+PKSeqLocBin);
                system.debug('PKSeqLocBin>size>2'+PKSeqLocBin.size());
                
                
                /*set<Decimal> PKSeqNuSet = PKSeqLocBin.keySet();   //new set<id>();
                system.debug('PKSeqNuSet>>'+PKSeqNuSet);
                system.debug('PKSeqNuSet>size>'+PKSeqNuSet.size());
                
                List<Decimal> PKSeqNuList = new List<Decimal>(PKSeqNuSet);
                system.debug('PKSeqNuList>>'+PKSeqNuList);
                system.debug('PKSeqNuList>size>'+PKSeqNuList.size());
                
                
                //PKSeqLocBin.get(mapOfLoc.get(PlD1.gii__Location__c).giic_Picklist_Sequence__c).add(PlD1);
                for(decimal dd1 : PKSeqNuList){
                    if( PKSeqLocBin.get(dd1).size() < 0){
                        PKSeqLocBinAndLocWB.put(dd1 ,new list<gii__LocationBin__c>());
                    }else{
                        PKSeqLocBin.get(dd1).sort();
                        PKSeqLocBinAndLocWB.put(dd1 ,PKSeqLocBin.get(dd1));
                    }
                }
                
                system.debug('PKSeqLocBinAndLocWB>>1'+PKSeqLocBinAndLocWB);
                system.debug('PKSeqLocBinAndLocWB>size>1'+PKSeqLocBinAndLocWB.size());
                */
                
            }
            
            
            // bbelow is soting the map and location Bin Sequence
            set<Decimal> PKSeqNuSet = PKSeqLocBin.keySet();   //new set<id>();
            system.debug('PKSeqNuSet>>'+PKSeqNuSet);
            system.debug('PKSeqNuSet>size>'+PKSeqNuSet.size());
            
            
            List<Decimal> PKSeqNuList = new List<Decimal>(PKSeqNuSet);
            system.debug('PKSeqNuList>>'+PKSeqNuList);
            system.debug('PKSeqNuList>size>'+PKSeqNuList.size());   
            
            for(decimal dd1 : PKSeqNuList){
                if( PKSeqLocBin.get(dd1).size() < 0){
                    PKSeqLocBinAndLocWB.put(dd1 ,new list<gii__LocationBin__c>());
                }else{
                    PKSeqLocBin.get(dd1).sort();
                    PKSeqLocBinAndLocWB.put(dd1 ,PKSeqLocBin.get(dd1));
                }
            }           
            
            
            system.debug('PKSeqLocBinAndLocWB>>1'+PKSeqLocBinAndLocWB);
                system.debug('PKSeqLocBinAndLocWB>size>1'+PKSeqLocBinAndLocWB.size());
            
          
            
            // below code  for updating the sequence in PKD
            list<gii__PickListDetail__c> listPKRecord = [select id ,gii__PickList__c ,Name,
                                                         gii__PickListPickSequence__c,
                                                         gii__ReserveSequence__c,
                                                         gii__ReserveSequence__r.gii__Location__c,
                                                         gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c,
                                                         gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c,
                                                         gii__ReserveSequence__r.gii__Location__r.gii__Sequence__c,
                                                         gii__ReserveSequence__r.gii__LocationBin__c
                                                         from gii__PickListDetail__c
                                                         where gii__PickList__c =:pkId 
                                                         AND
                                                         gii__ReserveSequence__r.gii__Location__c != null
                                                         AND
                                                         gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c != null
                                                         order by gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c  ASC NULLS LAST ];
            system.debug('listPKRecord>>'+listPKRecord);
            system.debug('listPKRecord>size()>'+listPKRecord.size());
            
            // id means location id and location bin id
            map<id ,list<gii__PickListDetail__c>> mapOfLocAndPKD = new map<id ,list<gii__PickListDetail__c>>();
            
            for( gii__PickListDetail__c pdld : listPKRecord ){
                system.debug('pdld>>'+pdld);
                system.debug('1>>'+pdld.gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c);
                system.debug('2>>'+pdld.gii__ReserveSequence__r.gii__Location__c);
                if(pdld.gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c == false){
                     system.debug('pdld>>if 1');
                    if(!mapOfLocAndPKD.containsKey(pdld.gii__ReserveSequence__r.gii__Location__c)){
                        mapOfLocAndPKD.put(pdld.gii__ReserveSequence__r.gii__Location__c ,new list<gii__PickListDetail__c>() );
                    }
                    system.debug('pdld>>if 2');
                    mapOfLocAndPKD.get(pdld.gii__ReserveSequence__r.gii__Location__c).add(pdld);
                }else{
                    system.debug('pdld>>else 1');
                    if(!mapOfLocAndPKD.containsKey(pdld.gii__ReserveSequence__r.gii__LocationBin__c)){
                        mapOfLocAndPKD.put(pdld.gii__ReserveSequence__r.gii__LocationBin__c ,new list<gii__PickListDetail__c>() );
                    }
                    system.debug('pdld>>else 2');
                    mapOfLocAndPKD.get(pdld.gii__ReserveSequence__r.gii__LocationBin__c).add(pdld);
                }
                
            }
            
            system.debug('mapOfLocAndPKD>>'+mapOfLocAndPKD);
            system.debug('mapOfLocAndPKD>size()>'+mapOfLocAndPKD.size());
            
           /* map<id ,gii__PickListDetail__c> mapPKRecord =  new map<id ,gii__PickListDetail__c>([select id ,gii__PickList__c ,Name,
                                                                                                gii__ReserveSequence__c,
                                                                                                gii__PickListPickSequence__c,
                                                                                                gii__ReserveSequence__r.gii__Location__c,
                                                                                                gii__ReserveSequence__r.gii__Location__r.gii__BinControlled__c,
                                                                                                gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c,
                                                                                                gii__ReserveSequence__r.gii__Location__r.gii__Sequence__c,
                                                                                                gii__ReserveSequence__r.gii__LocationBin__c
                                                                                                from gii__PickListDetail__c
                                                                                                where gii__PickList__c =:pkId 
                                                                                                AND
                                                                                                gii__ReserveSequence__r.gii__Location__c != null
                                                                                                AND
                                                                                                gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c != null
                                                                                                order by gii__ReserveSequence__r.gii__Location__r.giic_Picklist_Sequence__c  ASC NULLS LAST ]);
            system.debug('mapPKRecord>>'+mapPKRecord);
            system.debug('mapPKRecord>size()>'+mapPKRecord.size());
            */
            
            //Decimal  means Picklist Sequence ==>
            //map<Decimal , list<gii__LocationBin__c> >  PKSeqLocBinAndLocWB = new map<Decimal , list<gii__LocationBin__c >>();
            
            system.debug('PKSeqLocBinAndLocWB>>F '+PKSeqLocBinAndLocWB);
            system.debug('PKSeqLocBinAndLocWB>size()>F '+PKSeqLocBinAndLocWB.size());
            
            //Decimal  means Picklist Sequence ==>
            //map<decimal , gii__Location__c> mapOfSeqLocWb   = new map<decimal , gii__Location__c>();
            
            system.debug('mapOfSeqLocWb>>F '+mapOfSeqLocWb);
            system.debug('mapOfSeqLocWb>size()>F '+mapOfSeqLocWb.size());
            
            //// id means location id and location bin id
            // map<id ,gii__PickListDetail__c> mapOfLocAndPKD = new map<id ,gii__PickListDetail__c>();
            system.debug('mapOfLocAndPKD>>F '+mapOfLocAndPKD);
            system.debug('mapOfLocAndPKD>size()>F '+mapOfLocAndPKD.size());
            
            list<gii__PickListDetail__c> resultList = new list<gii__PickListDetail__c>();
            decimal countPkPickSeq = 1;
            
          /*  if( listPKForNotLocBin.size() > 0){
                FinalMapPKSeqLocBinAndLocWB = PKSeqLocBinAndLocWB;
            }else{
                FinalMapPKSeqLocBinAndLocWB = PKSeqLocBin;
            }    */        
            system.debug('>>>>F11 '+PKSeqLocBinAndLocWB);
            if(PKSeqLocBinAndLocWB.keySet().size() > 0){
                system.debug('1>>F '+PKSeqLocBinAndLocWB.keySet().size());
                system.debug('2>>'+PKSeqLocBinAndLocWB.keySet());
                for(decimal dd111: PKSeqLocBinAndLocWB.keySet()){
                    system.debug('22 >>'+dd111);
                    system.debug('3 >>'+PKSeqLocBinAndLocWB.get(dd111).size());
                    
                    system.debug('33 >>'+(PKSeqLocBinAndLocWB.get(dd111).size()==0));
                    system.debug('333 >>'+(PKSeqLocBinAndLocWB.get(dd111).size() == null));
                    system.debug('3333 >>'+(PKSeqLocBinAndLocWB.get(dd111).size() <= 0));
                     system.debug('33333 >>'+(PKSeqLocBinAndLocWB.get(dd111).size() > 0));
                    
                    system.debug('4>>'+PKSeqLocBinAndLocWB.get(dd111));
                    if(PKSeqLocBinAndLocWB.get(dd111).size() <= 0){
                        system.debug('yes1');
                        system.debug('44>>'+mapOfSeqLocWb.get(dd111));
                        system.debug('444>>'+ (mapOfSeqLocWb.get(dd111)!= null));
                        if(mapOfSeqLocWb.get(dd111) != null){
                            system.debug('yes2');
                            system.debug('5>>'+mapOfSeqLocWb);
                            system.debug('6>>'+mapOfSeqLocWb.get(dd111));
                            gii__Location__c lWOb = mapOfSeqLocWb.get(dd111);
                            system.debug('lWOb>>'+lWOb);
                            list<gii__PickListDetail__c> pklD11 =mapOfLocAndPKD.get(lWOb.id);
                            system.debug('pklD11>>'+pklD11);
                            for(gii__PickListDetail__c up :pklD11 ){
                                up.gii__PickListPickSequence__c =countPkPickSeq;
                                resultList.add(up);
                            }
                            
                            countPkPickSeq =countPkPickSeq+1;
                        }
                        
                    }else{
                        system.debug('7 >> '+PKSeqLocBinAndLocWB.get(dd111));
                        for(gii__LocationBin__c  lcwb1 :PKSeqLocBinAndLocWB.get(dd111) ){
                            system.debug('mapOfLocAndPKD>>'+mapOfLocAndPKD);
                            system.debug('mapOfLocAndPKD.get(lcwb1.id)'+mapOfLocAndPKD.get(lcwb1.id));
                            list<gii__PickListDetail__c> pklD22 =mapOfLocAndPKD.get(lcwb1.id);
                            system.debug('pklD22>>'+pklD22);
                            for(gii__PickListDetail__c up :pklD22 ){
                                if(resultList.contains(up) == false){
                                    up.gii__PickListPickSequence__c =countPkPickSeq;
                                    resultList.add(up);                                    
                                }
                            }
                            countPkPickSeq =countPkPickSeq+1;
                            
                        }
                    }
                    
                }
                
                system.debug('resultList>>B '+resultList);
                    system.debug('resultList>size()>B '+resultList.size());
                if(resultList.size()> 0){
                    update resultList;   
                    system.debug('resultList>>F '+resultList);
                    system.debug('resultList>size()>F '+resultList.size());
                }
                
                returnResult.add('Success');
            }
            
        }catch(exception e){
            system.debug(e.getMessage()+'####'+e.getlinenumber());
            returnResult.add('Error' + e.getMessage());
            
        } 
        
        return returnResult;
    }
    
    
}