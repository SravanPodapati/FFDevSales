public with sharing class ViewBTAHistoryController {
 
 //private ApexPages.StandardController controller;
 public Account acc;
 static User testUser  = 
            [
            select id, name, email, ProfileId, Profile.Name 
            from User 
            where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator' 
        limit 1
        ];
            
 public ViewBTAHistoryController(ApexPages.StandardController std1controller) {
        this.acc= (Account)std1Controller.getRecord();
 }
 
    
String currentUser=UserInfo.getUserId() ; 
String currentUserProfile=UserInfo.getProfileId(); 
 
ConstantsH__c ch    = ConstantsH__c.getInstance(UserInfo.getProfileId());
Public String Department =  ch.Department__c;



public List <Business_Team_Activity__c> AllBTAActivity {
        get{
            if(AllBTAActivity == null) {
                
                AllBTAActivity = [select 
                                    id, name 
                                    from Business_Team_Activity__c
                                    where Business_Team_Activity__c.Account__c= :acc.id 
                                    and Business_Team_Activity__c.name = :acc.name + ' ('+Department+')'];
            }
            return AllBTAActivity;
        }
        set;    
    }



public List<Task> acthist {
    get {
    if(acthist == null) {

        acthist =[Select Subject,
                         ActivityDate,
                         Description,
                         Status,
                         OwnerId,
                         WhoId
                        // ,Who.Name 
                    From Task
                    Where Task.WhatId= :AllBTAActivity[0].id and Task.Status!= 'Completed'
                    Order By ActivityDate ASC
                    Limit 100];
         List<Task> acthistCompleted =[Select Subject,
                         ActivityDate,
                         Description,
                         Status,
                         OwnerId,
                         WhoId
                        // ,Who.Name 
                    From Task
                    Where Task.WhatId= :AllBTAActivity[0].id and Task.Status= 'Completed'
                    Order By ActivityDate ASC
                    Limit 100];           
         acthist.addAll(acthistCompleted);           
         }
            return acthist;
        }
        set;
}

public List<Event> acteventhist {
    get {
    if(acteventhist == null) {

        acteventhist =[Select Subject,
                         ActivityDate,
                         Description,
                         OwnerId,
                         WhoId
                        // ,Who.Name 
                    From Event
                    Where Event.WhatId= :AllBTAActivity[0].id
                    Order By ActivityDate DESC
                    Limit 100];
         }
            return acteventhist;
        }
        set;
}



public List<Task> getactivityPagination() {
         return acthist;
    }
public List<Event> geteventactivityPagination() {
         return acteventhist;
    }    
}