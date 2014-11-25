public without sharing class AllAccountMappingTriggerMethods {

    private Boolean isExecuting = false;
    private Integer BatchSize = 0;

    // CONSTRUCTOR
    public AllAccountMappingTriggerMethods(Boolean isExecuting, Integer size) {
        isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterUpdate(Account_Mapping__c[] oldMappings, Account_Mapping__c[] updatedMappings, Map < ID, Account_Mapping__c > newMappingMap, Map < ID, Account_Mapping__c > oldMappingMap) {
        System.debug('Entered OnAfterUpdate....');
        List < Id > mappingIds = new List < Id > ();
        List < Id > acIds = new List < Id > ();
        List < String > cciIds = new List < String > ();
        Map < Id, String > accMap = new Map < Id, String > ();
        List<Id> activeAccIds = new List<Id>();
        

        for (Account_Mapping__c m: updatedMappings) {
            Account_Mapping__c oldMapping = oldMappingMap.get(m.id);
            if ((m.Source_System__c == 'CCI Mail' || m.Source_System__c == 'CCI Metro') && m.Active__c != oldMapping.Active__c) {
                AccountMappingInfo ai = new AccountMappingInfo(m.Id, m.Account__c, m.Source_Key__c, m.Source_System__c, m.active__c);
                accMap.put(m.id, JSON.serialize(ai));
                mappingIds.add(m.id) ;
                acIds.add(m.Account__c);
            }
        }
        if (accMap.size() > 0 && !test.isRunningTest()) {
            AllAccountMappingTriggerMethods.getCCIAccount(accMap.values());
        }
        
        List<FinanceAccount__c> finAccsList= [Select Account__c from FinanceAccount__c where Account__c in :acIds and (CloseStatus__c='Live' or CloseStatus__c='Alive')];
        List<Account_Mapping__c> activeMappingList = [Select Account__c from Account_Mapping__c where Account__c=:acIds and Active__c=true and (Source_System__c='CCI Mail' or Source_System__c='CCI Metro')];
        for(FinanceAccount__c f:finAccsList){
            activeAccIds.add(f.Account__c) ;
        }
        for(Account_Mapping__c a: activeMappingList ){
            activeAccIds.add(a.Account__c) ;
        }
        System.debug('Active accounts are'+ activeAccIds);
        List<Account> accsToLockList=[Select id,Status__c from Account where Id in :acIds and Id not in :activeAccIds];
        for(Account acc:accsToLockList){
            acc.Status__c='Unlocked';
        }
        
        upsert accsToLockList;

    }



    @future(callout = true)
    public static void getCCIAccount(List < String > mappingList) 
    {
        System.debug('Entered getCCIAccount in AllAccountMappingTriggerMethods...');
        List < AccountMappingInfo > firstMappingList = (List < AccountMappingInfo > ) JSON.deserialize('[' + mappingList[0] + ']', List < AccountMappingInfo > .class);

        try {

            set < Id > mappingIds = new set < ID > ();
            // System.debug(tokenInfo.access_token);
            Integer mappingSize = mappingList.Size();
            for (Integer i = 0; i < mappingSize; i++) {

                List < AccountMappingInfo > deserializedMappingList = (List < AccountMappingInfo > ) JSON.deserialize('[' + mappingList[i] + ']', List < AccountMappingInfo > .class);

                Boolean isMail;
                //   accountIds.add(deserializedMappingList[0].accountId);
                if (deserializedMappingList[0].sourcesystem == 'CCI Mail') {
                    isMail = true;
                } else if (deserializedMappingList[0].sourcesystem == 'CCI Metro') {
                    isMail = false;
                }

                System.debug('IsMail' + isMail);
                String customerJson = CCICustomerManager.getCustomerDataFromAccountMapping(deserializedMappingList[0], isMail);
                if (!String.isBlank(customerJson) && customerJson != null) {
                    CCICustomerManager.updateCustomerStatus(deserializedMappingList[0], customerJson, isMail);
                }
            }


        } catch (exception e) {
            system.debug('Exception in future handeler is : ' + e);
        } finally {
            if (Common.integLogs.size() > 0) {
                System.debug('Common.integLogs:' + Common.integLogs);
                insert Common.integLogs;
                /* List<String> integList = new List<String>();
            for(Integration_Logs__c integ:CCICustomerManager.integLogs)
            {
                CCICustomerWrapper.IntegInfo iInfo= new CCICustomerWrapper.IntegInfo(integ.source__c, integ.account__c, integ.description__c);
                integList.add(JSON.serialize(iInfo));
            }
            if(integList.Size()>0)
            {
                insertIntegLogs(integList);
            }*/
            }
            if (Common.chatterList.Size() > 0) {
                for (CCICustomerWrapper.ChatterInfo c: Common.chatterList) {
                    Common.addChatterFeedToObject(c.itemId, c.message);
                }
            }



        }
    }
    
    public static void updateCCIFieldsOnAccount(List<Account_Mapping__c> oldAccountMappingList)
    {
        // If a CCI Metro or a CCI Mail mapping is being deleted then the corresponding fields on the Account Record needs to be updated.
        Set<Id> cciMetroIdSet = new Set<Id>();
        Set<Id> cciMailIdSet = new Set<Id>();
        
        System.debug('oldAccountMappingList:'+oldAccountMappingList);
        
        for(Account_Mapping__c a:oldAccountMappingList)
        {
            if(a.Source_System__c=='CCI Metro')
            {
                cciMetroIdSet.add(a.Account__c);
            }
            else
            if(a.Source_System__c=='CCI Mail')
            {
                cciMailIdSet.add(a.Account__c);
            }
        }

        List<Account> accMailList = new List<Account>();
        List<Account> accMetroList = new List<Account>();

        for(Id i:cciMetroIdSet)
        {
            accMetroList.add(new Account(Id=i, CCIMetroCustID__c=null));
        }

        for(Id i:cciMailIdSet)
        {
            accMailList.add(new Account(Id=i, CCIMailCustID__c=null));
        }
        
        System.debug('accMailList:'+accMailList);
        System.debug('accMetroList:'+accMetroList);
        
        if(accMetroList.size()>0)
        {
            update accMetroList;
        }

        if(accMailList.size()>0)
        {
            update accMailList;
        }
    }
    

}