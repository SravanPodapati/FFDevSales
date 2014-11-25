/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    Using a single page, users are able to create a quick opportunity               ****
****    with one Pitch Idea.                                                            ****
****                                                                                    ****
****    If Pricebook doesn't exist, or if it is empty, than an error message is shown.  ****
****                                                                                    ****
****    Also, opportunity's currency will be the same as for selected product.          ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/

 

public with sharing class QuickOppController 
{


    public Account account                      { get; set; }
    public Opportunity opportunity              { get; set; }
    public OpportunityLineItem pitch            { get; set; }
    public OpportunityContactRole contactRole	{ get; set; }
    public String pricebookId 					{ get; set; }
    
    private Id loggedInUser
    {
       	get
       	{
   			if(loggedInUser==null)
   			{
       			return UserInfo.getUserId();
       		}
       		else
       		{
       			return loggedInUser;
       		}
       	}
       	set;
     }   
      
    public List<SelectOption> roleOptions
    {
    	get
    	{
    		
    		if(roleOptions==null)
    		{
    			
   				Map<string, schema.sobjectfield> fieldsMap = Schema.SObjectType.OpportunityContactRole.fields.getMap();
      			List<SelectOption> options = new List<SelectOption>();
                roleOptions = new List<SelectOption>();
                roleOptions.add(new SelectOption('None', '--None--'));
  				for (Schema.PicklistEntry p : fieldsMap.get('role').getDescribe().getPicklistValues())
  				{
    				roleOptions.add(new SelectOption(p.getValue(), p.getLabel()));
  				}   			
    			/*roleOptions = new List<SelectOption>();
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
    			roleOptions.add(new SelectOption('Supplier', 'Supplier'));*/
    		}
    		return roleOptions;
    	}
    	set;
    }

    public Integer UnitPrice                    { get; set; }
    public Integer TotalPrice                   { get; set; }
    public OpportunityContactRole  oppcontrole  { get; set; }
    public ConstantsH__c ch                     { get; set; }
    public List<Product2> filteredProducts      { get; set; }
    public String productsSelectList            { get; set; }
    public String roleSelectList            	{ get; set; }    
    public String stageSelectList               { get; set; }
    public Integer NoOfProductsSelectList       { get; set; }
    public String DateIncProductsList        	{ get; set; }
    public String mediaLeadRecTypeId            { get; set; }
    public Boolean productsExist                { get; set; }
    public List<OpportunityLineItem> opportunityLineView	
    {
    	get
    	{
    		if(opportunityLineView==null)
    		{
    			opportunityLineView = new List<OpportunityLineItem>();
    		}
    		return opportunityLineView;
    	}
    	set;
    }
    

   public QuickOppController()
   {
        
        List<String> filtProductIds     = new List<String>();
        //String pricebookId;
        
        opportunity     = new Opportunity();
        pitch           = new OpportunityLineItem();
        contactRole		= new OpportunityContactRole();
     
        
        ch              = ConstantsH__c.getInstance(UserInfo.getProfileId());
        productsExist   = true;
        
        opportunity.ownerId = loggedInUser;
        
        try
        {
            pricebookId = [select id 
            				from Pricebook2
            				where name =: ch.Price_Book__c].id;
        }
        catch (Exception e)
        {
            system.debug('Exception >>>>>>>> ' + e);
            productsExist = false;
        }   
        

        List<PricebookEntry> pricebookEntries = 
                [
                select Name, Product2Id, isActive
                from PricebookEntry 
                where Pricebook2Id =: pricebookId
                and isActive = true
                ];
        
        for (PricebookEntry pbe : pricebookEntries)
        {
        	filtProductIds.add(pbe.Product2Id);
        }
        
        filteredProducts = 
                [
                select Name, Family 
                from Product2 
                where id in :filtProductIds 
                order by Name
                ];
        
        if (filteredProducts.isEmpty())
        {
        	productsExist = false;
        }

        mediaLeadRecTypeId = 
                [
                select id 
                from RecordType 
                where DeveloperName = :Constants__c.getInstance('All').Regular_Opp_Record_Type__c 
                limit 1
                ].id; 
        
    }
    
    
    
    //#
    //# Get all filtered product options
    //#
    
    public List<SelectOption> getProductOptions() 
    {
        
        List<SelectOption> options = new List<SelectOption>();
        

        //#
        //# Set Display ROP as a default product (if it exists) 
        //#
        
        for(Product2 p : filteredProducts)
            if(p.Family != null && p.Name.contains('Display ROP'))
            {
            	options.add(new SelectOption(p.Id, p.Name));
            }
        
        if(options.isEmpty())
        {
            for(Product2 p : filteredProducts)
                if(p.Family != null)
                {
                	options.add(new SelectOption(p.Id, p.Name));
                }
        }
        else
        {
            for(Product2 p : filteredProducts)
                if(p.Family != null && !p.Name.contains('Display ROP'))
                {
                	options.add(new SelectOption(p.Id, p.Name));
                }
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
     
     
        return options;
        
    }
   
    //# Create no of products option
    public List<SelectOption> getNoOfProducts() 
    {
        
        List<SelectOption> prodoptions = new List<SelectOption>();
        
        /*prodoptions.add(new SelectOption('1','1'));
        prodoptions.add(new SelectOption('2','2'));
        prodoptions.add(new SelectOption('3','3'));
        prodoptions.add(new SelectOption('4','4'));*/
        
        for(integer i=0;i<13;i++)
        {
        	prodoptions.add(new SelectOption(String.Valueof(i),String.ValueOf(i)));
        }
     
     
        return prodoptions;
        
    }
    
    public List<SelectOption> getDateIncProducts() 
    {
        
        List<SelectOption> DateIncoptions = new List<SelectOption>();
        
        DateIncoptions.add(new SelectOption('Daily','Daily'));
        DateIncoptions.add(new SelectOption('Weekly','Weekly'));
        DateIncoptions.add(new SelectOption('Monthly','Monthly'));  
     
        return DateIncoptions;
        
    }
    
    public PageReference addNewLine()
    {
    	PageReference save = save();
    	if (!ApexPages.hasMessages(ApexPages.Severity.ERROR))
    	{
    		// save.setRedirect(false);
    		pitch = new OpportunityLineItem();
    	}
    	return null;
    	
    }
    
    //#
    //# Save Opportunity and Pitch Idea created against that Opportunity
    //#
    
    public PageReference save() 
    {

        PageReference opptyPage;
       	Id newOpportunityOwnerId = opportunity.OwnerId;
        
        // Validation to check that the First Insertion Date is greater than the Opportunity Close Date        
        if(pitch.ServiceDate<opportunity.closeDate)
        {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The First Insertion Date must be greater than the Opportunity Close Date.');
            ApexPages.addMessage(message);    
            //return ApexPages.currentPage();   
            return null; 	
        }
        else if(NoOfProductsSelectList==0)
        {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please ensure that the Number Of Products are greater than 0.');
            ApexPages.addMessage(message);
            //return ApexPages.currentPage();    
			return null;   	        	
        }       
        else
        {
        	// First Insertion Date is valid
	        List<Id> product2Ids = new List<Id>();
	        
	        //Pricebook2 priceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = :ch.Price_Book__c limit 1];
	        //product2Ids.add(productsSelectList);
	        
	        
	        /*Map<Id, Product2> products = new Map<Id, Product2>
	                ([
	                select id, Name, CurrencyIsoCode, (select id, Name from PricebookEntries where Pricebook2Id =: priceBook.id limit 1) 
	                from Product2 
	                where id 
	                IN :product2Ids
	                ]);*/

            Map<Id, Product2> products = new Map<Id, Product2>
                    ([
                    select
                    	Name, 
                    	CurrencyIsoCode, 
                    	(select 
                    		Name
                    	from PricebookEntries
                    	where pricebook2id = :pricebookId) 
                    from Product2
                    where id = :productsSelectList
                    ]);	
                                    
	        if(opportunity.Id==Null)
	        {      
		        opportunity.StageName       = stageSelectList;
		        opportunity.CreationMethod__c='One Opportunity Multiple Products';
		        opportunity.RecordTypeId    = mediaLeadRecTypeId;
		        opportunity.CurrencyIsoCode = products.get(productsSelectList).CurrencyIsoCode;
	        
		        System.debug('contactRole.ContactId:'+contactRole.ContactId);
		        System.debug('opportunity.AccountId:'+opportunity.AccountId);
		        if (contactRole.ContactId!=null)
		        {
		        	List<Contact> contactList = [
                                                Select Active__c
                                                From Contact
                                                Where  Id = :contactRole.ContactId
                                                /*And    ( AccountId = :opportunity.AccountId
                                                Or AccountId = :opportunity.Agency__c)*/
                                            ];
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
	      		  			ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The advertiser\'s contact is Inactive. Cannot Save Record.');
	        				ApexPages.addMessage(message);	
	        				return null;					        			
		        		}
					} 
		        }
				System.debug('************Opportunity:'+opportunity);

		        try 
		        {
		        	//Opportunity updateOpp;
		        	if(opportunity.OwnerId!=loggedInUser)
		        	{
		        		opportunity.OwnerId = loggedInUser;
		        	}
		        	insert opportunity;
		        	/*if(newOpportunityOwnerId!=opportunity.OwnerId)
		        	{
		        		updateOpp = new Opportunity(Id=opportunity.Id, OwnerId=newOpportunityOwnerId);
		        		// opportunity.OwnerId = newOpportunityOwnerId;
		        	}
		        	if(updateOpp!=null)
		        	{
		        		update updateOpp;
		        	}*/
		        	// update opportunity;
		        }
		        catch(Exception e) 
		        {
		        	System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
		        	ApexPages.addMessages(e);
		        	return null;
		        } 					
                System.debug('Opportunity Insert Complete!!');
                if(contactRole.ContactId!=null)
                {
                	/*
                	if(roleSelectList=='None')
        			{
		        		ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Contact Role: You must enter a value.');
		                ApexPages.addMessage(message);  
		                return null;	
		        	}
		        	else
		        	{
		        	*/
		                contactRole.OpportunityId=opportunity.Id;
		                contactRole.IsPrimary=true;
		                contactRole.Role=roleSelectList;
		                try
		                {
		                    insert contactRole;
		                }
		                catch(Exception e)
		                {
		                    ApexPages.addMessages(e);
		                }
		        	}
                //}

	        }
	        	        
	        System.debug('***********************opportunity:'+opportunity);
	        System.debug('***********************products:'+products);
	        
	        System.debug('************************productsSelectList:'+productsSelectList);
	        
	        if(products.containsKey(productsSelectList) && !products.get(productsSelectList).PricebookEntries.isEmpty()) 
	                    pitch.PricebookEntryId = products.get(productsSelectList).PricebookEntries.get(0).Id;
	        
	       //pitch.addError('no of products: '+noOfProductsSelectList);    
	       //Integer totalprice=0;
	       
	       
	       // opportunitylineitem[] opplist=new opportunitylineitem[i];
	       
	       List<OpportunityLineItem> newOppList = new List<OpportunityLineItem>();
	       Date firstInsertionDate = pitch.ServiceDate;
	       for (Integer j = 0; j < NoOfProductsSelectList; j++) 
	       {
	           OpportunityLineItem opplist = new OpportunityLineItem();        	
		       // opplist[j] = new opportunitylineitem();
		       opplist.opportunityId = opportunity.id;
		       opplist.quantity = 1;
		       opplist.PricebookEntryId = pitch.PricebookEntryId;  

		       if (DateIncProductsList=='Daily')
		       {
					opplist.ServiceDate =firstInsertionDate.addDays(j);
		       }
		       else if (DateIncProductsList=='Weekly')
		       {
		       		opplist.ServiceDate =firstInsertionDate;
		        	firstInsertionDate=firstInsertionDate.addDays(7); 
		       }
		       else if (DateIncProductsList=='Monthly')
		       {
			       		opplist.ServiceDate =firstInsertionDate.addMonths(j);
		       }
		       opplist.Description = pitch.Description;
		       opplist.UnitPrice = pitch.UnitPrice;
		       // opplist.TotalPrice = 100;
		       //opplist[j].TotalPrice = UnitPrice;
		       opplist.PricebookEntryId = products.get(productsSelectList).PricebookEntries.get(0).Id;
	           newOppList.add(oppList);
	           // opportunityLineView.add(oppList);
	           // System.debug('opportunityLineView:'+opportunityLineView);
	        }
	        
	        if(newOppList.size()>0)
	        {
	        	try
	        	{
	        		insert newOpplist;
	        		/*Set<Id> newOppSet = new Set<Id>();
	        		for(OpportunityLineItem opl:newOppList)
	        		{
	        			newOppSet.add(opl.id);
	        		}*/
		            
	        		opportunityLineView = [
	        								Select
	        									PricebookEntry.Name,
	        									Quantity,
	        									UnitPrice,
	        									ServiceDate,
	        									Description
	        								From OpportunityLineItem
	        								Where OpportunityId = :opportunity.Id
	        								];
	        		/*for(OpportunityLineItem op:newOppList)
	        		{
	        			opportunityLineView.add(op);
	        		}*/
	        	}
    	        catch(Exception e)
    	        {
 	        		ApexPages.addMessages(e);
	        		return null;   	        	
    	        }
	        }
	        Opportunity updateOpp;
        	if(newOpportunityOwnerId!=opportunity.OwnerId)
        	{
        		updateOpp = new Opportunity(Id=opportunity.Id, OwnerId=newOpportunityOwnerId);
        		// opportunity.OwnerId = newOpportunityOwnerId;
        	}
        	if(updateOpp!=null)
        	{
        		update updateOpp;
        	}	        
	        
	       // for (Integer i=0; i<noOfProductsSelectList; i++){
	        	//pitch.opportunityId         = opportunity.id;
	            //pitch.Quantity              = 1;
	        
	        
	        //try {insert pitchi;}
	        //catch(Exception e) 
	        //{
	        //    System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
	        //    return null;
	        //}
	        //}
            
         opptyPage = new PageReference('/' + opportunity.id);
         opptyPage.setRedirect(true);

        }       
        
 
 
     
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