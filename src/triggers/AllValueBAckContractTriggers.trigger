trigger AllValueBAckContractTriggers on Value_Back_Contract__c (before insert) {
	No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

	if (notriggers == null || !notriggers.Flag__c) 
	{
		ConstantsH__c ch = ConstantsH__c.getInstance(UserInfo.getProfileId());
		try 
		{
			AllValueBackContractTriggerMethods handler = new AllValueBackContractTriggerMethods(Trigger.isExecuting, Trigger.size);
			
            if (Trigger.isbefore && Trigger.isinsert) 
			{
				handler.onBeforeInsert(Trigger.new);
			}
		} 
		catch (Exception ex) 
		{

		}
	}
}