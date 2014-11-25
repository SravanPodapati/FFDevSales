public with sharing class AccountDeactivateController {
private ApexPages.StandardController controller;
    public Account acc;
    List<Contact> UpdatedContacts=new List<Contact>();
    List<Relationship__c> UpdatedRelations=new List<Relationship__c>();
    List<Relationship_Contact__c> UpdatedRelationshipContacts=new List<Relationship_Contact__c>();
    Public Boolean accountstatus;
    public AccountDeactivateController(ApexPages.StandardController stdcontroller) {
    //controller = stdController;
        this.acc= (Account)stdController.getRecord();
         System.debug('*******Account:'+acc);
        
        acc=[Select IsActive__c from Account Where id= :acc.id ];
        accountstatus=acc.IsActive__c;
        
        if(acc.IsActive__c=true)
        {
            acc.IsActive__c=false;
        }
        //else
        //{
        	//acc.IsActive__c=True;
        	//update acc;
        	//acc.IsActive__c=False;
        //}           
                    
    }

    
public List<Contact> AllContacts 
{
        get
        {
            if(AllContacts == null) 
            {
                
                AllContacts = [select id, Active__c, Reason_for_inactive__c from Contact c where c.AccountId = :acc.id And c.Active__c=True];
            }
            return AllContacts;
        }
        set;    
    }
    
public List<Relationship__c> AllRelations 
{
        get
        {
            if(AllRelations == null) 
            {
                
                AllRelations = [select Active__c from Relationship__c r where (r.Account_A__c= :acc.id OR r.Account_B__c = :acc.id) And r.Active__c=True];
            }
            return AllRelations;
        }
        set;    
    }    

public List<Relationship_Contact__c> AllRelationshipContacts 
{
        get
        {
            if(AllRelationshipContacts == null) 
            {
                
                AllRelationshipContacts = [select Active__c from Relationship_Contact__c d where (d.Relationship__r.Account_A__c= :acc.id OR d.Relationship__r.Account_B__c = :acc.id) And d.Active__c=True];
            }
            return AllRelationshipContacts;
        }
        set;    
    }

  public PageReference mydeactivate(){
                 
              for (Contact con : AllContacts)
              {               
                 if(AllContacts != null) 
                 {
                        con.Active__c=False;
                        con.Reason_for_inactive__c='Account was made Inactive';
                        UpdatedContacts.add(con);
                 }	
              } 
             for (Relationship_Contact__c rc : AllRelationshipContacts)
             {               
             	rc.Active__c=False;
                UpdatedRelationshipContacts.add(rc);
             }  
                                                 
             for (Relationship__c rel : AllRelations)
             {               
                 if(AllRelations != null) 
                 {
                        rel.Active__c=False;
                        UpdatedRelations.add(rel);
                 }    
             }              
            
			
            
             if(UpdatedRelationshipContacts.size() > 0)
             {
             	System.debug('*******UpdatedRelationshipContacts:'+UpdatedRelationshipContacts);
                update UpdatedRelationshipContacts;
             }                 
            
             if(UpdatedRelations.size() > 0)
             {
                update UpdatedRelations;
             }
              
              if(UpdatedContacts.size() > 0)
             {
             System.debug('*******UpdatedContacts:'+UpdatedContacts);
                update UpdatedContacts;
             }   
             if (acc != Null || accountstatus)
             {
             	update acc;
             }
             controller = new ApexPages.standardController(acc);
             return controller.view();
  }           
   
}