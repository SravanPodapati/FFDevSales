/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    On change of Business Team Activity ownership, this trigger populates           ****
****    "Owner's Department" field with value from new owner's Department               ****
****    custom setting field.                                                            ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/



trigger AllBusinessTeamActivityTriggers on Business_Team_Activity__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    
    
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers       = No_Triggers__c.getInstance(UserInfo.getUserId());
    
    if (notriggers == null || !notriggers.Flag__c)
    {

        
        //#######################################################
        //################ After Update Trigger #################
        //#######################################################
        
        if(trigger.isAfter && trigger.isUpdate)
        {
            
            
            List<String> newOwners                  = new List<String>();
            List<String> newDepartments             = new List<String>();
            List<User> newOwnersProfileId           = new List<User>();
            
            Map<String, String> btaIdprofileIdmap   = new Map<String, String>();
            Map<String, String> ownerIdBTAmap       = new Map<String, String>();
            
            ConstantsH__c ch;
        
            
            
            for(integer i=0; i<trigger.new.size(); i++)
            {
                if(trigger.new[i].ownerId != trigger.old[i].ownerId)
                {
                    
                    newOwners.add(trigger.new[i].ownerId);
                    ownerIdBTAmap.put(trigger.new[i].ownerId, trigger.new[i].id);
                    
                }
            }
            
            
            newOwnersProfileId = [select id, profileId from User where id in :newOwners and isActive = true];
            
            
            for (User u : newOwnersProfileId)
            {
                
                if(ownerIdBTAmap.containsKey(u.Id))
                {
                    btaIdprofileIdmap.put(ownerIdBTAmap.get(u.Id), u.profileId);
                }
            }
            
            
            List<Business_Team_Activity__c> bta = [select id, Owner_s_Department__c from Business_Team_Activity__c where id in : btaIdprofileIdmap.keySet()];
        

            for(Business_Team_Activity__c busTeamAct : bta)
            {
                
                ch  = ConstantsH__c.getInstance(btaIdprofileIdmap.get(busTeamAct.Id));
                busTeamAct.Owner_s_Department__c = ch.Department__c;
            }
            
            
            if(!bta.isEmpty()) update bta;
        
        }
    }
}