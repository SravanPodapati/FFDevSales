public with sharing class CampaignAddMembers {
	
	//GB-104 : Collaboration
	public static void AddEventContacts2CampaignMembers(List<Event> newEventList)
	{
		Set<Id> camsIds = new Set<Id>();
		Set<Id> consIds = new Set<Id>();
		
		Set<Event> eventsWithCampaigns = new Set<Event>();
		List<CampaignMember> newcammembers = new List<CampaignMember>();
		Map<Id, Campaign> eventCamMap = new Map<Id, Campaign>();
		Map<Id, Contact> eventConMap = new Map<Id, Contact>();
		
		for (Event e : newEventList) {
			if (e.WhoId!=null && e.Strategic_Campaign__c!=null)
	        	{
	            	eventsWithCampaigns.add(e);
	            	camsIds.add(e.Strategic_Campaign__c);
	            	consIds.add(e.WhoId);
	            	
	            }
		}
		system.debug('eventsWithCampaigns:' + eventsWithCampaigns);
		
		Map<Id, Campaign> camMap = new Map<Id, Campaign>([Select Id, (Select ContactId From CampaignMembers) From Campaign c WHERE c.Id In : camsIds]);
		Map<Id, Id> existCons= new Map<Id, Id>();
		//List<CampaignMember> existCons= new List<CampaignMember>();
		if (camMap.values().size()>0){
			for (Campaign c : camMap.values()){
				for (CampaignMember co: c.CampaignMembers){
					existCons.put(co.ContactId, c.id);
				}
				
			}
		}
		
		Map<Id, Contact> conMap = new Map<Id, Contact>([Select Id From Contact c WHERE c.Id In : consIds]);
		
		system.debug('camMap:' + camMap);
		system.debug('conMap:' + conMap);
		
		for (Event e : eventsWithCampaigns) {
			if (!eventCamMap.containskey(e.id)){
				eventCamMap.put(e.id,camMap.get(e.Strategic_Campaign__c));
			}
			if (!eventConMap.containskey(e.id)){
				if (!existCons.containskey(e.WhoId)){
					eventConMap.put(e.id,conMap.get(e.WhoId));
				}
			}
		}
		system.debug('eventCamMap:' + eventCamMap);
		system.debug('eventConMap:' + eventConMap);
		for(Event ec : eventsWithCampaigns) {
			if (eventConMap.containskey(ec.id)){
				system.debug('campaignId:' + eventCamMap.get(ec.id).id);
				system.debug('contactId:' + eventConMap.get(ec.id).id);
				CampaignMember newCM = new CampaignMember(
	              CampaignId=eventCamMap.get(ec.id).id,
	                ContactId=eventConMap.get(ec.id).id,
	                status = 'Sent' );
	                if (!existCons.containsKey(ec.WhoId)) {
	                	newcammembers.add(newCM);
	                }
			}
			
			
		}
		if (newcammembers.size()>0){
			insert newcammembers;
		}			
	}
	public static void AddTaskContacts2CampaignMembers(List<Task> newTaskList)
	{
		
		Set<Id> camsIds = new Set<Id>();
		Set<Id> consIds = new Set<Id>();
		
		Set<Task> eventsWithCampaigns = new Set<Task>();
		List<CampaignMember> newcammembers = new List<CampaignMember>();
		Map<Id, Campaign> eventCamMap = new Map<Id, Campaign>();
		Map<Id, Contact> eventConMap = new Map<Id, Contact>();
		
		for (Task e : newTaskList) {
			if (e.WhoId!=null && e.Strategic_Campaign__c!=null)
	        	{
	            	eventsWithCampaigns.add(e);
	            	camsIds.add(e.Strategic_Campaign__c);
	            	consIds.add(e.WhoId);
	            	
	            }
		}
		system.debug('eventsWithCampaigns:' + eventsWithCampaigns);
		
		Map<Id, Campaign> camMap = new Map<Id, Campaign>([Select Id, (Select ContactId From CampaignMembers) From Campaign c WHERE c.Id In : camsIds]);
		Map<Id, Id> existCons= new Map<Id, Id>();
		//List<CampaignMember> existCons= new List<CampaignMember>();
		if (camMap.values().size()>0){
			for (Campaign c : camMap.values()){
				for (CampaignMember co: c.CampaignMembers){
					existCons.put(co.ContactId, c.id);
				}
				
			}
		}
		
		Map<Id, Contact> conMap = new Map<Id, Contact>([Select Id From Contact c WHERE c.Id In : consIds]);
		
		system.debug('camMap:' + camMap);
		system.debug('conMap:' + conMap);
		
		for (Task e : eventsWithCampaigns) {
			if (!eventCamMap.containskey(e.id)){
				eventCamMap.put(e.id,camMap.get(e.Strategic_Campaign__c));
			}
			if (!eventConMap.containskey(e.id)){
				if (!existCons.containskey(e.WhoId)){
					eventConMap.put(e.id,conMap.get(e.WhoId));
				}
			}
		}
		
		system.debug('eventCamMap:' + eventCamMap);
		system.debug('eventConMap:' + eventConMap);
		for(Task ec : eventsWithCampaigns) {
			if (eventConMap.containskey(ec.id)){
				system.debug('campaignId:' + eventCamMap.get(ec.id).id);
				system.debug('contactId:' + eventConMap.get(ec.id).id);
				CampaignMember newCM = new CampaignMember(
	              CampaignId=eventCamMap.get(ec.id).id,
	                ContactId=eventConMap.get(ec.id).id,
	                status = 'Sent' );
	                if (!existCons.containsKey(ec.WhoId)) {
	                	newcammembers.add(newCM);
	                }
			}
			
			
			
		}
		if (newcammembers.size()>0){
			insert newcammembers;
		}			
	
	} 
}