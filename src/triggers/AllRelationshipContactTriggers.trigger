/*******************************************************************************************
********************************************************************************************
****																					****
****	This trigger is used for setting ownerId field on Relationship Contact. 		****
****																					****
********************************************************************************************
*******************************************************************************************/



trigger AllRelationshipContactTriggers on Relationship_Contact__c (after delete, after insert, after undelete, 
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
			
			for(Relationship_Contact__c rc : trigger.new)
			{
				rc.OwnerId = newOwnerId;
			}
		}
    }
   //# After update of the relationship contact.
   //Find the relationship and make it active.
     if(trigger.isAfter && trigger.isUpdate) 
        {               
                Set<Id> RelationshipContactsToUpdateIds = new Set<Id>();
                
                for(Relationship_Contact__c a: trigger.new) 
                {
                    if(a.active__c!= Trigger.oldMap.get(a.id).active__c && a.active__c==true) 
                    {
                           
                               RelationshipContactsToUpdateIds.add(a.Relationship__c);                      
                                            
                    }
                    System.debug('***RelationshipContactsToUpdateIds=' + RelationshipContactsToUpdateIds); 
                     System.debug('***Relationship=' + a.Relationship__c); 
                }
                                        List<Relationship__c> currrellista = [Select 
                                                        id,Active__c From Relationship__c
                                                     Where Relationship__c.id IN :RelationshipContactsToUpdateIds];    
                                                 
                       System.debug('***currrellista - part1 =' + currrellista);                                                                            
                   if (currrellista.size()>0)
                   {
                   	    for(Relationship__c r: currrellista) 
                   	    {
                   	        r.Active__c=true;
                   	        
                   	    }
                        System.debug('***currrellista=' + currrellista); 
                        update currrellista;
                   }
       }
}