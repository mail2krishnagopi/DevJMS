/**
* @author Vidya Chirlanchi - vidya.chirlanchi@fujitsu.com
* @date Creation 03/01/2022
* @description giic_TR_SupplyPlanCycleValidation – Trigger on Supply Plan Cycle
*/
trigger giic_TR_SupplyPlanCycleValidation on gii__SupplyPlanCycle__c (before insert,before update,after update,after insert) {
    giic_SPCTrig_Dispatcher.init(new giic_SPCTrig_Handler(), Trigger.operationType); 
}