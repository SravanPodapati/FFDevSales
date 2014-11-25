/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    This trigger is used for setting ownerId field on Contacts.                     ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/



trigger AllContactTriggers on Contact (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    
    
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers       = No_Triggers__c.getInstance(UserInfo.getUserId());
    
    if (notriggers == null || !notriggers.Flag__c)  
    {
        
        
        ConstantsH__c ch    = ConstantsH__c.getInstance(UserInfo.getProfileId());
        
        
       /* if(trigger.isBefore && trigger.isInsert)
        {

            Id newOwnerId = [select id from User where Name = :ch.Acc_and_Contact_owner__c limit 1].id;
            
            for(Contact c : trigger.new)
            {
               c.OwnerId = newOwnerId;
            }
        }*/
        
        if(trigger.isAfter && trigger.isInsert)
        {

            /*Id newOwnerId = [select id from User where Name = :ch.Acc_and_Contact_owner__c limit 1].id;
            List<Contact> contactList = new List<Contact>();
            for(Contact c : trigger.new)
            {
            	contactList.add(new Contact(Id=c.Id, OwnerId=newOwnerId));
            }            
            if(contactList.size()>0)
            {
            	update contactList;
            }*/
            List<Contact_Team__c> lContactTeamMembers   =   new List<Contact_Team__c>();
            // Add user to the contact team.
            for(Contact c : trigger.new)
            {
                Contact_Team__c sContactTeam    =   new Contact_Team__c();
                sContactTeam.Contact__c         =   c.Id;
                sContactTeam.Internal_User__c   =   UserInfo.getUserId();
                //NK sContactTeam.User_Department__c =   ch.Department__c;
                lContactTeamMembers.add(sContactTeam);
            }
            if(lContactTeamMembers.size()>0)
            {
	            try
	            {
	                insert  lContactTeamMembers;
	            }
	            catch(Exception e){
	                System.debug('Add Users To Contact Team Exception Log:'+e);             
	            }
            }           
            
            
        }
    
    }

}