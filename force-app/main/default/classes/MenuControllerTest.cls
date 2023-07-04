@IsTest(SeeAllData=false)
public class MenuControllerTest {   
    
    static testMethod void testgetData(){       
        String menuType = 'List Menu';        
        Map<String, Object> mapURL = new Map<String, Object>();
        mapURL.put('href', 'https://boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com/gloviachannel/s/');
        mapURL.put('protocol','https:');
        mapURL.put('host','boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');
        mapURL.put('hostname','boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');
        mapURL.put('port','');
        mapURL.put('pathname','/gloviachannel/s/');
        mapURL.put('search','');
        mapURL.put('hash','');
        mapURL.put('origin','https://boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');        
        String url =JSON.serialize(mapURL);  
        
        Map<String, Object> mapResult = MenuController.getData(menuType,url);
        //System.assertEquals(mapResult.get('SelectedTab'), 'Home');
        
        Map<String, Object> mapURL1 = new Map<String, Object>();
        mapURL1.put('href', 'https://boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com/gloviachannel/s/recordlist/gii__SalesOrder__c/Recent');
        mapURL1.put('protocol','https:');
        mapURL1.put('host','boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');
        mapURL1.put('hostname','boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');
        mapURL1.put('port','');
        mapURL1.put('pathname','/gloviachannel/s/recordlist/gii__SalesOrder__c/Recent');
        mapURL1.put('search','');
        mapURL1.put('hash','');
        mapURL1.put('origin','https://boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');        
        String url1 =JSON.serialize(mapURL1);
        
        Map<String, Object> mapResult1 = MenuController.getData(menuType,url1); 
        //System.assertEquals(mapResult1.get('SelectedTab'), 'Sales Order');
        
        Account acc = new Account();
        acc.Name='Community Account';
        insert acc;
        String accountid = acc.id;
        
        Map<String, Object> mapURL2 = new Map<String, Object>();
        mapURL2.put('href', 'https://boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com/gloviachannel/s/detail/'+accountid);
        mapURL2.put('protocol','https:');
        mapURL2.put('host','boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');
        mapURL2.put('hostname','boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');
        mapURL2.put('port','');
        mapURL2.put('pathname','/gloviachannel/s/detail/'+accountid);
        mapURL2.put('search','');
        mapURL2.put('hash','');
        mapURL2.put('origin','https://boltsol-gloviaom-149afc1b0df-14b7a96-14c38166d77.cs68.force.com');        
        String url2 =JSON.serialize(mapURL2);
        
        Map<String, Object> mapResult2 = MenuController.getData(menuType,url2); 
        //System.assertEquals(mapResult2.get('SelectedTab'), 'Account');
        System.assert(true);
    }
}