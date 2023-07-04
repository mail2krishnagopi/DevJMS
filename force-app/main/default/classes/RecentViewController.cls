public with Sharing class RecentViewController {

    @AuraEnabled
    public static List<RecentlyViewed> getData(){ 
        List<RecentlyViewed> recentlylist = new List<RecentlyViewed>([Select Type, Id, Name from RecentlyViewed where Type != 'ListView' limit 5]);
        return recentlylist;
    }
}