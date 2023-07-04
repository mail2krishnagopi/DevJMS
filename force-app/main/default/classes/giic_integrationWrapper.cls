public class giic_integrationWrapper {
    public String sourceSobject {get;set;}
    public String targetSobject {get;set;}
    public String targetField {get;set;}
    public String sourceField {get;set;}
    public Boolean dataTypeField {get;set;}
    public giic_IntegrationMapping__mdt wrapperInstance{get;set;}
	public static List<giic_integrationWrapper> getWrapperList(String sourceObj, String targetObj){ //Add param source and target obj
		List<giic_integrationWrapper> lstMetaData = new List<giic_integrationWrapper>();
        //[Select giic_ExternalField__r.QualifiedApiName,giic_SourceObject__r.QualifiedApiName,giic_SourceField__r.QualifiedApiName,
        //giic_TargetObject__r.QualifiedApiName, giic_TargetField__r.QualifiedApiName From giic_IntegrationMapping__mdt Where giic_SourceObject__r.QualifiedApiName =: sourceObj AND giic_TargetObject__r.QualifiedApiName =: targetObj ]); //Put Soql query with filter as source and target obj
		for(giic_IntegrationMapping__mdt objMetaData : [Select giic_SourceObject__r.QualifiedApiName,giic_SourceField__r.DataType,giic_SourceField__r.QualifiedApiName,giic_TargetObject__r.QualifiedApiName,
                                                        giic_TargetField__r.QualifiedApiName,giic_IsDataTypeCheck__c From giic_IntegrationMapping__mdt Where giic_SourceObject__r.QualifiedApiName =: sourceObj AND giic_TargetObject__r.QualifiedApiName =: targetObj]){ //Use lstMetaData
			giic_integrationWrapper wrapperObj = new giic_integrationWrapper();
			wrapperObj.sourceSobject = objMetaData.giic_SourceObject__r.QualifiedApiName;
			wrapperObj.targetSobject = objMetaData.giic_TargetObject__r.QualifiedApiName;
			wrapperObj.targetField = objMetaData.giic_TargetField__r.QualifiedApiName;
			wrapperObj.sourceField = objMetaData.giic_SourceField__r.QualifiedApiName;
            wrapperObj.dataTypeField = objMetaData.giic_IsDataTypeCheck__c;
			system.debug('objMetaData>>>>2'+wrapperObj);
			wrapperObj.wrapperInstance = objMetaData;                                               
			system.debug('objMetaData>>>>3'+wrapperObj.wrapperInstance);
			lstMetaData.add(wrapperObj);
		}
		if(lstMetaData.size() > 0)
			return lstMetaData;
		else
			return null;
	}
}