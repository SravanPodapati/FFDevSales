public with sharing class ViewBTAHistoryWithinAccount
{
//GB-92 : Collaboration
//List<wrapperopenactivity> openactivity {get;set;}
 
 //private ApexPages.StandardController controller;
public transient Account acc;

//public Map<ID,Opportunity> pitchMap = new Map<ID,Opportunity>();
 /*static User testUser  = 
            [
                select id, name, email, ProfileId, Profile.Name 
                from User 
                where isActive = true and Profile.Name = 'System Administrator' 
                limit 1
            ];*/
 
 private static String currentUserLocale = UserInfo.getlocale();
 private static String currentUserTZ = UserInfo.getTimeZone().getID();
 
 private Static String usersDateFormatEvent
 {
 	get
 	{
 		if(usersDateFormatEvent==null)
 		{
 			return getUserEventDateFormat(); 
 		}
 		else
 		{
 			return usersDateFormatEvent;
 		}
 	}
 	set;
 }

 private Static String usersDateFormatTask
 {
 	get
 	{
 		if(usersDateFormatTask==null)
 		{
 			return getUserTaskDateFormat(); 
 		}
 		else
 		{
 			return usersDateFormatTask;
 		}
 	}
 	set;
 } 
 public ViewBTAHistoryWithinAccount()
 {
    //this.tsk= (Task)std1Controller.getRecord().What();
    if(System.currentPageReference().getParameters().get('id')==null)
    {
            //Include error checking here
    } 
    else
    {
        transient String aId = System.currentPageReference().getParameters().get('id');
        transient Task tsk;
        transient Event event;
        transient Business_Team_Activity__c bta;  
        transient Opportunity opp;
        transient Contact con; 
        transient Campaign cam;  
        transient Id whatId;
        transient Id accountId;
        
        acc = new Account();
        
        if(aId.startswith(cam_prefix))
        {                  
            cam=[Select t.Advertiser__c
                 From Campaign t
                 Where t.id = :aId];
            WhatId=cam.Advertiser__c;
            accountId=cam.Advertiser__c;
            //acc.Id = cam.Advertiser__r.Id;
        }  
        
        else if(aId.startswith(tsk_prefix))
        {                  
            tsk=[Select 
                        t.WhatId,
                        t.AccountId
                 From Task t
                 Where t.id = :aId];
            whatId = tsk.WhatId;
            accountId = tsk.AccountId;
        }   
        else if(aId.startswith(con_prefix))
        {                  
            con=[Select 
                        t.AccountId
                 From Contact t
                 Where t.id = :aId];
            whatId = con.AccountId;
            accountId = con.AccountId;
        }
        
        else
        {
            event=[Select 
                        e.WhatId,
                        e.AccountId
                 From Event e
                 Where e.id = :aId];
            whatId = event.WhatId;
            accountId = event.AccountId;
        }              
        System.debug('tsk:'+tsk); 
        transient String whatIdStr = whatId;
        if(whatIdStr==null)
        {
            if(tsk.AccountId!=null)
            {
                acc.Id=whatId;
            }
        }
        else if(whatIdStr.startswith(bta_prefix))
        {
            bta=[Select 
                        b.Account__c 
                    From Business_Team_Activity__c b
                    Where b.id = :whatId];
            acc.Id = bta.Account__c;
        }
        else if(whatIdStr.startswith(opp_prefix))
        {
            opp=[Select 
                        o.AccountId
                    From Opportunity o
                    Where o.id = :whatId];
            acc.Id = opp.AccountId;
        }
        
        else if(whatIdStr.startswith(acc_prefix))
        {
            acc.Id=whatId;
        }
        /*else if(whatIdStr.startswith(con_prefix))
        {
            con=[Select 
                        c.AccountId
                    From Contact c
                    Where c.id = :whatId];
            acc.Id = con.AccountId;
        }*/
        else
        {
            
        }        
        


        System.debug('acc.id:'+acc.Id);
      }
 }
            
 public ViewBTAHistoryWithinAccount(ApexPages.StandardController std1controller) 
 {
        this.acc= (Account)std1Controller.getRecord();
        System.debug('Account from Standard Controller:'+ acc);
        // acc.Id=acc.id;
 }
 
    
//String currentUser=UserInfo.getUserId() ; 
//String currentUserProfile=UserInfo.getProfileId(); 
private transient String userProfile                       { get; set; }
public transient Boolean isLondon                          { get; set; }
public transient Boolean isnotLondon                       { get; set; }

private Static String bta_prefix 
{ 
    get
    {
        return Schema.SObjectType.Business_Team_Activity__c.getKeyPrefix();
    } 
    set; 
}
            
private Static String acc_prefix 
{ 
    get
    {
        return Schema.SObjectType.Account.getKeyPrefix();
    } 
    set; 
}

private  Static String opp_prefix 
{ 
    get
    {
        return Schema.SObjectType.Opportunity.getKeyPrefix();
    } 
    set; 
}

private Static String cam_prefix 
{ 
    get
    {
        return Schema.SObjectType.Campaign.getKeyPrefix();
    } 
    set; 
}

private  Static String con_prefix 
{ 
    get
    {
        return Schema.SObjectType.Contact.getKeyPrefix();
    } 
    set; 
}

private  Static String tsk_prefix 
{ 
    get
    {
        return Schema.SObjectType.Task.getKeyPrefix();
    } 
    set; 
}
  
private  Static String event_prefix 
{ 
    get
    {
        return Schema.SObjectType.Event.getKeyPrefix();
    } 
    set; 
}

private Static ConstantsH__c ch    = ConstantsH__c.getInstance(UserInfo.getProfileId());
private Static String Department =  ch.Department__c;

public List <Business_Team_Activity__c> AllBTAActivity {
        get{
            if(AllBTAActivity == null) {
                System.debug('Team Activity:'+acc.name + ' ('+Department+')');
                System.debug('acc.id:'+acc.id);
                AllBTAActivity = [select 
                                    id, name 
                                    from Business_Team_Activity__c
                                    where Business_Team_Activity__c.Account__c= :acc.id 
                                    /*and Business_Team_Activity__c.name = :acc.name + ' ('+Department+')'*/];
            }
            return AllBTAActivity;
        }
        set;    
    }

private Set<ID> pitchIDs 
    {
        get
        {
           transient Map<Id,Opportunity> pitchmap = new Map<Id,Opportunity>([select id, Name, AccountId, Agency__c from opportunity where AccountId = :acc.id OR Agency__c = :acc.id]);            
            //for (Opportunity op : pitches)
            //{
                //pitchIDs.add(op.Id);
            //}          
           return pitchmap.keyset();
        }
        set;
    }
    
private Set<ID> campaignIDs 
    {
        get
        {
           transient Map<Id, Campaign> campaignmap = new Map<Id,Campaign>([select id, Name, Advertiser__c, Digital_Agency__c from Campaign where Advertiser__c = :acc.id OR Digital_Agency__c = :acc.id]);            
            //for (Opportunity op : pitches)
            //{
                //pitchIDs.add(op.Id);
            //}          
           return campaignmap.keyset();
        }
        set;
    }    

private Set<ID> contactIDs 
    {
        get
        {
           Map<Id,Contact> contactmap = new Map<Id,Contact>([select id, Name, AccountId from Contact where AccountId = :acc.id]);            
           return contactmap.keyset();
        }
        set;
    }

/*public Set<ID> whoIDs 
    {
        get
        {
           Map<Id,Contact> whoIDs = new Map<Id,Contact>([select id, Name, AccountId from Contact where AccountId = :acc.id]);            
           return whoIDs.keyset();
        }
        set;
    }

Public Map<Id,Contact> conmap = new Map<Id,Contact>([Select id, AccountId from Contact where ])
*/
public List<Task> acthist 
{
    get {
    if(acthist == null) {

        acthist =[Select Subject,
                         ActivityDate, 
                         CreatedDate,
                         LastModifiedDate,
                         Status,
                         OwnerId,
                         WhoId,
                         WhatId,
                         Description,
                         t.Owner.name,
                         t.Who.name,
                         t.What.name,
                         Priority,
                         Outcome__c,
                         Prepare__c,
                         Open__c,
                         Probe__c,
                         Match__c,
                         Agreement__c,
                         Close__c,
                         AccountId,
                         Account.Name
                    From Task t
                    Where (t.WhatId IN :AllBTAActivity     // = :AllBTAActivity[0].id
                    OR t.WhatId In :pitchIDs
                    OR t.WhatId In :campaignIDs
                    OR t.WhatId In :contactIDs
                    OR t.WhatId= :acc.id 
                    OR (t.AccountId = :acc.id
                    AND t.WhatId != null)
                    OR (t.AccountId = :acc.id
                    AND t.WhatId = null))
                    Order By ActivityDate DESC
                    limit 300];
         }
            System.debug('acthist:'+acthist);
            return acthist;
        }
        set;
}

public List<Event> acteventhist {
    get {
    if(acteventhist == null) {

        acteventhist =[Select Subject,
                         ActivityDate, 
                         ActivityDateTime,
                         EndDateTime,
                         CreatedDate,
                         LastModifiedDate,
                         Status__c,
                         Description,
                         OwnerId,
                         WhoId,
                         WhatId,
                         e.Owner.name,
                         e.Who.name,
                         e.What.name,
                         AccountId,
                         Account.Name,
                         Proposed_Agenda__c
                    From Event e
                    Where (e.WhatId IN :AllBTAActivity //= :AllBTAActivity[0].id
                    OR e.WhatId In :pitchIDs
                    OR e.WhatId In :campaignIDs
                    OR e.WhatId In :contactIDs 
                    OR e.WhatId= :acc.id
                    OR (e.AccountId = :acc.id
                    AND e.WhatId != null)
                    OR (e.AccountId = :acc.id
                    AND e.WhatId = null))
                    Order By ActivityDate DESC
                    Limit 200];
         }
            System.debug('acteventhist:'+acteventhist);
            return acteventhist;
        }
        set;
}

////////////////////////////////////////////////////////////////

public List<wrapperopenactivity> allactivity {
        get
        {
            
            transient String strrelatedObject;
            allactivity = new List<wrapperopenactivity>();
            for(Task co : acthist) {
            transient String whatId = co.WhatId;
            if(whatid==null)
            {
                strrelatedObject='Account';
            }
            else if(whatId.startswith(bta_prefix))
            {
                strrelatedObject='BTA';
            }
            else if(whatId.startswith(opp_prefix))
            {
                strrelatedObject='Pitch';
            }
            else if(whatId.startswith(acc_prefix))
            {
                strrelatedObject='Account';
            }
            else if(whatId.startswith(cam_prefix))
            {
                strrelatedObject='Campaign';
            }
            else
            {
                strrelatedObject='Account';
            }
               transient wrapperopenactivity record5 = new wrapperopenactivity(co, strrelatedObject);
               allactivity.add(record5); 
         } 
            String strrelatedObject1;                         
        for(Event cp : acteventhist)
        {
           transient datetime myDateTime2 = datetime.now();
           transient String whatId = cp.WhatId;
           if(whatId==null)
           {
               strrelatedObject1='Account';
           }
           else if(whatId.startswith(bta_prefix))
           {
               strrelatedObject1='BTA';
           }
           else if(whatId.startswith(opp_prefix))
           {
               strrelatedObject1='Pitch';
           }
           else if(whatId.startswith(acc_prefix))
           {
               strrelatedObject1='Account';
           }
           else if(whatId.startswith(cam_prefix))
           {
                strrelatedObject1='Campaign';
           }  
           else
           {
               strrelatedObject1='Account';
           }
               transient wrapperopenactivity record6 = new wrapperopenactivity(cp, strrelatedObject1);
               allactivity.add(record6); 
           }
    return allactivity;  
       }
        Set;   
       }       



//////////////////////////////////////////////////////////////// 
      
       public List<wrapperopenactivity> openactivity 
       {
        get
        {
            
	        transient String strrelatedObject2;
	        openactivity = new List<wrapperopenactivity>();
	        for(Task co : acthist) 
	        {
	            if(co.get('Status') != 'Completed')
	            {
	               String whatId = co.WhatId;
	               if(whatId==null)
	               {
	                  strrelatedObject2='Account';
	               }
	               else if(whatId.startswith(bta_prefix))
	               {
	                  strrelatedObject2='BTA';
	               }
	               else if(whatId.startswith(opp_prefix))
	               {
	                  strrelatedObject2='Pitch';
	               }
	               else if(whatId.startswith(acc_prefix))
	               {
	                  strrelatedObject2='Account';
	               }
	               else if(whatId.startswith(cam_prefix))
           		   {
                	  strrelatedObject2='Campaign';
           		   }
	               else
	               {
	                 strrelatedObject2='Account';
	               }
	               transient wrapperopenactivity record1 = new wrapperopenactivity(co, strrelatedObject2);
	               openactivity.add(record1); 
	            }
		  	} 
			transient String strrelatedObject3;                         
			for(Event cp : acteventhist) 
			{
				transient datetime myDateTime1 = datetime.now();
			    if((DateTime)cp.get('EndDateTime') > myDateTime1)
			    {
			       String whatId = cp.WhatId;
			       if(whatId==null)
			       {
			          strrelatedObject3='Account';
			       }
			       else if(whatId.startswith(bta_prefix))
			       {
			          strrelatedObject3='BTA';
			       }
			       else if(whatId.startswith(opp_prefix))
			       {
			         strrelatedObject3='Pitch';
			       }
			       else if(whatId.startswith(acc_prefix))
			       {
			         strrelatedObject3='Account';
			       }
			        else if(whatId.startswith(cam_prefix))
           		   {
                	  strrelatedObject3='Campaign';
           		   }
			       else
			       {
			         strrelatedObject3='Account';
			       }
			       transient wrapperopenactivity record2 = new wrapperopenactivity(cp, strrelatedObject3);
			       openactivity.add(record2); 
			    }
			}
  		  return openactivity;  
       	}
       	 Set;   
       }
       
//////////////////////////////////////////////////////////////// 
      
       private List<wrapperopenactivity> activityhist 
       {
        get
        {            
            transient String strrelatedObject4;
            activityhist = new List<wrapperopenactivity>();
            for(Task co : acthist) 
            {
	            if(co.get('Status') == 'Completed')
	            {
	              transient String whatId = co.WhatId;
	              if(whatId==null)
	              {
	                 strrelatedObject4='Account';
	              }
	              else if(whatId.startswith(bta_prefix))
	              {
	                 strrelatedObject4='BTA';
	              }
	              else if(whatId.startswith(opp_prefix))
	              {
	                 strrelatedObject4='Pitch';
	              }
	              else if(whatId.startswith(acc_prefix))
	              {
	                 strrelatedObject4='Account';
	              }
	              else if(whatId.startswith(cam_prefix))
           		  {
                	 strrelatedObject4='Campaign';
           		  }
	              else
 	              {
	                strrelatedObject4='Account';
	              }
                  transient wrapperopenactivity record3 = new wrapperopenactivity(co, strrelatedObject4);
                  activityhist.add(record3); 
            }
        } 
        transient String strrelatedObject5;                         
        for(Event cp : acteventhist) 
        {
       		transient datetime myDateTime2 = datetime.now();
            if((DateTime)cp.get('EndDateTime') < myDateTime2)
            {
              transient String whatId = cp.WhatId;
              if(whatId==null)
              {
                 strrelatedObject5='Account';
              }
              else if(whatId.startswith(bta_prefix))
              {
                 strrelatedObject5='BTA';
              }
              else if(whatId.startswith(opp_prefix))
              {
                strrelatedObject5='Pitch';
              }
              else if(whatId.startswith(acc_prefix))
              {
                strrelatedObject5='Account';
              }
              else if(whatId.startswith(cam_prefix))
           	  {
                  strrelatedObject5='Campaign';
           	  }
              else
              {
                strrelatedObject5='Account';
              }
               transient wrapperopenactivity record4 = new wrapperopenactivity(cp, strrelatedObject5);
               activityhist.add(record4); 
            }
        }
    	return activityhist;  
       }
        Set;   
       }       
        
////////////////////////////////////////////////////////////// 
 
public class wrapperopenactivity {
        public transient Task openTask { get; set; }
        public transient Event openEvent { get; set; }
        public transient String subject { get; set; }
        public transient Datetime dateCreated { get; set; }
        public transient Datetime lastModified { get; set; }
        public transient String strLastModified { get; set; }
        public transient Datetime endDateTime { get; set; }
        public transient Datetime activityDate { get; set; }
        public transient String strActivityDate { get; set; }
        public transient String status { get; set; }
        public transient ID currid { get; set; }
        public transient String what { get; set; }
        public transient ID whatId { get; set; }
        public transient String who { get; set; }
        public transient ID whoId { get; set; }
        public transient ID contactAccountId { get; set; }
        public transient String contactAccountName { get; set; }
        public transient String owner { get; set; }
        public transient ID ownerId { get; set; }
        public transient Boolean isitaTask { get; set; }
        public transient String priority { get; set; }
        public transient String Prepare { get; set; }
        public transient String Open { get; set; }
        public transient String Probe { get; set; }
        public transient String Match { get; set; }
        public transient String Agreement { get; set; }
        public transient String Close { get; set; }
        public transient String Outcome { get; set; }
        public transient String Comments { get; set; }
        public transient String RelObj { get; set; }
        public transient String ProposedAgenda { get; set; }
                      
        //public wrapperopenactivity(Task theTask)
        //{
        //    this.openTask=theTask;  
        //}
        
        //public wrapperopenactivity(Task theEvent)
        //{
        //    this.openEvent=theEvent;  
        //}
        
        public wrapperopenactivity(Task theTask, String strrelatedObject)
        {
            this.subject=theTask.subject;
            this.dateCreated=theTask.CreatedDate;
            this.status=theTask.status;
            this.currid=theTask.id;
            this.isitaTask=True;
            this.what=theTask.What.name;
            this.whatId=theTask.WhatId;
            this.who=theTask.Who.name;
            this.whoId=theTask.WhoId;
        	this.contactAccountId=theTask.AccountId;
            this.contactAccountName=theTask.Account.Name;
            this.owner=theTask.Owner.name;
            this.ownerId=theTask.OwnerId;
            this.activityDate=theTask.ActivityDate;
            
            // this.stractivityDate=this.activityDate.format('dd/MM/yyyy HH:mm',currentUserTZ);
            System.debug('currentUserTZ:'+currentUserTZ);
            System.debug('activityDate:'+this.activityDate);
            //System.debug('getUserDateFormat:'+usersDateFormat);
            //System.debug('this.activityDate.format(usersDateFormat,currentUserTZ):'+this.activityDate==null?null:this.activityDate.format(usersDateFormat,currentUserTZ));
            
            this.stractivityDate=this.activityDate==null?null:this.activityDate.format(usersDateFormatTask,currentUserTZ);
            this.priority=theTask.Priority;
            this.lastModified=theTask.LastModifiedDate;
            this.strLastModified=this.lastModified.format(usersDateFormatEvent, currentUserTZ);
            this.Prepare=theTask.Prepare__c;
            this.Open=theTask.Open__c;
            this.Probe=theTask.Probe__c;
            this.Match=theTask.Match__c;
            this.Agreement=theTask.Agreement__c;
            this.Close=theTask.Close__c;
            this.Outcome=theTask.Outcome__c;
            this.Comments=theTask.Description;
            this.RelObj=strrelatedObject;
        }
        public wrapperopenactivity(Event theEvent, String strrelatedObject)
        {
            this.subject=theEvent.subject;
            this.dateCreated=theEvent.CreatedDate;
            this.endDateTime=theEvent.EndDateTime;
            this.status=theEvent.status__c;
            this.currid=theEvent.id;
            this.isitaTask=False;
            this.what=theEvent.What.name;
            this.whatId=theEvent.WhatId;
            this.who=theEvent.Who.name;
            this.whoId=theEvent.WhoId;
        	this.contactAccountId=theEvent.AccountId;
            this.contactAccountName=theEvent.Account.Name;            
            this.owner=theEvent.Owner.name;
            this.ownerId=theEvent.OwnerId;
            // this.activityDate=theEvent.ActivityDate;
            this.activityDate=theEvent.ActivityDateTime;
            this.stractivityDate=this.activityDate==null?null:this.activityDate.format(usersDateFormatEvent,currentUserTZ);
            //this.stractivityDate=this.activityDate.format('dd/MM/yyyy HH:mm');
            this.lastModified=theEvent.LastModifiedDate;
            this.strLastModified=this.lastModified.format(usersDateFormatEvent, currentUserTZ);
            this.Comments=theEvent.Description;
            this.RelObj=strrelatedObject;
            this.ProposedAgenda=theEvent.Proposed_Agenda__c;
         }
        
}

	/*The following code is removed because we are assuming that the AccountId field
	  on both the Task and the Activity will be populated by SF if the WhoId is populated*/
	private Map<Id, Contact> contactsAccount(Set<Id> contactSet)
	{
		transient Map<Id, Contact> contactMap = new Map<Id, Contact>([
															Select AccountId,
																   Account.Name
															From Contact
															Where Id IN :contactSet]);
		// System.debug('contactMap:'+contactMap);
		return contactMap;
	}
	
	private List<wrapperopenactivity> addContactsAccount(List<wrapperopenactivity> inActivityList)
	{
		transient List<wrapperopenactivity> activityList = new List<wrapperopenactivity>();
		activityList = inActivityList;
		transient Set<Id> contactIdSet = new Set<Id>();
		for(wrapperopenactivity a: activityList)
        {
        	if(a.WhoId!=null)
        	{
        		transient String whoIdStr = a.WhoId;
        		if(whoIdStr.startswith(con_prefix))
        		{
        			contactIdSet.add(a.WhoId);
        		}
        	}
        }
        transient Map<Id, Contact> contactMap = new Map<Id, Contact>();
        System.debug('before contact map');
        contactMap = contactsAccount(contactIdSet);
        System.debug('Contacts Map'+contactMap);
        
        for(wrapperopenactivity a:activityList)
        {
    		transient String whoIdStr = a.WhoId;
    		if(a.WhoId!=null)
    		{
	    		if(whoIdStr.startswith(con_prefix))
	    		{	
	    			System.debug('contactMap.get(a.WhoId).AccountId:'+contactMap.get(a.WhoId).AccountId);
	    			System.debug('contactMap.get(a.WhoId).Account.Name:'+contactMap.get(a.WhoId).Account.Name);
		        	a.ContactAccountId = contactMap.get(a.WhoId).AccountId;
		        	a.ContactAccountName = contactMap.get(a.WhoId).Account.Name;
	    		}
    		}
        }
        
        return activityList;
	        
	}
     
////////////////////////////////////////////////////////////// 


	public List<wrapperopenactivity> getallactivitypagination() 
	{
	    try
	    {

	    	
	        userProfile = [
	                            Select Name 
	                            From   Profile
	                            Where Id = :UserInfo.getProfileId()
	                            ].Name;
	        if(userProfile.substring(0,6)=='London'||userProfile.substring(0,6)=='System')
	        {
	            isLondon=true;
	        }
	        else
	        {
	            isLondon=false;
	            isnotLondon=true;
	        }
	        
	        transient List<wrapperopenactivity> allactivityWithContactAcc = addContactsAccount(allactivity);
	        // System.debug('allactivityWithContactAcc:'+allactivityWithContactAcc);     
	        return sortList(allactivityWithContactAcc);
	        // return sortList(allactivity);
	    }
	    catch(Exception ex)
	    {
	      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
	      return null;
	    }
       
    }    


	public List<wrapperopenactivity> getopenactivitypagination() 
	{
	    try
	    {
	      userProfile = [
	                            Select Name 
	                            From   Profile
	                            Where Id = :UserInfo.getProfileId()
	                            ].Name;
	        if(userProfile.substring(0,6)=='London'||userProfile.substring(0,6)=='System')
	        {
	            isLondon=true;
	        }
	        else
	        {
	            isLondon=false;
	            isnotLondon=true;
	        }
	      
	      transient List<wrapperopenactivity> openActivityWithContactAcc = addContactsAccount(openactivity);
	      //return openactivity;
	      return sortList(openActivityWithContactAcc);
	      //return sortList(openactivity);
	    }
	    catch(Exception ex)
	    {
	      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
	      return null;
	    }
     
     } 
    
    public List<wrapperopenactivity> getactivityhistpagination() 
    {
      try
    {
        userProfile = [
                            Select Name 
                            From   Profile
                            Where Id = :UserInfo.getProfileId()
                            ].Name;
        if(userProfile.substring(0,6)=='London'||userProfile.substring(0,6)=='System')
        {
            isLondon=true;
        }
        else
        {
            isLondon=false;
            isnotLondon=true;
        }
        
        transient List<wrapperopenactivity> histActivityWithContactAcc = addContactsAccount(activityhist);
        return sortList(histActivityWithContactAcc);
        // return sortList(activityhist);
    }
    catch(Exception ex)
    {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      return null;
    }
       
    }    
    
    private List<wrapperopenactivity> sortList(List<wrapperopenactivity> unsortedList)
    {
        
        transient Map<DateTime, List<wrapperopenactivity>> allActivityMap = new Map<DateTime, List<wrapperopenactivity>>();
        for(wrapperopenactivity w: unsortedList)
        {
            if(allActivityMap.containsKey(w.activityDate))
            {
                transient List<wrapperopenactivity> tmpWrapperList = new List<wrapperopenactivity>();
                tmpWrapperList = allActivityMap.get(w.activityDate);
                tmpWrapperList.add(w);
                allActivityMap.put(w.activityDate, tmpWrapperList);
            }
            else
            {
                transient List<wrapperopenactivity> tmpWrapperList = new List<wrapperopenactivity>();
                tmpWrapperList.add(w);
                allActivityMap.put(w.activityDate, tmpWrapperList);
            }
        }
        
        transient Set<DateTime> dateSet = allActivityMap.keySet();
        transient List<DateTime> dateList = new List<DateTime>();
        dateList.addAll(dateSet);
        System.debug('BEFORE dateList:'+dateList);
        dateList.Sort();
        System.debug('AFTER dateList:'+dateList);
        
        transient List<wrapperopenactivity> outSortList = new List<wrapperopenactivity>();
        transient List<wrapperopenactivity> activityNullDateList = new List<wrapperopenactivity>();
        
        for(DateTime d:dateList)
        {
            transient List<wrapperopenactivity> tmpWrapperList = allActivityMap.get(d);
            if(d!=null)
            {
                outSortList.addAll(tmpWrapperList);
            }
            else
            {
                activityNullDateList.addAll(tmpWrapperList);
            }
        }
        
        outSortList.addAll(activityNullDateList);
        System.debug('AFTER allactivityReturn:'+outSortList);

        transient List<wrapperopenactivity> retSortList = new List<wrapperopenactivity>();
        
        Integer limiter=outSortList.Size()-1>400?400:-1;
        
        
        for(integer i=outSortList.Size()-1;i>limiter; i--)
        {
            retSortList.add(outSortList[i]);
        }   
        return retSortList;     
        //return outSortList;

    }
    
    private static String getUserEventDateFormat()
    {
    	try
    	{
    		Map<String, String>  allUsersLocaleMap= new Map<String, String>();
    		allUsersLocaleMap = usersLocaleEventMap();
    		System.debug('currentUserLocale:'+currentUserLocale);
    		System.debug('allUsersLocaleMap.get(currentUserLocale):'+allUsersLocaleMap.get(currentUserLocale));
    		return allUsersLocaleMap.get(currentUserLocale);
    	}
    	catch(exception e)
    	{
    		return null;
    	}
    }

    private static String getUserTaskDateFormat()
    {
    	try
    	{
    		Map<String, String>  allUsersLocaleMap= new Map<String, String>();
    		allUsersLocaleMap = usersLocaleTaskMap();
    		System.debug('currentUserLocale:'+currentUserLocale);
    		System.debug('allUsersLocaleMap.get(currentUserLocale):'+allUsersLocaleMap.get(currentUserLocale));
    		return allUsersLocaleMap.get(currentUserLocale);
    	}
    	catch(exception e)
    	{
    		return null;
    	}
    }
    
	private static Map<String, String> usersLocaleEventMap() 
	{
		Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
		locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
		locale_map.put('bg_BG', 'yyyy-M-d H:mm');
		locale_map.put('ca', 'dd/MM/yyyy HH:mm');
		locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
		locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
		locale_map.put('cs', 'd.M.yyyy H:mm');
		locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
		locale_map.put('da', 'dd-MM-yyyy HH:mm');
		locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
		locale_map.put('de', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
		locale_map.put('el_GR', 'd/M/yyyy h:mm a');
		locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
		locale_map.put('en_B', 'M/d/yyyy h:mm a');
		locale_map.put('en_BM', 'M/d/yyyy h:mm a');
		locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
		locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
		locale_map.put('en_GH', 'M/d/yyyy h:mm a');
		locale_map.put('en_ID', 'M/d/yyyy h:mm a');
		locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
		locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
		locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
		locale_map.put('en_SG', 'M/d/yyyy h:mm a');
		locale_map.put('en_US', 'M/d/yyyy h:mm a');
		locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
		locale_map.put('es', 'd/MM/yyyy H:mm');
		locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
		locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
		locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
		locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
		locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_ES', 'd/MM/yyyy H:mm');
		locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
		locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
		locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
		locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
		locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
		locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
		locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
		locale_map.put('et_EE', 'd.MM.yyyy H:mm');
		locale_map.put('fi', 'd.M.yyyy H:mm');
		locale_map.put('fi_FI', 'd.M.yyyy H:mm');
		locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
		locale_map.put('fr', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
		locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
		locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
		locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
		locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
		locale_map.put('hu', 'yyyy.MM.dd. H:mm');
		locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
		locale_map.put('is_IS', 'd.M.yyyy HH:mm');
		locale_map.put('it', 'dd/MM/yyyy H.mm');
		locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
		locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
		locale_map.put('iw', 'HH:mm dd/MM/yyyy');
		locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
		locale_map.put('ja', 'yyyy/MM/dd H:mm');
		locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
		locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
		locale_map.put('km_KH', 'M/d/yyyy h:mm a');
		locale_map.put('ko', 'yyyy. M. d a h:mm');
		locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
		locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
		locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
		locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
		locale_map.put('nl', 'd-M-yyyy H:mm');
		locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
		locale_map.put('nl_NL', 'd-M-yyyy H:mm');
		locale_map.put('nl_SR', 'd-M-yyyy H:mm');
		locale_map.put('no', 'dd.MM.yyyy HH:mm');
		locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
		locale_map.put('pl', 'yyyy-MM-dd HH:mm');
		locale_map.put('pt', 'dd-MM-yyyy H:mm');
		locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
		locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
		locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
		locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
		locale_map.put('ru', 'dd.MM.yyyy H:mm');
		locale_map.put('sk_SK', 'd.M.yyyy H:mm');
		locale_map.put('sl_SI', 'd.M.y H:mm');
		locale_map.put('sv', 'yyyy-MM-dd HH:mm');
		locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
		locale_map.put('th', 'M/d/yyyy h:mm a');
		locale_map.put('th_TH', 'd/M/yyyy, H:mm ?.');
		locale_map.put('tr', 'dd.MM.yyyy HH:mm');
		locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
		locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
		locale_map.put('zh', 'yyyy-M-d ah:mm');
		locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
		locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
		locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
		return locale_map; //return the map
	}    

	private static Map<String, String> usersLocaleTaskMap() 
	{
		Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
		locale_map.put('ar', 'dd/MM/yyyy');
		locale_map.put('ar_AE', 'dd/MM/yyyy');
		locale_map.put('ar_BH', 'dd/MM/yyyy');
		locale_map.put('ar_JO', 'dd/MM/yyyy');
		locale_map.put('ar_KW', 'dd/MM/yyyy');
		locale_map.put('ar_LB', 'dd/MM/yyyy');
		locale_map.put('ar_SA', 'dd/MM/yyyy');
		locale_map.put('bg_BG', 'yyyy-M-d');
		locale_map.put('ca', 'dd/MM/yyyy');
		locale_map.put('ca_ES', 'dd/MM/yyyy');
		locale_map.put('ca_ES_EURO', 'dd/MM/yyyy');
		locale_map.put('cs', 'd.M.yyyy');
		locale_map.put('cs_CZ', 'd.M.yyyy');
		locale_map.put('da', 'dd-MM-yyyy');
		locale_map.put('da_DK', 'dd-MM-yyyy');
		locale_map.put('de', 'dd.MM.yyyy');
		locale_map.put('de_AT', 'dd.MM.yyyy');
		locale_map.put('de_AT_EURO', 'dd.MM.yyyy');
		locale_map.put('de_CH', 'dd.MM.yyyy');
		locale_map.put('de_DE', 'dd.MM.yyyy');
		locale_map.put('de_DE_EURO', 'dd.MM.yyyy');
		locale_map.put('de_LU', 'dd.MM.yyyy');
		locale_map.put('de_LU_EURO', 'dd.MM.yyyy');
		locale_map.put('el_GR', 'd/M/yyyy');
		locale_map.put('en_AU', 'd/MM/yyyy');
		locale_map.put('en_B', 'M/d/yyyy');
		locale_map.put('en_BM', 'M/d/yyyy');
		locale_map.put('en_CA', 'dd/MM/yyyy');
		locale_map.put('en_GB', 'dd/MM/yyyy');
		locale_map.put('en_GH', 'M/d/yyyy');
		locale_map.put('en_ID', 'M/d/yyyy');
		locale_map.put('en_IE', 'dd/MM/yyyy');
		locale_map.put('en_IE_EURO', 'dd/MM/yyyy');
		locale_map.put('en_NZ', 'd/MM/yyyy');
		locale_map.put('en_SG', 'M/d/yyyy');
		locale_map.put('en_US', 'M/d/yyyy');
		locale_map.put('en_ZA', 'yyyy/MM/dd');
		locale_map.put('es', 'd/MM/yyyy');
		locale_map.put('es_AR', 'dd/MM/yyyy');
		locale_map.put('es_BO', 'dd-MM-yyyy');
		locale_map.put('es_CL', 'dd-MM-yyyy');
		locale_map.put('es_CO', 'd/MM/yyyy');
		locale_map.put('es_CR', 'dd/MM/yyyy');
		locale_map.put('es_EC', 'dd/MM/yyyy');
		locale_map.put('es_ES', 'd/MM/yyyy');
		locale_map.put('es_ES_EURO', 'd/MM/yyyy');
		locale_map.put('es_GT', 'd/MM/yyyy');
		locale_map.put('es_HN', 'MM-dd-yyyy');
		locale_map.put('es_MX', 'd/MM/yyyy');
		locale_map.put('es_PE', 'dd/MM/yyyy');
		locale_map.put('es_PR', 'MM-dd-yyyy');
		locale_map.put('es_PY', 'dd/MM/yyyy');
		locale_map.put('es_SV', 'MM-dd-yyyy');
		locale_map.put('es_UY', 'dd/MM/yyyy');
		locale_map.put('es_VE', 'dd/MM/yyyy');
		locale_map.put('et_EE', 'd.MM.yyyy');
		locale_map.put('fi', 'd.M.yyyy');
		locale_map.put('fi_FI', 'd.M.yyyy');
		locale_map.put('fi_FI_EURO', 'd.M.yyyy');
		locale_map.put('fr', 'dd/MM/yyyy');
		locale_map.put('fr_BE', 'd/MM/yyyy');
		locale_map.put('fr_CA', 'yyyy-MM-dd');
		locale_map.put('fr_CH', 'dd.MM.yyyy');
		locale_map.put('fr_FR', 'dd/MM/yyyy');
		locale_map.put('fr_FR_EURO', 'dd/MM/yyyy');
		locale_map.put('fr_LU', 'dd/MM/yyyy');
		locale_map.put('fr_MC', 'dd/MM/yyyy');
		locale_map.put('hr_HR', 'yyyy.MM.dd');
		locale_map.put('hu', 'yyyy.MM.dd');
		locale_map.put('hy_AM', 'M/d/yyyy');
		locale_map.put('is_IS', 'd.M.yyyy');
		locale_map.put('it', 'dd/MM/yyyy');
		locale_map.put('it_CH', 'dd.MM.yyyy');
		locale_map.put('it_IT', 'dd/MM/yyyy');
		locale_map.put('iw', 'dd/MM/yyyy');
		locale_map.put('iw_IL', 'dd/MM/yyyy');
		locale_map.put('ja', 'yyyy/MM/dd');
		locale_map.put('ja_JP', 'yyyy/MM/dd');
		locale_map.put('kk_KZ', 'M/d/yyyy');
		locale_map.put('km_KH', 'M/d/yyyy');
		locale_map.put('ko', 'yyyy. M. d');
		locale_map.put('ko_KR', 'yyyy. M. d');
		locale_map.put('lt_LT', 'yyyy.M.d');
		locale_map.put('lv_LV', 'yyyy.d.M');
		locale_map.put('ms_MY', 'dd/MM/yyyy');
		locale_map.put('nl', 'd-M-yyyy');
		locale_map.put('nl_BE', 'd/MM/yyyy');
		locale_map.put('nl_NL', 'd-M-yyyy');
		locale_map.put('nl_SR', 'd-M-yyyy');
		locale_map.put('no', 'dd.MM.yyyy');
		locale_map.put('no_NO', 'dd.MM.yyyy');
		locale_map.put('pl', 'yyyy-MM-dd');
		locale_map.put('pt', 'dd-MM-yyyy');
		locale_map.put('pt_AO', 'dd-MM-yyyy');
		locale_map.put('pt_BR', 'dd/MM/yyyy');
		locale_map.put('pt_PT', 'dd-MM-yyyy');
		locale_map.put('ro_RO', 'dd.MM.yyyy');
		locale_map.put('ru', 'dd.MM.yyyy');
		locale_map.put('sk_SK', 'd.M.yyyy');
		locale_map.put('sl_SI', 'd.M.y');
		locale_map.put('sv', 'yyyy-MM-dd');
		locale_map.put('sv_SE', 'yyyy-MM-dd');
		locale_map.put('th', 'M/d/yyyy');
		locale_map.put('th_TH', 'd/M/yyyy');
		locale_map.put('tr', 'dd.MM.yyyy');
		locale_map.put('ur_PK', 'M/d/yyyy');
		locale_map.put('vi_VN', 'dd/MM/yyyy');
		locale_map.put('zh', 'yyyy-M-d');
		locale_map.put('zh_CN', 'yyyy-M-d');
		locale_map.put('zh_HK', 'yyyy-M-d');
		locale_map.put('zh_TW', 'yyyy/M/d');
		return locale_map; //return the map
	} 
    
}