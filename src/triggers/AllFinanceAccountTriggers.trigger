trigger AllFinanceAccountTriggers on FinanceAccount__c(before insert, before update, after insert, after update) {
	//#
	//# Do not execute for any user that has the No validation flag set to true
	//#
	No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

	if (notriggers == null || !notriggers.Flag__c) {
		//FinanceAccountTriggerMethods.createCCIFinanceAccount(trigger.newMap.keyset(), trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isAfter);
		FinanceAccountTriggerMethods.updateFinanceAccountName(trigger.new, trigger.isInsert, trigger.isUpdate, trigger.isBefore);
		FinanceAccountTriggerMethods.createCCIFinanceAccount(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isAfter);
	}
	if (trigger.isAfter && trigger.isUpdate) {

		FinanceAccountTriggerMethods.updateCCIFinanceAccount(trigger.New, trigger.oldMap, trigger.isUpdate, Trigger.isAfter);
	}

}