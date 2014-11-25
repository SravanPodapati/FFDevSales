/*******************************************************************************************
********************************************************************************************
****    Pitch hub is used to create a single pitch(Opportunity) with a single pitch     ****
****    product(Opportunity Line Item) but for multiple insertion dates                 ****
****                                                                                    ****
****    If Pricebook doesn't exist, or if it is empty, than an error message is shown.  ****
****                                                                                    ****
****    Also, opportunity's currency will be the same as for selected product.          ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/


public with sharing class PitchHubController
{


    public Account account                      { get; set; }
    public Opportunity opportunity              { get; set; }
    public OpportunityLineItem pitch            { get; set; }
    public ConstantsH__c ch                     { get; set; }
    public Pitch_Hub_Settings__c cPitchHubConstants { get; set; }
    public List<Product2> filteredProducts      { get; set; }
    public String productsSelectList            { get; set; }
    public String stageSelectList               { get; set; }
    public String mediaLeadRecTypeId            { get; set; }
    public Boolean productsExist                { get; set; }
    public OpportunityContactRole contactRole   { get; set; }
    
    public String pricebookId                   { get; set; }    
    public String SelectedInsertionDates        { get; set; }
    
    public String userProfile						{ get; set; }    
    public ID actId;
    public Task tsk;
    public Event evt;
    public ID evtId;
    
    // Contact Roles
    public List<SelectOption> roleOptions
    {
        get
        {
            
            if(roleOptions==null)
            {

                Map<string, schema.sobjectfield> fieldsMap = Schema.SObjectType.OpportunityContactRole.fields.getMap();
                roleOptions = new List<SelectOption>();
                roleOptions.add(new SelectOption('None', '--None--'));
                for (Schema.PicklistEntry p : fieldsMap.get('role').getDescribe().getPicklistValues())
                {
                    roleOptions.add(new SelectOption(p.getValue(), p.getLabel()));
                }  
                /*
                roleOptions = new List<SelectOption>();
                roleOptions.add(new SelectOption('None', '--None--'));
                roleOptions.add(new SelectOption('Agency decision maker', 'Agency decision maker'));
                roleOptions.add(new SelectOption('Agency planning', 'Agency planning'));
                roleOptions.add(new SelectOption('Agency press', 'Agency press'));
                roleOptions.add(new SelectOption('Client decision maker', 'Client decision maker'));
                roleOptions.add(new SelectOption('Collaborator', 'Collaborator'));
                roleOptions.add(new SelectOption('Creative', 'Creative'));
                roleOptions.add(new SelectOption('Digital', 'Digital'));
                roleOptions.add(new SelectOption('Partner', 'Partner'));
                roleOptions.add(new SelectOption('PR', 'PR'));
                roleOptions.add(new SelectOption('Project Manager', 'Project Manager'));
                roleOptions.add(new SelectOption('Proprietor', 'Proprietor'));
                roleOptions.add(new SelectOption('Supplier', 'Supplier'));
                */
            }
            return roleOptions;
        }
        set;
    }  
    public String roleSelectList                { get; set; }    
    
    

    public PitchHubController()
    {
        
        List<String> filtProductIds     = new List<String>();        
        opportunity                     = new Opportunity();
        pitch                           = new OpportunityLineItem();
        ch                              = ConstantsH__c.getInstance(UserInfo.getProfileId());
        contactRole                     = new OpportunityContactRole();
        productsExist                   = true;
        cPitchHubConstants              = Pitch_Hub_Settings__c.getInstance(UserInfo.getProfileId());
        ID accountId                    = ApexPages.currentPage().getParameters().get('Accountid');
        opportunity.accountId           = accountId;
        String type                     = ApexPages.currentPage().getParameters().get('type');
        opportunity.Type                = type;
        ID conId                        = ApexPages.currentPage().getParameters().get('Contactid');
        ID agencyId                     = ApexPages.currentPage().getParameters().get('Agencyid');
        opportunity.Agency__c           = agencyId;
        opportunity.ownerId             = UserInfo.getUserId();
        actId                           = ApexPages.currentPage().getParameters().get('Activityid');
        evtId                           = ApexPages.currentPage().getParameters().get('Eventid');
        String NewBus                   = ApexPages.currentPage().getParameters().get('NewBus');
        String pitchSource              = ApexPages.currentPage().getParameters().get('PitchSource');
        System.debug('pitchSource:'+pitchSource);
        
        userProfile		= [
        					Select Name 
        					From   Profile
        					Where Id = :UserInfo.getProfileId()
        					].Name;
        
        if (NewBus=='1'){
            opportunity.IsNew__c=True;
        }
        
        ID activityId;
        String activityParent;
         
        try
        {
            pricebookId = [select id from Pricebook2 where name =: ch.Price_Book__c].id;
        }
        catch (Exception e)
        {
            system.debug('Exception >>>>>>>> ' + e);
            productsExist = false;
        }   
        
        if (conId != null)
        {          
            // Populate the Contact in the Pitch Hub
            try{
                contactRole.ContactId = conId;
                }
            catch (Exception e)
            {
               system.debug('Exception >>>>>>>> ' + e); 
            }
            

            Contact con = [select id, accountid from Contact where id = :conId limit 1];            
            Account acct = [select Record_Type__c, Type from Account where id = :con.accountid limit 1];

            // Populate the Account or Agency in the Pitch Hub            
            if (acct.Record_Type__c == 'Agency')
            {
                opportunity.Agency__c = con.accountid;  
            }
            else
            {
                //opportunity.accountid = con.accountid;
            }                            
        }                               

        // User has clicked 'Convert to Pitch' from an Event 
        if (evtId != null)
        {
            evt = [select Id, WhatId, What.Type from Event where id = :evtId limit 1];          
            activityId = evt.WhatId;
            activityParent = evt.What.Type;         
        }
        // User has clicked 'Convert to Pitch' from a Task
        if (actId != null)
        {
            tsk = [select Id, WhatId, What.Type from Task where id = :actId limit 1];
            activityId = tsk.WhatId;
            activityParent = tsk.What.Type;
        }
                
        if (activityId != null && activityParent != null && activityParent != '')
        {           
            // If Event or Task is associated with a Business Team Activity         
            if (activityParent == 'Business_Team_Activity__c')
            {
                Business_Team_Activity__c bta = [select id, Account__c from Business_Team_Activity__c where id = :activityId limit 1];
                Account btaAcct = [select Record_Type__c, Type from Account where id = :bta.Account__c limit 1];                
                
                if (btaAcct.Record_Type__c == 'Agency')
                {
                    opportunity.Agency__c = bta.Account__c;                 
                }
                else
                {
                    opportunity.accountid = bta.Account__c;
                }                               
            }
            
            // If Event or Task is associated to the Account
            
            if (activityParent == 'Account')
            {
                Account actAcct = [select Record_Type__c, Type from Account where id = :activityId limit 1];
                
                if (actAcct.Record_Type__c == 'Agency')
                {
                    opportunity.Agency__c = activityId;
                    
                }
                else
                {
                    opportunity.accountid = activityId;
                }
            }           
        }
        
        if(pitchSource!=null)
        {
            opportunity.Source_Of_Pitch__c = pitchSource;
        }
                
        List<PricebookEntry> pricebookEntries = 
                [
                select id, Name, Product2Id, isActive
                from PricebookEntry 
                where Pricebook2Id =: pricebookId and isActive = true
                ];
        
        for (PricebookEntry pbe : pricebookEntries) filtProductIds.add(pbe.Product2Id);
        
        filteredProducts = 
                [
                select id, Name, Family 
                from Product2 
                where id in :filtProductIds 
                order by Name
                ];
        
        if (filteredProducts.isEmpty()) productsExist = false;
      
        String profileName = [Select Name From Profile Where Id = :UserInfo.getProfileId()].Name;
        
        /*if(profileName.contains('London')){
           mediaLeadRecTypeId = 
                   [
                   select id 
                   from RecordType 
                   where DeveloperName = 'PopMac' 
                   limit 1
                   ].id;        
         }
         else{*/
           mediaLeadRecTypeId = 
                   [
                   select id 
                   from RecordType 
                   where DeveloperName = :Constants__c.getInstance('All').Regular_Opp_Record_Type__c 
                   limit 1
                   ].id; 
          //}
    }
    
    
    
    //#
    //# Get all filtered product options
    //#
    
    public List<SelectOption> getProductOptions() 
    {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','-- Select a product --'));
        
        for(Product2 p : filteredProducts){
            //if(p.Family != null && p.Name.contains('Metro Provisional Product')) 
                options.add(new SelectOption(p.Id, p.Name));
        }
        
        System.debug('>>>>>>>>> Get a list of all products ' + options);
        
        return options;
        
    }
    
    
    
    //#
    //# Create custom Stage options
    //#
    
    public List<SelectOption> getStageOptions() 
    {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Preparation',         'Preparation'));
        options.add(new SelectOption('Brief',               'Brief'));
        options.add(new SelectOption('Discussion',          'Discussion'));
        options.add(new SelectOption('Final Negotiations',  'Final Negotiations'));
        options.add(new SelectOption('Closed Won',          'Closed Won'));
          
        return options;
        
    }
    
    
    
    //#
    //# Save Opportunity and Pitch Idea created against that Opportunity
    //#
    
    public PageReference save() 
    {
        
        //Savepoint savepoint = null;
        String sOpportunityOwner    =   opportunity.OwnerId;
        System.debug('Selected Dates in string format:'+SelectedInsertionDates);
        
        List<String> lSelectedDates =   SelectedInsertionDates.split(',');
        
        List<Date> lDates           =   new List<Date>();
        Date dDate                  =   null;
        
        Date dOppCloseDate          =   opportunity.CloseDate;
        
        Date dLIDate                =   pitch.Last_Insertion_Date__c;

        // Check to ensure that the dates selected (i.e. first insertion dates) are less than opportunity close date
        
        for(String sDate    :   lSelectedDates){
            //System.debug('Opportunity Close Date:'+dOppCloseDate);
            //System.debug('First Insertion Date:'+date.parse(sDate));
            if(dOppCloseDate > date.parse(sDate)){
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The First Insertion Date must be greater than or equal to the Pitch Close Date.');
                ApexPages.addMessage(message);  
                return null;                
            }
            else
                lDates.add(date.parse(sDate));          
            
        }
        
        List<Id> product2Ids = new List<Id>();
        
        /*
        Pricebook2 priceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = :ch.Price_Book__c limit 1];
        */
        
        product2Ids.add(productsSelectList);
        
        
        Map<Id, Product2> products = new Map<Id, Product2>
                ([
                select id, Name, CurrencyIsoCode, Schedule_Revenue__c, (select id, Name from PricebookEntries where Pricebook2Id =: pricebookId limit 1) 
                from Product2 
                where id 
                IN :product2Ids
                ]);
                
        
        opportunity.StageName           = stageSelectList;
        opportunity.RecordTypeId        = mediaLeadRecTypeId;
        opportunity.CurrencyIsoCode     = products.get(productsSelectList).CurrencyIsoCode;
        opportunity.CreationMethod__c   = 'Pitch Hub';
        opportunity.OwnerId             = UserInfo.getUserId();
        
        // Check that the contact selected by the user is active and either an agency contact or an advertiser contact
        
        if(contactRole.ContactId!=null){

            List<Contact> contactList = [Select Active__c
                                        From Contact 
                                        Where  Id = :contactRole.ContactId];
                                        // Commented out the feature which ensures that the contact belongs to either Advertiser or Agency
                                        /*
                                        And    ( AccountId = :opportunity.AccountId Or AccountId = :opportunity.Agency__c)
                                        ];
                                        */
            
            if(contactList.size()==0)
            {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The External Contact chosen is not the advertiser\'s contact');
                ApexPages.addMessage(message);  
                return null;                
            }
            else
            {
                // Check that the contact is Active. In addition there is only really one, so no need to bulkify
                if(!contactList[0].Active__c)
                {
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The contact specified is Inactive. Cannot Save Record.');
                    ApexPages.addMessage(message);  
                    return null;                                        
                }
            }
            
            // Check if the product is custom schedule - if it is make sure Last Insertion Date is entered
            if(products.get(productsSelectList).Schedule_Revenue__c == 'Monthly' && dLIDate == null)
            {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Last Insertion Date must be set. Cannot Save Record.');
                ApexPages.addMessage(message);  
                return null;                
            }
            
        }
        
        if(roleSelectList=='None'){
            
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.fatal,'Contact Role: You must enter a value.');
                ApexPages.addMessage(message); 
                //Database.rollback(savepoint);
                system.debug('roleSelectList:'+roleSelectList); 
                return null; 
          }
        
        
        boolean IsOpportunityClosedWon = false;
        Savepoint savepoint = null;
        savepoint = Database.setSavePoint();
        
        if (opportunity.StageName == 'Closed Won') 
        {
            isOpportunityClosedWon = true;
            opportunity.StageName = 'Preparation';
        }
        
        try 
        {
            if(opportunity.Id != null)
            { 
                opportunity = opportunity.clone();
            }
            insert opportunity;
        }
        catch(Exception e) 
        {
            System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            ApexPages.addMessage(message);  
            Database.rollback(savepoint);
            return null; 
        }
        
        if(products.containsKey(productsSelectList) && !products.get(productsSelectList).PricebookEntries.isEmpty()) 
                    pitch.PricebookEntryId = products.get(productsSelectList).PricebookEntries.get(0).Id;
        
        // If Pitch was created from a Task, assign the activity to the Pitch       
        if (actId != null)
        {           
            tsk = [select Id, WhatId, WhoId, OwnerId, Status, Priority, Subject from Task where Id = :actId limit 1];                                               
            tsk.whatId = opportunity.id;
            try
            {
                update tsk;
            }
            catch (Exception e)
            {
                System.Debug('>>>>>>>>>>>>>> EXCEPTION: '+e);
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
                ApexPages.addMessage(message);  
                return null; 
            }
            finally
            {
                tsk = null;
            }                   
        }
        
        // If Pitch was created from an Event, assigne the event to the Pitch    
        if (evtId != null)
        {           
            evt = [select Id, WhatId from Event where Id = :evtId limit 1];                                             
            evt.whatId = opportunity.id;
            try
            {
                update evt;
            }
            catch (Exception e)
            {
                System.Debug('>>>>>>>>>>>>>> EXCEPTION: '+e);
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
                ApexPages.addMessage(message);  
                return null; 
            }
            finally
            {
                evt = null;
            }                   
        }
        
        List<OpportunityLineItem> lOppLineItems =   new List<OpportunityLineItem>();
        
        if(lDates.size() > 0){
            
            for(Date dInsertionDate : lDates){
            
            OpportunityLineItem pitchProducts       = new OpportunityLineItem();
    
            pitchProducts.opportunityId             = opportunity.id;
            pitchProducts.PricebookEntryId          = pitch.PricebookEntryId;
            pitchProducts.Brand__c                  = pitch.Brand__c;
            pitchProducts.Color_Specification__c    = pitch.Color_Specification__c;
            pitchProducts.UnitPrice                 = pitch.UnitPrice;
            pitchProducts.Region__c                 = pitch.Region__c;
            pitchProducts.Description               = pitch.Description;
            pitchProducts.Size__c                   = pitch.Size__c;
            pitchProducts.Position__c               = pitch.Position__c;        
            pitchProducts.Quantity                  = 1;
            pitchProducts.ServiceDate               = dInsertionDate;
            pitchProducts.URN__c                    = pitch.URN__c;
            pitchProducts.Last_Insertion_Date__c    = pitch.Last_Insertion_Date__c;
            
            lOppLineItems.add(pitchProducts);           
               
            }                       
            
            try 
            {
                insert lOppLineItems;
            }
            catch(Exception e) 
            {
                System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
                ApexPages.addMessages(e);
                return null;
            }
        }
        
        
        
        if (isOpportunityClosedWon) 
        {
            // Update status in order to fire validation rule that depends on line items
            opportunity.StageName = 'Closed Won';
            try 
            {
                update opportunity;
                // Database.Saveresult sr = Database.update(opportunity);
            }
            catch(Exception e) 
            {
                System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
                ApexPages.addMessages(e);
                Database.rollback(savepoint);
                return null;
            }
            
        }
        ////////////////////////////////////////////////
        
        /* if(roleSelectList=='None')
        {
           ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Contact Role: You must enter a value.');
            ApexPages.addMessage(message);  
                Database.rollback(savepoint);
                return null; 
            
        }*/
       
        
        ///////////////////////////////////////////////
        if(contactRole.ContactId!=null)
        {
            try{
            	if(roleSelectList!='None'){
            
                	ContactRole =   new OpportunityContactRole(
                                             OpportunityId=opportunity.Id,
                                             IsPrimary=true,
                                             ContactId=contactrole.contactid,
                                             Role=roleSelectList
                                             );            
        
                      
                    insert ContactRole;
                    system.debug('ContactRole:'+ContactRole);
                    //////////////////////////////////////////////////////////////////
		              //Auto-Task on Opportunity
					if(userProfile.contains('Mail Classified')||userProfile.contains('Mail Display')||userProfile.contains('MailOnline')||userProfile.contains('System Administrator')){
						List<Opportunity> newopps=new List<Opportunity>();
		               List<OpportunityContactRole> newocrs=new List<OpportunityContactRole>();
		               newopps.add(opportunity);
		               newocrs.add(ContactRole);
		               map<Id, List<OpportunityContactRole>> newocrsmap=new map<Id, List<OpportunityContactRole>>();
		               map<Id, List<OpportunityLineItem>> newopplinesmap=new map<Id, List<OpportunityLineItem>>();
		               
		               newocrsmap.put(opportunity.id,newocrs);
		               newopplinesmap.put(opportunity.id, lOppLineItems);
		               
		               AutoCreateTaskOnOpportunity.createTasks(newopps, newopplinesmap, newocrsmap);   
            			}
            	}
            }		
           catch(Exception e) 
            {       ApexPages.addMessages(e);
                    //Database.rollback(savepoint);
                    return null;
                }
            }      
                    
           system.debug('status:after contactrol');         
            
        
        
        // If Opportunity owner should be different from the person creating the opportunity, opportunity & its related objects are 
        // initially created (with logged-in user as opp owner) and then updated to ensure the right person is set as opp owner.  
        if(sOpportunityOwner <> UserInfo.getUserId()){
            
            //System.debug('********Opportunity Owner is different from logged in person...hence the update*******');
            opportunity.OwnerId = sOpportunityOwner;
            
            try
            {
                update opportunity;
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e);
                return null;
            }
            
        }
                                
 
        PageReference opptyPage = new PageReference('/apex/PitchHub');
        //PageReference opptyPage = new PageReference('/apex/PitchHub?sfdc.tabName='+cPitchHubConstants.Custom_Tab_ID__c);        
        opptyPage.setRedirect(true);
     
        return opptyPage;
        
    }

    //#
    //# Cancel and return to the Home page
    //#
  
    public PageReference cancel()
    {
        
        PageReference opptyPage = new PageReference('/home/home.jsp');
        opptyPage.setRedirect(true);

        return opptyPage;
        
    }
    
}