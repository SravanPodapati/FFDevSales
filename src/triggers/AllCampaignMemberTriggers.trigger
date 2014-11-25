/*******************************************************************************************
********************************************************************************************
****																					****
****	This trigger is used for ensuring that the Contacts used in a Campaign Member	****
****	are active.																		****
****																					****									
****																					****
********************************************************************************************
*******************************************************************************************/

trigger AllCampaignMemberTriggers on CampaignMember (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
	No_Triggers__c notriggers 		= No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 	
    {
		if(trigger.isBefore&&(trigger.isInsert||trigger.isUpdate))
		{
			AllCampaignMemberTriggerMethods.checkContactsOnCampaignMembers(trigger.new);
		}
    }
}