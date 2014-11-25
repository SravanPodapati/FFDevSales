/*******************************************************************************************
********************************************************************************************
****																					****
****	On change of Contact Details ownership, this trigger is used for populating 	****
****	"Owner's Department" field with value from new owner's Department 				****
****	custom setting field															****
****																					****
********************************************************************************************
*******************************************************************************************/



trigger AllContactDetailsTriggers on Contact_Details__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
	
	
	//#
	//# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers 		= No_Triggers__c.getInstance(UserInfo.getUserId());
    
    if (notriggers == null || !notriggers.Flag__c) 	
    {
    	
    	
    	if(trigger.isAfter && trigger.isUpdate)
		{
			
			
			List<String> newOwners 					= new List<String>();
			List<String> newDepartments 			= new List<String>();
			List<User> newOwnersProfileId 			= new List<User>();
			
			Map<String, String> cdIdprofileIdmap	= new Map<String, String>();
			Map<String, String> ownerIdCDmap		= new Map<String, String>();
			
			ConstantsH__c ch;
			
			
			
			for(integer i=0; i<trigger.new.size(); i++)
			{
				if(trigger.new[i].ownerId != trigger.old[i].ownerId)
				{
					
					newOwners.add(trigger.new[i].ownerId);
					ownerIdCDmap.put(trigger.new[i].ownerId, trigger.new[i].id);
					
				}
			}
			

			newOwnersProfileId = [select id, profileId from User where id in :newOwners];
			
			
			for (User u : newOwnersProfileId)
			{
				
				if(ownerIdCDmap.containsKey(u.Id))
				{
					cdIdprofileIdmap.put(ownerIdCDmap.get(u.Id), u.profileId);
				}
			}
			
			
			List<Contact_Details__c> cd = [select id, Owner_s_Department__c from Contact_Details__c where id in : cdIdprofileIdmap.keySet()];
			

			for(Contact_Details__c contDet : cd)
			{
				
				ch 	= ConstantsH__c.getInstance(cdIdprofileIdmap.get(contDet.Id));
				contDet.Owner_s_Department__c = ch.Department__c;
			}
			
			
			if(!cd.isEmpty()) update cd;

		}
    }
}