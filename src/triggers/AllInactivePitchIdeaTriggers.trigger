/*******************************************************************************************
********************************************************************************************
****																					****
****	This trigger is used for ensuring data integrity on inactive Pitch Ideas.		****
****	If inactive Pitch Idea is updated and First Insertion Date is not equal or		****
****	higher than Opportunity Close Date than error message will appear.				****
****																					****
****	If Unit Price or Quantity is changed this trigger calculates 					****
****	new Total Value.																****
****																					****
****	Also, if Pricebook Entry is deleted than Inactive Pitch Idea cannot be 			****
****	activated and error message is shown											****
****																					****
****	If all conditions are met and Activate button is clicked than new Pitch Idea 	****
****	gets created and all fields are populated with the values from the inactive 	****
****	Pitch Idea (except of Reason for Inactive and Lost to Competitor). 				****
****	Afterwards, newly created Pitch Idea is inserted and inactive Pitch Idea 		****
****	is deleted.																		****
****																					****
********************************************************************************************
*******************************************************************************************/



trigger AllInactivePitchIdeaTriggers on Inactive_Pitch_Idea__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{


	//#
	//# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers 		= No_Triggers__c.getInstance(UserInfo.getUserId());
    
    if (notriggers == null || !notriggers.Flag__c) 	
    {
    	
		
		ConstantsH__c ch 	= ConstantsH__c.getInstance(UserInfo.getProfileId());
	
	
		//################################################
	    //############ Before Update Trigger #############
	    //################################################
		
		if (trigger.isBefore && trigger.isUpdate)    
	    { 
		
			List<Id> ids = new List<Id>();
			for (Integer i = 0; i < trigger.new.size(); i++) { ids.add(trigger.new[i].id); }
			
			Inactive_Pitch_Idea__c[] ipis = 
					[
					select id,ServiceDate__c, Opportunity__c, Opportunity__r.CloseDate 
					from Inactive_Pitch_Idea__c ipi
					where id in :ids 
					];   
			
			for (Integer i = 0; i < trigger.new.size(); i++) 
			{
	
	        	if (
	        		//(trigger.new[i].First_Insertion_Date__c != trigger.old[i].First_Insertion_Date__c) && 
	        		//(trigger.new[i].First_Insertion_Date__c < ipis[i].Opportunity__r.CloseDate)
	        		(trigger.new[i].ServiceDate__c != trigger.old[i].ServiceDate__c) && 
	        		(trigger.new[i].ServiceDate__c < ipis[i].Opportunity__r.CloseDate)
	        		) 
	        	{
	        		trigger.new[0].addError('First Insertion Date has to be equal or higher then Opp Close Date.');
	        	}
	        }
	    }
	
	
	
	    //################################################
	    //############# After Update Trigger #############
	    //################################################
	    
	    if (trigger.isAfter && trigger.isUpdate)    
	    { 
	        
	        List<Inactive_Pitch_Idea__c> newActiveIPIs 	= new List<Inactive_Pitch_Idea__c>();
	        List<Inactive_Pitch_Idea__c> IPIsForUpdate 	= new List<Inactive_Pitch_Idea__c>();
	       	List<OpportunityLineItem> newOLIs 			= new List<OpportunityLineItem>();
	        List<String> ipiPbeIds						= new List<String>();
	        List<PricebookEntry> existingPbEs			= new List<PricebookEntry>();	
	        
	        Set<String> newInactivePitchIdeaIds 		= new Set<String>();
	        Set<String> IPIForUpdateIds 				= new Set<String>();
	        Set<Id> product2Ids = new Set<Id>();
	        
	        OpportunityLineItem oli 					= new OpportunityLineItem();
	
	
	        for(integer i=0; i<trigger.new.size(); i++)
	        {
	        	
	        	//#
	        	//# Populate a list with newly active Pitch Ideas
	            //#
	            if ((trigger.new[i].Active__c == true) && (trigger.old[i].Active__c == false))
	            {
	                
	                newActiveIPIs.add(trigger.new[i]);
	                newInactivePitchIdeaIds.add(trigger.new[i].Id);
	                ipiPbeIds.add(trigger.new[i].PriceBookEntryID__c);
	                              
	            }

	            
	            //#
	        	//# Check if Unit Price(Sales Price, Cost) or Quantity has been changed
	            //#
	            if 	(
	            	(trigger.new[i].Cost__c != trigger.old[i].Cost__c) 
	            	|| 
	            	(trigger.new[i].Quantity__c != trigger.old[i].Quantity__c)
	            	)
	            {
	            	IPIForUpdateIds.add(trigger.new[i].Id);
	            }
	            
	        }
	        
	        
	        //#
	        //# Ensure that Inactive Pitch Idea cannot be activated
	        //# if Pricebook Entry is deleted in the meantime.
	        //#
	        existingPbEs = [select id from PricebookEntry where id in : ipiPbeIds]; 
	        
	        if(ipiPbeIds.size() != existingPbEs.size()) 
	        	trigger.new[0].addError('Pricebook Entry is deleted so you cannot activate this Inactive Pitch Idea');
	        
	        string result=null;
			//Fetching the resource
			List<StaticResource> resourceList = [SELECT Id, Body
													FROM StaticResource
													WHERE Name = 'DeActivatePitchFieldSetting'];
			//Checking if the result is returned or not
			if(resourceList.size() == 1) {
			    result = resourceList[0].Body.toString();
			}
			list<ActivateDeActivatePitchSettings> pitchSettings = new list<ActivateDeActivatePitchSettings>();
			pitchSettings = (list<ActivateDeActivatePitchSettings>)System.JSON.deserialize(result, list<ActivateDeActivatePitchSettings>.class);
						
	        for(Inactive_Pitch_Idea__c ipi : newActiveIPIs)
	        {
	      
	            System.debug('>>>>>>>>>>>>>>>>> ipi ' + ipi);
	            oli = new OpportunityLineItem();
	            
	            for(ActivateDeActivatePitchSettings setting : pitchSettings){
            		if(!setting.lineField.equalsIgnoreCase('Subtotal')&&!setting.lineField.equalsIgnoreCase('ProductCode')&&!setting.lineField.equalsIgnoreCase('Product2ID')&&!setting.lineField.equalsIgnoreCase('ListPrice')&&!setting.lineField.equalsIgnoreCase('Reason_for_Inactive2__c') && !setting.lineField.equalsIgnoreCase('Competitor_Title__c')){
            			oli.put(setting.lineField, ipi.get(setting.inActiveField));
            		}
            	}
	            
	            oli.Competitor_Title__c     = null;
	            oli.Reason_for_Inactive2__c = null;
	            /*
	            oli.Active__c               = ipi.Active__c;
	            
	            oli.Description             = ipi.Description__c;
	            oli.Discount                = ipi.Discount__c;
	            oli.ServiceDate 			= ipi.ServiceDate__c;
	            oli.Last_Insertion_Date__c  = ipi.Last_Insertion_Date__c;
	            oli.OpportunityId           = ipi.Opportunity__c;
	            oli.Other_Media_Used__c     = ipi.Other_Media_Used__c;
	            oli.PricebookEntryId 		= ipi.PriceBookEntryID__c;
	            oli.Quantity                = ipi.Quantity__c; 
	            
	            oli.Revenue_Group__c        = ipi.Revenue_Group__c;
	            oli.ServiceDate             = ipi.ServiceDate__c;
	            oli.UnitPrice               = ipi.Cost__c;
	            oli.Brand__c				= ipi.Brand__c;
	            oli.Color_Specification__c	= ipi.Color_Specification__c;
	            oli.Position__c				= ipi.Position__c;
	            oli.Region__c				= ipi.Region__c;
	            oli.Size__c					= ipi.Size__c;
	            oli.Upweight__c				= ipi.Upweight__c;
	            oli.URN__c					= ipi.URN__c;
	            */
	            System.debug('>>>>>>>>>>>>>>>>> oli ' + oli);
	            newOLIs.add(oli);
	
	        }
	        
	        
	        
	        //#
	        //# Insert new Pitch Ideas
	        //#
	        if(newOLIs.size() > 0) 
	        {
	            try { insert newOLIs; }
	            catch(Exception e) 
	            { 
	            	System.debug('>>>>>>>>>>> EXCEPTION!!!! ' + e);
	            }  
	        }
	        
			
	        if(newInactivePitchIdeaIds.size() > 0) 
	        {
	            
	            List<Inactive_Pitch_Idea__c> IPIsForDeletion = [select id from Inactive_Pitch_Idea__c where id in :newInactivePitchIdeaIds];
	        
	            try { delete IPIsForDeletion; }
	            catch(Exception e) { System.debug('>>>>>>>>>>> EXCEPTION!!!! ' + e); }
	        }
	        
	        
	        
	        if(IPIForUpdateIds.size() > 0) 
	        {
	            
	            IPIsForUpdate = [select id, TotalPrice__c, Quantity__c, Cost__c from Inactive_Pitch_Idea__c where id in :IPIForUpdateIds];
	        
	        
	        	//#
	       	 	//# Calculate the Total Price if Quantity or Unit Price has been updated
	        	//#
	        	for(Inactive_Pitch_Idea__c ipi : IPIsForUpdate)
	        	{
	        		ipi.TotalPrice__c	= ipi.Quantity__c * ipi.Cost__c;
	        	}
	        	
	            try{ update IPIsForUpdate; }
	            catch(Exception e) { System.debug('>>>>>>>>>>> EXCEPTION!!!! ' + e); }
	            
	        }
	        
	    }
    }
}