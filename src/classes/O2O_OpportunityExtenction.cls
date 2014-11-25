public with sharing class O2O_OpportunityExtenction {
    OpportunityToOrder_BaseController currentController;
    /*Constructer for VF Extenction*/
    public O2O_OpportunityExtenction(OpportunityToOrder_BaseController controller) {
            currentController = controller;
    } 
    
/*Public Methods Includes actions for VF related to Opportunity*/
    
    /*get the related Advertisers*/
    public list<Selectoption> getOpportunity_Advertisers(){
        
        list<Selectoption> resultList = new list<SelectOption>();
        list<Relationship__c> relationshipsList = new list<Relationship__c>([Select Role__c, Name, Id, Active__c, Account_B__c, Account_A__c, 
                                                                                Account_B__r.Type, Account_A__r.Type, Account_B__r.Name, Account_A__r.Name,
                                                                                Account_B__r.RecordType.Name, Account_A__r.RecordType.Name  
                                                                                From Relationship__c
                                                                                WHERE ((Account_A__c =: currentController.currentOpp.Agency__c ) 
                                                                                OR (Account_B__c =: currentController.currentOpp.Agency__c))
                                                                                AND Active__c = true]);
        resultList.add(new SelectOption('000000000000000000', '-- None --'));
        for(Relationship__c rel : relationshipsList){
            if(rel.Account_A__c == currentController.currentOpp.Agency__c && rel.Account_B__r.recordType.Name.equalsIgnoreCase('Advertiser')){
                resultList.add(new SelectOption(rel.Account_B__c, rel.Account_B__r.Name +' -- '+rel.Account_B__r.Type));
            }
            if(rel.Account_B__c == currentController.currentOpp.AccountID && rel.Account_A__r.recordType.Name.equalsIgnoreCase('Advertiser')){
                resultList.add(new SelectOption(rel.Account_A__c, rel.Account_A__r.Name +' -- '+rel.Account_A__r.Type));
            }
        }
        /*//remove the firest element if the size is 2
        if(resultList.size() == 2){
            resultList.remove[0];
        }
        */ 
        return resultList;
    }
    
    /*get the related agencies*/
    public list<Selectoption> getOpportunity_Agencies(){
        set<String> accepactibaleTypes = new set<String> {'Direct Advertiser','Billing Agency','Charity','Private Advertiser','Brand','Booking Agency'};
        list<Selectoption> resultList = new list<SelectOption>();
        list<Relationship__c> relationshipsList = new list<Relationship__c>([Select Role__c, Name, Id, Active__c, Account_B__c, Account_A__c, 
                                                                                Account_B__r.Type, Account_A__r.Type, Account_B__r.Name, Account_A__r.Name  
                                                                                From Relationship__c
                                                                                WHERE ((Account_A__c =: currentController.currentOpp.AccountID ) 
                                                                                OR (Account_B__c =: currentController.currentOpp.AccountID))
                                                                                AND Active__c = true]);
        resultList.add(new SelectOption('000000000000000000', '-- None --'));
        for(Relationship__c rel : relationshipsList){
            if(rel.Account_A__c == currentController.currentOpp.AccountID && accepactibaleTypes.contains(rel.Account_B__r.Type)){
                resultList.add(new SelectOption(rel.Account_B__c, rel.Account_B__r.Name +' -- '+rel.Account_B__r.Type));
            }
            if(rel.Account_B__c == currentController.currentOpp.AccountID && accepactibaleTypes.contains(rel.Account_A__r.Type)){
                resultList.add(new SelectOption(rel.Account_A__c, rel.Account_A__r.Name +' -- '+rel.Account_A__r.Type));
            }
        }
        /*//remove the firest element if the size is 2
        if(resultList.size() == 2){
            resultList.remove[0];
        }
        */ 
        return resultList;
    }
    
    /*Validate and Save Opportunity*/
    public Pagereference saveOpportunity(){
        PageReference resultPage = null;
        Savepoint saveOpportunity = Database.setSavepoint();
        currentController.resetResultWrapper();
        //handel opportunity update
        try{
            if(currentController.currentOpp.AccountID == '000000000000000000'){
                currentController.currentOpp.AccountID = null;
            }
            if(currentController.currentOpp.Agency__c == '000000000000000000'){
                currentController.currentOpp.Agency__c = null;
            }
            validateOpportunity();
            if(currentController.hasMessages == true){
                currentController.handelErrorMessages();
                return null;
            }
            if(currentController.currentOpp.ID == null){
                resultPage = new Pagereference('/apex/OpportunityToOrder');
            }
            upsert currentController.currentOpp;
            if(resultPage!=null){
                resultPage.getParameters().put('oppId',currentController.currentOpp.ID);
                resultPage.setRedirect(true);
            }
            currentController.editOpp = false;
        }catch(Exception e){
                    Database.rollback(saveOpportunity);
                    currentController.hasMessages = true;
                    currentController.resultWrapper = new ResultWrapper(e, ApexPages.severity.ERROR);
                    currentController.handelErrorMessages();
                    return null;
        }
        
        //handel contact Role
        list<OpportunityContactRole> existingContactRoles;
        existingContactRoles = new list<OpportunityContactRole>([Select Role, OpportunityId, Id, ContactId, Contact.Name From OpportunityContactRole where ContactID=:currentController.contactRole.ContactID and OpportunityId=:currentController.currentOpp.ID and Role =: currentController.contactRole.Role]);
        if(existingContactRoles.size()>0){
            return null;//DO nothing 
        }else{
            currentController.contactRole.Id = null;
            currentController.contactRole.OpportunityID = currentController.currentOpp.ID;
            currentController.contactRole.IsPrimary = true;
        }
        try{
            upsert currentController.contactRole;
            Contact tempContact = [SELECT id, name, phone from Contact where Id=:currentController.contactRole.ContactID];
            currentController.currentOpp.Pitch_Contact_Name__c = tempContact.Name;
            currentController.currentOpp.Pitch_Contact_Phone__c = tempContact.Phone;
            currentController.currentOpp.Pitch_Contact_ID__c = tempContact.Id;
            update currentController.currentOpp;
            /* removing contact information from url paramaters as we will be storing this on opportunity
            if(resultPage!=null){
                resultPage.getParameters().put('conId',currentController.contactRole.ContactID);
                resultPage.setRedirect(true);
            }*/
        }catch(Exception ex){
            Database.rollback(saveOpportunity);
                    currentController.hasMessages = true;
                    currentController.resultWrapper = currentController.resultWrapper.addExceptionMessage(currentController.resultWrapper, ApexPages.severity.ERROR, ex);
                    currentController.handelErrorMessages();
                    return null;
        }
        currentController.editOpp = false;
        system.debug('***resultPage'+resultPage);
        return resultPage;      
    } 
    
    /* Delete Opportunity*/
    public Pagereference deleteOpportunity(){
        PageReference resultPage = null;
        try{
            delete currentController.currentOpp;
            resultPage = new Pagereference('/apex/OpportunityToOrder');
            resultPage.setRedirect(true);
            return resultPage;
        }catch(Exception e){
            // add Error message to VF
            string consoludatedMessge;
            String exceptionString = e.getMessage();
            if(exceptionString.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                consoludatedMessge = exceptionString.subString(exceptionString.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,'));
                consoludatedMessge = consoludatedMessge.replace('FIELD_CUSTOM_VALIDATION_EXCEPTION,','');
                consoludatedMessge = consoludatedMessge.replace(': []',''); 
            }else{
                consoludatedMessge = e.getMessage() +'.<br/> Please contact Administrator to resolve the above issue.';
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,consoludatedMessge));
            return null;
        }
    }
    
    public void editOpportunity(){
        currentController.editOpp = true;
    }
    
    public void cancelOpportunity(){
        currentController.resetResultWrapper();
        currentController.editOpp = false;
    }
/*--Public Methods--*/

/*Private Methods*/
    
    //Returns the Opportunity with all the necessory fields
    private Opportunity queryOpportunity(ID oppID){
        list<Opportunity> resultList; 
        resultList = new list<Opportunity> ([SELECT ID, Name, Account.Name, Account.Parent.ID, Account.CCIMailCustID__c, Account.CCIMetroCustID__c, AccountId, Agency__c, Agency__r.Name, 
                                                    Type, StageName, CloseDate, OwnerID, CampaignID, IsNew__c, Opportunity_Start_Date__c, Opportunity_End_Date__c, LastModifiedDate,
                                                    Estimated_Total_Opportunity_Value__c, Amount, Pitch_Contact_Phone__c, Pitch_Contact_Name__c, Pitch_Contact_ID__c, Agency__r.Parent.Id,
                                                    Agency__r.CCIMailCustID__c, Agency__r.CCIMetroCustID__c, Owner.Name, Agency__r.Parent.CCIMailCustID__c, Agency__r.Parent.CCIMetroCustID__c,
                                                    Account.Parent.CCIMailCustID__c, Account.Parent.CCIMetroCustID__c
                                                FROM Opportunity 
                                                WHERE ID=:oppID]);
        if(resultList.size() >= 1){
            return resultList[0];
        }else{
            currentController.hasMessages = true;
            currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.severity.ERROR, 'You do not have access to view the Opportunity Or Opportunity is Deleted.');
            currentController.handelErrorMessages();
            return null;
        }
    }
    
    /*validates the opportunity*/
    private void validateOpportunity(){
        // Validation 1
        // Either AccountID or Agency__c must be populated to save the opportnity.  
        if(currentController.currentOpp.AccountID == null && currentController.currentOpp.Agency__c == null){
            currentController.hasMessages = true;
            currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.Severity.ERROR, 'Either \'Client or Advertiser\' or \'Agency\' fields must to be entered.');
        }
        // Validation 2
        // If both AccountID, Agenecy__c are entered, both accounts need to be in a relationship of Any type
        if(currentController.currentOpp.AccountID != null && currentController.currentOpp.Agency__c != null){
            list<Relationship__c> relationshipsList = new list<Relationship__c>([Select Role__c, Name, Id, Active__c, Account_B__c, Account_A__c 
                                                                                    From Relationship__c
                                                                                    WHERE ((Account_A__c =: currentController.currentOpp.AccountID AND Account_B__c =: currentController.currentOpp.Agency__c) 
                                                                                    OR (Account_B__c =: currentController.currentOpp.AccountID  AND Account_A__c =: currentController.currentOpp.Agency__c))
                                                                                    AND Active__c = true]);
            if(relationshipsList == null || relationshipsList.size() == 0){
                currentController.hasMessages = true;
                currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.Severity.ERROR, 'Entered \'Client or Advertiser\' and \'Agency\' fields must be in atleast one active relationship.');
            }
        }
        // Validation 3 
        // Opportunity Start Date must be Less or Equal to Opportnity End Date
        if(currentController.currentOpp.Opportunity_Start_Date__c > currentController.currentOpp.Opportunity_End_Date__c){
            currentController.hasMessages = true;
            currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.Severity.ERROR, '\'Opportunity Start Date\' must be less or equal to \'Opportnity End Date\'');
        } 
        //Validation 4
        //At the time of creation of opportunity, validate that the opportunity start and end dates must be in future. This rule is not valid for editing of existing opportunities.
        if(currentController.currentOpp.id == null){
            if(currentController.currentOpp.Opportunity_Start_Date__c < Date.Today()){
                currentController.hasMessages = true;
                currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.Severity.ERROR, 'Opportunity Start Date can not be in past when creating an Opportunity');
            }
        }
        //Validation 5 
        //At any stage Opportunity Start Date must be greater than or equal to Opportunity Close Date.
        if(currentController.currentOpp.Opportunity_Start_Date__c < currentController.currentOpp.CloseDate){
            currentController.hasMessages = true;
            currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.Severity.ERROR, 'Opportunity Start Date must be greater or equal to Opportunity Close Date.');
        }
        //Validation 6 
        //At any stage Opportunity End Date must be greater than or equal to Opportunity Close Date.
        if(currentController.currentOpp.Opportunity_End_Date__c < currentController.currentOpp.CloseDate){
            currentController.hasMessages = true;
            currentController.resultWrapper = currentController.resultWrapper.addErrorMessage(currentController.resultWrapper, ApexPages.Severity.ERROR, 'Opportunity End Date must be greater or equal to Opportunity Close Date.');
        }
    }
    
    
    
/*--Private Methods--*/
}