public class SalesQuoteHandler {
    public static map<id ,String> ValidateSite(list<gii__SalesQuote__c> listSalesQ){
        system.debug('listSalesQ>>>'+listSalesQ);
        map<id ,String> result= new map<id ,String>();
        if(listSalesQ.size() > 0){
            Map<id , list<gii__Site__c>> mapAccIdAdSiteList = new Map<id , list<gii__Site__c>>();
           // Map<id ,gii__Site__c > mapAccIdAndSite = new Map<<id ,gii__Site__c >();
            set<id> accId = new set<id>();
            set<id> siteId = new set<id>();
            for(gii__SalesQuote__c sQ :listSalesQ ){
                if(sQ.gii__Account__c != null && sQ.giic_Site__c != null ){
                    accId.add(sQ.gii__Account__c);
                    siteId.add(sQ.giic_Site__c);
                }
            }
            system.debug('accId>>>'+accId);
            system.debug('siteId>>>'+siteId);
            if(accId.size() > 0 && siteId.size() > 0){
                list<gii__Site__c> listSite =[select id, gii__Account__c  from gii__Site__c  where id in:siteId AND gii__Account__c in:accId ];
                 system.debug('listSite>>>'+listSite);
                if(listSite.size() > 0)
                {
                    for(gii__Site__c site :listSite ){
                        if(!mapAccIdAdSiteList.containsKey(site.gii__Account__c)){
                            mapAccIdAdSiteList.put(site.gii__Account__c , new list<gii__Site__c>());
                        }
                        mapAccIdAdSiteList.get(site.gii__Account__c).add(site);
                        
                    }
                    
               
                system.debug('mapAccIdAdSiteList>>>'+mapAccIdAdSiteList);
                for(gii__SalesQuote__c sQ :listSalesQ ){
                    if(sQ.gii__Account__c != null && sQ.giic_Site__c != null ){
                        list<gii__Site__c> listS = mapAccIdAdSiteList.get(sQ.gii__Account__c); 
                        system.debug('listS>>>'+listS);
                        for(gii__Site__c sites :listS){
                            if(sites.gii__Account__c == sQ.giic_Site__c){
                                result.put(sQ.gii__Account__c ,'yes');  
                            }else{
                                result.put(sQ.gii__Account__c ,'No'); 
                            }
                        }
                    }
                }
            }
            }
            
        }
        
        return result;
    }
}