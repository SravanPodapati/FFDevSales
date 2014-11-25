trigger AllOrderTriggers on Order(before insert, after update) {

	//#
	//# Do not execute for any user that has the No validation flag set to true
	//#
	No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

	if (notriggers == null || !notriggers.Flag__c) {
		ConstantsH__c ch = ConstantsH__c.getInstance(UserInfo.getProfileId());
		try {
			AllOrderTriggerMethods handler = new AllOrderTriggerMethods(Trigger.isExecuting, Trigger.size);
			// befor insert
			if (trigger.isBefore && trigger.isInsert) {
				handler.OnBeforeInsert(Trigger.new);
			}

			// AFTER UPDATE
			else if (Trigger.isUpdate && Trigger.isAfter) {
				handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
			}
		} catch (Exception ex) {

		}
	}
}