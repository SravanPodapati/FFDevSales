public with sharing class EventTriggerMethods 
{
	public static void sendEmail(List<Event> eventList)
	{
		
		String bta_prefix = Schema.SObjectType.Business_Team_Activity__c.getKeyPrefix();
		String opp_prefix = Schema.SObjectType.Opportunity.getKeyPrefix();
		
		Id taskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketing Task').getRecordTypeId();	
		
		Set<Id> btaIdSet = new Set<Id>();
		
		Set<Id> oppIdSet = new Set<Id>();
		
		for(Event ev:eventList)
		{
			if(ev.Do_you_require_marketing_info__c=='Yes'&&ev.Status__c!='Completed'&&ev.Status__c!='Cancelled'&&ev.EmailSent__c !=true)
			{
				/*if(ev.AccountId!=null)
				{
					accountSet.add(ev.AccountId);	
				}
				else
				{*/
					String whatId = ev.WhatId;
					System.debug('whatId:'+whatId);
					if(whatId.startswith(bta_prefix))
					{
						btaIdSet.add(ev.WhatId);
					}
					else 
					{
					   if (whatId.startswith(opp_prefix))
					   {
							oppIdSet.add(ev.WhatId);
					   }
					}
				//}			
			}
		}
		
		if(btaidSet.size()>0||oppIdSet.size()>0)
		{
		
		//	Map oventRecTypesByName = Event.SObjectType.getDescribe().getRecordTypeInfosByName();
			Id eventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Structured Sales Meeting').getRecordTypeId();		
			
			Id currentUserProfile = UserInfo.getProfileId();
			
			String profileName = [
									Select
										Name
									From Profile
									Where Id = :currentUserProfile
									].Name;	
			
			/*RecordType popmacRecordType = [Select 
												Id
											From RecordType
											Where DeveloperName = 'Structured_Sales_Meeting'
											And   SObjectType = 'Event'];*/
			String emailGroupName;
			String taskOwnerGroupName;
			if(profileName.contains('London Class')||profileName.contains('System'))
			{
				emailGroupName = 'LonClassMarketingEmailGroup';
				taskOwnerGroupName = 'LonClassTaskOwnerMarketingGroup';
			}
			else if(profileName.contains('Mail Class'))
			{
				emailgroupName = 'MailClassMarketingEmailGroup';
				taskOwnerGroupName = 'MailClassTaskOwnerMarketingGroup';
			}
			else if(profileName.contains('Mail Disp'))
			{
				emailgroupName = 'MailDisplayMarketingEmailGroup';
				taskOwnerGroupName = 'MailDisplayTaskOwnerMarketingGroup';
			}
			
			Set<String> groupSet = new Set<String>();
			groupSet.add(emailGroupName);
			groupSet.add(taskOwnerGroupName);
			
			Map<Id, Group> classGroupMap;
			
			try
			{
				classGroupMap = new Map<Id, Group>([Select
										DeveloperName
									  From Group
									  Where DeveloperName IN :groupSet]);
			}
			catch(QueryException e)
			
			{
				//return null;
				//trigger.new[0].adderror('Public Group '+groupName+' does not exist. Please inform your System Administrator.');
			}	
			
			Map<String,Id> groupMap = new Map<String, Id>();
			for(Group g:classGroupMap.Values())
			{
				groupMap.put(g.DeveloperName, g.Id);
			}				  
			System.debug('GroupMap:'+groupMap);
			List<GroupMember> classMemList = [Select
													UserOrGroupId,
													GroupId
												From GroupMember
												Where GroupId IN :classGroupMap.KeySet()
													];
			Map<Id, List<GroupMember>> groupMemberMap = new Map<Id, List<GroupMember>>();
			for(GroupMember m: classMemList)
			{
				if(groupMemberMap.containsKey(m.GroupId))
				{
					List<GroupMember> gList = new List<GroupMember>();
					gList = groupMemberMap.get(m.GroupId);
					gList.add(m);
					groupMemberMap.put(m.GroupId, gList);
				}
				else
				{
					List<GroupMember> gList = new List<GroupMember>();
					gList.add(m);
					groupMemberMap.put(m.GroupId, gList);
				}
			}
			Set<Id> accountSet = new Set<Id>();
			
			System.debug('groupMemberMap:'+groupMemberMap);
			System.debug('groupMemberMap.containsKey(groupMap.get(\'LonClassTaskOwnerMarketingGroup\'))'+groupMemberMap.containsKey(groupMap.get('LonClassTaskOwnerMarketingGroup')));
			System.debug('groupMemberMap.containsKey(groupMap.get(\'MailClassTaskOwnerMarketingGroup\'))'+groupMemberMap.containsKey(groupMap.get('MailClassTaskOwnerMarketingGroup')));
			Map<Id, Business_Team_Activity__c> btaMap;
			Map<Id, Opportunity> oppMap;
			
			if(btaIdSet.size()>0)
			{
				if(!groupMap.containsKey('LonClassTaskOwnerMarketingGroup')&&!groupMap.containsKey('MailClassTaskOwnerMarketingGroup')&&!groupMap.containsKey('MailDisplayTaskOwnerMarketingGroup'))
				{
					trigger.new[0].adderror('The group '+taskOwnerGroupName+' is missing. No email can be sent for Marketing Material preparation. Please inform your administrator.');
					return;
				}
				if(!groupMemberMap.containsKey(groupMap.get('LonClassTaskOwnerMarketingGroup'))&&!groupMemberMap.containsKey(groupMap.get('MailClassTaskOwnerMarketingGroup'))&&!groupMemberMap.containsKey(groupMap.get('MailDisplayTaskOwnerMarketingGroup')))
				{
					trigger.new[0].adderror('There are no members belonging to the group '+taskOwnerGroupName+'. No email can be sent for Marketing Material preparation. Please inform your administrator.');
					return;
				}
				
				btaMap = new Map<Id,Business_Team_Activity__c>([Select Account__c
																From Business_Team_Activity__c
																Where Id IN :btaIdSet]);
				for(Business_Team_Activity__c b:btaMap.Values())
				{
					accountSet.add(b.Account__c);
				}
			}
			else
			{

				if(!groupMap.containsKey('LonClassTaskOwnerMarketingGroup')&&!groupMap.containsKey('MailClassTaskOwnerMarketingGroup')&&!groupMap.containsKey('MailDisplayTaskOwnerMarketingGroup'))
				{
					trigger.new[0].adderror('The group '+taskOwnerGroupName+' is missing. No email can be sent for Marketing Material preparation. Please inform your administrator.');
					return;
				}
				if(!groupMemberMap.containsKey(groupMap.get('LonClassTaskOwnerMarketingGroup'))&&!groupMemberMap.containsKey(groupMap.get('MailClassTaskOwnerMarketingGroup'))&&!groupMemberMap.containsKey(groupMap.get('MailDisplayTaskOwnerMarketingGroup')))
				{
					trigger.new[0].adderror('There are no members belonging to the group '+taskOwnerGroupName+'. No email can be sent for Marketing Material preparation. Please inform your administrator.');
					return;
				}				
				if(oppIdSet.size()>0)
				{
					oppMap = new Map<Id, Opportunity>([Select AccountId
														From  Opportunity
														Where Id IN :oppIdSet
														]);
				for(Opportunity b:oppMap.Values())
				{
					accountSet.add(b.AccountId);
				}			
				}
			}
			
			System.debug('btaMap: '+btaMap);
	
			if(accountSet.size()>0)
			{
				
					// Get user and group key prefixes so we can test to see what the UserOrGroupId field contains
					String userType = Schema.SObjectType.User.getKeyPrefix();
					String groupType = Schema.SObjectType.Group.getKeyPrefix();
					Set<Id> userSet = new Set<Id>();
					for(GroupMember g:classMemList)
					{
						if (((String)g.UserOrGroupId).startsWith(userType))
						{
							userSet.add(g.UserOrGroupId);
						}
					}
			
					List<User> userList = [Select
												Email
											From User
											Where Id IN :userSet
											];
					System.debug('userList:'+userList);						
					List<String> emailAddresses = new List<String>();
					
					for(User u:userList)
					{
						System.debug('u.Email:'+u.Email);
						emailAddresses.add(u.Email);
						System.debug('u.Email after add:'+u.Email);
					}
					
					
					
					Map<Id,Account> accountMap = new Map<Id,Account>([Select Name
																		From Account
																		Where Id IN :accountSet]);
					
					System.debug('accountMap:'+accountMap);
			
					Messaging.reserveSingleEmailCapacity(5);
							
					// Now create a new list of single email message object 
							    
					List<Messaging.SingleEmailMessage> emailsToSendList = new List<Messaging.SingleEmailMessage>();
					
					String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
							
					List<Task> taskList = new List<Task>();
					// List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();																	
					for(Event ev:eventList)
					{
						if(ev.Do_you_require_marketing_info__c=='Yes'/*&&ev.RecordTypeId==eventRecTypeId*/)
						{						    						
			
								Id accId = ((String) ev.whatId).startswith(bta_prefix)?btaMap.get(ev.WhatId).Account__c:oppMap.get(ev.WhatId).AccountId;
								Id taskOwnerId;
								System.debug('groupMemberMap:'+groupMemberMap);
								List<GroupMember> gTaskOwnerList = groupMemberMap.get(groupMap.get(taskOwnerGroupName));
								taskOwnerId = gTaskOwnerList[0].UserOrGroupId;
								taskList.add(new Task(Subject='Marketing Material Required for: '+accountMap.get(accId).Name,
													  // Description ='Please prepare Marketing Material for: ' + accountMap.get(accId).Name +' By: '+ev.Deadline_for_Info__c+', Type of Event: '+ev.Type_of_Event__c+', Proposed Agenda: '+ ev.Proposed_Agenda__c+', Where/how often does Customer Advertise: '+ev.Where_How_Often_Does_Customer_Advertise__c+', Description: '+ev.Description,
													  Description='Please prepare Marketing Material for: ' + accountMap.get(accId).Name +' By: '+((datetime) ev.Deadline_for_Info__c).format('dd-MM-yyyy')+'\r\n\r\nAppointment Agenda\r\nType of Event: '+ev.Type_of_Event__c+'\r\nProposed Agenda: '+ ev.Proposed_Agenda__c+'\r\n\r\nMarketing Information'+'\r\nDescription: '+
	                            ev.Description+'\r\nWhere/how often does Customer Advertise: '+ev.Where_How_Often_Does_Customer_Advertise__c,
													  WhatId=ev.WhatId,
													  OwnerId=taskOwnerId,
													  RecordTypeId=taskRecTypeId,
													  ActivityDate=ev.Deadline_for_Info__c));
													  // OwnerId=userList[0].Id));	    
								
							//}
						    
						}
					}
					
					
					Map<Id,Id> taskEventMap = new Map<Id,Id>();
					if(taskList.size()>0)
					{
						System.debug('taskList:'+taskList);
						insert taskList;
						for(Task t:taskList)
						{
							taskEventMap.put(t.WhatId, t.Id);
						}
					}
					
					System.debug('************taskList:'+taskList);
	
					for(Event ev:eventList)
					{
						if(ev.Do_you_require_marketing_info__c=='Yes'/*&&ev.RecordTypeId==eventRecTypeId*/)
						{
							// First, reserve email capacity for the current Apex transaction to ensure 
							    
							// that we won't exceed our daily email limits when sending email after 
							    
							// the current transaction is committed. 
							    
							
			
							Messaging.SingleEmailMessage e = new Messaging.SingleEmailMessage();
							e.setToAddresses(emailAddresses);
	
								Id accId = ((String) ev.whatId).startswith(bta_prefix)?btaMap.get(ev.WhatId).Account__c:oppMap.get(ev.WhatId).AccountId;
								e.setSubject(ev.Subject+' for: '+accountMap.get(accId).Name+' By: '+((datetime) ev.Deadline_for_Info__c).format('dd-MM-yyyy'));
								e.setPlainTextBody('Please prepare Marketing Material for: '+accountMap.get(accId).Name+' By: '+((datetime) ev.Deadline_for_Info__c).format('dd-MM-yyyy'));
								e.setHtmlBody('Please prepare Marketing Material for: ' + accountMap.get(accId).Name +' By: '+((datetime) ev.Deadline_for_Info__c).format('dd-MM-yyyy')+'<br/><br/><b><u>Appointment Agenda</u></b><br/>Type of Event: '+ev.Type_of_Event__c+'<br/>Proposed Agenda: '+ ev.Proposed_Agenda__c+'<br/><br/><b><u>Marketing Information</b></u>'+'<br/>Description: '+
	                            ev.Description+'<br/>Where/how often does Customer Advertise: '+ev.Where_How_Often_Does_Customer_Advertise__c+
	                            '<br/><br/>To view the Task <a href='+fullRecordURL+taskEventMap.get(ev.WhatId)+'>click here.</a>');
								e.setUseSignature(false);
								emailsToSendList.add(e);
							    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { e });								 
								
							// }
						    
						}
					}
	
	
	
					// Send the email you have created. 
							    
					// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailsToSendList });	
			
				}
			}	
	  }
	
	}