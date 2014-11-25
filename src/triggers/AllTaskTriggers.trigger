trigger AllTaskTriggers on Task (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
//GB-104 : Collaboration
	if(trigger.isBefore && trigger.isInsert)
    {
		// Make this profile specific i.e. Classified users only.
        /*for(Task t : trigger.new)
        {
           if (t.Outcome__c==Null){
           	t.Outcome__c = 'Ineffective';
           }
           if (t.Type__c==Null){
            t.Type__c = 'Reactive';
           }
        }*/
    		
		//TaskTriggerMethods.changeTaskCreatedBy(trigger.new);
    }
    /*if(trigger.isBefore && (trigger.IsInsert||trigger.isUpdate))
    {
    	TaskTriggerMethods.updateTaskContactMobileNo(trigger.OldMap, trigger.Old, trigger.NewMap, trigger.New);
    }*/
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) {
		//AG - 2013-10-24 - conditional Event reassignment to BTA
		TaskHandler handler  = TaskHandler.getHandler();
		if(Trigger.isBefore && Trigger.isInsert) {
			handler.beforeInsert();
		}
		if(Trigger.isAfter && Trigger.isInsert) {
			CampaignAddMembers.AddTaskContacts2CampaignMembers(Trigger.new);
		} 
	}
}