/**
* @author Vidya Chirlanchi - vidya.chirlanchi@fujitsu.com
* @date Creation 01/03/2022
* @description giic_SPCTrig_Dispatcher- Dispatcher for generic Trigger
*/

public class giic_SPCTrig_Dispatcher{

/**
* @author Vidya Chirlanchi - vidya.chirlanchi@fujitsu.com 
* @description Method to init Dispatcher of Trigger Handlers
* @param handler Instance of the Trigger handler
* @param triggerEvent type of Trigger event
*/

public static void init(giic_SPCTrig_Handler handler, System.TriggerOperation triggerEvent){        
    
    switch on triggerEvent {   
            when AFTER_INSERT {
                handler.onAfterInsert(Trigger.new);
            }
             when AFTER_UPDATE {
                handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            }
        }  

    }

}