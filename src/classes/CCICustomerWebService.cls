global class CCICustomerWebService {

    private final Id accID;


    WebService static String createCCICustomer(String accId, String dbType, boolean directOrder) {

        Account acc;
        FinanceAccount__c finAcc;
        Company__c company;
        Boolean finAccExis;
        String errorResponse;
        String successResponse;

        try {
            //start1

            acc = [SELECT RecordType.Name, CCIMailCustID__c, CCIMetroCustID__c,
            Name, Type, BillingCity, BillingState, Phone, BillingStreet,
            BillingPostalCode, IsActive__c, BillingCountry,
            Industry, Industry_Minor_Category__c,
            FirstName__c, Salutation__c, ParentId,IndClassLvl1__c
            FROM Account
            WHERE ID = : accID LIMIT 1];


            System.debug('RecordType:' + acc.RecordType.Name + 'and type is' + acc.Type);

            User u = Common.getUserInfo();
            System.debug('User is' + u);
            String userType = Common.getUserType(u);
            System.debug('UserType' + userType);
            System.debug('Common.sharedSecret' + Common.sharedSecret);
            if (String.IsBlank(acc.Type)) errorResponse = 'Type can not be null.Please update the account and then try again';
            else if (!acc.IsActive__c) errorResponse = Label.InActiveAccountMessage;
            // if(u.CCI_User_Id__c==null||u.CCI_Profile__c==null||u.CCI_User_Password__c==null||u.CCI_Group_Id__c==null || u.CCI_User_Id__c==''||u.CCI_Profile__c==''||u.CCI_User_Password__c==''||u.CCI_Group_Id__c=='' )
            //else if(String.IsBlank(Common.sharedSecret) )
            //    errorResponse = Label.Missing_Shared_Secret; 

            else if ((acc.Type == 'Billing Agency' || acc.Type == 'Direct Advertiser' || acc.Type == 'Private Advertiser' || acc.Type == 'Charity') && String.IsBlank(acc.Phone)) errorResponse = Label.MissingPhone;

            else if ((acc.Type == 'Billing Agency' || acc.Type == 'Direct Advertiser' || acc.Type == 'Private Advertiser' || acc.Type == 'Charity') && (String.IsBlank(acc.BillingStreet) || String.IsBlank(acc.BillingPostalCode)) && (String.isBlank(acc.BillingCountry)||acc.BillingCountry.equalsIgnoreCase('united kingdom')||acc.BillingCountry.equalsIgnoreCase('uk')||acc.BillingCountry.equalsIgnoreCase('u.k'))) errorResponse = Label.MissingBillingAddress;

            else if ((acc.Type == 'Billing Agency' || acc.Type == 'Direct Advertiser' || acc.Type == 'Private Advertiser' || acc.Type == 'Charity') && String.IsBlank(acc.BillingStreet) && !(String.isBlank(acc.BillingCountry)||acc.BillingCountry.equalsIgnoreCase('united kingdom')||acc.BillingCountry.equalsIgnoreCase('uk')||acc.BillingCountry.equalsIgnoreCase('u.k'))) errorResponse = Label.MissingBillingAddress;

            else if (acc.RecordType.Name == 'Advertiser' && acc.Type != 'Private Advertiser' && acc.Type != 'Holding Company' && (u.Profile.Name.contains('Mail Display') ||u.Profile.Name.contains('Metro')|| u.Profile.Name.contains('Credit Controller') || u.Profile.Name.contains('Group Client Sales')) && String.IsBlank(acc.Industry_Minor_Category__c)) errorResponse = Label.MissingIndustry;


            else if (acc.RecordType.Name == 'Agency' && (acc.Type != 'Billing Agency' && acc.Type != 'Booking Agency' && acc.Type != 'Holding Agency')) errorResponse = Label.AgencyTypeInvalid;
            else if (acc.RecordType.Name == 'Advertiser' && acc.Type != 'Private Advertiser' && acc.Type != 'Holding Company' && u.Profile.Name.contains('Classified') && String.IsBlank(acc.IndClassLvl1__c)) errorResponse = Label.ClassifiedCategoryError;



            else if (dbType == 'Mail') {
                //start2
                if (userType == Common.mailUser || userType == Common.systemAdministrator || userType == Common.groupClientSales || userType == Common.creditController) {
                    //start3   
                    if (acc.CCIMailCustID__c != null && acc.CCIMailCustID__c != '') {
                        errorResponse = Label.CCIAccount_already_exists;
                    } else {
                        //start4
                        List < Id > accIds = new List < Id > ();
                        accIds.add(acc.Id);
                        Map < ID, String > mResponse = CCICustomerManager.createCustomer(accIds, 'Mail', u, directOrder);
                        if (acc.Type == 'Brand') {
                            // call update to parent Direct Advertiser
                        }
                        if (directorder) successResponse = mResponse.get(accID);
                        else {
                            //start5
                            errorResponse = mResponse.get(accID);
                            System.debug('Direct Order..' + directOrder + 'ErrorResponse..' + errorResponse);

                            if (errorResponse == null && !directorder && ((acc.Type == 'Billing Agency' || acc.Type == 'Direct Advertiser' || acc.Type == 'Private Advertiser' || acc.Type == 'Charity') || (acc.Type == 'Brand' && !String.IsBlank(acc.BillingStreet) && !String.IsBlank(acc.Phone) && !String.IsBlank(acc.BillingPostalCode)))) {
                                //start6
                                try {
                                    company = [SELECT ID from Company__c where name like '%Mail%'
                                    Limit 1];
                                    finAcc = [SELECT ID, Neo_ID__c, Name, SOP_ID__c, SOP_Source__c FROM FinanceAccount__c where Account__c = : accID and Company__c = : company.id LIMIT 1];
                                    if (finAcc != null) finAccExis = true;
                                } catch (Exception e) {
                                    System.debug('An error encountered');
                                    finAccExis = false;
                                }
                                if (!finAccExis) {
                                    FinanceAccount__c newFinAcc = new FinanceAccount__c();
                                    newFinAcc.Account__c = accId;
                                    newFinAcc.Company__c = company.id;
                                    insert newFinAcc;

                                    //Create finance account in CCI
                                    CCIAccountWebService.createFutureCCIAccount(newFinAcc.id, false);
                                } else {
                                    if (finAcc.SOP_Source__c == 'CCI' && finAcc.SOP_ID__c != null && finAcc.SOP_ID__c != '') {
                                        System.debug('DO nothing as fin acc is already synchronised');
                                    } else {
                                        CCIAccountWebService.createFutureCCIAccount(finAcc.id, false);
                                    }
                                }
                                //end6

                            }
                            //end5
                        }


                        //end4
                    }
                    //end3
                } else {
                    errorResponse = Label.InAppropriateAccountInCCI;
                }


                //end2

            } else if (dbType == 'Metro') {
                //start7
                if (userType == Common.metroUser || userType == Common.londonClassified || userType == Common.systemAdministrator || userType == Common.groupClientSales || userType == Common.creditController) {
                    //start8

                    if (acc.CCIMetroCustID__c != null && acc.CCIMetroCustID__c != '') {
                        errorResponse = Label.CCIAccount_already_exists;

                    } else {
                        //start9
                        List < Id > accIds = new List < Id > ();
                        accIds.add(acc.Id);
                        Map < ID, String > mResponse = CCICustomerManager.createCustomer(accIds, 'Metro', u, directOrder);
                        if (directorder) successResponse = mResponse.get(accID);
                        else{
                         errorResponse = mResponse.get(accID);

                        if (errorResponse == null && !directorder && ((acc.Type == 'Billing Agency' || acc.Type == 'Direct Advertiser' || acc.Type == 'Private Advertiser' || acc.Type == 'Charity') || (acc.Type == 'Brand' && !String.IsBlank(acc.BillingStreet) && !String.IsBlank(acc.Phone) && !String.IsBlank(acc.BillingPostalCode)))) {
                            //start10
                            try {
                                company = [SELECT ID from Company__c where name like '%Metro%'
                                Limit 1];
                                finAcc = [SELECT ID, Name, SOP_ID__c, SOP_Source__c FROM FinanceAccount__c where Account__c = : accID and Company__c = : company.id LIMIT 1];
                                if (finAcc != null) finAccExis = true;
                            } catch (Exception e) {
                                System.debug('An error encountered');
                                finAccExis = false;
                            }
                            if (!finAccExis) {
                                FinanceAccount__c newFinAcc = new FinanceAccount__c();
                                newFinAcc.Account__c = accId;
                                newFinAcc.Company__c = company.id;
                                insert newFinAcc;

                                //Create finnace account in CCI
                                CCIAccountWebService.createFutureCCIAccount(newFinAcc.id, false);
                            } else {
                                if (finAcc.SOP_Source__c == 'CCI' && finAcc.SOP_ID__c != null && finAcc.SOP_ID__c != '') {
                                    System.debug('DO nothing as fin acc is alredya synchronised');
                                } else {
                                    CCIAccountWebService.createFutureCCIAccount(finAcc.id, false);
                                }

                            }
                            //end10              

                        }
                        //end9

                    }

                    //end8
                } }else errorResponse = Label.InAppropriateMetroUser;


                //end7
            }
            // end1     

        } Catch(Exception e) {

            errorResponse = Label.CCI_Exception;
            // pr = new Pagereference('/' + acc.ID);
            //  ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.CCI_Exception));

        }

        System.debug('Error is' + errorResponse);
        if ((!directOrder && String.isBlank(errorResponse)) || (directOrder && !String.isBlank(successResponse))) {
            Common.addChatterFeedToObject((Id) accId, 'Account ' + acc.name + ' has been successfully integrated with CCI.');
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI '+dbType,
            Account__c = (Id) accId, Status__c = 'Success',
            Description__c = 'Account ' + acc.name + ' has been successfully integrated with CCI.');
            insert intL;

        }


        if (directOrder && !String.isBlank(successResponse) && String.isBlank(errorResponse)) return successResponse;
        else if (directOrder && String.isBlank(successResponse) && !String.isBlank(errorResponse)) return null;
        System.debug('ErrorResponse..' + errorResponse);
        return errorResponse;



    }

    //public static boolean totalSync;
    /*
    public static void getCCIAccount(List<String> accountList, List<String> oldAccountList, boolean tempTotalSync){
        if(tempTotalSync == true){
            totalSync = true; 
        }else{
            totalSync = false;
        }
        getCCIAccount(accountList, oldAccountList);
    }
    */
@future(callout = true)
    public static void getCCIAccount(List < String > accountList, List < String > oldAccountList, boolean totalSync) {
        system.debug('***totalSync' + totalSync);
        if (totalSync == null) {
            totalSync = false;
        }
        system.debug('***totalSync' + totalSync);
        if (CCICustomerManager.firstAccountId == null) {
            List < CCICustomerWrapper.AccountInfo > firstAccountList = (List < CCICustomerWrapper.AccountInfo > ) JSON.deserialize('[' + accountList[0] + ']', List < CCICustomerWrapper.AccountInfo > .class);

            CCICustomerManager.firstAccountId = firstAccountList[0].accountId;
        }
        try {

            CCICustomerWrapper.AccessToken tokenInfo; //= Common.cciToken; // CCICustomerManager.getCCIToken();
            //if(tokenInfo!=null)
            {
                set < Id > accountIds = new set < ID > ();
                // System.debug(tokenInfo.access_token);
                Integer accSize = accountList.Size();
                for (Integer i = 0; i < accSize; i++) {

                    List < CCICustomerWrapper.AccountInfo > deserializedAccountList = (List < CCICustomerWrapper.AccountInfo > ) JSON.deserialize('[' + accountList[i] + ']', List < CCICustomerWrapper.AccountInfo > .class);

                    List < CCICustomerWrapper.AccountInfo > deserializedOldAccountList = (List < CCICustomerWrapper.AccountInfo > ) JSON.deserialize('[' + oldAccountList[i] + ']', List < CCICustomerWrapper.AccountInfo > .class);
                    System.debug('deserializedAccountList:' + deserializedAccountList);
                    System.debug('deserializedOldAccountList:' + deserializedOldAccountList);
                    Boolean isMail;
                    accountIds.add(deserializedAccountList[0].accountId);
                    if (!String.IsBlank(deserializedAccountList[0].cciMailId)) {
                        isMail = true;
                        String customerJson = CCICustomerManager.getCustomerData(deserializedAccountList[0], tokenInfo, isMail);
                        if (!String.isBlank(customerJson) && customerJson != null) {
                            CCICustomerManager.updateCustomerData(deserializedAccountList[0], deserializedOldAccountList[0], customerJson, tokenInfo, totalSync);
                        }
                    }
                    if (!String.IsBlank(deserializedAccountList[0].cciMetroId)) {
                        isMail = false;
                        String customerJson = CCICustomerManager.getCustomerData(deserializedAccountList[0], tokenInfo, isMail);
                        if (!String.isBlank(customerJson) && customerJson != null) {
                            CCICustomerManager.updateCustomerData(deserializedAccountList[0], deserializedOldAccountList[0], customerJson, tokenInfo, totalSync);
                        }
                    }
                }

                if (accountIds.size() > 0) {
                    list < Account > updateAccountList = new list < Account > ([select id, DoCCIInt__c from Account where ID in : accountIds and DoCCIInt__c = true]);
                    for (Account a: updateAccountList) {
                        a.DoCCIInt__c = false;
                    }
                    update updateAccountList;
                }
            }
        } catch (exception e) {
            system.debug('Exception in future handeler is : ' + e);
        } finally {
            if (Common.integLogs.size() > 0) {
                System.debug('Common.integLogs:' + Common.integLogs);
                insert Common.integLogs;
                /*List<String> integList = new List<String>();
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



}