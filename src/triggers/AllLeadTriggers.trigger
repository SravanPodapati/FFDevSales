/*******************************************************************************************
********************************************************************************************
****																					****
****	This trigger is used for changing field values on Account and Opportunity		****
****	after the Lead Conversion process.												****
****																					****
****	If lead Record Type is 'Media Lead' than the Record Type on converted 			****
****	opportunity will be 'Media Lead Opportunity' and Industry field on the			****
****	opportunity will be populated from Industry field on Lead.						****
****																					****
****	If lead Record Type is 'New Business' than the Record Type on converted 		****
****	opportunity will be 'Opportunity' and Industry field on the						****
****	opportunity will be populated from Industry field on Lead.						****		
****																					****
****	If lead Type is 'Client' than the Status on converted 							****
****	account will be 'Prospect' and Type field on the account will be 'Client'.		****
****																					****
****	If lead Type is 'Direct Advertiser' than the Status on converted 				****	
****	account will be 'Prospect' and Type field on the account will be 				****
****	'Direct Advertiser'.															****
****																					****
********************************************************************************************
*******************************************************************************************/



trigger AllLeadTriggers on Lead (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{


	//#
	//# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers 		= No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 	
    {
    	

		//#######################################################
		//################ After Update Trigger #################
		//#######################################################
			
		if (Trigger.isAfter && Trigger.isUpdate)
		{
			
			Map<Id, String>	opptyIdType				= new Map<Id, String>();
				
		 	Set<Id> accIds 							= new Set<Id>();
		 	Set<Id> accClientIds					= new Set<Id>();
		 	Set<Id> accDirectAdvertiserIds			= new Set<Id>();
		 	Set<Id> opptyMediaLeadIds 				= new Set<Id>();
		 	Set<Id> opptyNewBusinessIds 			= new Set<Id>();
		 	Set<Id> opptyOpptyIds					= new Set<Id>();
	 	
		 	List<Opportunity> opptysForUpdate 		= new List<Opportunity>();
		 	List<Account> accountsForUpdate 		= new List<Account>();
		 	

			String advertiserRecTypeId = 
					[
					select id 
					from RecordType 
					where DeveloperName = :Constants__c.getInstance('All').Advertiser_Record_Type__c 
					limit 1
					].id; 
			
			String mediaLeadRecTypeId = 
					[
					select id 
					from RecordType 
					where DeveloperName = :Constants__c.getInstance('All').Media_Lead_Opp_Record_Type__c 
					limit 1
					].id; 
					
			String opportunityRecTypeId = 
					[
					select id 
					from RecordType 
					where DeveloperName = :Constants__c.getInstance('All').Regular_Opp_Record_Type__c 
					limit 1
					].id; 
					
					

			for(integer i=0; i<trigger.new.size(); i++)
	  		{
	        		
				if ((trigger.new[i].isConverted == true) && (trigger.old[i].isConverted == false))
	        	{
	
					if(trigger.new[i].LeadSource == 'Newspaper')
	        		{
	        			opptyMediaLeadIds.add(trigger.new[i].ConvertedOpportunityId);
	        		}
	        		
	        		else if(trigger.new[i].LeadSource != 'Newspaper')
	        		{
	        			opptyOpptyIds.add(trigger.new[i].ConvertedOpportunityId);
	        		}
					
	
	
	        		if(trigger.new[i].Type__c == 'Client')
	        		{
	        			accClientIds.add(trigger.new[i].ConvertedAccountId);
	        		}
	        		
	        		
	        		if(trigger.new[i].Type__c == 'Direct Advertiser')
	        		{
	        			accDirectAdvertiserIds.add(trigger.new[i].ConvertedAccountId);
	        		}
	        		
	
	        		opptyIdType.put(trigger.new[i].ConvertedOpportunityId, trigger.new[i].Proactive_Reactive__c);
	        		
	        	}
	        }
	        
	       
	
			if(accClientIds.size() > 0)
	        {
		        
		        accountsForUpdate = 
		        		[
		        		select id, Name, Record_Type__c, RecordType.Name
		        		from Account
		        		where id IN: accClientIds
		        		];
		        
				Map<Id, Account> accMap 		= new Map<Id, Account>(accountsForUpdate);
		        	
		        
		        for(Lead l : trigger.new)
		        {
		        	if(accMap.containsKey(l.ConvertedAccountId))
		        	{
		        		Account acc 			= accMap.get(l.ConvertedAccountId);
		        		acc.Type 				= 'Client';
		        	} 
		        }
		        
		        accountsForUpdate = accMap.values();
		        
		        System.debug('>>>>>>>>>>>> accountsForUpdate ' + accountsForUpdate);
		        update accountsForUpdate;
		        
	        }
			
			accountsForUpdate.clear();
			
			
			if(accDirectAdvertiserIds.size() > 0)
	        {
		        
		        accountsForUpdate = 
		        		[
		        		select id, Name, Record_Type__c, RecordType.Name
		        		from Account
		        		where id IN: accDirectAdvertiserIds
		        		];
		        
				Map<Id, Account> accMap 		= new Map<Id, Account>(accountsForUpdate);
		        	
		        
		        for(Lead l : trigger.new)
		        {
		        	if(accMap.containsKey(l.ConvertedAccountId))
		        	{
		        		Account acc 			= accMap.get(l.ConvertedAccountId);
		        		acc.Type 				= 'Direct Advertiser';
		        	} 
		        }
		        
		        accountsForUpdate = accMap.values();
		        
		        System.debug('>>>>>>>>>>>> accountsForUpdate ' + accountsForUpdate);
		        update accountsForUpdate;
		        
	        }
	
	
	        if(opptyMediaLeadIds.size() > 0)
	        {
		        
		        opptysForUpdate = 
		        		[
		        		select id, Name, Record_Type__c, RecordType.Name
		        		from Opportunity
		        		where id IN: opptyMediaLeadIds
		        		];
		        
				Map<Id,Opportunity> oppMap 		= new Map<Id,Opportunity>(opptysForUpdate);
		        	
		        
		        for(Lead l : trigger.new)
		        {
		        	if(oppMap.containsKey(l.ConvertedOpportunityId))
		        	{
		        		Opportunity opp 		= oppMap.get(l.ConvertedOpportunityId);
		        		opp.RecordTypeId 		= mediaLeadRecTypeId;
		        		//opp.Industry__c 		= l.Industry; 
		        		opp.Created_Using__c	= 'Lead Conversion';
		        		opp.Type				= opptyIdType.get(l.ConvertedOpportunityId);	
		        	
		        	} 
		        }
		        
		        opptysForUpdate = oppMap.values();
		        
		        System.debug('>>>>>>>>>>>> opptysForUpdate ' + opptysForUpdate);
		        update opptysForUpdate;
		        
	        }
	     
	     
			opptysForUpdate.clear();
	
	
	        
	        if(opptyOpptyIds.size() > 0)
	        {
		        
		        opptysForUpdate = 
		        		[
		        		select id, Name, Record_Type__c, RecordType.Name
		        		from Opportunity
		        		where id IN: opptyOpptyIds
		        		];
		        		
		        Map<Id,Opportunity> oppMap 		= new Map<Id,Opportunity>(opptysForUpdate);
		        
		        
		        for(Lead l : trigger.new)
		        {
		        	if(oppMap.containsKey(l.ConvertedOpportunityId))
		        	{
		        		Opportunity opp 		= oppMap.get(l.ConvertedOpportunityId);
		        		opp.RecordTypeId 		= opportunityRecTypeId;
		        		//opp.Industry__c 		= l.Industry;
		        		opp.Created_Using__c	= 'Lead Conversion';
		        		opp.Type				= opptyIdType.get(l.ConvertedOpportunityId);	
		      
		        	} 
		        }
		        
		        opptysForUpdate = oppMap.values();
		        
		        System.debug('>>>>>>>>>>>> opptysForUpdate ' + opptysForUpdate);
		        update opptysForUpdate;
		        
	        }
	        
		}	
    }
}