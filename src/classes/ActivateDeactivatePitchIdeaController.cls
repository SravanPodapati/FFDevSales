/*******************************************************************************************
********************************************************************************************
****																					****
****	Users are able to make inactive Pitch Idea active - the pitch is removed		****			 
****	from Inactive Pitch Ideas list and brought back as an active pitch.				****
****																					****
****	Also, users are able to deactivate Pitch Ideas. After deactivation, 			****
****	record gets created in Inactive Pitch Ideas related list and 					****
****	Pitch Idea gets removed from the Opportunity.  									****
****																					****
********************************************************************************************
*******************************************************************************************/


public class ActivateDeactivatePitchIdeaController 
{
	
	private PageReference retPage;
	public Id pitchIdeaId;
	
	public string errorMessage 			{ get; set; }
	public boolean showSelectList 		{ get; private set; }
	public boolean showLostToCompList 	{ get; private set; }
	public boolean renderPage 			{ get; private set; }
	public string inactiveReason 		{ get; set; }
	public string competitorTitle 		{ get; set; }
	
	public OpportunityLineItem oli 		{ get; set; }

	
	
	public ActivateDeactivatePitchIdeaController(ApexPages.StandardController controller) 
	{
		
		pitchIdeaId = Apexpages.currentPage().getParameters().get('id');
		system.debug('>>>>>>>>>>>>> pitchIdeaId ' + pitchIdeaId);
		
		showSelectList 		= false;
		showLostToCompList 	= false;
		renderPage			= true;

	}



	//#
	//# Activate inactive Pitch Idea
	//#
	public PageReference Activate() 
	{
		
		errorMessage = null;
		
		Inactive_Pitch_Idea__c ipi = 
				[
				select id, name, Active__c, Opportunity__c, Opportunity__r.Id, Opportunity__r.CloseDate, ServiceDate__c
				from Inactive_Pitch_Idea__c 
				where id =: pitchIdeaId
				];

		
		ipi.Active__c = true;
		
		
		// if (ipi.First_Insertion_Date__c < ipi.Opportunity__r.CloseDate) 
		if (ipi.ServiceDate__c < ipi.Opportunity__r.CloseDate) 
		{
		   	ipi.addError('First Insertion Date has to be equal or higher then Opp Close Date.');
		}
		
		
		try
		{
			update ipi;
		}
		catch(DmlException dmle)
		{
				
			if(dmle.getMessage().contains('higher then Opp Close Date')) 
					errorMessage = 'First Insertion Date has to be equal or higher then Opp Close Date.';
			else 	errorMessage = dmle.getMessage();
				
			return null;
				
		}
		catch(exception e)
		{
			errorMessage = e.getMessage();
			return null;
		}
		
		retPage = new Pagereference('/' + ipi.Opportunity__r.Id);
		retPage.setRedirect(true);
		
		
		return retPage;
		
	}
	
	
	
	//#
	//# Dectivate active Pitch Idea
	//#
	
	public PageReference Deactivate() 
	{
		
		
		oli =
				[
				select id, Active__c, OpportunityId, Reason_for_Inactive2__c, Competitor_Title__c, ServiceDate
				from OpportunityLineItem 
				where id =: pitchIdeaId
				];


		Opportunity oppty = 
				[
				select id, Name, CloseDate
				from Opportunity 
				where id =: oli.OpportunityId
				];
				

		if (inactiveReason  == null)		inactiveReason	= oli.Reason_for_Inactive2__c;
		if (competitorTitle == null) 		competitorTitle	= oli.Competitor_Title__c;
	    System.debug('inactiveReason:'+inactiveReason);
	    System.debug('competitorTitle:'+competitorTitle);
	
		if	(
			((inactiveReason == 'Lost to Competitor' && competitorTitle != null) || (inactiveReason != null && inactiveReason != 'Lost to Competitor'))
			&&
			(oli.ServiceDate >= oppty.CloseDate)
			)
		{
			System.debug('Setting inactive flag');
			oli.Active__c = false;
			
			
			try
			{ 
				
				oli.Reason_for_Inactive2__c = InactiveReason;
				oli.Competitor_Title__c = competitorTitle;
				System.debug('******** oli'+oli);
				update oli; 
				
				retPage = new Pagereference('/' + oli.OpportunityId);
				retPage.setRedirect(true);
			
				return retPage;
				
			}
			catch(Exception e)
			{
				
				System.debug('>>>>>>>>>>> EXCEPTION!!!! ' + e); 
				errorMessage = e.getMessage();
				
				return null;
			}
			
		}
		else if(oli.ServiceDate < oppty.CloseDate)
		{
			errorMessage = 'First Insertion Date has to be equal or higher then Opp Close Date.';
			renderPage = false;
			return null; 
		}
		
		
		if(oli.Reason_for_Inactive2__c == null && !showSelectList)
		{
				showSelectList = true;
				return null;
				
		}
		showSelectList = false;
		
		
		
		if(inactiveReason == 'Lost to Competitor' && oli.Competitor_Title__c == null && !showLostToCompList)
		{
		
				showLostToCompList = true;
				return null;
				
		}
		
		
		return null;
		
	}
	
	
	
	//#
	//# Get all Reason for Inactive options
	//#
	
	public List<Selectoption> getInactiveOpts()
	{
		
		List<Selectoption> opts 		= new List<Selectoption>();
		List<Schema.PicklistEntry> vals = Schema.SObjectType.OpportunityLineItem.fields.Reason_for_Inactive2__c.getPicklistValues();
		for(Schema.PicklistEntry val : vals) opts.add(new selectOption(val.getValue(), val.getLabel()));
		return opts;
		
	}
	
	
	
	//#
	//# Get all Competitor Title options
	//#
	
	public List<Selectoption> getLostToCompOpts()
	{
		
		List<Selectoption> opts 		= new List<Selectoption>();
		List<Schema.PicklistEntry> vals = Schema.SObjectType.OpportunityLineItem.fields.Competitor_Title__c.getPicklistValues();
		for(Schema.PicklistEntry val : vals) opts.add(new selectOption(val.getValue(), val.getLabel()));
		return opts;
		
	}
	
	
	
	//#
	//# Cancel and return to the Pitch Idea
	//#
	
	public PageReference cancel()
    {
   		
   		PageReference opptyPage = new PageReference('/' + oli.Id);
      	opptyPage.setRedirect(true);

      	return opptyPage;
		
    }
    
    
	//#
	//# Delete OpportunityLine which have already been archived
	//#
	@future 
	public static void deleteOpportunityLine (Set<Id> oplIdSet)
	{
		if(oplIdset.size()>0)
		{
			System.debug('oplIdset:'+oplIdset);
			List<OpportunityLineItem> oplList = new List<OpportunityLineItem>();
			for(Id opl:oplIdSet)
			{
				oplList.add(new OpportunityLineItem(Id=opl));
			}
			system.debug('oplList:'+oplList);
			delete oplList;
		}
	}

}