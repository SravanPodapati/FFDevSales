public with sharing class AutoCreateTaskOnOpportunity {
		
			
	private static Id userProfileId = UserInfo.getProfileId();	
	private static String userProfileName = [Select
									Name
									From Profile
									Where Id = :userProfileId].Name;
	
	public static void createTasks(List<Opportunity> newopps, map<Id, List<OpportunityLineItem>>newopplines, map<Id, List<OpportunityContactRole>> ocr)
		{
					system.debug('userProfileName:'+userProfileName);
					//GB-106 : Collaboration
    				if(userProfileName.contains('Mail Classified')||userProfileName.contains('Mail Display')||userProfileName.contains('MailOnline')||userProfileName.contains('System Administrator')){
    					List<OpportunityContactRole> newcon= new List<OpportunityContactRole>();
    					List<OpportunityLineItem> newlines= new List<OpportunityLineItem>();
	        			List<Opportunity> newOppsToUpdate=new List<Opportunity>();
	        			List<Opportunity> closedMultiOppsToUpdate=new List<Opportunity>();
				        Map<Id, Opportunity> oppMap=new Map<Id, Opportunity>();
				        List<Task> newTasksToCreate=new List<Task>();
				        
				        Map<Id, String> prodmap=new Map<Id, String>(); 
				        
				        List<OpportunityLineItem> oppProds = [SELECT Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.Family 
   						FROM OpportunityLineItem 
   						WHERE OpportunityId IN :newopps];
   						
   						for (OpportunityLineItem opprod: oppProds){
   							prodmap.put(opprod.id,opprod.PricebookEntry.Product2.Name);
   						}
   							
   					
				    	for (Opportunity op1:newopps) {
							if (op1.StageName=='Closed Won'){
								closedMultiOppsToUpdate.add(op1);
								
							}else{
									
							newcon=ocr.get(op1.id);
							newlines=newopplines.get(op1.id);
							String description='';
							Double amount=0;
							Datetime myDatetime = op1.CloseDate;
							String sCloseDate = myDatetime.format('dd/MM/yyyy');
														                                            
							for (OpportunityLineItem opl1:newlines) {
								if(opl1.opportunityid==op1.id){
								amount=amount+opl1.UnitPrice;
								Datetime myDatetime1 = opl1.ServiceDate;
								String sFirstInsertionDate = myDatetime1.format('dd/MM/yyyy');
								String sLastInsertionDate;
								if (opl1.Last_Insertion_Date__c!=null){
                                    Datetime myDatetime2 = opl1.Last_Insertion_Date__c;
                                    sLastInsertionDate = myDatetime2.format('dd/MM/yyyy');
                                }else {
                                   	sLastInsertionDate='null';
                                }
								String productName = prodmap.get(opl1.id);
								if(opl1.description==''){
									if(userProfileName.contains('Mail Classified')){
										description='Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('Mail Display')){
										description='Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('MailOnline')){
										description='Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Last Insertion Date: '+sLastInsertionDate+' Description: '+opl1.Description;
									}else{
										description='Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;	
									}
								}else{
									if(userProfileName.contains('Mail Classified')){
										description=description+'\n'+'Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('Mail Display')){
										description=description+'\n'+'Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('MailOnline')){
										description=description+'\n'+'Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Last Insertion Date: '+sLastInsertionDate+' Description: '+opl1.Description;
									}else{
										description=description+'\n'+'Product Name: '+productName+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;	
									}
								}
								}
							}
							//, WhoId=op1.OpportunityContactRoles[0].ContactId
							system.debug('description:'+description);
							system.debug('amount:'+amount);
							//newOppsToUpdate.add(op.Opportunity);
							 //WhoId=op1.OpportunityContactRoles[0].ContactId,
								if (op1.CampaignId!=null){
									try {
										Task newTask = new Task(WhatId=op1.Id, Description=description, Subject='Pitch for: £'+amount+' created at: '+op1.StageName+'. Pitch close date: '+sCloseDate, Strategic_Campaign__c=op1.CampaignId, WhoId=ocr.get(op1.id)[0].ContactId, OwnerId=op1.OwnerId, Type__c=op1.Type, Status='Completed', Outcome__c='Ineffective', IsNew__c=op1.IsNew__c, ActivityDate=Date.today(), isReminderSet=true, reminderdatetime=DateTime.Now());
						              	newTasksToCreate.add(newTask);
				                    
										} catch(DmlException e) {
								
										}
								}else {
									try {
										Task newTask = new Task(WhatId=op1.Id, Description=description, Subject='Pitch for: £'+amount+' created at: '+op1.StageName+'. Pitch close date: '+sCloseDate, WhoId=ocr.get(op1.id)[0].ContactId, OwnerId=op1.OwnerId, Type__c=op1.Type, Status='Completed', Outcome__c='Ineffective', IsNew__c=op1.IsNew__c, ActivityDate=Date.today(), isReminderSet=true, reminderdatetime=DateTime.Now());
						              	newTasksToCreate.add(newTask);
				                    
										} catch(DmlException e) {
								
										}
								}
								
							}
							
											
						}
						if(closedMultiOppsToUpdate.size()>0){
								AutoCreateTaskOnOpportunity.createClosedOppTasks(closedMultiOppsToUpdate);		
							}
						
						if(newTasksToCreate.size()>0){
							insert newTasksToCreate;
						}
						
			       	
        			}
	}
   //////////////////////////////////////////////////////////////////////////////////////////
   //public static void createClosedOppTasks(List<Opportunity> newopps, Map<Id,Opportunity> oldopps )
   public static void createClosedOppTasks(List<Opportunity> newopps)
   {
   	system.debug('userProfileName1:'+userProfileName);
   if(userProfileName.contains('Mail Classified')||userProfileName.contains('Mail Display')||userProfileName.contains('MailOnline')||userProfileName.contains('System Administrator')){
				List<Task> newTasksToCreate=new List<Task>();
						
						ID contact;
						List<Opportunity> oppsWithTasks = new List<Opportunity>(); 
						List<Opportunity> oppsToUpdate = [Select id, IsNew__c, Amount, Loss_Reason__c, AutoTaskWonCreated__c, AutoTaskLostCreated__c, StageName, CloseDate, OwnerId, CampaignId, Type, (SELECT OpportunityId, ContactId FROM OpportunityContactRoles), (SELECT Id,OpportunityId,URN__c, Brand__c, UnitPrice, ServiceDate, Last_Insertion_Date__c, Description, Product_Name__c, Size__c FROM OpportunityLineItems) 
			       	 														from Opportunity Where Id IN :newopps];
			       	 	
			       	 	system.debug('oppsToUpdate:'+oppsToUpdate);
						for (Opportunity op1:oppsToUpdate) {
				          //Opportunity oldop = oldopps.get(op1.Id); 
						  String subject=''; 
						  String outcome=''; 
						  Double amount2=0;
						  Datetime myDatetime = op1.CloseDate;
						  String sCloseDate = myDatetime.format('dd/MM/yyyy');
						  //if (oldop.StageName!=op1.StageName) { 
				          if ((op1.StageName=='Closed Won' && op1.AutoTaskWonCreated__c==False)||(op1.StageName=='Closed Lost' && op1.AutoTaskLostCreated__c==False)) {
				        		amount2=op1.Amount;
				        		if (op1.StageName=='Closed Won'){
				        			if(userProfileName.contains('Mail Classified')){
										subject='Pitch for: £'+amount2+'.Closed Won Booked. Close Date: '+sCloseDate;
										outcome='Effective';
									}else if(userProfileName.contains('Mail Display')){
										subject='Pitch for: £'+amount2+'.Closed Won Booked. Close Date: '+sCloseDate;
										outcome='';
									}else if(userProfileName.contains('MailOnline')){
										subject='Pitch for: £'+amount2+'.Closed Won Booked. Close Date: '+sCloseDate;
										outcome='';
									}else{
										subject='Pitch for: £'+amount2+'.Closed Won Booked. Close Date: '+sCloseDate;
										outcome='Effective';	
									}
				        		}else if(op1.StageName=='Closed Lost') {
				        			if(userProfileName.contains('Mail Classified')){
										subject='Pitch for: £'+amount2+'.Closed Lost with Close Reason: '+op1.Loss_Reason__c+'. Close Date: '+sCloseDate;
										outcome='Ineffective';
									}else if(userProfileName.contains('Mail Display')){
										subject='Pitch for: £'+amount2+'.Closed Lost with Close Reason: '+op1.Loss_Reason__c+'. Close Date: '+sCloseDate;
										outcome='';
									}else if(userProfileName.contains('MailOnline')){
										subject='Pitch for: £'+amount2+'.Closed Lost with Close Reason: '+op1.Loss_Reason__c+'. Close Date: '+sCloseDate;
										outcome='';
									}else{
										subject='Pitch for: £'+amount2+'.Closed Lost with Close Reason: '+op1.Loss_Reason__c+'. Close Date: '+sCloseDate;
										outcome='Ineffective';	
									}
				        			
				        		}
								Double amount1=0;				        
								String description='';
								for(OpportunityLineItem opl1:op1.OpportunityLineItems){
									if(opl1.opportunityid==op1.id){
									Datetime myDatetime1 = opl1.ServiceDate;
									String sFirstInsertionDate = myDatetime1.format('dd/MM/yyyy');
									String sLastInsertionDate;
									 if (opl1.Last_Insertion_Date__c!=null){
                                        Datetime myDatetime2 = opl1.Last_Insertion_Date__c;
                                        sLastInsertionDate = myDatetime2.format('dd/MM/yyyy');
                                    }else {
                                       	sLastInsertionDate='null';
                                    }
									amount1=amount1+opl1.UnitPrice;
									if(opl1.description==''){
									if(userProfileName.contains('Mail Classified')){
										description='Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('Mail Display')){
										description='Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('MailOnline')){
										description='Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Last Insertion Date: '+sLastInsertionDate+' Description: '+opl1.Description;
									}else{
										description='Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;	
									}
									}else{
									if(userProfileName.contains('Mail Classified')){
										description=description+'\n'+'Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('Mail Display')){
										description=description+'\n'+'Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;
									}else if(userProfileName.contains('MailOnline')){
										description=description+'\n'+'Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Last Insertion Date: '+sLastInsertionDate+' Description: '+opl1.Description;
									}else{
										description=description+'\n'+'Product Name: '+opl1.Product_Name__c+' Sales Price: '+opl1.UnitPrice+' URN: '+opl1.urn__c+' Size: '+opl1.Size__c+' First Insertion Date: '+sFirstInsertionDate+' Description: '+opl1.Description;	
									}
									}
								}
								}
								system.debug('op1.OpportunityContactRoles:'+op1.OpportunityContactRoles);
								for(OpportunityContactRole opc1:op1.OpportunityContactRoles){
									if(opc1.opportunityid==op1.id){
										system.debug('opc1:'+contact);
										contact=opc1.ContactId;
									}
								}
								
								
								//WhoId=ocr.get(op1.id)[0].ContactId
								
								if (op1.CampaignId!=null){
									try {
										Task newTask = new Task(WhatId=op1.Id, Description=description, Strategic_Campaign__c=op1.CampaignId, Subject=subject, OwnerId=op1.OwnerId, Type__c=op1.Type, WhoId=contact, Status='Completed', Outcome__c=outcome, IsNew__c=op1.IsNew__c, ActivityDate=Date.today(), isReminderSet=true, reminderdatetime=DateTime.Now());
						              	newTasksToCreate.add(newTask);
						              	//op1.AutoTaskTypeCreated__c=op1.StageName;						              
						              	oppsWithTasks.add(op1);
						         	} catch(DmlException e) {
								
									}
								}else{
									try {
										Task newTask = new Task(WhatId=op1.Id, Description=description, Subject=subject, OwnerId=op1.OwnerId, Type__c=op1.Type, WhoId=contact, Status='Completed', Outcome__c=outcome, IsNew__c=op1.IsNew__c, ActivityDate=Date.today(), isReminderSet=true, reminderdatetime=DateTime.Now());
						              	newTasksToCreate.add(newTask);
						              	//op1.AutoTaskTypeCreated__c=op1.StageName;						              
						              	oppsWithTasks.add(op1);
						         	} catch(DmlException e) {
								
									}
									
								}
								
								}
						//}
						}
				        	if (newTasksToCreate.size()>0){
				        	insert newTasksToCreate;
				        	}
				        	if (oppsWithTasks.size()>0){
				        		for (Opportunity O1:oppsWithTasks){
				        			if (O1.StageName=='Closed Won'){
				        				O1.AutoTaskWonCreated__c=True;
				        			}else if(O1.StageName=='Closed Lost') {
				        				O1.AutoTaskLostCreated__c=True;
				        			}
				        	update oppsWithTasks;
				        	}
				}
   }
   }
   
   //////////////////////////////////////////////////////////////////////////////////////////
   
        		
}