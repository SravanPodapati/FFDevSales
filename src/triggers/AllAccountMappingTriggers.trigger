trigger AllAccountMappingTriggers on Account_Mapping__c(after update, after delete) 
{

	//# Do not execute for any user that has the No validation flag set to true
	//#
	No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

	if (notriggers == null || !notriggers.Flag__c) 
	{
		ConstantsH__c ch = ConstantsH__c.getInstance(UserInfo.getProfileId());
		try 
		{
			AllAccountMappingTriggerMethods handler = new AllAccountMappingTriggerMethods(Trigger.isExecuting, Trigger.size);
			// befor insert

			// AFTER UPDATE
			if (Trigger.isUpdate && Trigger.isAfter) 
			{
				handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
			}
			else
			if(Trigger.isDelete && Trigger.isAfter)
			{
				// If a CCI Metro or a CCI Mail mapping is being deleted then the corresponding fields on the Account Record needs to be updated.
				AllAccountMappingTriggerMethods.updateCCIFieldsOnAccount(trigger.old);
			}
		} 
		catch (Exception ex) 
		{

		}
	}
}