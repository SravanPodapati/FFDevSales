trigger AllEventTriggers on Event (before insert, after insert, after update) 
{
//GB-104 : Collaboration
    System.debug('Trigger.new:'+Trigger.new);
    
    ConstantsH__c ch    = ConstantsH__c.getInstance(UserInfo.getProfileId());
    
    
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    
    if (notriggers == null || !notriggers.Flag__c)  
    {
    	if(trigger.isAfter)
    	{
    		EventTriggerMethods.sendEmail(trigger.new);
    	}
		//AG - 2013-10-24 - conditional Event reassignment to BTA
		if(Trigger.isBefore && Trigger.isInsert) {
			TaskHandler.reassignToBTA(Trigger.new);
		}
		
		if(Trigger.isAfter && Trigger.isInsert) {
			CampaignAddMembers.AddEventContacts2CampaignMembers(Trigger.new);
		}
    }
}