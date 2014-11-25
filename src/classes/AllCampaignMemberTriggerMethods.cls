public with sharing class AllCampaignMemberTriggerMethods 
{
	public static void checkContactsOnCampaignMembers(List<CampaignMember> campaignMemberList)
	{
		Set<Id> contactIdSet = new Set<Id>();
		for(CampaignMember c:campaignMemberList)
		{
			contactIdSet.add(c.ContactId);
		}
		
		List<Contact> contactList = [
										Select
											Active__c,
											Name
										From Contact
										Where Id IN :contactIdSet
									];
		for(Contact c: contactList)
		{
			if(!c.Active__c)
			{
				trigger.new[0].addError('Contact: '+c.Name+' is InActive, Cannot Save record.');
			}
		}
	}
	

}