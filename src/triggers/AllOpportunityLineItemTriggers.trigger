/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    This trigger is used for deactivating active Pitch Ideas.                       ****
****    If the Deactivate button (on Pitch Idea) is clicked than new                    ****
****    Inactive Pitch Idea gets created and all fields are populated with the values   ****
****    from the active Pitch Idea. Afterwards, newly created Inactive Pitch Idea       ****
****    is inserted and active Pitch Idea is deleted.                                   ****
****                                                                                    ****                                                    
****    Also, this trigger is used for sending notification emails.                     ****
****    Detailed description of this notifications can be found in the code.            ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/


trigger AllOpportunityLineItemTriggers on OpportunityLineItem (after delete, after insert, after undelete,
after update, before delete, before insert, before update) 
{


    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers       = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c)  
    {
        
        //#######################################################
        //################ After Update Trigger #################
        //#######################################################
        
        if (trigger.isAfter && ((trigger.isUpdate)||(trigger.isInsert)))    
        { 
            System.debug('afterUpdate: '+'YES');   
            List<OpportunityLineItem> newInactiveOppLineItems   = new List<OpportunityLineItem>();
            List<Inactive_Pitch_Idea__c> newIPIs                = new List<Inactive_Pitch_Idea__c>();
            // List<OpportunityLineItem> OLIsForDeletion            = new List<OpportunityLineItem>();
            Set<Id> OLIsForDeletion                             = new Set<Id>();
            
            Set<String> newInactiveOppLineItemIds               = new Set<String>(); 
            
            System.debug('trigger.new.size(): '+trigger.new.size());    
            for(integer i=0; i<trigger.new.size(); i++)
            {
        
                if(trigger.isUpdate && (trigger.new[i].Active__c == false && trigger.old[i].Active__c == true)) 
                {
                    newInactiveOppLineItemIds.add(trigger.new[i].Id);
                    OLIsForDeletion.add(trigger.new[i].Id);
                }
            }
            
            System.debug('newInactiveOppLineItemIds1: '+newInactiveOppLineItemIds);
            System.debug('OLIsForDeletion1: '+OLIsForDeletion);
            
            
            Map<Id, OpportunityLineItem> productOLI = new Map<Id, OpportunityLineItem>
                    ([
                    select id, PricebookEntry.Product2Id 
                    from OpportunityLineItem 
                    where id 
                    IN :trigger.newMap.keySet()
                    ]);
          
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
			
            for(OpportunityLineItem oli : trigger.newMap.values())
            {
          
                if (oli.Active__c == false && (newInactiveOppLineItemIds.contains(oli.id)))
                {
                	System.debug('>>>>>>>>>>>>>>>>> oli ' + oli);
                	Inactive_Pitch_Idea__c ipi  = new Inactive_Pitch_Idea__c();
                	for(ActivateDeActivatePitchSettings setting : pitchSettings){
                		if(!setting.inActiveField.equalsIgnoreCase('Product2__c') && !setting.inActiveField.equalsIgnoreCase('ProductCode__c')){
                			ipi.put(setting.inActiveField, oli.get(setting.lineField));
                		}
                	}
                	
                	ipi.Product2__c             = productOLI.get(oli.id).PricebookEntry.Product2Id;
                    
                    /*ipi.Active__c               = oli.Active__c;
                    ipi.Competitor_Title__c     = oli.Competitor_Title__c;
                    ipi.Cost__c                 = oli.UnitPrice;
                    ipi.CurrencyIsoCode         = oli.CurrencyIsoCode; 
                    ipi.Description__c          = oli.Description;
                    ipi.Discount__c             = oli.Discount;
                    ipi.ServiceDate__c          = oli.ServiceDate;
                    ipi.Last_Insertion_Date__c  = oli.Last_Insertion_Date__c;     
                    ipi.ListPrice__c            = oli.ListPrice;
                    ipi.Opportunity__c          = oli.OpportunityId; 
                    ipi.Other_Media_Used__c     = oli.Other_Media_Used__c;
                    ipi.Quantity__c             = oli.Quantity;
                    ipi.Product2__c             = productOLI.get(oli.id).PricebookEntry.Product2Id;
                    ipi.PriceBookEntryID__c     = oli.PricebookEntryId;
                    ipi.Reason_for_Inactive2__c = oli.Reason_for_Inactive2__c;
                    ipi.Revenue_Group__c        = oli.Revenue_Group__c;
                    ipi.ServiceDate__c          = oli.ServiceDate;
                    ipi.Subtotal__c             = oli.Subtotal;
                    ipi.UnitPrice__c            = oli.UnitPrice;
                    ipi.TotalPrice__c           = oli.TotalPrice;
                    ipi.Brand__c                = oli.Brand__c;
                    ipi.Color_Specification__c  = oli.Color_Specification__c;
                    ipi.Position__c             = oli.Position__c;
                    ipi.Region__c               = oli.Region__c;
                    ipi.Size__c                 = oli.Size__c;
                    ipi.Upweight__c             = oli.Upweight__c;
                    ipi.URN__c                  = oli.URN__c;    
                        */
                    System.debug('>>>>>>>>>>>>>>>>> ipi ' + ipi);
                    newIPIs.add(ipi);
                
                }
            }
            
            
            if(newIPIs.size() > 0) 
            {
                try { insert newIPIs; }
                catch(Exception e) { System.debug('>>>>>>>>>>> EXCEPTION!!!! ' + e); }
            }
            
            System.debug('newInactiveOppLineItemIds:'+newInactiveOppLineItemIds);
            if(newInactiveOppLineItemIds.size() > 0) 
            {
                
                // List<OpportunityLineItem> OLIsForDeletion = [select id from OpportunityLineItem where id in :newInactiveOppLineItemIds];              
                
                System.debug('newInactiveOppLineItemIds.size:'+newInactiveOppLineItemIds.size());
                System.debug('OLIsForDeletion:'+OLIsForDeletion);
                //try { delete OLIsForDeletion; }
                //catch(Exception e) { System.debug('>>>>>>>>>>> EXCEPTION!!!! ' + e); }
                ActivateDeactivatePitchIdeaController.deleteOpportunityLine(OLIsForDeletion);
            
            }
        }
        
        
        
        //#######################################################
        //################ After Insert Trigger #################
        //#######################################################
        
        if(trigger.isAfter && trigger.isInsert)
        {
            
            List <Messaging.SingleEmailMessage> emails          = new List <Messaging.SingleEmailMessage>();
                
            Set<String> opptyIdsSet                             = new Set<String>();
            Set<String> accntIds                                = new Set<String>();
            Set<String> pbeIds                                  = new Set<String>();
            
            Boolean sendAdvertiserToManagerEmail                = false;
            Boolean sendEmailToFinance                          = false;
            Boolean sendAgencyEmailToManager                    = false;
            Boolean isManager;
            
            String bookingSystemLabel;
            String managerName;
            String managerEmail;
            String managerPhone;
            String agencyAddressHTML;
            String agencyAddressPlainText;
            String contactDetailsHTML;
            String contactDetailsPlainText;
            String financeEmail;
            
            
            for(integer i=0; i<trigger.new.size(); i++)
            {
                opptyIdsSet.add(trigger.new[i].OpportunityId);
                pbeIds.add(trigger.new[i].PricebookEntryId);
            }
            
            
            //#
            //# Create and populate map of opportunities with all necessary details.
            //#
        
            Map<String, Opportunity> idOpptyMap = new Map<String, Opportunity>
                ([
                select  id, Name, Agency__c, Agency__r.Type,    Agency__r.Name, AccountId,              Account.Name, Owner.Name,
                        OwnerId, Owner.ProfileId,               Owner.ManagerId,                        Owner.Manager.Email, Owner.Manager.Name,  Owner.Manager.Phone,
                        Owner.Email, Owner.Phone,
                        Account.CustomerRef1__c,                Account.CustomerRef2__c,                Account.CustomerRef3__c, 
                        Account.CustomerRef4__c,                Account.CustomerRef5__c,               
                        Agency__r.BillingStreet,                Agency__r.BillingState,                 Agency__r.BillingPostalCode,
                        Agency__r.BillingCountry,               Agency__r.BillingCity,
                        Agency__r.Company_Registration__c, 
                        Agency__r.CustomerRef1__c,              Agency__r.CustomerRef2__c,              Agency__r.CustomerRef3__c,
                        Agency__r.CustomerRef4__c,              Agency__r.CustomerRef5__c,
                        Agency__r.CustomerRef1AgencyNotification__c,                                    Agency__r.CustomerRef2AgencyNotification__c,                
                        Agency__r.CustomerRef3AgencyNotification__c,                                    Agency__r.CustomerRef4AgencyNotification__c,                        
                        Agency__r.CustomerRef5AgencyNotification__c,
                        CustomerRef1AdvertiserNotification__c,  CustomerRef2AdvertiserNotification__c,  CustomerRef3AdvertiserNotification__c, 
                        CustomerRef4AdvertiserNotification__c,  CustomerRef5AdvertiserNotification__c,
                        CustomerRef1AgencyNotification__c,      CustomerRef2AgencyNotification__c,      CustomerRef3AgencyNotification__c, 
                        CustomerRef4AgencyNotification__c,      CustomerRef5AgencyNotification__c
                from Opportunity
                where id in : opptyIdsSet
                ]);
         
         
          
            /*for(Opportunity o : idOpptyMap.values()) 
                if(o.Agency__c != null) accntIds.add(o.Agency__c);*/


            //#
            //# Create and populate map of agencies with all necessary details.
            //#
            
            /*Map<String, Account> idAgencyAccountMap = new Map<String, Account>
                ([
                select  id, Name,
                        CustomerRef1AgencyNotification__c,      CustomerRef2AgencyNotification__c,      CustomerRef3AgencyNotification__c, 
                        CustomerRef4AgencyNotification__c,      CustomerRef5AgencyNotification__c
                from Account
                where id in : accntIds
                ]);*/
             Map<String, Account> idAgencyAccountMap = new Map<String, Account>();
             for(Opportunity o : idOpptyMap.values()) 
             {
                if(o.Agency__c != null)
                {
                    idAgencyAccountMap.put(o.Agency__c, new Account(Id=o.Agency__c, 
                                                                    Name=o.Agency__r.Name,
                                                                    CustomerRef1AgencyNotification__c=o.Agency__r.CustomerRef1AgencyNotification__c,
                                                                    CustomerRef2AgencyNotification__c=o.Agency__r.CustomerRef2AgencyNotification__c,
                                                                    CustomerRef3AgencyNotification__c=o.Agency__r.CustomerRef3AgencyNotification__c,
                                                                    CustomerRef4AgencyNotification__c=o.Agency__r.CustomerRef4AgencyNotification__c,
                                                                    CustomerRef5AgencyNotification__c=o.Agency__r.CustomerRef5AgencyNotification__c));
                }
             }
        
            //#
            //# Create and populate map of pricebook entries with all necessary details.
            //#
          
            Map<String, PricebookEntry> idPricebookEntryMap = new Map<String, PricebookEntry>
                ([
                select  id, Name, Product2Id, Product2.CustomerRef__c, Product2.CanUseRevenueSchedule
                from PricebookEntry
                where id in : pbeIds
                ]); 
            


            //#
            //# Loop through the list of inserted Opportunity Line Items
            //#
            
            for(integer i=0; i<trigger.new.size(); i++)
            {
                
                
                //#
                //# Fetch all necessary information for the current Opportunity Line Item
                //#
                
                Opportunity tmpOppty        = idOpptyMap.get(trigger.new[i].OpportunityId);
                PricebookEntry tmpPBE       = idPricebookEntryMap.get(trigger.new[i].PricebookEntryId);
                Account tmpAgencyAccount    = new Account();
                
                if (tmpOppty.Agency__c != null) tmpAgencyAccount = idAgencyAccountMap.get(tmpOppty.Agency__c);
                
                isManager                   = ConstantsH__c.getInstance(tmpOppty.Owner.ProfileId).IsManager__c;
                managerName                 = '';
                managerEmail                = '';
                managerPhone                = '';
                financeEmail                = '';
                
                System.debug('>>>>>>>>>>>>>> istmpOppty.Owner.ProfileIdManager ' + tmpOppty.Owner.ProfileId);
                System.debug('>>>>>>>>>>>>>> isManager ' + isManager);
                
                if (tmpOppty.Agency__r.BillingStreet        != null) agencyAddressHTML = tmpOppty.Agency__r.BillingStreet                           + '<br/>';
                if (tmpOppty.Agency__r.BillingCity          != null) agencyAddressHTML = agencyAddressHTML + tmpOppty.Agency__r.BillingCity         + '<br/>';
                if (tmpOppty.Agency__r.BillingPostalCode    != null) agencyAddressHTML = agencyAddressHTML + tmpOppty.Agency__r.BillingPostalCode   + '<br/>';
                if (tmpOppty.Agency__r.BillingCountry       != null) agencyAddressHTML = agencyAddressHTML + tmpOppty.Agency__r.BillingCountry      + '<br/>';
                
                
                if(isManager)
                {
                     managerName    = tmpOppty.Owner.Name;
                     managerEmail   = tmpOppty.Owner.Email;
                     managerPhone   = tmpOppty.Owner.Phone;
                     
                     contactDetailsHTML = '<br/> <br/> Please contact ' /*+ tmpOppty.Owner.Name + '\'s manager - '*/ + managerName + 
                            ' (email: ' + managerEmail + ', phone: ' + (managerPhone == null ? '' : managerPhone);
                }
                else if(tmpOppty.Owner.ManagerId != null) 
                {
                    managerName     = tmpOppty.Owner.Manager.Name;
                    managerEmail    = tmpOppty.Owner.Manager.Email;
                    managerPhone    = tmpOppty.Owner.Manager.Phone;
                    
                    contactDetailsHTML  = '<br/> <br/> Please contact ' + tmpOppty.Owner.Name + '\'s manager - ' + managerName + 
                            ' (email: ' + managerEmail + ', phone: ' + (managerPhone == null ? '' : managerPhone); 
                }   
                

                if (contactDetailsHTML != null) contactDetailsPlainText = contactDetailsHTML.replace('<br/>', '\n');
                if (agencyAddressHTML != null) agencyAddressPlainText   = agencyAddressHTML.replace('<br/>', '\n');
                
            
                if      (tmpPBE.Product2.CustomerRef__c == 'CustomerRef1') financeEmail = Constants__c.getInstance('All').CustomerRef1email__c;
                else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef2') financeEmail = Constants__c.getInstance('All').CustomerRef2email__c;
                else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef3') financeEmail = Constants__c.getInstance('All').CustomerRef3email__c;
                else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef4') financeEmail = Constants__c.getInstance('All').CustomerRef4email__c;
                else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef5') financeEmail = Constants__c.getInstance('All').CustomerRef5email__c;
            
                

                if(tmpPBE.Product2.CustomerRef__c != null)
                {
                
                    //###########################################################################################//
                    //#                                                                                         #//
                    //# if Agency is not null and Agency Type is ‘Billing Agency’                               #//
                    //#     - check if that account has CustomerRefX__c field populated                         #//
                    //#         - if not, than check whether the belonging CustomerRefXAgencyNotification__c    #//
                    //#           (on that Account) field is populated.                                         #//
                    //#             - if not, than send an email to Finance and populate this field with        #//
                    //#               current date/time                                                         #//
                    //#                 - finance email is found in Constant ‘All’ custom settings.             #//
                    //#                 - if a user who created this opportunity is a manager than we're using  #//
                    //#                   his name. If not, than we’ll use owners manager details               #//
                    //#                   (if we have that information).                                        #//
                    //#                     - If not - an email is not going to be sent and the field won't be  #//
                    //#                       populated.                                                        #//
                    //#                                                                                         #//
                    //#         - if not, than check whether the belonging CustomerRefXAgencyNotification__c    #//
                    //#           (on the Opportunity) field is populated                                       #//
                    //#             - if not, than send an email to opportunity’s owner manager and             #//
                    //#               populate this field with current date/time.                               #//
                    //#                 - if a user who created this opportunity is manager OR owner's          #//
                    //#                   managerId field is not populated, than an email is not going to be    #//
                    //#                   sent and the field won't be populated.                                #//
                    //#                                                                                         #//
                    //###########################################################################################//
                    
                    if (tmpOppty.Agency__c != null && tmpOppty.Agency__r.Type == 'Billing Agency')
                    {
                        
                        if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef1' && tmpOppty.Agency__r.CustomerRef1__c == null)
                        {
                            
                            if (tmpOppty.Agency__r.CustomerRef1AgencyNotification__c == null && managerName != '' && managerEmail != '')
                            {
                                tmpAgencyAccount.CustomerRef1AgencyNotification__c = datetime.now();
                                bookingSystemLabel = Account.CustomerRef1__c.getDescribe().getLabel();
                                sendEmailToFinance = true;
                            }
                            
                            
                            if (tmpOppty.CustomerRef1AgencyNotification__c == null && !isManager && managerEmail != '' && managerName != '')
                            {
                                tmpOppty.CustomerRef1AgencyNotification__c = datetime.now();
                                sendAgencyEmailToManager = true;
                            }
                        }
                        
                        
                        if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef2' && tmpOppty.Agency__r.CustomerRef2__c == null)
                        {
                            
                            if (tmpOppty.Agency__r.CustomerRef2AgencyNotification__c == null && managerName != '' && managerEmail != '')
                            {
                                tmpAgencyAccount.CustomerRef2AgencyNotification__c = datetime.now();
                                bookingSystemLabel = Account.CustomerRef2__c.getDescribe().getLabel();
                                sendEmailToFinance = true;
                            }
                            
                            
                            if (tmpOppty.CustomerRef2AgencyNotification__c == null && !isManager && managerEmail != '' && managerName != '')
                            {
                                tmpOppty.CustomerRef2AgencyNotification__c = datetime.now();
                                sendAgencyEmailToManager = true;
                            }
                        }
                        
                        
                        if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef3' && tmpOppty.Agency__r.CustomerRef3__c == null)
                        {
                            
                            if (tmpOppty.Agency__r.CustomerRef3AgencyNotification__c == null && managerName != '' && managerEmail != '')
                            {
                                tmpAgencyAccount.CustomerRef3AgencyNotification__c = datetime.now();
                                bookingSystemLabel = Account.CustomerRef3__c.getDescribe().getLabel();
                                sendEmailToFinance = true;
                            }
                            
                            
                            if (tmpOppty.CustomerRef3AgencyNotification__c == null && !isManager && managerEmail != '' && managerName != '')
                            {
                                tmpOppty.CustomerRef3AgencyNotification__c = datetime.now();
                                sendAgencyEmailToManager = true;
                            }
                        }
                        
                        
                        if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef4' && tmpOppty.Agency__r.CustomerRef4__c == null)
                        {
                            
                            if (tmpOppty.Agency__r.CustomerRef4AgencyNotification__c == null && managerName != '' && managerEmail != '')
                            {
                                tmpAgencyAccount.CustomerRef4AgencyNotification__c = datetime.now();
                                bookingSystemLabel = Account.CustomerRef4__c.getDescribe().getLabel();
                                sendEmailToFinance = true;
                            }
                            
                            
                            if (tmpOppty.CustomerRef4AgencyNotification__c == null && !isManager && managerEmail != '' && managerName != '')
                            {
                                tmpOppty.CustomerRef4AgencyNotification__c = datetime.now();
                                sendAgencyEmailToManager = true;
                            }
                        }
                        
                        
                        if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef5' && tmpOppty.Agency__r.CustomerRef5__c == null)
                        {
                            
                            if (tmpOppty.Agency__r.CustomerRef5AgencyNotification__c == null && managerName != '' && managerEmail != '')
                            {
                                tmpAgencyAccount.CustomerRef5AgencyNotification__c = datetime.now();
                                bookingSystemLabel = Account.CustomerRef5__c.getDescribe().getLabel();
                                sendEmailToFinance = true;
                            }
                            
                            
                            if (tmpOppty.CustomerRef5AgencyNotification__c == null && !isManager && managerEmail != '' && managerName != '')
                            {
                                tmpOppty.CustomerRef5AgencyNotification__c = datetime.now();
                                sendAgencyEmailToManager = true;
                            }
                        }
                    }
 

                    //###########################################################################################//
                    //#                                                                                         #//
                    //# check if Account CustomRefX__c field is populated                                       #//
                    //#     - if not, check whether the belonging CustomerRefXAdvertiserNotification__c         #//
                    //#       (on the Opportunity) field is populated                                           #//
                    //#         - if not, than send an email to opportunity’s owner manager and populate        #//
                    //#           CustomerRefXAdvertiserNotification__c field with current date/time.           #//
                    //#                 - if a user who created this opportunity is manager OR owner's          #//
                    //#                   managerId field is not populated, than an email is not going to be    #//
                    //#                   sent and the field won't be populated.                                #// 
                    //#                                                                                         #//
                    //###########################################################################################//
                
                    if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef1' && tmpOppty.Account.CustomerRef1__c == null)
                    {
                        if (tmpOppty.CustomerRef1AdvertiserNotification__c == null  && !isManager && managerEmail != '' && managerName != '')
                        {
                            tmpOppty.CustomerRef1AdvertiserNotification__c = datetime.now();
                            bookingSystemLabel = Account.CustomerRef1__c.getDescribe().getLabel();
                            sendAdvertiserToManagerEmail = true;
                        }
                    }
                    
                    
                    else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef2' && tmpOppty.Account.CustomerRef2__c == null)
                    {
                        if (tmpOppty.CustomerRef2AdvertiserNotification__c == null  && !isManager && managerEmail != '' && managerName != '')
                        {
                            tmpOppty.CustomerRef2AdvertiserNotification__c = datetime.now();
                            bookingSystemLabel = Account.CustomerRef2__c.getDescribe().getLabel();
                            sendAdvertiserToManagerEmail = true;
                        }
                    }
                    
                    
                    else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef3' &&  tmpOppty.Account.CustomerRef3__c == null )
                    {
                        if (tmpOppty.CustomerRef3AdvertiserNotification__c == null  && !isManager && managerEmail != '' && managerName != '')
                        {
                            tmpOppty.CustomerRef3AdvertiserNotification__c = datetime.now();
                            bookingSystemLabel = Account.CustomerRef3__c.getDescribe().getLabel();
                            sendAdvertiserToManagerEmail = true;
                        }
                    }
                    

                    else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef4' && tmpOppty.Account.CustomerRef4__c == null)
                    {
                        if (tmpOppty.CustomerRef4AdvertiserNotification__c == null  && !isManager && managerEmail != '' && managerName != '')
                        {
                            
                            tmpOppty.CustomerRef4AdvertiserNotification__c = datetime.now();
                            bookingSystemLabel = Account.CustomerRef4__c.getDescribe().getLabel();
                            sendAdvertiserToManagerEmail = true;
                        }
                    }
                    
                    
                    else if (tmpPBE.Product2.CustomerRef__c == 'CustomerRef5' && tmpOppty.Account.CustomerRef5__c == null)
                    {
                        if (tmpOppty.CustomerRef5AdvertiserNotification__c == null  && !isManager && managerEmail != '' && managerName != '')
                        {   
                            tmpOppty.CustomerRef5AdvertiserNotification__c = datetime.now();
                            bookingSystemLabel = Account.CustomerRef5__c.getDescribe().getLabel();
                            sendAdvertiserToManagerEmail = true;
                        }
                    }
                    
                    
                    //#
                    //# Create email messages
                    //#
                    
                    if (sendAdvertiserToManagerEmail)
                    {
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        
                        message.setSubject('CRM: ' + tmpOppty.Account.Name + ' needs ' + bookingSystemLabel + ' number');
                        
                        message.setHtmlBody('Opportunity <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) tmpOppty.Id + '">' + tmpOppty.Name + '</a> owned by ' + 
                            tmpOppty.Owner.Name + ', needs ' + bookingSystemLabel + 
                            ' populated on <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) tmpOppty.AccountId +'">' + tmpOppty.Account.Name + '</a>' + 
                            '. <br/>' + 'Make sure that this account doesn\'t already exist in ' + bookingSystemLabel + ' before creating it.');


                        message.setPlainTextBody('Opportunity "' + tmpOppty.Name + ' owned by ' + tmpOppty.Owner.Name + ', needs ' + bookingSystemLabel + ' populated on ' + 
                            tmpOppty.Account.Name + '. \n' + 
                            'Make sure that this account doesn\'t already exist in ' + bookingSystemLabel + ' before creating it.');
                            
                        message.setToAddresses(new List<String>{managerEmail});
                        emails.add(message);
                        sendAdvertiserToManagerEmail = false;

                    }
                    

                    if (sendAgencyEmailToManager)
                    {
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        
                        message.setSubject('CRM: ' + tmpOppty.Agency__r.Name + ' needs ' + bookingSystemLabel + ' number');
                        
                        message.setHtmlBody('Opportunity <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) tmpOppty.Id + '">' + tmpOppty.Name + '</a> owned by ' + 
                            tmpOppty.Owner.Name + ', needs ' + bookingSystemLabel + ' populated on ' + tmpOppty.Agency__r.Name + '. <br/>' + 
                            'Email has been sent to Group Finance (' + Constants__c.getInstance('All').CustomerRef1email__c + '). <br/>' + 
                            'Finance Department will contact you with Booking System ID which you need to enter on the Agency record');
                        
                        message.setPlainTextBody('Opportunity "' + tmpOppty.Name + '" owned by ' + tmpOppty.Owner.Name + ', needs ' + bookingSystemLabel + ' populated on ' + 
                            tmpOppty.Agency__r.Name + '.\n' +
                            'Email has been sent to Group Finance (' + Constants__c.getInstance('All').CustomerRef1email__c + '). \n' +
                            'Finance Department will contact you with Booking System ID which you need to enter on the Agency record');
                        
                        message.setToAddresses(new List<String>{managerEmail});
                        emails.add(message);
                        sendAgencyEmailToManager = false;

                    }
                    
                    
                    if (sendEmailToFinance)
                    {
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        
                        message.setSubject('CRM: ' + tmpOppty.Agency__r.Name + ' needs ' + bookingSystemLabel + ' number');
                        
                        message.setHtmlBody('Opportunity "' + tmpOppty.Name + '" owned by ' + tmpOppty.Owner.Name + 
                            ' (email: ' + tmpOppty.Owner.email + ', phone: ' + (tmpOppty.Owner.phone == null ? '' : tmpOppty.Owner.phone) + ')' +
                            ', needs ' + bookingSystemLabel + ' populated on ' + tmpOppty.Agency__r.Name + '.' +
                            '<br/> <br/> <b> Agency adress: </b> <br/>' + agencyAddressHTML + 
                            '<br/>  <b> Agency Registration number: </b> <br/>' + 
                                (tmpOppty.Agency__r.Company_Registration__c == null ? '' : (tmpOppty.Agency__r.Company_Registration__c + '<br/>')) + 
                            '<br/>  <b> Agency Booking fields: </b>' + 

                            '<br/>' + Account.CustomerRef1__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef1__c == null ? '' : tmpOppty.Agency__r.CustomerRef1__c) + 
                            '<br/>' + Account.CustomerRef2__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef2__c == null ? '' : tmpOppty.Agency__r.CustomerRef2__c) + 
                            '<br/>' + Account.CustomerRef3__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef3__c == null ? '' : tmpOppty.Agency__r.CustomerRef3__c) + 
                            '<br/>' + Account.CustomerRef4__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef4__c == null ? '' : tmpOppty.Agency__r.CustomerRef4__c) + 
                            '<br/>' + Account.CustomerRef5__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef5__c == null ? '' : tmpOppty.Agency__r.CustomerRef5__c) +    

                            contactDetailsHTML + ') after creating this agency in the ' + bookingSystemLabel + '.');
                        
            
                        message.setPlainTextBody('Opportunity "' + tmpOppty.Name + '" owned by ' + tmpOppty.Owner.Name + 
                            '(email: ' + tmpOppty.Owner.email + ', phone: ' + (tmpOppty.Owner.phone == null ? '' : tmpOppty.Owner.phone) + ')' +
                            ', needs ' + bookingSystemLabel + ' populated on ' + tmpOppty.Agency__r.Name + '.' + 
                            '\n \n Agency adress: \n' + agencyAddressPlainText + 
                            '\n Agency Registration number: \n' + 
                                (tmpOppty.Agency__r.Company_Registration__c == null ? '' : (tmpOppty.Agency__r.Company_Registration__c + '\n')) + 
                            '\n Agency Booking fields: ' + 
                            
                            '\n' + Account.CustomerRef1__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef1__c == null ? '' : tmpOppty.Agency__r.CustomerRef1__c) + 
                            '\n' + Account.CustomerRef2__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef2__c == null ? '' : tmpOppty.Agency__r.CustomerRef2__c) + 
                            '\n' + Account.CustomerRef3__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef3__c == null ? '' : tmpOppty.Agency__r.CustomerRef3__c) + 
                            '\n' + Account.CustomerRef4__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef4__c == null ? '' : tmpOppty.Agency__r.CustomerRef4__c) + 
                            '\n' + Account.CustomerRef5__c.getDescribe().getLabel() + ': ' + 
                                (tmpOppty.Agency__r.CustomerRef5__c == null ? '' : tmpOppty.Agency__r.CustomerRef5__c) +    
                            
                            contactDetailsPlainText + ') after creating this agency in the ' + bookingSystemLabel + '.');
                        
                        
                       // message.setToAddresses(new List<String>{Constants__c.getInstance('All').CustomerRef1email__c});
                        message.setToAddresses(new List<String>{financeEmail});
                        emails.add(message);
                        sendEmailToFinance = false;

                    }
                }   
            }

         
            
            //#
            //# Update opportunity and agency fields and send emails.
            //#
            
            if(!idOpptymap.values().isEmpty())
            {
                try
                {
                    update idOpptymap.values();
                }
                catch(Exception e1)
                {
                    trigger.new[0].adderror(e1.getMessage());
                }
            }
            if(!idAgencyAccountMap.values().isEmpty())
            {
                try
                {
                    update idAgencyAccountMap.values();
                }
                catch(Exception e2)
                {
                    trigger.new[0].adderror(e2.getMessage());
                }
            }
            if(!emails.isEmpty())
            {
                try
                {
                    Messaging.sendEmail(emails);
                }
                catch(Exception e3)
                {
                    trigger.new[0].adderror(e3.getMessage());
                }
            }
                   
            
        }
////////////////////////////////////////////////////////////////////////////////////////////////
         if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)) 
        {               
                //Set<Id> ProdsToUpdateIds = new Set<Id>();
                Map<ID,String> URNSearch = new Map<ID,String>();
                List<Opportunity> OppsToUpdate = new List<Opportunity>();
                List<OpportunityLineItem> alllines = new List<OpportunityLineItem>();
                
                for(OpportunityLineItem a: trigger.new) 
                {
                    
                    if(a.URN__c!=null&&((trigger.isupdate&& a.URN__c!= Trigger.oldMap.get(a.id).URN__c && a.active__c)|| trigger.isinsert))
                    {
                        alllines.add(a);   
                        //ProdsToUpdateIds.add(a.OpportunityId);                                             
                    }
                    //System.debug('***prodsToUpdate=' + ProdsToUpdateIds); 
                }
                /*List<OpportunityLineItem> alllines = [Select 
                                OpportunityId, URN__c From OpportunityLineItem
                             Where OpportunityId IN :ProdsToUpdateIds and URN__c!=Null]; */   
                                                 
                       System.debug('***alllines1=' + alllines);                                                                            
                   if (alllines.size()>0)
                   {
                        for(OpportunityLineItem r: alllines) 
                        {
                                                   
                          if (URNSearch.containsKey(r.OpportunityId))
                          {
                            String tempstr = URNSearch.get(r.OpportunityId);
                            URNSearch.Remove(r.OpportunityId);
                            URNSearch.put(r.OpportunityId,tempstr+':'+r.URN__c);
                          }else{
                             URNSearch.put(r.OpportunityId,r.URN__c);
                      
                          }  
                           
                        }
                        for(Id urs : URNSearch.keyset())
                        {
                            OppsToUpdate.add(new Opportunity(id=urs,URNSearchable__c=URNSearch.get(urs)));
                        }
                        
                        if (OppsToUpdate.size()>0)
                        {
                             update OppsToUpdate;
                        }
                       
                   }
       }
       
        ////////////////////////////////////////////////////////////////////////////////////////////////
        //
        //  After Insert trigger to recalculate revenue split for each opportunity line item
        //
        ////////////////////////////////////////////////////////////////////////////////////////////////                    
        
        if (trigger.isBefore)
        {
            /*if(trigger.isInsert || trigger.isUpdate){
                map<ID, list<OpportunityLineItem>> opportunityToOpportunityLinesMap = new map<id, list<OpportunityLineItem>>();
                                
                for(OpportunityLineItem oLI : trigger.new){
                    if(!opportunityToOpportunityLinesMap.containsKey(oLI.OpportunityID)){
                        opportunityToOpportunityLinesMap.put(oLI.OpportunityID, new list<OpportunityLineItem>() );
                    }
                    opportunityToOpportunityLinesMap.get(oLI.OpportunityID).add(oLI);
                }
                map<Id, Opportunity> currentOpportunityMap = new map<ID, Opportunity>([SELECT ID, Schedule_Identifier__c from Opportunity Where ID IN: opportunityToOpportunityLinesMap.keySet()]);
                for(ID oppId : opportunityToOpportunityLinesMap.keySet()){
                    system.debug('***Opp Schedule Identifier : '+currentOpportunityMap.get(oppID).Schedule_Identifier__c);
                    //update to default values if the Schedule Identifier of opportunity is blank
                    if(currentOpportunityMap.get(oppID).Schedule_Identifier__c == null || currentOpportunityMap.get(oppID).Schedule_Identifier__c == ''){
                        currentOpportunityMap.get(oppID).Schedule_Identifier__c = 'SCH-1';
                    }
                    for(OpportunityLineItem oLI : opportunityToOpportunityLinesMap.get(oppId)){
                        oLI.Schedule_Identifier__c = currentOpportunityMap.get(oppID).Schedule_Identifier__c;
                    }
                    //Increment the schedule identifier. 
                    String currentSI = currentOpportunityMap.get(oppID).Schedule_Identifier__c;
                    integer value = integer.valueof(currentSI.substring(currentSI.indexof('-')+1));
                    value++;
                    currentSI = 'SCH-'+value;
                    currentOpportunityMap.get(oppID).Schedule_Identifier__c = currentSI;
                }
                try{
                    update currentOpportunityMap.values();
                }catch(Exception ex){
                    trigger.new[0].addError(Common.handelExceptionMessage(ex.getMessage()));
                }
            }*/
            if(trigger.isInsert)
            {
                for(OpportunityLineItem opl:trigger.new)
                {
                    opl.Schedule_Count__c = 0;
                }               
            }
            else
            if (trigger.isUpdate)
            {           
                Map<Id, Decimal> scheduleCountMap = new Map<Id, Decimal>();
                List<AggregateResult> groupedResults = new List<AggregateResult>();
                System.debug('trigger.newmap.keySet():'+trigger.newmap.keySet());
                try
                {
                     groupedResults = [SELECT OpportunityLineItemId, Count(Id)
                                        FROM OpportunityLineItemSchedule
                                        WHERE OpportunityLineItemId in :trigger.newmap.keySet()
                                        GROUP BY OpportunityLineItemId];
                
                }
                catch(QueryException qe)
                {
                    
                }
                System.Debug('XXXX:'+groupedResults.Size());
                
                if (groupedResults.Size() > 0)
                {                
                    for (AggregateResult ar : groupedResults)  
                    {
                        scheduleCountMap.put((Id) ar.get('OpportunityLineItemId'), (decimal)(ar.get('expr0')));
                    }
                    for(OpportunityLineItem opl:trigger.new)
                    {
                        opl.Schedule_Count__c = scheduleCountMap.get(opl.Id);
                    }
                }
                else
                {
                    for(OpportunityLineItem opl:trigger.new)
                    {
                        opl.Schedule_Count__c = 0;
                    }
                }
            }
            /*
            for (integer y=0; y<trigger.new.size(); y++)
            {
                trigger.new[y].Schedule_Count__c = [select count() from OpportunityLineItemSchedule where OpportunityLineItemId = :trigger.new[y].Id];
                
            }
            */
        }
        Savepoint savepoint = Database.setSavePoint();
        
        if (trigger.isAfter && ((trigger.isInsert) || (trigger.isUpdate)))
        {
           Set<String> pbeIds = new Set<String>();
        
           for(integer i=0; i<trigger.new.size(); i++)
            {
                pbeIds.add(trigger.new[i].PricebookEntryId);
            }
            
           Map<String, PricebookEntry> idPricebookEntryMap = new Map<String, PricebookEntry>
                ([
                select  id, Name, Product2Id, Product2.CustomerRef__c, Product2.CanUseRevenueSchedule
                from PricebookEntry
                where id in : pbeIds
                ]); 
        
            Set<String> olisInsert = new Set<String>();
            Set<String> olisInsertSingle = new Set<String>();
            Set<String> olisUpdate = new Set<String>();
            System.Debug('---->RevenueScheduleProcessed: '+RevenueSchedule.recordProcessed);
            System.Debug('---->ProcessedIds: '+RevenueSchedule.processedIds);
                                              
            for (integer x=0; x<trigger.new.size(); x++)
            {                                                              
                System.Debug('---->FL: '+trigger.new[x].Description);
                
                if (!RevenueSchedule.processedIds.contains(trigger.new[x].Id))
                {   
                    //  if(trigger.new[x].HasRevenueSchedule||trigger.new[x].HasQuantitySchedule) // added to exclude products which are not revenue scheduled
                    System.Debug('---->CanUseRevenueSchedule: '+idPricebookEntryMap.get(trigger.new[x].PricebookEntryId).Product2.CanUseRevenueSchedule);
                    if (idPricebookEntryMap.get(trigger.new[x].PricebookEntryId).Product2.CanUseRevenueSchedule)
                    {                                                                   
                        if (trigger.new[x].Schedule_Revenue__c == 'Monthly')
                        {
                            if (trigger.isInsert && !RevenueSchedule.recordProcessed)
                            {
                                // List of Id's to which to add custom schedule
                                olisInsert.add(trigger.new[x].Id);                        
                                RevenueSchedule.processedIds.add(trigger.new[x].Id);
                                RevenueSchedule.recordProcessed = true;
                                
                                System.Debug('---->Custom Insert: '+trigger.new[x].Description);                        
                            }
                            else 
                            {                                                       
                                if (!RevenueSchedule.recordProcessed && trigger.isUpdate &&
                                ((trigger.new[x].ServiceDate != trigger.old[x].ServiceDate) ||
                                (trigger.new[x].Last_Insertion_Date__c != trigger.old[x].Last_Insertion_Date__c) ||                         
                                ((trigger.new[x].UnitPrice != trigger.old[x].UnitPrice) &&
                                (trigger.new[x].Schedule_Count__c == 0))
                                ))                                                      
                                {
                                    // List of Id's to update
                                    olisInsert.add(trigger.new[x].Id);
                                    olisUpdate.add(trigger.new[x].Id);
                                    RevenueSchedule.processedIds.add(trigger.new[x].Id);
                                    RevenueSchedule.recordProcessed = true;
                                    
                                    System.Debug('---->Custom Update: '+trigger.new[x].Description);                         
                                }
                            }
                        }
                        else
                        {                    
                            if (trigger.isInsert && !RevenueSchedule.recordProcessed)
                            {
                                // List of Id's to which to add a single schedule record
                                olisInsertSingle.add(trigger.new[x].Id);
                                RevenueSchedule.processedIds.add(trigger.new[x].Id);
                                RevenueSchedule.recordProcessed = true;
                                
                                System.Debug('---->Standard Insert: '+trigger.new[x].Description);
                                
                            }
                            else
                            {                        
                                if (!RevenueSchedule.recordProcessed && trigger.isUpdate &&
                                ((trigger.new[x].ServiceDate != trigger.old[x].ServiceDate) ||
                                (trigger.new[x].Last_Insertion_Date__c != trigger.old[x].Last_Insertion_Date__c) ||
                                ((trigger.new[x].UnitPrice != trigger.old[x].UnitPrice) &&
                                (trigger.new[x].Schedule_Count__c == 0))
                                ))                          
                                {
                                    // List of Id's to update
                                    olisInsertSingle.add(trigger.new[x].Id);
                                    olisUpdate.add(trigger.new[x].Id);
                                    RevenueSchedule.processedIds.add(trigger.new[x].Id);
                                    RevenueSchedule.recordProcessed = true;
                                    
                                    System.Debug('---->Standard Update: '+trigger.new[x].Description);                        
                                }
                            }
                        }
                        RevenueSchedule.recordProcessed = false;
                    }
                    continue;
                    System.Debug('---->Iterations: '+string.valueof(x));
                    System.Debug('---->Trigger Size: '+string.valueof(trigger.new.size()));           
                }
            }
                
            List<OpportunityLineItemSchedule> olisToDelete = new List<OpportunityLineItemSchedule>();
            
            // Get a list of revenue schedule lines to delete
            if (olisUpdate.size() > 0) {
                olisToDelete = [select id from OpportunityLineItemSchedule where OpportunityLineItemId IN :olisUpdate];                
            }
            // Insert new custom schedules
            List<OpportunityLineItemSchedule> customOlisToInsert = new List<OpportunityLineItemSchedule>();
            
            if (olisInsert.size() > 0)
            {
                // List<OpportunityLineItem> olisToInsert = [select id, ServiceDate, Last_Insertion_Date__c, UnitPrice from OpportunityLineItem where id IN :olisInsert];
                List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
                for(Id o:olisInsert)
                {
                    olisToInsert.add(trigger.newMap.get(o));
                }
                
                // Populate list with custom revenue schedule lines
                for (OpportunityLineItem o : olisToInsert)                
                {
                    if ((o.ServiceDate != null) && (o.Last_Insertion_Date__c != null) && ((o.UnitPrice != null) || (o.UnitPrice != 0.0)))
                    {                                            
                        RevenueSchedule rs = new RevenueSchedule();                    
                        List<RevenueSchedule.RevenueScheduleItem> rsi;
                        rsi = rs.generateSchedule(o.ServiceDate, o.Last_Insertion_Date__c, o.UnitPrice);
                        
                        for (integer j=0; j<rsi.size(); j++)
                        {
                            OpportunityLineItemSchedule olis = new OpportunityLineItemSchedule();
                            
                            olis.Description = rsi[j].scheduleMonth;                
                            olis.Revenue = rsi[j].scheduleAmount;
                            olis.ScheduleDate = rsi[j].scheduleDate;
                            olis.Type = 'Revenue';
                            olis.OpportunityLineItemId = o.Id;
                            
                            customOlisToInsert.add(olis);
                            
                            olis = null;
                        }
                    }
                }
            }
            
            if (olisInsertSingle.size() > 0) 
            {
                // List<OpportunityLineItem> olisToInsertSingle = [select id, ServiceDate, UnitPrice from OpportunityLineItem where id IN :olisInsertSingle];
                List<OpportunityLineItem> olisToInsertSingle = new List<OpportunityLineItem>();
                for(Id o:olisInsertSingle)
                {
                    olisToInsertSingle.add(trigger.newMap.get(o));
                }                
                // Populate list with standard revenus schedule lines
                for (OpportunityLineItem oSingles : olisToInsertSingle)
                {
                    OpportunityLineItemSchedule oliSingles = new OpportunityLineItemSchedule();
                    
                    oliSingles.Description = 'Revenue Amount';                
                    oliSingles.Revenue = oSingles.UnitPrice;
                    oliSingles.ScheduleDate = oSingles.ServiceDate;
                    oliSingles.Type = 'Revenue';
                    oliSingles.OpportunityLineItemId = oSingles.Id;
                    
                    customOlisToInsert.add(oliSingles);
                    
                    oliSingles = null;
                }
            }

            // Perform Delete operation on modified reveneue schedules
            if (olisToDelete.size() > 0)
            {
                try 
                { 
                    delete olisToDelete; 
                }
                catch (Exception e) 
                { 
                    System.Debug('---->Exception: '+e); 
                }
            }
            
            // perform revenue schedule insertsions
            if (customOlisToInsert.size() > 0)
            {
                try 
                {
                    System.debug('customOlisToInsert:'+customOlisToInsert);
                    insert customOlisToInsert;
                }
                catch (Exception e) 
                {
                    Database.rollback(savepoint);
                    System.Debug('---->Exception: '+e);
                }
            }            
        }    
            

    }
}