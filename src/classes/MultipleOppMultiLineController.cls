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

 

public with sharing class MultipleOppMultiLineController
{
	
	public ID actId;
    public Task tsk;
    public Event evt;
    public ID evtId;
    public Integer int1 {get; set;}
    map<Id, List<OpportunityContactRole>> newocrsmap=new map<Id, List<OpportunityContactRole>>();
	map<Id, List<OpportunityLineItem>> newopplinesmap=new map<Id, List<OpportunityLineItem>>();

    public class OppLine 
    {
        public String product { get; set; }
        public String SelectedInsertionDates { get; set; }
        /*{ 
        	get
        	{
        		return SelectedInsertionDates==null?'':SelectedInsertionDates;
        	} 
        	set; 
        }*/
        public Boolean deleteline 
        { 
            get
            {
                    if(deleteline==null)
                    {
                            return false;
                    }
                    else
                    {
                            return deleteline;
                    }       
            }
            set; 
          }
                
        public OpportunityLineItem opline { get; set; }
        
        public OppLine(SelectOption product, OpportunityLineItem opline )
        {
                this.opline = opline;
        }
        
        public OppLine()
        {
                this.product = null;
                this.opline = new OpportunityLineItem();
                this.SelectedInsertionDates = '';
        }
        
    }
    
    private String returnURL						{ get; set; }

    public Account account                          { get; set; }
    public Opportunity opportunity                  { get; set; }

    public integer num                              { get; set; }

    public OpportunityContactRole contactRoleList   { get; set; }
    public String pricebookId                       { get; set; }
    
    
    public List<OppLine> pitchLinesList             { get; set; } 
    public OpportunityContactRole contactRole       { get; set; }
        
    public String userProfile						{ get; set; }

    public Boolean isMetro							{ get; set; }
        
    public OppLine selectedOppLine					{ get; set; }
    
    String pitchSource								{ get; set; }
    
    
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
    
 /*   public String selectedProduct					{ get; set; }   
    public Double selectedUnitPrice					{ get; set; }
    public Date selectedFirstInsertionDate			{ get; set; }
    public String selectedDescription				{ get; set; }*/
        
    public List<SelectOption> roleOptions
    {
        get
        {
            
            if(roleOptions==null)
            {
    
   			   	// Change "Account" to any other object
  				Map<string, schema.sobjectfield> fieldsMap = Schema.SObjectType.OpportunityContactRole.fields.getMap();
      			List<SelectOption> options = new List<SelectOption>();
                roleOptions = new List<SelectOption>();
                roleOptions.add(new SelectOption('None', '--None--'));
  				for (Schema.PicklistEntry p : fieldsMap.get('role').getDescribe().getPicklistValues())
  				{
    				roleOptions.add(new SelectOption(p.getValue(), p.getLabel()));
  				}
    
/*                roleOptions = new List<SelectOption>();
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
    public String roleSelectList                { get; set; }         

    public Integer unitPrice                    { get; set; }
    public Integer totalPrice                   { get; set; }
    public OpportunityContactRole  oppcontrole  { get; set; }
    public ConstantsH__c ch                     { get; set; }
    public List<Product2> filteredProducts      { get; set; }
    public String productsSelectList            { get; set; }
    public String stageSelectList               { get; set; }
    
    public Integer noOfIncrements               { get; set; }
    
    public String dateIncProductsList           { get; set; }
    public String mediaLeadRecTypeId            { get; set; }
    public Boolean productsExist                { get; set; }
    
    private ID provisionalProductId				{ get; set; }
    
    public Boolean shouldDisable				{ get; set; }			

    public PageReference call()
    {
    	return null;
    }
    
   public PageReference add_rows() 
   {
   		if(selectedOppLine.SelectedInsertionDates==null||selectedOppLine.SelectedInsertionDates.length()==0)
   		{
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please enter at least one Insertion Date.');
                ApexPages.addMessage(message);  
                return null;                   			
   		}
   		if(roleSelectList=='None')
   		{
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please enter a Contact Role.');
                ApexPages.addMessage(message);  
                return null;                   			
   		}
   		 		
   	    List<String> lSelectedDates =   new List<String>();
   	    lSelectedDates = selectedOppLine.SelectedInsertionDates.split(',');
   	    List<Date> lDates           =   new List<Date>();
   	    Date dOppCloseDate          =   opportunity.CloseDate;
   	    Date dLIDate                =   selectedOppLine.opline.Last_Insertion_Date__c;
		
		Account checkAccount = [Select
									Type,
									RecordType.Name
								From Account
								Where Id = :opportunity.AccountId];
								
		if(checkAccount.RecordType.Name=='Advertiser'&&checkAccount.Type=='Client'&&opportunity.Agency__c==null)
		{
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'If main account is an Advertiser and is of Type Client, the Agency must be set.');
                ApexPages.addMessage(message);  
                return null;                			
		}   	    
        for(String sDate    :   lSelectedDates)
        {
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
           	    
        if(pitchLinesList==null)
        {
                pitchLinesList=new List<OppLine>();
        }
        

        
        /*for(integer i=0;i<num ;i++)
        {
                pitchLinesList.add(new OppLine());    
        }
        
        for(OppLine op:pitchLinesList)
        {
        	if(op.product==null)
        	{
	        	op.Product = selectedOppLine.product;
	        	op.opline.UnitPrice = selectedOppLine.Opline.UnitPrice;
	        	op.opline.ServiceDate = selectedOppLine.OpLine.ServiceDate;
	        	op.opline.Description = selectedOppLine.Opline.Description;
	        	op.opline.Brand__c = selectedOppLine.Opline.Brand__c;
	        	op.opline.Size__c = selectedOppLine.Opline.Size__c;
	        	op.opline.Position__c = selectedOppLine.Opline.Position__c;
	        	op.opline.Color_Specification__c = selectedOppLine.Opline.Color_Specification__c;
	        	op.opline.Region__c = selectedOppLine.Opline.Region__c;
	        	op.opline.URN__c = selectedOppLine.Opline.URN__c;
        	}        	
        }*/
        
        if(lDates.size() > 0){
            
            for(Date dInsertionDate : lDates)
            {
            
	            OppLine pitchProducts       					= new OppLine();
	    		pitchProducts.Product 							= selectedOppLine.product;
	            // pitchProducts.PricebookEntryId          = selectedOppLine.Opline.PricebookEntryId;
	            pitchProducts.opline.Brand__c                  = selectedOppLine.Opline.Brand__c;
	            pitchProducts.opline.Color_Specification__c    = selectedOppLine.Opline.Color_Specification__c;
	            pitchProducts.opline.UnitPrice                 = selectedOppLine.Opline.UnitPrice;
	            pitchProducts.opline.Region__c                 = selectedOppLine.Opline.Region__c;
	            pitchProducts.opline.Description               = selectedOppLine.Opline.Description;
	            pitchProducts.opline.Size__c                   = selectedOppLine.Opline.Size__c;
	            pitchProducts.opline.Position__c               = selectedOppLine.Opline.Position__c;        
	            pitchProducts.opline.Quantity                  = 1;
	            pitchProducts.opline.ServiceDate               = dInsertionDate;
	            pitchProducts.opline.URN__c                    = selectedOppLine.Opline.URN__c;
	            pitchProducts.opline.Last_Insertion_Date__c    = selectedOppLine.Opline.Last_Insertion_Date__c;
	            
	            pitchLinesList.add(pitchProducts);           
               
            }
            
	    		selectedOppLine.product=null;
	            selectedOppLine.Opline.Brand__c=null;
	            selectedOppLine.Opline.Color_Specification__c=null;
	            selectedOppLine.Opline.UnitPrice=null;
	            selectedOppLine.Opline.Region__c=null;
	            selectedOppLine.Opline.Description=null;
	            selectedOppLine.Opline.Size__c=null;
	            selectedOppLine.Opline.Position__c=null;        
	            selectedOppLine.SelectedInsertionDates=null;
	            selectedOppLine.Opline.URN__c=null;
	            selectedOppLine.Opline.Last_Insertion_Date__c=null;                                   
            
        }
        
        return null;
   }
   
   public PageReference delete_rows() 
   {
        System.debug('In Delete Rows!!');
        System.debug('pitchLinesList Before:'+pitchLinesList);
        if(pitchLinesList==null)
        {
                pitchLinesList=new List<OppLine>();
        }
        
        List<OppLine> newOppLine = new List<OppLine>();
        
        for(OppLine opl: pitchLinesList)
        {
                System.debug('Line:'+opl);
                if(!opl.deleteline)
                {
                        newOppLine.add(opl);
                }
        }
        
        System.debug('newOppLine:'+newOppLine);
        
        pitchLinesList=new List<OppLine>(newOppLine);
        
        System.debug('pitchLinesList After:'+pitchLinesList);
        
        return null;
        
   }


   public MultipleOppMultiLineController()
   {
        
        List<String> filtProductIds     = new List<String>();
        // String pricebookId;
        
        returnURL = ApexPages.currentPage().getParameters().get('returl');
        
        opportunity     = new Opportunity();
        opportunity.ownerId = loggedInUser;
        //pitch           = new OpportunityLineItem();
        //pitchLinesList = new List<OpportunityLineItem>();
        //pitchLinesList.add(new OpportunityLineItem()); 
         
        contactRole     = new OpportunityContactRole();
        
        selectedOppLine = new OppLine();
        
        ch              = ConstantsH__c.getInstance(UserInfo.getProfileId());
        productsExist   = true;
        shouldDisable   = true;
        noOfIncrements  = 1;
        
        ID accountId                    = ApexPages.currentPage().getParameters().get('Accountid');
        opportunity.accountId           = accountId;
        String type                     = ApexPages.currentPage().getParameters().get('type');
        opportunity.Type                = type;
        ID campaign                 	= ApexPages.currentPage().getParameters().get('CampaignId');
        opportunity.CampaignId          = campaign ;
        ID conId                        = ApexPages.currentPage().getParameters().get('Contactid');
        ID agencyId                     = ApexPages.currentPage().getParameters().get('Agencyid');
        opportunity.Agency__c           = agencyId;
        opportunity.ownerId             = UserInfo.getUserId();
        actId                        	= ApexPages.currentPage().getParameters().get('Activityid');
        evtId                        	= ApexPages.currentPage().getParameters().get('Eventid');
        String NewBus                   = ApexPages.currentPage().getParameters().get('NewBus');
        pitchSource              		= ApexPages.currentPage().getParameters().get('PitchSource');
        System.debug('opportunity.CampaignId:'+opportunity.CampaignId);
        
        if (NewBus=='1'){
            opportunity.IsNew__c=True;
        }
        
        ID activityId;
        String activityParent;
        
        
        userProfile		= [
        					Select Name 
        					From   Profile
        					Where Id = :UserInfo.getProfileId()
        					].Name;
        // This is done do that the fields(currently specific to Metro) will appear. This logic will need to be removed when we 
        // allow all the fields to be visible to all users. 
        /*if(userProfile.substring(0,5)=='Metro'||userProfile.substring(0,6)=='System')
        {
        	isMetro=true;
        }
        else
        {
        	isMetro=false;
        }*/
        // The above has been commented as all should see the information
        isMetro=true;
        
        try
        {
            pricebookId = [Select
                                    id
                            From Pricebook2
                            Where name =: ch.Price_Book__c].id;
        }
        catch (Exception e)
        {
            system.debug('Exception >>>>>>>> ' + e);
            productsExist = false;
        }  
        
        
        // rows 285-361 added to convert task to multipitch
        if (conId != null)
        {          
            // Populate the Contact in the Pitch Hub
            try{
                contactRole.ContactId = conId;
                }
            catch (Exception e)
            {
                
            }
            

            Contact con = [select id, accountid from Contact where id = :conId limit 1];            
            Account acct = [select Record_Type__c from Account where id = :con.accountid limit 1];

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
                select Name, Product2Id, isActive
                from PricebookEntry 
                where Pricebook2Id =: pricebookId and isActive = true
                ];
        
        for (PricebookEntry pbe : pricebookEntries) filtProductIds.add(pbe.Product2Id);
        
        filteredProducts = 
                [
                select Name, Family 
                from Product2 
                where id in :filtProductIds 
                order by Name
                ];
        
        if (filteredProducts.isEmpty()) productsExist = false;
    

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
        System.debug('>>>>>>>>> getProductOptions');
        List<SelectOption> options = new List<SelectOption>();
        
        //#
        //# Set Display ROP as a default product (if it exists) 
        //#
        options.add(new SelectOption('None','-- Select a product --'));
        
        for(Product2 p : filteredProducts)
        {
        	if(p.name=='Metro  Provisional Product')
        	{
        		provisionalProductId=p.Id;
        	}
            if(p.Family != null && p.Name.contains('Display ROP'))
            {
                options.add(new SelectOption(p.Id, p.Name));
            }
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
        options.add(new SelectOption('Closed Won',  		'Closed Won'));
     
     
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
        
        for(integer i=1;i<=52;i++)
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
    
    /*
                    <apex:pageBlockSectionItem id="multioppsection1">
                        <apex:outputLabel for="noOfIncrementsSelect">Number Of Increments</apex:outputLabel>
                        <apex:panelGroup >
                                <apex:selectList value="{!NoOfIncrements}" size="1" id="noOfIncrementsSelect"   required="true" >
                                    <apex:actionSupport event="onchange" action="{!doDisableDateInc}" rerender="multiopppage:multioppform:multioppblock:multioppsection"/>               
                                    <apex:selectOptions value="{!NoOfProducts}"/>
                                </apex:selectList>
                        </apex:panelGroup>
                    </apex:pageBlockSectionItem>
                        
                    <apex:pageBlockSectionItem id="theDateInc">  
                        <apex:outputLabel for="DateIncProductsSelect">Dates To Be Incremented</apex:outputLabel>
                        <apex:panelGroup id="thePanel">
                            <apex:selectList value="{!DateIncProductsList}" size="1" id="DateIncProductsSelect"   required="true" disabled="{!shouldDisable}">
                                <apex:selectOptions value="{!DateIncProducts}"/>
                            </apex:selectList>
                        </apex:panelGroup>
                    </apex:pageBlockSectionItem>    
    
    */
    
	/*public PageReference doDisableDateInc() 
	{
	  System.debug('doDisableDateInc');
	  if (NoOfIncrements == 1) 
	  {
	    shoulddisable = true;
	  } 
	  else 
	  {
	    shoulddisable = false;
	  }
	  System.debug('doDisableDateInc:'+shouldDisable);
	  Return null;
	}  */  
    
    
    //#
    //# Save Opportunity and Pitch Idea created against that Opportunity
    //#
    
    public PageReference save() 
    {
    	Opportunity opTmp = new Opportunity();
    	opTmp = opportunity;
    	
    	System.debug('opTmp:'+opTmp);
		
        System.debug('Save.....');
        PageReference opptyPage;
        
        Set<Id> productSet = new Set<Id>();
        List<Opportunity> multiOppList = new List<Opportunity>();
        
        if(pitchLinesList==null||pitchLinesList.Size()==0)
        {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please Enter at least 1 Pitch Line Item.');
                ApexPages.addMessage(message);   
                return null;                    
        }
        
        
        
        System.debug('provisionalProductId:'+provisionalProductId);
        System.debug('stageSelectList:'+stageSelectList);
        // Validation to check that the First Insertion Date is greater than the Opportunity Close Date   
        for(OppLine opl:pitchLinesList)
        {     
				System.debug('opl.product:'+opl.product);
                if(stageSelectList=='Closed Won'&&(Id)opl.product==provisionalProductId)
                {
                	ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Pitch cannot be closed-won with a provisional product allocated.');
                	ApexPages.addMessage(message);                 	
                }
                if(opl.opline.ServiceDate==null)
                {
                	ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The First Insertion Date should be inserted on the Pitch Line.');
                	ApexPages.addMessage(message);          
                }
                else
                {

	                if(opl.opline.ServiceDate<opportunity.closeDate)
	                {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'The First Insertion Date must be greater than the Opportunity Close Date.');
	                ApexPages.addMessage(message);          
	                }
	                else
	                {
	                        productSet.add(opl.product);
	                }
                }
        }
        if(NoOfIncrements==0)
        {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'Please ensure that the Number Of Products are greater than 0.');
            ApexPages.addMessage(message);                      
        }
        
        if(!ApexPages.hasMessages())
        {
            // First Insertion Date is valid
            List<Id> product2Ids = new List<Id>();

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
                    where id IN :productSet
                    ]); 
                                    
            if(opportunity.Id==Null)
            {      

              //  try 
               // {
                    Date firstCloseDate = opportunity.CloseDate;
                    //List<Opportunity> multiOppList = new List<Opportunity>();
                    for (Integer j = 0; j < NoOfIncrements; j++){
                        Opportunity curropp=new Opportunity();
                        //curropp.OwnerId=opportunity.OwnerId;
                        curropp.OwnerId = loggedInUser;
                        curropp.name=opportunity.name+' '+(j+1);
                        curropp.Stagename=stageSelectList;
                        curropp.RecordTypeId    = mediaLeadRecTypeId;
                        curropp.CurrencyIsoCode = products.get(pitchLinesList[0].product).CurrencyIsoCode;
                        curropp.AccountId=opportunity.AccountId;
                        curropp.Agency__c=opportunity.Agency__c;
                        curropp.Type=opportunity.Type;
                        curropp.CampaignId=opportunity.CampaignId;
                        curropp.CreationMethod__c='Multiple Opportunities Multiple Products';
                        curropp.Source_Of_Pitch__c = pitchSource;
                        curropp.PriceBook2Id = priceBookId; 
                        curropp.IsNew__c = opportunity.IsNew__c;
						System.debug('DateIncProductsList:'+DateIncProductsList);
                        if (DateIncProductsList=='Daily'||DateIncProductsList==null)
                        {
                           curropp.CloseDate=firstCloseDate.addDays(j);
                        }
                        else if (DateIncProductsList=='Weekly')
                        {
                            curropp.CloseDate =firstCloseDate;
                            firstCloseDate=firstCloseDate.addDays(7); 
                        }
                        else if (DateIncProductsList=='Monthly')
                        {
                            curropp.CloseDate=firstCloseDate.addMonths(j);
                        }
                        multiOppList.add(curropp);
                    }
                    if (multiOppList.size()>0)
                    {

                            List<Contact> contactList;
                            List <OpportunityContactRole> multipleOpportunityContactRole=new List <OpportunityContactRole>();
                            System.debug('Contact List:');
                            if(contactRole.ContactId!=null)
                            {
                                contactList = [
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

                           try 
                           {
                                insert multiOppList;
                                
                           }
                           catch(Exception e) 
                           {
                                ApexPages.addMessages(e);
                                return null;
                           }                          
						   if(!ApexPages.HasMessages())
						   {
                           List<OpportunityLineItem> newOppList = new List<OpportunityLineItem>();
							
                           Integer j=0;

                           for (Opportunity op:multiOppList)                       
                           {
                                //OpportunityContactRole contactRoleForOpp = new OpportunityContactRole();
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
	                                    multipleOpportunityContactRole.add(new OpportunityContactRole(
	                                                                 OpportunityId=op.Id,
	                                                                 IsPrimary=true,
	                                                                 ContactId=contactrole.contactid,
	                                                                 Role=roleSelectList
	                                                                 ));
	                                    System.debug('***********************ContactRoleList:'+multipleOpportunityContactRole);
	                                    //Auto-Task on Opportunity
	                                    newocrsmap.put(op.id,multipleOpportunityContactRole);
	                                //}
                               	}
                                
                                Date firstInsertionDate;                               
                                
                                

                                for(OppLine opl:pitchLinesList)
                                {
                                                                   
                                        OpportunityLineItem oppLine = new OpportunityLineItem();         
                                        
                                        oppLine.opportunityId = op.id;
                                        oppLine.quantity = 1;
										System.debug('*****products**:'+products);
                                        oppLine.PricebookEntryId = products.get(opl.product).PricebookEntries.get(0).Id;  
                        
                                       if (DateIncProductsList=='Daily'||DateIncProductsList==null)
                                       {
                                            oppLine.ServiceDate =opl.opLine.ServiceDate.addDays(j);
                                            //j++;
                                       }
                                       else if (DateIncProductsList=='Weekly')
                                       {
                                            oppLine.ServiceDate =opl.opLine.ServiceDate.addDays(j*7);
                                            // firstInsertionDate=firstInsertionDate.addDays(7); 
                                       }
                                       else if (DateIncProductsList=='Monthly')
                                       {
                                            oppLine.ServiceDate =opl.opLine.ServiceDate.addMonths(j);
                                            //j++;
                                       }
                                       oppLine.UnitPrice = opl.opLine.UnitPrice;
                                       oppLine.Description = opl.opLine.Description;
                                       
                                       oppLine.Brand__c = opl.opLine.Brand__c;
                                       oppLine.Size__c = opl.opLine.Size__c;
                                       oppLine.Position__c = opl.opLine.Position__c;
                                       oppLine.Color_Specification__c = opl.opLine.Color_Specification__c;
                                       oppLine.Region__c = opl.opLine.Region__c;
                                       oppLine.URN__c = opl.opLine.URN__c;
                                       oppLine.Last_Insertion_Date__c = opl.opLine.Last_Insertion_Date__c;

                                       oppLine.PricebookEntryId = products.get(opl.product).PricebookEntries.get(0).Id;
                                       newOppList.add(oppLine);
                                       
                                       
                                 }
                                 //Auto-Task on Opportunity
                                 newopplinesmap.put(op.id, newOppList);
                                 j++;
                                }
                           
                            
                            if(newOppList.size()>0)
                            {
                                try
                                {
                                    System.debug('***********************newOpplist:'+newOpplist);
                                    insert newOpplist;
                                }
                                catch(Exception e)
                                {
                                    ApexPages.addMessages(e);
                                    return null;                
                                }
                            }
                            
                            if(multipleOpportunityContactRole.size()>0)
                            {
                                try
                                {
                                    System.debug('***********************contactRoleList:'+multipleOpportunityContactRole);
                                    insert multipleOpportunityContactRole;
                                }
                                catch(Exception e)
                                {
                                    ApexPages.addMessages(e);
                                    return null;                
                                }
                            }                           
						   	
						   }
                        
                    }
                    
                //}
                //catch(Exception e) 
                //{
                //    System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
                //    ApexPages.addMessages(e);
                //    return null;
               // }
            }
                        
            System.debug('***********************opportunity:'+opportunity);
            System.debug('***********************products:'+products);
            // The update below has to occur after the the above insert due to a bug reported. The problem
            // does not occur for System Admin but if an ordinary user logs on to the Multi Pitch
            // and creates a pitch and changes the Owner prior to saving an error occurs: Insufficient Privileges.
            List<Opportunity> updateOpportunity = new List<Opportunity>();
            System.debug('multiOppList:'+multiOppList);
            System.debug('loggedInUser:'+loggedInUser);
            for(Opportunity op:multiOppList)
            {
            	System.debug('op.OwnerId:'+op.OwnerId);
            	if(op.OwnerId!=opportunity.OwnerId)
            	{
            		// op.OwnerId = opportunity.OwnerId;
            		updateOpportunity.add(new Opportunity(Id=op.Id, OwnerId=opportunity.OwnerId));
            	}
            }
            System.debug('updateOpportunity:'+updateOpportunity);
            if(updateOpportunity.size()>0)
            {
            	update updateOpportunity;
            }
//////////////////////////////////////////////////////////////////////
//Auto-Task on Opportunity
if(userProfile.contains('Mail Classified')||userProfile.contains('Mail Display')||userProfile.contains('MailOnline')||userProfile.contains('System Administrator')){
	AutoCreateTaskOnOpportunity.createTasks(multiOppList, newopplinesmap, newocrsmap);
}

/////////////////////////////////////////////////////////////////////
            
            
            
            
	        if(returnURL==null)
	        {   
	         	opptyPage = new PageReference('/' + opportunity.AccountId);
	        }
	        else
	        {
	        	opptyPage = new PageReference(returnURL);
	        }
	         
	        opptyPage.setRedirect(true);

        }       
     
        return opptyPage;
        
    }
   
   
   
  
    //#
    //# Cancel and return to the Home page
    //#
  
    public PageReference cancel()
    {
      	PageReference opptyPage;
        if(returnURL==null)
        {
        	opptyPage = new PageReference('/home/home.jsp');
        }
        else
        {
        	opptyPage = new PageReference(returnURL);
        }
        opptyPage.setRedirect(true);

        return opptyPage;
        
    }
    
}