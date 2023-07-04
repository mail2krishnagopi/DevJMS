trigger giic_picklistTrigger on gii__PickList__c (after insert, after update)
{
    if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert))
    {  
        /*for(gii__PickList__c pc : trigger.new)
          {
             giic_picklistDetailLabelPdfGenerator.PDFGenerator(pc);
          }   */
        
          if(trigger.new.size() == 1) 
          {
               giic_picklistDetailLabelPdfGenerator.PDFGenerator(trigger.new[0].id);
          }
    }  
}