// Apex class which adds the user to a contact team of a specific contact

public with sharing class AddUserToContactTeam {
    
    public Id ContactID {get;set;}
    
    public AddUserToContactTeam(){
        ContactID   =   ApexPages.currentPage().getParameters().get('Id');
    }

    public PageReference AddToContactTeam(){
        
        
        // System.debug('Contact ID:'+ContactID);
        ConstantsH__c ch                    = ConstantsH__c.getInstance(UserInfo.getProfileId());   
        List<Contact_Team__c> lContactTeams = [SELECT Id, Internal_User__c, User_Department__c, Internal_User_Role__c
                                               FROM contact_team__c where Contact__c = :ContactID  and Internal_User__c =: UserInfo.getUserId()];
        // System.debug('Contact Team Size:'+lContactTeams);
        
        // Check if the user is a member of the contact team. If yes - no action needed. If no - add user to the contact team. 
        
        if(lContactTeams.size() == 0){
            Contact_Team__c sContactTeam    =   new Contact_Team__c();
            sContactTeam.Contact__c         =   ContactID;
            sContactTeam.Internal_User__c   =   UserInfo.getUserId();
            sContactTeam.User_Department__c =   ch.Department__c;
            
            try{
                insert  sContactTeam;
            }
            catch(Exception e){
                return null;
            }
                        
        }
        
        PageReference contactPage = new PageReference('/'+ContactID);
        contactPage.setRedirect(true);
     
        return contactPage;     

                                               
        
    }

@isTest(SeeAllData=true)
 private static void testAddUserToContactTeam()
    {
       User testUser  = 
                [
                Select name, email, ProfileId, Profile.Name 
                From User 
                Where isActive = true /*and managerId != null*/ 
                And Profile.Name = 'System Administrator' 
                Limit 1
                ];

 
        Contact sContact = new Contact(FirstName='Jane', LastName='Doe');
        insert sContact;
        // Contact sContact = [select id from contact order by createddate desc limit 1];

        Test.startTest();
            system.runAs(testUser)
            {
                PageReference pageRef = Page.AddUserToContactTeam;
                Test.setCurrentPageReference(pageRef);
                
                ApexPages.currentPage().getParameters().put('Id', sContact.id);
                        
                AddUserToContactTeam    oAUTCT = new AddUserToContactTeam();
                oAUTCT.AddToContactTeam();
                
             }
        Test.stopTest();
        
        Contact_Team__c ct = [
        						Select Contact__c
        						From Contact_Team__c
        						Where Contact__c = :sContact.Id
        						Limit 1
        						];
        System.assertEquals(ct.Contact__c, sContact.Id);
        
    }
    

}