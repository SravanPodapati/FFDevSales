/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    This trigger is used for setting Relationship name on insert/update.            ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/

trigger AllRelationshipTriggers on Relationship__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update)
{
    
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId()); 
    
    if (notriggers == null || !notriggers.Flag__c)
    {
       
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
        {
           
            Map<Id,Account> accs 	= new Map<Id,Account>();
            List<Id> aids 			= new List<Id>();
            
            
            for(Relationship__c rel : trigger.new)
            {
                
                aids.add(rel.Account_A__c);
                aids.add(rel.Account_B__c);
            }
            
            accs = new Map<Id,Account>([select id, Name from Account where id IN :aids]);
            
            for(Relationship__c rel : trigger.new)
            {
            	
				if(accs.get(rel.Account_A__c) != null && accs.get(rel.Account_B__c)!= null)
				{
					 rel.Name = accs.get(rel.Account_A__c).Name + ' <--> ' + accs.get(rel.Account_B__c).Name;
                	 if (rel.Name.length() > 80) rel.Name = rel.Name.substring(0, 79);
				}	
               
            }
        }
    }
}