public with sharing class AccountTriggerMethods {
    public static Boolean firstAttempt {
        get {
            if (firstAttempt == null) {
                firstAttempt = True;
            }
            return firstAttempt;
        }
        set;
    }

    
    
    public static void reviewUpdateAccount(List<Account> newAccountList,Map<Id,Account> oldAccountMap){
        System.debug('Inside reviewUpdateAccount...');
        List<Id> validAccIds = new List<Id>();
        List<Account> validAcc = new List<Account>();
        List<Id> accWithLiveFinAcc = new List<Id>();
        for(Account a: newAccountList){
            if(a.Type=='Client'&&oldAccountMap.get(a.id).Type=='Direct Advertiser' && String.IsBlank(a.CCIMailCustId__c)&&String.IsBlank(a.CCIMetroCustId__c))  {
                validAccIds.add(a.id);
                validAcc.add(a) ;
            }
        }
      List<FinanceAccount__c> finAccsList = [Select id from FinanceAccount__c where Account__c in :validAccIds and CloseStatus__c='Live'];
     /* for(FinanceAccount__c f:finAccsList){
          accWithLiveFinAcc.add(f.Account__c) ;
      }*/
     if(finAccsList!=null && finAccsList.size()>0)
        newAccountList[0].addError(System.Label.ChangeTypeNotAllowedMsg);
        
            
    }
    
    public static void updateCCIAccount(List < Account > newAccountList, Map < Id, Account > oldAccountMap, Boolean isUpdate, Boolean isAfter) {
        System.debug('firstAttempt:' + firstAttempt);
        boolean totalSync = false;
        set<String> accountFieldAPINamesSet = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().KeySet();
        /********GAR-569 Start******/
        /*
         *Relacing the above statement with a custom label and 
         *Converting the set into a map of sets  
         *Map Keys => oldAccount Type Values
         *Map Value => set of strings that allowed new values Related to the old values. 
         *For Example consider A 'Client' can be changed into 'Brand' and 'Direct Advertiser' where as 'Brand' can only be coverted into a 'Client'
         *The lable for the above senario will be   Brand=>Client, 
                                                    Client=>Brand,
                                                    Client=>Direct Advertiser,
         *And the map will be as {Brand={Client}, Client={Brand, Direct Advertiser}}
         
        */
        map<String, set<String>> allowedFACreationVsTypeChange = new map<String, set<String>>();
        list<String> typeChengeVsFASettingsList = System.Label.Type_Change_Vs_Finance_Account_creation.split(',');
        for(String s: typeChengeVsFASettingsList){
            list<String> t = s.split('=>', 2);
            if(t.Size() == 2){
                String mapKey = t[0].trim();
                String mapVlaue = t[1].trim();
                if(mapVlaue.subString(mapVlaue.length()-1) == ','){
                    mapVlaue = mapVlaue.subString(0, mapVlaue.length()-1);
                    system.debug(mapVlaue);
                }
                if(!allowedFACreationVsTypeChange.containsKey(mapKey))
                    allowedFACreationVsTypeChange.put(mapKey, new set<String>());
                allowedFACreationVsTypeChange.get(mapKey).add(mapVlaue);
            }
        }
        system.debug('***allowedFACreationVsTypeChange : '+allowedFACreationVsTypeChange);
        /*Set<String> allowedTypeChange = new Set<String>{'Brand','Client'};
         *Relacing the above statement with a custom label and 
         *Converting the set into a map of sets  
         *Map Keys => oldAccount Type Values
         *Map Value => set of strings that allowed new values Related to the old values. 
         *For Example consider A 'Client' can be changed into 'Brand' and 'Direct Advertiser' where as 'Brand' can only be coverted into a 'Client'
         *The lable for the above senario will be   Brand=>Client, 
                                                    Client=>Brand,
                                                    Client=>Direct Advertiser,
         *And the map will be as {Brand={Client}, Client={Brand, Direct Advertiser}}
        */
        list<String> typeChengeSettingsList = System.Label.Allowed_Type_Change_Combinations.split(',');
        map<String, set<String>> allowedTypeChanges = new Map<String, set<String>>();
        for(String s: typeChengeSettingsList){
            list<String> t = s.split('=>', 2);
            if(t.Size() == 2){
                String mapKey = t[0].trim();
                String mapVlaue = t[1].trim();
                if(mapVlaue.subString(mapVlaue.length()-1) == ','){
                    mapVlaue = mapVlaue.subString(0, mapVlaue.length()-1);
                    system.debug(mapVlaue);
                }
                if(!allowedTypeChanges.containsKey(mapKey))
                    allowedTypeChanges.put(mapKey, new set<String>());
                allowedTypeChanges.get(mapKey).add(mapVlaue);
            }
        }
        
        system.debug('***allowedTypeChanges:'+allowedTypeChanges);

        
        if (firstAttempt || test.isRunningTest()) {
            map < Id, String > accMap = new map < ID, String > ();
            map < Id, String > oldAccMap = new map < ID, String > ();
            /*List<String> account = new List<String>();
            List<String> oldAccount = new List<String>();*/
            CCICustomerManager.firstAccountId = newAccountList[0].Id;
            System.debug('new Val:' + newAccountList);
            System.debug('old Val:' + oldAccountMap);
            //if(newAccountList.size()<10)
            //{
            map < Id, list < FinanceAccount__c >> newFinanceAccountsMap = new map < Id, list < FinanceAccount__c >> ();
            Company__c mailCompany = [SELECT ID from Company__c where name like '%Mail%'
            Limit 1];
            Company__c metroCompany = [SELECT ID from Company__c where name like '%Metro%'
            Limit 1];
            map < String, Integer > financeAccountMap = new map < String, Integer > ();
            list < FinanceAccount__c > financeAccountsToInsert = new list < FinanceAccount__c > ();
            if (isAfter && isUpdate) {
                for (FinanceAccount__c fA: [select id, Company__c, CCIMailCustomerID__c, CCIMetroCustomerID__c, Account__c, CloseStatus__c  from FinanceAccount__c where Account__c IN: oldAccountMap.keySet() and CloseStatus__c = 'Live']) {
                    if (fa.Company__c == mailCompany.id) {
                        if (!financeAccountMap.containsKey(fA.CCIMailCustomerID__c)) financeAccountMap.put(fA.CCIMailCustomerID__c, 0);
                        financeAccountMap.put(fA.CCIMailCustomerID__c, financeAccountMap.get(fA.CCIMailCustomerID__c) + 1);
                    }
                    if (fa.Company__c == metroCompany.id) {
                        if (!financeAccountMap.containsKey(fA.CCIMetroCustomerID__c)) financeAccountMap.put(fA.CCIMetroCustomerID__c, 0);
                        financeAccountMap.put(fA.CCIMetroCustomerID__c, financeAccountMap.get(fA.CCIMetroCustomerID__c) + 1);
                    }
                }
                
                for (Account a: newAccountList) {
                	//Gar-795
                	//Checking for a Live finance account if the type is changed from Brand / Client to Direct Advertiser. 
                	if((a.CCIMailCustID__c != null || a.CCIMetroCustID__c != null) && 
                		a.Type!=oldAccountMap.get(a.Id).Type && 
                		(oldAccountMap.get(a.Id).Type.equalsIgnoreCase('Brand') || oldAccountMap.get(a.Id).Type.equalsIgnoreCase('Client')) && 
                		a.Type.equalsIgnoreCase('Direct Advertiser')){
                			if(a.CCIMailCustID__c != null && a.CCIMailCustID__c != ''){
                				// check for finance account
		                		if(financeAccountMap.containsKey(a.CCIMailCustID__c) && financeAccountMap.get(a.CCIMailCustID__c) >= 1){
		                			a.addError('Can not change type to Direct Advertiser as a live Finance Account attached to this Account');
		                		}
                			}
                			if(a.CCIMetroCustID__c != null && a.CCIMetroCustID__c != ''){
                				// check for finance account
		                		if(financeAccountMap.containsKey(a.CCIMetroCustID__c) && financeAccountMap.get(a.CCIMetroCustID__c) >= 1){
		                			a.addError('Can not change type to Direct Advertiser as a live Finance Account attached to this Account');
		                		}
                			}
                	}
                    if ((a.CCIMailCustID__c != null || a.CCIMetroCustID__c != null) && 
                        (   a.Name != oldAccountMap.get(a.Id).Name || 
                            (a.Type!=oldAccountMap.get(a.Id).Type && 
                             allowedTypeChanges.containsKey(oldAccountMap.get(a.Id).Type) && 
                             allowedTypeChanges.get(oldAccountMap.get(a.Id).Type).contains(a.Type)
                            )|| 
                            a.Phone != oldAccountMap.get(a.Id).Phone || 
                            a.BillingStreet != oldAccountMap.get(a.Id).BillingStreet || 
                            a.BillingCity != oldAccountMap.get(a.Id).BillingCity || 
                            a.BillingPostalCode != oldAccountMap.get(a.Id).BillingPostalCode || 
                            a.BillingState != oldAccountMap.get(a.Id).BillingState || 
                            a.BillingCountry != oldAccountMap.get(a.Id).BillingCountry || 
                            a.Industry_Minor_Category__c != oldAccountMap.get(a.Id).Industry_Minor_Category__c || 
                            a.NPA__c != oldAccountMap.get(a.Id).NPA__c || 
                            a.Salutation__c != oldAccountMap.get(a.id).Salutation__c || 
                            a.FirstName__c != oldAccountMap.get(a.id).FirstName__c)) {
                                
                        CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(a.Id, a.Name, a.Phone, a.BillingStreet, a.BillingCity, a.BillingPostalCode, a.BillingState, a.BillingCountry, a.Industry_Minor_Category__c, a.CCIMailCustID__c, a.CCIMetroCustID__c, a.NPA__c, a.Type, a.FirstName__c, a.Salutation__c);
                        accMap.put(a.id, JSON.serialize(ai));
                        CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(a.Id, oldAccountMap.get(a.Id).Name, oldAccountMap.get(a.Id).Phone, oldAccountMap.get(a.Id).BillingStreet, oldAccountMap.get(a.Id).BillingCity, oldAccountMap.get(a.Id).BillingPostalCode, oldAccountMap.get(a.Id).BillingState, oldAccountMap.get(a.Id).BillingCountry, oldAccountMap.get(a.Id).Industry_Minor_Category__c, oldAccountMap.get(a.Id).CCIMailCustID__c, oldAccountMap.get(a.Id).CCIMetroCustID__c, oldAccountMap.get(a.Id).NPA__c, oldAccountMap.get(a.ID).Type, oldAccountMap.get(a.ID).FirstName__c, oldAccountMap.get(a.ID).Salutation__c);
                        oldAccMap.put(a.id, JSON.serialize(oldai));
                    }

                    if ((a.DoCCIInt__c == true && oldAccountMap.get(a.id).DoCCIInt__c == false) && (a.CCIMailCustID__c != null || a.CCIMetroCustID__c != null)) {

                        CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(a.Id, a.Name, a.Phone, a.BillingStreet, a.BillingCity, a.BillingPostalCode, a.BillingState, a.BillingCountry, a.Industry_Minor_Category__c, a.CCIMailCustID__c, a.CCIMetroCustID__c, a.NPA__c, a.Type, a.FirstName__c, a.Salutation__c);
                        accMap.put(a.id, JSON.serialize(ai));
                        CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(a.Id, oldAccountMap.get(a.Id).Name, oldAccountMap.get(a.Id).Phone, oldAccountMap.get(a.Id).BillingStreet, oldAccountMap.get(a.Id).BillingCity, oldAccountMap.get(a.Id).BillingPostalCode, oldAccountMap.get(a.Id).BillingState, oldAccountMap.get(a.Id).BillingCountry, oldAccountMap.get(a.Id).Industry_Minor_Category__c, oldAccountMap.get(a.Id).CCIMailCustID__c, oldAccountMap.get(a.Id).CCIMetroCustID__c, oldAccountMap.get(a.Id).NPA__c, oldAccountMap.get(a.ID).Type, oldAccountMap.get(a.ID).FirstName__c, oldAccountMap.get(a.ID).Salutation__c);
                        oldAccMap.put(a.id, JSON.serialize(oldai));
                        totalSync = true;
                    }

                    //if type changes from client/Brand to direct advertiser
                    /*removed as it is changed to config changes GAR-569
                    //if (a.Type != null && (a.Type.equalsIgnoreCase('Direct Advertiser') && (oldAccountMap.get(a.id).Type.equalsIgnoreCase('Client')))) {*/
                    /************GAR-569**************/
                    if(a.Type!=oldAccountMap.get(a.Id).Type && 
                         allowedFACreationVsTypeChange.containsKey(oldAccountMap.get(a.Id).Type) && 
                         allowedFACreationVsTypeChange.get(oldAccountMap.get(a.Id).Type).contains(a.Type)
                     ){
                        set<String> accountrequiredFields = new set<String>();
                        accountrequiredFields.addAll(System.Label.Finance_Account_Creation_Required_Fields_On_Account.split(','));
                        boolean createFinanaceAccount = true;
                        
                        for(String field : accountrequiredFields){
                            if(field != null && field != '' && accountFieldAPINamesSet.contains(field.toLowerCase())){
                                String tempField = (String) a.get(field);
                                if(string.isBlank(tempField)){
                                    createFinanaceAccount = false;
                                    break;
                                }
                            }
                        }
                        if(createFinanaceAccount){
                            if (a.CCIMailCustID__c != null && a.CCIMailCustID__c != '') {
                                if (!(financeAccountMap.containsKey(a.CCIMailCustID__c) && financeAccountMap.get(a.CCIMailCustID__c) > 0)) {
                                    FinanceAccount__c newFinAcc = new FinanceAccount__c();
                                    newFinAcc.Account__c = a.Id;
                                    newFinAcc.Company__c = mailCompany.id;
                                    financeAccountsToInsert.add(newFinAcc);
                                    if (!newFinanceAccountsMap.containsKey(a.id)) {
                                        newFinanceAccountsMap.put(a.id, new list < FinanceAccount__c > ());
                                    }
                                    newFinanceAccountsMap.get(a.id).add(newFinAcc);
                                }
                            }
                            if (a.CCIMetroCustID__c != null && a.CCIMetroCustID__c != '') {
                                if (!(financeAccountMap.containsKey(a.CCIMetroCustID__c) && financeAccountMap.get(a.CCIMetroCustID__c) > 0)) {
                                    FinanceAccount__c newFinAcc = new FinanceAccount__c();
                                    newFinAcc.Account__c = a.Id;
                                    newFinAcc.Company__c = metroCompany.id;
                                    financeAccountsToInsert.add(newFinAcc);
                                    if (!newFinanceAccountsMap.containsKey(a.id)) {
                                        newFinanceAccountsMap.put(a.id, new list < FinanceAccount__c > ());
                                    }
                                    newFinanceAccountsMap.get(a.id).add(newFinAcc);
                                }
                            }
                        }
                    }
                }
                if (financeAccountsToInsert.size() > 0) {
                    insert financeAccountsToInsert;
                }

                if (accMap.size() > 0 && !test.isRunningTest()) {
                    CCICustomerWebService.getCCIAccount(accMap.values(), oldAccMap.values(), totalSync);
                }
                for (FinanceAccount__c fA: financeAccountsToInsert) {
                    CCIAccountWebService.createFutureCCIAccount(fA.id, false);
                }
            }
            firstAttempt = false;
            //}
        }
    }


    /*@future(callout=true)
    public static void getCCIAccount(List<String> accountList, List<String> oldAccountList)
    {
        CCICustomerWrapper.AccessToken tokenInfo = AccountTriggerMethods.getCCIToken();
        System.debug(tokenInfo.access_token);
        Integer accSize = accountList.Size();
        for(Integer i=0;i< accSize;i++)
        {

            List<CCICustomerWrapper.AccountInfo> deserializedAccountList = 
                    (List<CCICustomerWrapper.AccountInfo>)JSON.deserialize('['+accountList[i]+']', List<CCICustomerWrapper.AccountInfo>.class);

            List<CCICustomerWrapper.AccountInfo> deserializedOldAccountList = 
                    (List<CCICustomerWrapper.AccountInfo>)JSON.deserialize('['+oldAccountList[i]+']', List<CCICustomerWrapper.AccountInfo>.class);

            String customerJson = getCustomerData(deserializedAccountList[i], deserializedOldAccountList[0], tokenInfo);

            updateCustomerData(deserializedAccountList[0], deserializedOldAccountList[i], customerJson, tokenInfo);
        }       
        if(integLogs.size()>0)
        {
            insert integLogs;
        }
    }*/

    /*private static void updateCustomerData(CCICustomerWrapper.AccountInfo acc, CCICustomerWrapper.AccountInfo oldAcc, String customer, CCICustomerWrapper.AccessToken tokenInfo)
    {


        //Map<String, Object> customerMap = (Map<String, Object>) JSON.deserializeUntyped(customer);

        //System.debug('customerMap:'+customerMap);
        Boolean accountNameChange=false;
        Boolean phoneChange=false;
        Boolean billingStreetChange=false;
        Boolean billingCityChange=false;
        Boolean billingPostalCodeChange=false;
        Boolean industryMinorCategoryChange=false;

        if(acc.name!=oldacc.name)
        {
            //customer = customer.replace('"companyName":"'+customerMap.get('companyName')+'"', '"companyName":"'+acc.name+'"');
            //customerMap.put('companyName','companyName : "'+acc.Name+'",');
            customer = customer.substring(0,customer.indexOf('"companyName"'))+'"companyName" : "'+acc.name+'",'+customer.substring(customer.indexOf('presentationName')-1);
            accountNameChange=true;
        }

        if(acc.phone!=oldacc.phone)
        {
            // customer = customer.replace('"companyName":"'+customerMap.get('companyName')+'"', '"companyName":"'+acc.name+'"');
            //System.debug('mainTelephone:- '+customerMap.get('mainTelephone'));
            //String mainTelephone = String.valueOf(customerMap.get('mainTelephone'));
            //String newMainTelephone = mainTelephone.substring(0,mainTelephone.indexOf('number')) +'number: "'+acc.phone+','+mainTelephone.Substring(mainTelephone.indexOf('description'));

            //customerMap.put('mainTelephone',newMainTelephone);
            String newCustomerStr1 = customer.substring(0,customer.indexOf('"mainTelephone"'));
            String newCustomerStr2 = customer.substring(customer.indexOf('"mainTelephone"'));
            newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"number"'))+'"number" :"'+acc.phone+'",'+newCustomerStr2.substring(newCustomerStr2.indexOf('"description"'));
            newCustomerStr1+=newCustomerStr2;

            customer = newCustomerStr1;         
            phoneChange=true;

        }

        if(acc.BillingStreet!=oldacc.BillingStreet)
        {
            String newCustomerStr1 = customer.substring(0,customer.indexOf('"mainAddress"'));
            String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
            newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"streetAddress"'))+'"streetAddress" :"'+acc.BillingStreet+'",'+newCustomerStr2.substring(newCustomerStr2.indexOf('"floorNo"'));
            newCustomerStr1+=newCustomerStr2;

            customer = newCustomerStr1; 
            
            billingStreetChange=true;                   

        }

        if(acc.BillingCity!=oldacc.BillingCity)
        {
            String newCustomerStr1 = customer.substring(0,customer.indexOf('"mainAddress"'));
            String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
            newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"city"'))+'"city" :"'+acc.BillingCity+'",'+newCustomerStr2.substring(newCustomerStr2.indexOf('"extraCity"'));
            newCustomerStr1+=newCustomerStr2;

            customer = newCustomerStr1; 
            
            billingCityChange=true;                 

        }

        if(acc.BillingPostalCode!=oldacc.BillingPostalCode)
        {
            String newCustomerStr1 = customer.substring(0,customer.indexOf('"mainAddress"'));
            String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
            newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"zipCode"'))+'"zipCode" :"'+acc.BillingPostalCode+'",'+newCustomerStr2.substring(newCustomerStr2.indexOf('"stateCode"'));
            newCustomerStr1+=newCustomerStr2;

            customer = newCustomerStr1;   
            
            billingPostalCodeChange=true;           

        }       

        if(acc.industry_Minor_Category!=oldacc.industry_Minor_Category)
        {
            String newCustomerStr1 = customer.substring(0,customer.indexOf('"industryCode"'));
            String newCustomerStr2 = customer.substring(customer.indexOf('"industryCode"'));
            String IndustryMinorCategory = (!String.isBlank(acc.industry_Minor_Category)?acc.industry_Minor_Category.split('-')[0].trim():'');
            newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"code"'))+'"code" :"'+IndustryMinorCategory+'",'+newCustomerStr2.substring(newCustomerStr2.indexOf('"description"'));
            newCustomerStr1+=newCustomerStr2;

            customer = newCustomerStr1;     
            
            industryMinorCategoryChange=true;               

        }

        system.debug('Updated customer :'+customer);


        String endpointUrl = cci.Domain__c+cci.CustomerPath__c+'/'+acc.cciMailId;

        System.debug('endpointUrl:'+endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();  
        //set method  
        req.setMethod('PUT'); 
        req.setHeader('Content-Type', cci.ContentType__c);

        // req.setBody(JSON.serialize(customerMap.values()));

        req.setBody(customer);
        req.setHeader('x-cci-user', userInfo.CCI_User_Id__c);
        req.setHeader('x-cci-profile', 'System Administrator');
        req.setHeader('x-cci-group', 'Systems Support');
        req.setHeader('Authorization', tokenInfo.token_type +' '+tokenInfo.access_token);   

        req.setEndpoint(endpointUrl);
        HTTPResponse res = new HTTPResponse();
        try
        {
            res = http.send(req); 
        }
        catch(System.CalloutException e) 
        {
            System.debug('*****'+e.getMessage());
        } 

        System.debug(String.ValueOf(res)==null?null:res.getBody());     

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200))
        {
        
            Common.addChatterFeedToObject(acc.accountId, 'Account has failed to update the following in CCI '+(accountNameChange?'Account':null)+(phoneChange?', Phone':null)+(billingStreetChange?', Billing Street':null)+(billingCityChange?', Billing City':null)+(billingPostalCodeChange?', Billing Postal Code':null)+(industryMinorCategoryChange?', Industry Minor Code':null));
            Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI',
                    Account__c = acc.accountId,
                    Description__c = 'Account has failed to update the following in CCI '+(accountNameChange?'Account':null)+(phoneChange?', Phone':null)+(billingStreetChange?', Billing Street':null)+(billingCityChange?', Billing City':null)+(billingPostalCodeChange?', Billing Postal Code':null)+(industryMinorCategoryChange?', Industry Minor Code':null),
                    Exception__c = res.getBody(),
                    Status__c = 'Failure'
                    );
            integLogs.add(intL);            
        }
        else
        {
            System.debug('Update Customer:'+res.getBody());
            Common.addChatterFeedToObject(acc.accountId, 'Account has been updated successfully in CCI.');
            Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI',
                    Account__c = acc.accountId,
                    Description__c = 'Account has been updated successfully in CCI.',
                    Status__c = 'Success'
                    );
            integLogs.add(intL);
        }       

    }*/
    /*
    private static String getCustomerData(CCICustomerWrapper.AccountInfo account, CCICustomerWrapper.AccountInfo oldAccount, CCICustomerWrapper.AccessToken tokenInfo)
    {
        System.debug('Account:'+account);

        String endpointUrl = cci.Domain__c+cci.CustomerPath__c+'/'+account.cciMailId;

        System.debug('endpointUrl:'+endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();  
        //set method  
        req.setMethod('GET'); 

        // req.setHeader('Content-Type', cci.ContentType__c);

        req.setHeader('x-cci-user', userInfo.CCI_User_Id__c);
        req.setHeader('x-cci-profile', userInfo.CCI_Profile__c);
        req.setHeader('x-cci-group', userInfo.CCI_Group_Id__c);
        req.setHeader('Authorization', tokenInfo.token_type +' '+tokenInfo.access_token);


        req.setEndpoint(endpointUrl);
        HTTPResponse res = new HTTPResponse();
        try
        {
            res = http.send(req); 
        }
        catch(System.CalloutException e) 
        {
            Common.addChatterFeedToObject(account.accountId, 'Failed to connect to CCI.');
            Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI',
                    Account__c = account.accountId,
                    Description__c = 'Failed to connect to CCI.',
                    Exception__c = res.getBody(),
                    Status__c = 'Failure'
                    );
            integLogs.add(intL);
            System.debug('*****'+e.getMessage());
        } 

        System.debug('getCustomerData res:'+String.ValueOf(res)==null?null:res.getBody());      

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200))
        {
            Common.addChatterFeedToObject(account.accountId, 'Failed to get CCI Customer data.');
            Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI',
                    Account__c = account.accountId,
                    Description__c = 'Failed to get CCI Customer data.',
                    Exception__c = res.getBody(),
                    Status__c = 'Failure'
                    );
            integLogs.add(intL);
            return null;

        }
        else
        {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('responseMap:'+responseMap);

            System.debug('responseMap.keyset:'+responseMap.keyset());   


            /*String jsonStr = '['+res.getBody()+']';
            JSONParser parser = JSON.createParser(jsonStr);
            List<AccessToken> deserializedContent = 
            (List<AccessToken>)JSON.deserialize(jsonStr, List<AccessToken>.class);

            //return deserializedContent[0];    
            return res.getBody();       
        }       
    }
    
    private static CCICustomerWrapper.AccessToken getCCIToken()
    {
        // BookingSystemSettings__c cci = BookingSystemSettings__c.getInstance('CCI');
        String endpointUrl = cci.Domain__c+cci.AuthenticationPath__c;
        // String endpointUrl = cci.TempDomain__c+cci.AuthenticationPath__c;
        endpointUrl=endpointUrl.replace('<username>', userInfo.CCI_User_Id__c);
        endpointUrl=endpointUrl.replace('<password>', userInfo.CCI_User_Password__c);

        System.debug('endpointUrl:'+endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();  
        //set method  
        req.setMethod('GET');   
        req.setHeader('Content-Type', cci.ContentType__c);
        req.setEndpoint(endpointUrl);
        HTTPResponse res = new HTTPResponse();
        try
        {
            res = http.send(req); 
        }
        catch(System.CalloutException e) 
        {
            System.debug('*****'+e.getMessage());
        } 

        System.debug('Get Token:'+String.ValueOf(res)==null?null:res.getBody());        

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200))
        {
            Common.addChatterFeedToObject(firstAccountId, 'Failed to get CCI Token.');
            Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI',
                    Account__c = firstAccountId,
                    Description__c = 'Failed to get CCI Token.',
                    Exception__c = res.getBody(),
                    Status__c = 'Failure'
                    );
            integLogs.add(intL);
            return null;

        }
        else
        {
            String jsonStr = '['+res.getBody()+']';
            //JSONParser parser = JSON.createParser(jsonStr);
            List<CCICustomerWrapper.AccessToken> deserializedContent = 
                    (List<CCICustomerWrapper.AccessToken>)JSON.deserialize(jsonStr, List<CCICustomerWrapper.AccessToken>.class);

            return deserializedContent[0];          
        }

    }*/

    /*private class AccountInfo
    {
        private Id accountId {get; set;}
        private String name {get; set;}
        private String phone {get; set;}
        private String billingStreet {get; set;}
        private String billingCity {get; set;}
        private String billingPostalCode {get; set;}
        private String industry_Minor_Category {get; set;}
        private String cciMailId {get; set;}
        private String cciMetroId {get; set;}

        private AccountInfo(Id accId, String n, String ph, String bs, String bc, String bp, String im, String cma, String cme)
        {
            accountId=accId;
            name=n;
            phone=ph;
            billingStreet=bs;
            billingCity=bc;
            billingPostalCode=bp;
            industry_Minor_Category=im;
            cciMailId=cma;
            cciMetroId=cme;
        }
    }*/

    /*private class AccessToken
    {
        private String access_token {get; set;}
        private String token_type {get; set;}
        private String refresh_token {get; set;}
        private String expires_in {get; set;}
        private String read {get; set;}

        private AccessToken(String ato, String tto, String rto, String exp, String rd)
        {
            access_token=ato;
            token_type=tto;
            refresh_token=rto;
            expires_in=exp;
            read=rd;            
        }
    }*/
}