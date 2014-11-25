public with sharing class AccountReactivateController {

private ApexPages.StandardController controller;
    public Account reacc;
    List<Contact> UpdatedContacts=new List<Contact>();
    List<Relationship__c> UpdatedRelations=new List<Relationship__c>();
    List<Relationship_Contact__c> UpdatedRelationshipContacts=new List<Relationship_Contact__c>();
    Public Boolean accountstatus;
    public AccountReactivateController(ApexPages.StandardController stdcontroller) {
    //controller = stdController;
        this.reacc= (Account)stdController.getRecord();
         System.debug('*******Account:'+reacc);
        
        reacc=[Select IsActive__c from Account Where id= :reacc.id ];
        accountstatus=reacc.IsActive__c;
        System.debug('*******IsActive__c:'+accountstatus);
        //if(reacc.IsActive__c=false)
        if(!accountstatus)
        {
            reacc.IsActive__c=true;
        }          
    }

  public PageReference myreactivate(){
                 
             if (reacc != Null && !accountstatus )
             {
                update reacc;
             }
             controller = new ApexPages.standardController(reacc);
             return controller.view();
  }           
}