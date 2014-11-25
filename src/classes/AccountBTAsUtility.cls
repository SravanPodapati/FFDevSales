public with sharing class AccountBTAsUtility 
{
	public static void CreateBTAs(Id accountId)
	{
		Business_Team_Activity__c[] newBTAs = new Business_Team_Activity__c[] {};
		
		Set<String> uniqueDepartments = new Set<String>();
		Set<String> uniqueNames	= new Set<String>();
		
		Map<String, String> departmentOwnerMap		= new Map<String, String>();
		Map<String, String> mapUserNameId 			= new Map<String, String>();
		
		
		ConstantsH__c[] constHlst = [select id, Name, Department__c, Acc_and_Contact_owner__c from ConstantsH__c];
		ConstantsH__c[] filteredConstH = new ConstantsH__c[] {};
			
		for(ConstantsH__c cnstH : constHlst)
		{	
			if(cnstH.Department__c != null && cnstH.Department__c != '' && cnstH.Department__c != 'None')
			{
				if(!uniqueDepartments.contains(cnstH.Department__c))
				{	 
					 uniqueDepartments.add(cnstH.Department__c);
					 filteredConstH.add(cnstH);
					 departmentOwnerMap.put(cnstH.Department__c, cnstH.Acc_and_Contact_owner__c);
					 
					 if(!uniqueNames.contains(cnstH.Acc_and_Contact_owner__c)) 
					 {
					 	uniqueNames.add(cnstH.Acc_and_Contact_owner__c);
					 }
				}
			}
		}
			
		//#
		//# Create a map where key will be user's name and value will be id of that user
		//#
		Map<Id, User> mapUser;
		if (uniqueNames.size() > 0)
		{
			mapUser = new Map<Id, User>([select id, Name from User where Name in : uniqueNames]);
			
			for(String tmpKey : mapUser.keyset())
			{
				string tmpUsername = mapUser.get(tmpKey).Name;
				
				if (!mapUserNameId.containsKey(tmpUsername))
				{
					mapUserNameId.put(tmpUsername, tmpKey);
				}
			}
		}
			
Account acc = [select name from Account where id =:accountId];

		for(ConstantsH__c constH : filteredConstH)
		{
			Business_Team_Activity__c bta = new Business_Team_Activity__c
			(
				Account__c				= accountId,
				Visibility__c	        = 'Departmental', 
				Owner_s_Department__c 	= constH.Department__c,
				//Name					= constH.Department__c,
				Name                    = acc.name + ' ('+constH.Department__c+')',
				OwnerId					= mapUserNameId.get(constH.Acc_and_Contact_owner__c)
			);
			
			newBTAs.add(bta);
		}
		
		insert newBTAs;
	}
}