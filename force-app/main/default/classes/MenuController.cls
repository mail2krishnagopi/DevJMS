public with sharing class MenuController {
    
    @AuraEnabled
    public static  Map<String, Object> getData(String menuType, String url){
        Map<String, Object> mapResult = new Map<String, Object>();
        List<MenuWrapper> lstWrapper = new List<MenuWrapper>();
        Map<String,String> mapLabels = new Map<String,String>();       
        String strMenuType =  menuType;        
        strMenuType = '%' + strMenuType + '%';         
        
        List<Menu__mdt> lstMenu = [SELECT IsActive__c, Sequence_Order__c, Label, Title__c, Sub_Title__c, Tab_Type__c, Tab_Value__c, Icon__c, 
                                   Theam_CSS__c, Menu_Type__c, List_View_Icon_Size__c, Tiles_View_Icon_Size__c
                                   FROM Menu__mdt 
                                   WHERE IsActive__c = true and Menu_Type__c like :strMenuType                               
                                   order by Sequence_Order__c];
        System.debug('lstMenu:::' + lstMenu );
        
        if(!lstMenu.isEmpty()){
            for(Menu__mdt objMenu : lstMenu){               
                MenuWrapper objWrapper = new MenuWrapper();
                if(objMenu.Tab_Type__c.equalsIgnoreCase('SOBJECT')){
                    mapLabels.put(objMenu.Tab_Value__c, objMenu.Title__c);
                }else{
                    mapLabels.put(objMenu.Tab_Value__c, objMenu.Label);
                }                
                objWrapper.Title = objMenu.Title__c;
                objWrapper.SubTitle = objMenu.Sub_Title__c;
                objWrapper.TabType = objMenu.Tab_Type__c;
                objWrapper.URL = objMenu.Tab_Value__c; 
                objWrapper.TheamCSS = objMenu.Theam_CSS__c;
                objWrapper.Icon = objMenu.Icon__c;
                objWrapper.ListIconSize = objMenu.List_View_Icon_Size__c;
                objWrapper.TilesIconSize = objMenu.Tiles_View_Icon_Size__c;
                lstWrapper.add(objWrapper);                           
            } 
        } 
        mapResult.put('menus', lstWrapper);
        
        String selectedTab = getSelectedTab(url, mapLabels); 
        mapResult.put('SelectedTab', selectedTab);
        
        List<Network> ntwrl = [Select Name, UrlPathPrefix from Network where Id= :Network.getNetworkId()];
        if(ntwrl != null && !ntwrl.isEmpty()) mapResult.put('UrlPathPrefix', ntwrl[0].UrlPathPrefix + '/s'); else mapResult.put('UrlPathPrefix', '');
        
        return mapResult;
    } 
    
    private static String getSelectedTab(String url, Map<String,String> mapLabels){
        System.debug('mapLabels:::' + mapLabels); 
        System.debug('url:::' + url); 
        if(url != null && url != ''){             
            Map<String, Object> mapURL = (Map<String, Object>)JSON.deserializeUntyped(url);            
            String path = (String) mapURL.get('pathname');
            System.debug('path:::' + path);            
            List<String> lstPath = path.split('/');
            System.debug('lstPath:::' + lstPath);
            System.debug('lstPathSize:::' + lstPath.size());
            
            for(Integer i = 0; i < lstPath.size(); i++){
                if(lstPath[i].equalsIgnoreCase('recordlist')){
                    if(mapLabels.containsKey(lstPath[i + 1]))  return mapLabels.get(lstPath[i + 1]);
                    else return 'Home';
                }else if(lstPath[i].equalsIgnoreCase('detail')){
                    Id recordId = (Id) lstPath[i + 1];
                    String sObjName = recordId.getSObjectType().getDescribe().getLabel();
                    return sObjName;
                }else if(lstPath[i].equalsIgnoreCase('salesorderlistview') || lstPath[i].equalsIgnoreCase('new-sales-order')){
                    return 'Sales Order';
                }else if(lstPath[i].equalsIgnoreCase('purchaseorderlistview') || lstPath[i].equalsIgnoreCase('new-purchase-order')){
                    return 'Purchase Order';
                }else if(lstPath[i].equalsIgnoreCase('report')){
                    return 'Reports';
                } 
            }
            
            return 'Home';
            /*if(lstPath.size() > 3 ){
                if(lstPath[3].equalsIgnoreCase('recordlist')){
                    if(mapLabels.containsKey(lstPath[4]))  return mapLabels.get(lstPath[4]);
                    else return 'Home';
                }else if(lstPath[3].equalsIgnoreCase('detail')){
                    Id recordId = (Id) lstPath[4];
                    String sObjName = recordId.getSObjectType().getDescribe().getLabel();
                    return sObjName;
                }else if(lstPath[3].equalsIgnoreCase('salesorderlistview') || lstPath[3].equalsIgnoreCase('new-sales-order')){
                    return 'Sales Order';
                }else if(lstPath[3].equalsIgnoreCase('purchaseorderlistview') || lstPath[3].equalsIgnoreCase('new-purchase-order')){
                    return 'Purchase Order';
                }else if(lstPath[3].equalsIgnoreCase('report')){
                    return 'Reports';
                }
                else{
                    return 'Home';
                }                 
            }
            else{
                return 'Home'; 
            }*/
        }
        return 'Home';        
    }
}