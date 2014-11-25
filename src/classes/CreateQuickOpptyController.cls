/*******************************************************************************************
********************************************************************************************
****																					****
****	Using a single page, users are able to create a quick opportunity 				****
****	with one Pitch Idea.															****
****																					****
****	If Pricebook doesn't exist, or if it is empty, than an error message is shown.	****
****																					****
****	Also, opportunity's currency will be the same as for selected product.			****
****																					****
********************************************************************************************
*******************************************************************************************/


public with sharing class CreateQuickOpptyController 
{


	public Account account 						{ get; set; }
	public Opportunity opportunity 				{ get; set; }
	public OpportunityLineItem pitch 			{ get; set; }
	public ConstantsH__c ch						{ get; set; }
	public List<Product2> filteredProducts		{ get; set; }
	public String productsSelectList 			{ get; set; }
	public String stageSelectList 				{ get; set; }
	public String mediaLeadRecTypeId 			{ get; set; }
	public Boolean productsExist 				{ get; set; }
	

	public CreateQuickOpptyController()
	{
		
		List<String> filtProductIds 	= new List<String>();
		String pricebookId;
		
		opportunity 	= new Opportunity();
		pitch			= new OpportunityLineItem();
		ch 				= ConstantsH__c.getInstance(UserInfo.getProfileId());
		productsExist 	= true;
		
		
		try
		{
			pricebookId = [select id from Pricebook2 where name =: ch.Price_Book__c].id;
		}
		catch (Exception e)
		{
			system.debug('Exception >>>>>>>> ' + e);
			productsExist = false;
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
        	if(p.Family != null && p.Name.contains('Display ROP')) options.add(new SelectOption(p.Id, p.Name));
        
        
        if(options.isEmpty())
        {
        	for(Product2 p : filteredProducts)
	        	if(p.Family != null) options.add(new SelectOption(p.Id, p.Name));
        }
        else
        {
       		for(Product2 p : filteredProducts)
        		if(p.Family != null && !p.Name.contains('Display ROP')) options.add(new SelectOption(p.Id, p.Name));
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
    	
    	options.add(new SelectOption('Preparation', 		'Preparation'));
    	options.add(new SelectOption('Brief', 				'Brief'));
    	options.add(new SelectOption('Discussion', 			'Discussion'));
    	options.add(new SelectOption('Final Negotiations', 	'Final Negotiations'));
     
     
        return options;
        
    }
    
    
	
	//#
	//# Save Opportunity and Pitch Idea created against that Opportunity
	//#
	
	public PageReference save() 
	{

      	List<Id> product2Ids = new List<Id>();
      	
      	Pricebook2 priceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = :ch.Price_Book__c limit 1];
       	product2Ids.add(productsSelectList);
        
        
        Map<Id, Product2> products = new Map<Id, Product2>
        		([
        		select id, Name, CurrencyIsoCode, (select id, Name from PricebookEntries where Pricebook2Id =: priceBook.id limit 1) 
        		from Product2 
        		where id 
        		IN :product2Ids
        		]);
        		
		
      	opportunity.StageName		= stageSelectList;
      	opportunity.RecordTypeId	= mediaLeadRecTypeId;
      	opportunity.CurrencyIsoCode = products.get(productsSelectList).CurrencyIsoCode;
		
		try {insert opportunity;}
    	catch(Exception e) {System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);}
      	

      	if(products.containsKey(productsSelectList) && !products.get(productsSelectList).PricebookEntries.isEmpty()) 
            		pitch.PricebookEntryId = products.get(productsSelectList).PricebookEntries.get(0).Id;
            
      	pitch.opportunityId 		= opportunity.id;
		pitch.Quantity				= 1;
		
		
    	try {insert pitch;}
    	catch(Exception e) 
    	{
    		System.debug('>>>>>>>>>>>>>> EXCEPTION: ' + e);
    		return null;
    	}
 
 
      	PageReference opptyPage = new PageReference('/' + opportunity.id);
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