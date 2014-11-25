public with sharing class FinanceAccountTriggerMethods {
    public static void createCCIFinanceAccount(List < FinanceAccount__c > newFinAccList, Map < Id, FinanceAccount__c > oldFinAccMap, Boolean isInsert, Boolean isUpdate, Boolean isAfter) {
        if (isAfter && (isInsert || isUpdate)) {
            //List<Account> accList = new List<Account>();
            Set < Id > finIdSet = new Set < Id > ();
            for (FinanceAccount__c a: newFinAccList) {
                if (a.DoCCIInt__c && (isInsert || (isUpdate && !oldFinAccMap.get(a.Id).DoCCIInt__c))) {
                    finIdSet.add(a.Id);
                }

            }
            System.debug('finIdSet:' + finIdSet);
            if (finIdSet.size() > 0) {
                // We will enable this for Sprint 2. Commented so that I can get Sprint 1 out of the way. Sorry
                //CCIEuropeIntegration.createCCIFinanceAcc(finIdSet);
            }
        }
    }

    public static Boolean firstAttempt {
        get {
            if (firstAttempt == null) {
                firstAttempt = True;
            }
            return firstAttempt;
        }
        set;
    }

    //It updates name of Finance Account with this format Account Name-CompanyNamew
    public static void updateFinanceAccountName(List <FinanceAccount__c > newFinAccList, Boolean isInsert, Boolean isUpdate, Boolean isBefore) {
        if (isBefore && (isInsert || isUpdate)) {
        System.debug('Entered updateFinanceAccountName...');
            try {
                List < Id > coIds = new List < Id > ();
                List < Id > accIds = new List < Id > ();

                for (FinanceAccount__c a: newFinAccList) {
                    coIds.add(a.Company__c);
                    accIds.add(a.Account__c);
                }
                Map < Id, Company__c > coName = new Map < Id, Company__c > ([Select Name from Company__c where Id in : coIds]);

                Map < Id, Account > accName = new Map < Id, Account > ([Select Name, Type, Salutation__c, FirstName__c, BillingStreet, BillingPostalCode from Account where Id in : accIds]);
              
                for (FinanceAccount__c a: newFinAccList) {
                 if(accName.get(a.Account__c).Type == 'Private Advertiser'){
                     if(!String.IsBlank(accName.get(a.Account__c).Salutation__c))
                         a.Name = accName.get(a.Account__c).Salutation__c;
                     if(!String.isBlank(accName.get(a.Account__c).FirstName__c))
                         a.Name+=accName.get(a.Account__c).FirstName__c;
                     a.Name+=accName.get(a.Account__c).Name ;
                     if(!String.isBlank(accName.get(a.Account__c).BillingStreet))
                         a.Name+=accName.get(a.Account__c).BillingStreet;
                     if(!String.isBlank(accName.get(a.Account__c).BillingPostalCode))
                         a.Name+=accName.get(a.Account__c).BillingPostalCode;
                     a.Name=a.Name.length()>80?a.Name.substring(0,80):a.Name;
                    }
                 else{
                     a.Name=accName.get(a.Account__c).Name + '-' + coName.get(a.Company__c).Name;
                     a.Name=a.Name.length()>80?a.Name.substring(0,80):a.Name;
                     }
                     
                }
            } catch (Exception e) {
                System.debug('Error in updating Finnace Account Name');
            }
        }
    }


    public static void updateCCIFinanceAccount(List < FinanceAccount__c > newAccountList, Map < Id, FinanceAccount__c > oldAccountMap, Boolean isUpdate, Boolean isAfter) {
        System.debug('firstAttempt:' + firstAttempt);
        List<Id> acIds = new List<Id>();
        List<Id> activeAccs = new List<Id>();
        List<FinanceAccount__c> finAccsList = new List<FinanceAccount__c>();
        List<Account_Mapping__c> activeMappingList = new List<Account_Mapping__c>();
        if (firstAttempt || test.isRunningTest()) {
            map < Id, String > accMap = new map < ID, String > ();
            map < Id, String > oldAccMap = new map < ID, String > ();
            CCIFinanceAccountManager.firstAccountId = newAccountList[0].Id;
            System.debug('new Val:' + newAccountList);
            System.debug('old Val:' + oldAccountMap);
            //if(newAccountList.size()<10)
            //{
            if (isAfter && isUpdate) {
                for (FinanceAccount__c a: newAccountList) {

                    if ((a.DoCCIInt__c == true && oldAccountMap.get(a.id).DoCCIInt__c == false) && (a.SOP_ID__c != null && a.SOP_Source__c == 'CCI')) {

                        CCIAccountCreation.AccountInfo ai = new CCIAccountCreation.AccountInfo(a.Id, a.SOP_ID__c);
                        accMap.put(a.id, JSON.serialize(ai));
                        CCIAccountCreation.AccountInfo oldai = new CCIAccountCreation.AccountInfo(a.Id, a.SOP_ID__c);
                        oldAccMap.put(a.id, JSON.serialize(oldai));

                    }
                     if (a.CloseStatus__c== 'Dead'&& (oldAccountMap.get(a.id).CloseStatus__c== 'Live' || oldAccountMap.get(a.id).CloseStatus__c== 'Alive')) {

                            acIds.add(a.Account__c);

                    }
                }
                if (accMap.size() > 0 && !test.isRunningTest()) {
                    CCIFinanceAccountManager.getCCIAccount(accMap.values(), oldAccMap.values());
                }
                if(acIds.size()>0){
                    finAccsList= [Select Account__c from FinanceAccount__c where Account__c in :acIds and (CloseStatus__c='Live' or  CloseStatus__c='Alive')];
                    activeMappingList = [Select Account__c from Account_Mapping__c where Account__c=:acIds and Active__c=true  and (Source_System__c='CCI Mail' or Source_System__c='CCI Metro')];
                }
              for(FinanceAccount__c f:finAccsList){
                activeAccs .add(f.Account__c) ;
                }
            for(Account_Mapping__c a: activeMappingList ){
                activeAccs .add(a.Account__c) ;
                }
            List<Account> accsToUnlockList=[Select id,Status__c from Account where Id in :acIds and Id not in :activeAccs ];
            for(Account acc:accsToUnlockList){
                acc.Status__c='Unlocked';
            }
        
            upsert accsToUnlockList;
            }
            firstAttempt = false;
            //}
        }
    }


}