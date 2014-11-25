/*******************************************************************************************
********************************************************************************************
****																					****
****	This trigger is used for setting ownerId field on Revenue Insertion. 			****
****																					****
********************************************************************************************
*******************************************************************************************/



trigger AllRevenueInsertionTriggers on Revenue_Insertion__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
	
	
	//#
	//# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers 		= No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 	
    {
    	
    	ConstantsH__c ch 	= ConstantsH__c.getInstance(UserInfo.getProfileId());
    	
    	
		if(trigger.isBefore && trigger.isInsert)
		{
			
			Id newOwnerId 		= [select id from User where Name = :ch.Acc_and_Contact_owner__c limit 1].id;
			
			for(Revenue_Insertion__c ri : trigger.new)
			{
				ri.OwnerId = newOwnerId;
			}
		}
    }
}