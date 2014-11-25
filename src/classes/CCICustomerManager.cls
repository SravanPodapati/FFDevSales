/************************************************************************************************************************                                                                                         
 
 

 
 Code purpose  : Class reponsible for synchronizing changes on account with CCI(external system):
   
 Api version   : v1

****************************************************************************************************************************/
public without sharing class CCICustomerManager {

    /*  public static BookingSystemSettings__c cci
    {
        get
        {
            if(cci==null)
            {
                BookingSystemSettings__c cciSet = BookingSystemSettings__c.getInstance('CCI');
                return cciSet;
            }
            return cci;
        }
        set;
    }*/




    public static Id firstAccountId {
        get;
        set;
    }

    /*public static List<Integration_Logs__c> integLogs
    {
        get
        {
            if(integLogs==null)
            {
                integLogs = new List<Integration_Logs__c>();
            }
            return integLogs;
        }
        set;
    }*/

    /*public static List<CCICustomerWrapper.ChatterInfo> chatterList
    {
        get
        {
            if(chatterList==null)
            {
                chatterList = new List<CCICustomerWrapper.ChatterInfo>();
            }
            return chatterList;
        }
        set;
    }*/

    @future(callout = true)
    public static void createCCIMailCustomerAsync(List < Id > accIds) {
        //createCustomer(accIds,'Mail');

    }





    // Method does call out to CCI creating new customer account

    public static Map < ID, String > createCustomer(List < Id > accIds, String dbType, User user, boolean directOrder) {
        string errorResponse = null;
        List < Account > actErrors = new List < Account > ();
        Map < ID, String > mErrorResponse = new Map < ID, String > (); // key - account id
        Map < ID, Account > mNewAccounts = new Map < ID, Account > (); // key - account id
        List < Account > liupdatedAccounts = new List < Account > ();
        Map < Id, String > cciCustomerMap = new Map < Id, String > ();

        String username = user.CCI_User_Id__c;

        String password = user.CCI_User_Password__c;
        String domain;
        String cusPath;
        //String authString;
        String contentType;
        String strResponse = null;
        // List<Integration_Logs__c> integLogs = new List<Integration_Logs__c> ();
        Map < Account, Exception > errorMap = new Map < Account, Exception > ();
        List < Account > liAccs;

        try {
            // BookingSystemSettings__c setting  = BookingSystemSettings__c.getInstance('CCI');
            BookingSystemSettings__c setting = Common.cci;
            if (setting != null) {
                domain = setting.Domain__c;
                //domain = setting.TempDomain__c;
                domain = setting.Domain__c;
                cusPath = setting.CustomerPath__c;
                // authString = setting.AuthenticationPath__c;

                contentType = setting.ContentType__c;
                // if(String.IsBlank(domain) ||String.IsBlank(cusPath)||String.IsBlank(authString)||String.IsBlank(contentType))
                if (String.IsBlank(domain) || String.IsBlank(cusPath) || String.IsBlank(contentType)) {
                    throw new BookingSystemSettingsException();
                }
                if (String.IsBlank(Common.sharedSecret) && (String.ISBlank(username) && String.ISBlank(user.CCI_Profile__c) && String.ISBlank(password) && String.ISBlank(user.CCI_Group_Id__c))) throw new CCIApiException(Label.Missing_Shared_Secret);

            } else {
                throw new BookingSystemSettingsException();
            }

            // authString  = authString.replace('<username>',username);
            // authString = authString.replace('<password>',password);
            String query = getAccountQuery(accIds); // get all fields for query
            List < Id > tmpVar1 = accIds;
            liAccs = Database.query(query);
            // String accessToken = getAccessTokenForCustomer(domain+authString);
            String accessToken;
            if (Common.cciToken != null) {
                accessToken = Common.cciToken.access_token;
            } else {
                throw new CCIApiException('Can not read Access Token.');
            }
            System.debug('Token is' + accessToken);


            for (Account acc: liAccs) {
                try {
                    CCIClientCreation client = new CCIClientCreation(acc, dbType);
                    strResponse = sendCustomerCreateRequest(client, accessToken, domain + cusPath, contentType, user,dbType);
                    String customerId = ObjectUpdateFromCCIResponse.createAccounMapping(strResponse, dbType, acc.Id);
                    cciCustomerMap.put(acc.id, customerId);

                    //Direct Advertiser Roles
                    if (acc.Type.equalsIgnoreCase('Direct Advertiser')) {
                        System.debug('Inside updateDARoles');
                        updateDACustomerRoles(strResponse, acc.id, dbType);
                         System.debug('Outside updateDARoles');
                    }

                } catch (CCIApiException e) {
                    System.debug('CCIApiException' + e);
                    errorMap.put(acc, e);
                    actErrors.add(acc);
                    if ((e.getMessage()).contains('The zip code is invalid')) mErrorResponse.put(acc.id, Label.Invalid_Zip);
                    else mErrorResponse.put(acc.id, Label.CCI_Exception);
                } catch (Exception e) {
                    System.debug('Exception' + e);
                    errorMap.put(acc, e);
                    actErrors.add(acc);
                    mErrorResponse.put(acc.id, Label.CCI_Exception);
                }
            }



            for (Account acc: actErrors) {
                Integration_Logs__c log = new Integration_Logs__c();
               log.Source__c = 'CCI ' +dbType;
                log.Status__c = 'Failure';
                log.Account__c = acc.Id;
                log.Description__c =  Common.addErrorMsgToDesc(errorMap.get(acc).getMessage());
                if(String.IsBlank(log.Description__c))log.Description__c=Label.CCI_Exception;
                if(log.Description__c.length()>255)
                    log.Description__c = log.Description__c.subString(0, 255);
                log.Exception__c = errorMap.get(acc).getMessage();
                Common.integLogs.add(log);
            }

            if (Common.integLogs.size() > 0) {
                insert Common.integLogs;
            }
        } catch (BookingSystemSettingsException e) {
            System.debug('BookingSystem Setting Exception' + e);
            List < Integration_Logs__c > integrationLogList = new List < Integration_Logs__c > ();
            for (Id id: accIds) {
                mErrorResponse.put(id, Label.No_Custom_Setting_Value + 'for Booking System settings');
                integrationLogList.add(
                new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = id,
                Description__c = Label.No_Custom_Setting_Value + 'for Booking System settings',
                Exception__c = e.getMessage(),
                Status__c = 'Failure'));
            }
            if (integrationLogList.size() > 0) {
                insert integrationLogList;
            }

        } catch (Exception e) {
            System.debug('Exception' + e);
            String desc1 = Common.addErrorMsgToDesc(e.getMessage());
            List < Integration_Logs__c > integrationLogList = new List < Integration_Logs__c > ();
            for (Id id: accIds) {
                mErrorResponse.put(id, Label.CCI_Exception);
                integrationLogList.add(
                new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = id,
                Description__c = !String.IsBlank(desc1)?desc1:Label.CCI_Exception,
                Exception__c = e.getMessage(),
                Status__c = 'Failure'));
            }
            if (integrationLogList.size() > 0) {
                insert integrationLogList;
            }

        }



        if (directOrder) return cciCustomerMap;

        return mErrorResponse;
    }

    @future(callout = true)
    public static void updateDACustomerRoles(String accountJason, id accId, String dbType) {
    //String dbType='Mail';
        if (accountJason != null) {
            String customerID = accountJason.subString(0, accountJason.indexOf('","externalCustomerId"')).replace('{"customerId":"', '');
            try {
                Account acc = [SELECT ID, name from account where id = : accId];
                String resultString = addAgencyRoles(accountJason);

                Httprequest req = buildRequest(Common.cci.Domain__c + Common.cci.CustomerPath__c + '/' + customerID, resultString, Common.cciToken.access_token, Common.cci.ContentType__c, Common.getUserInfo(), dbType);
                req.setMethod('PUT');
                //@513 or 326
                handleResponse(req);
                //return resultString;
                String successMessage = 'Account roles are updated succesfully for Account - ' + customerID;
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(accid, successMessage));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = accID,
                Description__c = successMessage,
                Status__c = 'Success');
                Common.integLogs.add(intL);

            } catch (Exception e) {
                string errorMessage = 'Failed to update CCI Customer data for Agency Roles for CCI Customer - ' + customerID;
                //Common.addChatterFeedToObject(account.accountId, 'Failed to get CCI Customer data.');
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(accID, errorMessage));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = accID,
                Description__c = (errorMessage+Common.addErrorMsgToDesc(e.getMessage())),
                Exception__c = e.getMessage(),
                Status__c = 'Failure');
                if(intL.Description__c.length()>255)
                    intL.Description__c = intL.Description__c.subString(0, 255);
                Common.integLogs.add(intL);
            } finally {
                if (Common.integLogs.size() > 0) {
                    System.debug('Common.integLogs:' + Common.integLogs);
                    insert Common.integLogs;
                }
                if (Common.chatterList.Size() > 0) {
                    for (CCICustomerWrapper.ChatterInfo c: Common.chatterList) {
                        Common.addChatterFeedToObject(c.itemId, c.message);
                    }
                }
            }
        }
    }
    
    public static String addAgencyRoles(String accountJason){
        String resultJSON;
        
        String temp1 = accountJason.subString(accountJason.indexOf('"roles":{"custRole":['));
        integer startIndex = temp1.indexof('"customer":{');
        string temp2 = temp1.substring(startIndex);
        integer stopIndex = startIndex + temp2.indexOf('}') + 1;
        String customerContent = temp1.substring(startIndex, stopIndex);
        system.debug(customerContent);
        String roleString = '{"roleCode":"Agency","roleName": "Agency",' + customerContent + '}';
        String resultString;
        if (accountJason.indexof('"roles":null') > 0) {
            String str1 = accountJason.subString(0, accountJason.indexof('"roles":') + '"roles":'.length());
            String str2 = accountJason.subString(accountJason.indexof('"clients":'));
            Str1 += '"custRole":[' + roleString + ']';
            resultString = Str1 + Str2;
        } else {
            String str1 = accountJason.subString(0, accountJason.indexof('"roles":{"custRole":[') + '"roles":{"custRole":'.length());
            system.debug('*** Str1:' + str1);
            String str2 = accountJason.subString(accountJason.indexof('"roles":{"custRole":[') + '"roles":{"custRole":'.length());
            system.debug('*** Str2:' + str2);
            if (str2.startsWith('[')) {
                str2.substring(1);
                str1 += '[' + roleString + ',';
                str2 = str2.substring(1);
            }
            resultString = Str1 + Str2;
        }
        resultJSON = resultString;
        return resultJSON;
    }

    public static String sendCustomerCreateRequest(CCIClientCreation client, String accessToken, String cusPath, String contentType, User user,String dbType) {
        System.debug('Inside sendCustomerCreate Request...');
        System.debug('Inside sendCustomerCreate Request...');
    
        String jsonreq = client.getReqJsonBody();
       System.debug('jsnReq is'+ jsonreq);
        String updatedRequest = jsonreq.replace('"phNumber":', '"number":');
        HttpRequest req = buildRequest(cusPath, updatedRequest, accessToken, contentType,user,dbType);
     
        return handleResponse(req);

    }


    /*  public static String getAccessTokenForCustomer(String authPath){

  //   HttpRequest req = buildAccessTokenRequest('api/authentication/oauth/token?grant_type=password&client_id=app&username=male&password=dmg2013', 
   //                                    '');
                                       
       HttpRequest req = buildAccessTokenRequest(authPath, 
                                       '');
        
        
        String response  = handleResponse(req);
        Map<String, Object> mWholeResponse = (Map<String, Object>) JSON.deserializeUntyped(response  );
        String accessToken  = (String) mWholeResponse.get('access_token') ;
        return accessToken  ;
    
    }*/

    /* private static HttpRequest buildAccessTokenRequest(String path, String requestXML) {
       System.debug('Entered buildRequest'+ requestXML);
         System.debug('Path is'+ path);

        
                 
               //create a new instance of httprequest  
        HttpRequest req = new HttpRequest();  
        //set method  
        req.setMethod('POST');  
        req.setEndpoint(path);   
        req.setHeader('Content-Type', 'application/json');  
        
       
     //   req.setCompressed(true);   
        req.setBody(requestXML);  
       // req.setTimeout(60000); // timeout in milliseconds 
        system.debug('Envelope is...'+requestXML);
        system.debug('req...' + req.toString());
           
        return req;
    } */

    private static HttpRequest buildRequest(String cusPath, String requestXML, String accessToken, String contentType, User u,String dbType) {
        System.debug('Entered buildRequest' + requestXML);
        
        boolean isMail = false;
        if(dbType=='Mail')
            isMail = true;


        //create a new instance of httprequest  
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());

        //set method  
        req.setMethod('POST');
        req.setEndpoint(cusPath);
        req.setHeader('Content-Type', contentType);
        // req.SetHeader('x-cci-profile',u.CCI_Profile__c);
        
		Set<String> cciGroups = Common.CCIGroups();
		Set<String> cciProfiles = Common.CCIProfiles();
       
         if(u.Virtual_Data_Team_Member__c||cciGroups.size()>1||cciProfiles.size()>1){
             System.debug('dbtype is'+dbtype);
             System.debug('Virtual Data Team Member');
              req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
              System.debug('header cci user');
              if(isMail){
              
              req.setHeader('x-cci-profile', Common.cci.ServiceUserMailProfile__c);
              System.debug('Setting Mail profile');
              }
              else{
               System.debug('before Setting Metro profile');
               req.setHeader('x-cci-profile',Common.cci.ServiceUserMetroProfile__c);
               System.debug('Setting Metro profile');
               }
              
              System.debug('header cci profile');
              req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
              System.debug('header ccigroup');
         
         }else{
          if (Common.sharedSecret != null) {
            //List<String> sList = common.userInformation.Email.split('@',2);
            //req.SetHeader('x-cci-user', sList[0]);    
            req.SetHeader('x-cci-user', Common.cciuser);
        }

        req.SetHeader('x-cci-profile', common.userProfile());

        System.debug('Group:' + common.userProfile());

        // req.SetHeader('x-cci-group',u.CCI_Group_Id__c);
        req.SetHeader('x-cci-group', common.userGroup());
        }

        req.SetHeader('Authorization', 'bearer ' + accessToken);
        //   req.setCompressed(true);   
        req.setBody(requestXML);

        system.debug('Envelope is...' + requestXML);
        system.debug('req...' + req.toString());

        return req;
    }

    private static String handleResponse(HttpRequest req) {
        // create a new instance of Http class  
        System.debug('Entered handleResponse...');
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        // send request  

        System.debug('Request is ' + req);
        // if (!Test.isRunningTest()){

        res = http.send(req);
        // }
        /*else {
        MockHttpResponseGenerator mockGen = new MockHttpResponseGenerator();
            res = mockGen.respond(req);
        } */
        system.debug('res....' + res);
        System.debug('Response is ' + res.getBody());
        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            throw new CCIApiException(res.getBody());
        }

        return res.getBody();
    }

    public static String getAccountQuery(List < Id > accIds) {

        String retVal = Database.getQueryLocator([SELECT Id,
        Name, NPA__c, Industry, Type, Industry_Minor_Category__c, BillingCity, BillingState, BillingStreet, BillingPostalCode, BillingCountry, Phone, Salutation__c, FirstName__c

        FROM Account
        WHERE ID in : accIds]).getQuery();
        System.debug('>>>Query = ' + retVal);
        return retVal;
    }

    /*public static CCICustomerWrapper.AccessToken getCCIToken()
    {
       // cci = BookingSystemSettings__c.getInstance('CCI');
        String endpointUrl = Common.cci.Domain__c+Common.cci.AuthenticationPath__c;
        // String endpointUrl = cci.TempDomain__c+cci.AuthenticationPath__c;
        endpointUrl=endpointUrl.replace('<username>', userInfo.CCI_User_Id__c);
        endpointUrl=endpointUrl.replace('<password>', userInfo.CCI_User_Password__c);

        System.debug('endpointUrl:'+endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();  
        //set method  
        req.setMethod('GET');   
        req.setHeader('Content-Type', Common.cci.ContentType__c);
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
            // Common.addChatterFeedToObject(firstAccountId, 'Failed to get CCI Token.');
            chatterList.add(new CCICustomerWrapper.ChatterInfo(firstAccountId, 'Failed to get CCI Token.'));
            Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI ' +dbType,
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

    } */
    
   /* //creates finance Accounts
    public static void createFinanceAccountForDirectAdvertiser(list<FinanceAccount__c> newFinanceAccounts){
        for(FinanceAccount__c fA: newFinanceAccounts){
            CCIAccountWebService.createNonFutureCCIAccount(fA.Id, false);
        }
    }
     */   
    public static boolean totalSync;

    public static void updateCustomerData(CCICustomerWrapper.AccountInfo acc, CCICustomerWrapper.AccountInfo oldAcc, String customer, CCICustomerWrapper.AccessToken tokenInfo, boolean tempTotalSync) {
        if (tempTotalSync == true) {
            totalSync = true;
        } else {
            totalSync = false;
        }
        updateCustomerData(acc, oldAcc, customer, tokenInfo);
    }

    public static void updateCustomerData(CCICustomerWrapper.AccountInfo acc, CCICustomerWrapper.AccountInfo oldAcc, String customer, CCICustomerWrapper.AccessToken tokenInfo) {
    Set<String> allowedTypeChange = new Set<String>{'Brand','Direct Advertiser','Client'};
        totalSync = true; // this is a workaround until we find the root cause of the update issue
        String dbType;
        try {
            if (totalSync == null) {
                totalSync = false;
            }
            system.debug('***totalSync' + totalSync);

            //Map<String, Object> customerMap = (Map<String, Object>) JSON.deserializeUntyped(customer);

            System.debug('customer: ' + customer);
            Boolean isMail;
           
            Boolean accountNameChange = false;
            Boolean phoneChange = false;
            Boolean billingStreetChange = false;
            Boolean billingCityChange = false;
            Boolean billingStateChange = false;
            Boolean billingPostalCodeChange = false;
            Boolean billingCountryChange = false;
            Boolean industryMinorCategoryChange = false;
            Boolean npaChange = false;
            Boolean typeChange=false;
            System.debug('oldAcc' + oldAcc + 'new acc' + acc);

            //determine wether it is mail mapping update or metro mapping update.
            string customerId = customer.substring(customer.indexOf('{"customerId":"') + '{"customerId":"'.length(), customer.indexOf('","externalCustomerId"')).trim();
            if (customerId == acc.cciMailId) {
                isMail = true;
                dbType='Mail';
            } else if (customerId == acc.cciMetroId) {
                ismail = false;
                dbType='Metro';
            }

            if (acc.accountType == 'Private Advertiser') {
                if (acc.salutation != oldacc.salutation || totalSync) {
                    customer = customer.substring(0, customer.indexOf('"addressAs"')) + '"addressAs" : "' + acc.salutation + '",' + customer.substring(customer.indexOf('name') - 1);
                }
                if (acc.firstName != oldacc.firstName || totalSync) {
                    customer = customer.substring(0, customer.indexOf('"initials"')) + '"initials" : "' + acc.firstName + '",' + customer.substring(customer.indexOf('surname') - 1);
                }
                if (acc.name != oldacc.name || totalSync) {
                    customer = customer.substring(0, customer.indexOf('"surname"')) + '"surname" : "' + acc.name + '",' + customer.substring(customer.indexOf('companyName') - 1);
                }
            } else {
                if (acc.name != oldacc.name || totalSync) {
                    //customer = customer.replace('"companyName":"'+customerMap.get('companyName')+'"', '"companyName":"'+acc.name+'"');
                    //customerMap.put('companyName','companyName : "'+acc.Name+'",');
                    customer = customer.substring(0, customer.indexOf('"companyName"')) + '"companyName" : "' + acc.name + '",' + customer.substring(customer.indexOf('presentationName') - 1);
                    accountNameChange = true;
                }
            }
            
            //changed added by yuvika for NPA
            if (customer.indexOf('"customerCategory":null') < 0) {
                if (acc.npa != oldacc.npa || totalSync) {
                    System.debug('NPA changed olod acc' + oldacc.npa + 'New acc' + acc.npa);
                    String code;
                    if (acc.accountType == null || acc.accountType == '') {
                        throw new CCIApiException('Type can not be null. Please update the account and then try again');
                    }
                    CustomerCategory__c categories;
                    if (acc.accountType.contains('Agency') && !acc.accountType.contains('Holding Agency')) {
                        if (acc.npa) {
                            System.debug('acc is npa');
                            categories = CustomerCategory__c.getInstance('NPA');

                        } else {
                            categories = CustomerCategory__c.getInstance('NonNPA');
                        }
                    } else {
                        categories = CustomerCategory__c.getInstance(acc.accountType);
                    }
                    if (categories == null) {
                        throw new CCIApiException('Customer Category does not exist for this account type');
                    }
                     code = categories.CategoryCode__c;
                    System.debug('Code is' + code);
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"customerCategory"'));
                    System.debug('NewCustomerStr1' + newCustomerStr1);
                    String newCustomerStr2 = customer.substring(customer.indexOf('"customerCategory"'));
                    System.debug('NewCustomerStr2' + newCustomerStr2);
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"categoryCode"')) + '"categoryCode" :' + (String.ISBlank(code) ? 'null' : '"' + code + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"categoryName"'));
                    System.debug('NewCustomerStr2' + newCustomerStr2);
                    newCustomerStr1 += newCustomerStr2;
                    System.debug('NewCustomerStr1' + newCustomerStr1);

                    customer = newCustomerStr1;
                    System.debug('Customer is' + customer);
                    npaChange = true;
                }
                else if(allowedTypeChange.contains(acc.accountType)){
                
                //new block added
                    System.debug('New block for categoryChange');
                CustomerCategory__c categories=CustomerCategory__c.getInstance(acc.accountType);
                String code = categories.CategoryCode__c;
               
                if (categories == null) {
                    throw new CCIApiException('Customer Category does not exist for this account type');
                }
                CCICustomerWrapper.customerCategoryExt customerCategory = new CCICustomerWrapper.CustomerCategoryExt(categories.CategoryCode__c);

                String customerCategoryJson = Json.serialize(customerCategory);

                String newCustomerStr1 = customer.substring(0, customer.indexOf('"customerCategory"'));
                System.debug('newCustomerStr1:' + newCustomerStr1);
                String newCustomerStr2 = customer.substring(customer.indexOf('"customerCategory"'));
                System.debug('newCustomerStr2:' + newCustomerStr2);
                System.debug('customerCategoryJson:' + customerCategoryJson);
                newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('{')) + customerCategoryJson + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"paymentTerm"'));
              //  newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"categoryCode"')) + '"categoryCode" :' + (String.ISBlank(code) ? 'null' : '"' + code + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"categoryName"'));
                System.debug('newCustomerStr2:' + newCustomerStr2);
                newCustomerStr1 += newCustomerStr2;
                System.debug('newCustomerStr2:' + newCustomerStr2);

                customer = newCustomerStr1;
                //finishes new block
                
                             
                
                }
            } else {
                   System.debug('Old block 1 for categoryChange');
                CustomerCategory__c categories;
                if (acc.accountType == null || acc.accountType == '') {
                    throw new CCIApiException('Type can not be null. Please update the account and then try again');
                }
                if (acc.accountType.contains('Agency') && !acc.accountType.contains('Holding Agency')) {
                    if (acc.npa) {
                        System.debug('acc is npa');
                        categories = CustomerCategory__c.getInstance('NPA');

                    } else {
                        categories = CustomerCategory__c.getInstance('NonNPA');
                    }
                } else {
                    categories = CustomerCategory__c.getInstance(acc.accountType);
                }

                if (categories == null) {
                    throw new CCIApiException('Customer Category does not exist for this account type');
                }
                System.debug('Old block 2 for categoryChange');
                CCICustomerWrapper.customerCategoryExt customerCategory = new CCICustomerWrapper.CustomerCategoryExt(categories.CategoryCode__c);

                String customerCategoryJson = Json.serialize(customerCategory);

                String newCustomerStr1 = customer.substring(0, customer.indexOf('"customerCategory"'));
                System.debug('newCustomerStr1:' + newCustomerStr1);
                String newCustomerStr2 = customer.substring(customer.indexOf('"customerCategory"'));
                System.debug('newCustomerStr2:' + newCustomerStr2);
                System.debug('customerCategoryJson:' + customerCategoryJson);
                newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('null')) + customerCategoryJson + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"paymentTerm"'));
                newCustomerStr1 += newCustomerStr2;

                customer = newCustomerStr1;
            }

            if (customer.indexOf('"mainTelephone":null') < 0) {
                if (acc.phone != oldacc.phone || totalSync) {
                    // customer = customer.replace('"companyName":"'+customerMap.get('companyName')+'"', '"companyName":"'+acc.name+'"');
                    //System.debug('mainTelephone:- '+customerMap.get('mainTelephone'));
                    //String mainTelephone = String.valueOf(customerMap.get('mainTelephone'));
                    //String newMainTelephone = mainTelephone.substring(0,mainTelephone.indexOf('number')) +'number: "'+acc.phone+','+mainTelephone.Substring(mainTelephone.indexOf('description'));

                    //customerMap.put('mainTelephone',newMainTelephone);
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainTelephone"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"mainTelephone"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"number"')) + '"number" :' + (String.ISBlank(acc.phone) ? 'null' : '"' + acc.phone + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"description"'));
                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;
                    phoneChange = true;

                }
            } else {
                CCICustomerWrapper.Telephone mainTelephone = new CCICustomerWrapper.Telephone(acc.Phone);

                String mainPhoneJson = Json.serialize(mainTelephone);
                mainPhoneJson = String.ValueOf(mainPhoneJson).replace('"phNumber":', '"number":');

                String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainTelephone"'));
                System.debug('newCustomerStr1:' + newCustomerStr1);
                String newCustomerStr2 = customer.substring(customer.indexOf('"mainTelephone"'));
                System.debug('newCustomerStr2:' + newCustomerStr2);
                System.debug('mainPhoneJson:' + mainPhoneJson);
                newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('null')) + mainPhoneJson + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"cellTelephone"'));
                newCustomerStr1 += newCustomerStr2;

                customer = newCustomerStr1;
            }

            System.debug('Customer Index: ' + customer.indexOf('"mainAddress":null'));

            if (customer.indexOf('"mainAddress":null') < 0) {
                if (acc.BillingStreet != oldacc.BillingStreet || totalSync) {
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainAddress"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"streetName"')) + '"streetName" :' + 'null' + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"streetNo"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"streetNo"')) + '"streetNo" :' + 'null' + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"additionalAddress"'));

                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"collection1"')) + '"collection1" :' + (String.ISBlank(acc.BillingStreet) ? 'null' : '"' + acc.BillingStreet + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"floorNo"'));
                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;

                    billingStreetChange = true;

                }

                if (acc.BillingCity != oldacc.BillingCity || totalSync) {
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainAddress"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"city"')) + '"city" :' + (String.ISBlank(acc.BillingCity) ? 'null' : '"' + acc.BillingCity + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"extraCity"'));
                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;

                    billingCityChange = true;

                }
                if (acc.BillingState != oldacc.BillingState || totalSync) {
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainAddress"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                    // newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"county"'))+'"county" :'+(String.ISBlank(acc.BillingState)?'null':'"'+acc.BillingState+'"')+','+newCustomerStr2.substring(newCustomerStr2.indexOf('"zipCode"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"county"')) + '"county" :' + (String.ISBlank(acc.BillingState) ? 'null' : '"' + acc.BillingState + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"stateCode"'));
                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;

                    billingStateChange = true;
                }

                if (acc.BillingPostalCode != oldacc.BillingPostalCode || totalSync) {
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainAddress"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                    //newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"zipCode"'))+'"zipCode" :'+(String.ISBlank(acc.BillingPostalCode)?'null':'"'+acc.BillingPostalCode+'"')+','+newCustomerStr2.substring(newCustomerStr2.indexOf('"stateCode"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"zipCode"')) + '"zipCode" :' + (String.ISBlank(acc.BillingPostalCode) ? 'null' : '"' + acc.BillingPostalCode + '"') + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"isAddressFormatted"'));
                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;
                    billingPostalCodeChange = true;
                }

                /*if(acc.BillingCountry!=oldacc.BillingCountry || totalSync)
            {
                String newCustomerStr1 = customer.substring(0,customer.indexOf('"mainAddress"'));
                String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"countryName"'))+'"countryName" :'+(String.ISBlank(acc.BillingCountry)?'null':'"'+acc.BillingCountry+'"')+','+newCustomerStr2.substring(newCustomerStr2.indexOf('"isAddressFormatted"'));
                newCustomerStr1+=newCustomerStr2;
    
                customer = newCustomerStr1;   
                
                billingCountryChange=true;           
    
            }*/
                if (acc.BillingCountry != oldacc.BillingCountry || totalSync) {
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainAddress"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                    BookingSystemCountryCodes__c cciCountry = new BookingSystemCountryCodes__c();
                    //try{
                    if (String.IsBlank(acc.BillingCountry) || acc.BillingCountry == 'UK' || acc.BillingCountry == 'England' || acc.BillingCountry == 'Wales' || acc.BillingCountry == 'Scotland') {
                        acc.BillingCountry = 'United Kingdom';
                    }
                    cciCountry = BookingSystemCountryCodes__c.getInstance(acc.BillingCountry);
                    if (cciCountry == null) {
                        throw new CCIApiException('Invalid Country - ' + acc.BillingCountry);
                    }
                    /*
                } catch (Exception e) {
                    throw new CCIApiException('Invalid Country - ' + acc.BillingCountry);
                }*/
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"countryCode"')) + '"countryCode" :' + '"' + cciCountry.CountryCode__c + '"' + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"countryName"'));
                    // newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"countryName"'))+'"countryName" :'+'"'+cciCountry.Name+'"'+','+newCustomerStr2.substring(newCustomerStr2.indexOf('"isAddressFormatted"'));
                    newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"countryName"')) + '"countryName" :' + '"' + cciCountry.Name + '"' + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"zipCode"'));

                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;

                    billingCountryChange = true;

                }

            } else {
                CCICustomerWrapper.Address mainAddress = new CCICustomerWrapper.Address(acc.BillingStreet, 'UK', acc.billingCity, acc.BillingCountry, acc.BillingPostalCode, acc.billingState);
                String mainAddressJson = Json.serialize(mainAddress);

                String newCustomerStr1 = customer.substring(0, customer.indexOf('"mainAddress"'));
                System.debug('newCustomerStr1:' + newCustomerStr1);
                String newCustomerStr2 = customer.substring(customer.indexOf('"mainAddress"'));
                System.debug('newCustomerStr2:' + newCustomerStr2);
                System.debug('mainAddressJson:' + mainAddressJson);
                newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('null')) + mainAddressJson + ',' + newCustomerStr2.substring(newCustomerStr2.indexOf('"boxAddress"'));
                newCustomerStr1 += newCustomerStr2;

                customer = newCustomerStr1;
            }
            
            //changed less than to grater than in the following if cluse 
            //@gar-768
            if (customer.indexOf('"industryCodes":null') > 0) {
                if (acc.industry_Minor_Category != oldacc.industry_Minor_Category || totalSync) {
                    String newCustomerStr1 = customer.substring(0, customer.indexOf('"industryCodes"'));
                    String newCustomerStr2 = customer.substring(customer.indexOf('"industryCodes"'));
                    String IndustryMinorCategory = (!String.isBlank(acc.industry_Minor_Category) ? acc.industry_Minor_Category.split('-')[0].trim() : '');
                    If(IndustryMinorCategory != '') {
                        newCustomerStr2 = '"industryCodes": { "industryCode":[{"code":"' + IndustryMinorCategory + '"}]},' + newCustomerStr2.substring(newCustomerStr2.indexOf('"salesTerritories"'));
                    } else {
                        newCustomerStr2 = '"industryCodes":null,' + newCustomerStr2.substring(newCustomerStr2.indexOf('"salesTerritories"'));
                    }
                    newCustomerStr1 += newCustomerStr2;

                    customer = newCustomerStr1;
                    industryMinorCategoryChange = true;
                }
            } else {
                if (acc.industry_Minor_Category != oldacc.industry_Minor_Category || totalSync) {
                    String IndustryMinorCategory = (!String.isBlank(acc.industry_Minor_Category) ? acc.industry_Minor_Category.split('-')[0].trim() : '');
                    if (IndustryMinorCategory == '') {
                        String newCustomerStr1 = customer.substring(0, customer.indexOf('"industryCodes"'));
                        String newCustomerStr2 = customer.substring(customer.indexOf('"industryCodes"'));
                        newCustomerStr2 = '"industryCodes":null,' + newCustomerStr2.substring(newCustomerStr2.indexOf('"salesTerritories"'));
                        newCustomerStr1 += newCustomerStr2;

                        customer = newCustomerStr1;

                        industryMinorCategoryChange = true;
                    } else {
                        String newCustomerStr1 = customer.substring(0, customer.indexOf('"industryCodes"'));
                        String newCustomerStr2 = customer.substring(customer.indexOf('"industryCodes"'));
                        newCustomerStr2 = newCustomerStr2.substring(0, newCustomerStr2.indexOf('"code"')) + '"code" :"' + IndustryMinorCategory + '",' + newCustomerStr2.substring(newCustomerStr2.indexOf('"description"'));
                        newCustomerStr1 += newCustomerStr2;

                        customer = newCustomerStr1;

                        industryMinorCategoryChange = true;
                    }
                }
            }

            system.debug('Updated customer :' + customer);
            /*/check if the type is Direct Advertiser Add the agency role to the customer string 
            if(acc.accountType == 'Direct Advertiser'){
                customer = addAgencyRoles(customer);
            }*/
            system.debug('Updated customer after agency roles added:' + customer);
            //changed for GAR-767
            String endpointUrl;
            if(isMail){
                endpointUrl = Common.cci.Domain__c + Common.cci.CustomerPath__c + '/' + acc.cciMailId;
            }else{
                endpointUrl = Common.cci.Domain__c + Common.cci.CustomerPath__c + '/' + acc.cciMetroId;
            }




            System.debug('endpointUrl:' + endpointUrl);

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
            //set method  
            req.setMethod('PUT');
            req.setHeader('Content-Type', Common.cci.ContentType__c);

            // req.setBody(JSON.serialize(customerMap.values()));

            req.setBody(customer);
            /*req.setHeader('x-cci-user', Common.userInformation.CCI_User_Id__c);
        req.setHeader('x-cci-profile', Common.userInformation.CCI_Profile__c);
        req.setHeader('x-cci-group', Common.userInformation.CCI_Group_Id__c);*/

            if (Common.sharedSecret != null) {
                //List<String> sList = common.userInformation.Email.split('@',2);
                //req.SetHeader('x-cci-user', sList[0]);    
                req.SetHeader('x-cci-user', Common.cciuser);
            }
            req.setHeader('x-cci-profile', Common.userProfile());
            req.setHeader('x-cci-group', Common.userGroup());
            //req.setHeader('Authorization', tokenInfo.token_type +' '+tokenInfo.access_token); 
            req.setHeader('Authorization', Common.cciToken.token_type + ' ' + Common.cciToken.access_token);

            req.setEndpoint(endpointUrl);
            system.debug('***req : ' + req);
            HTTPResponse res = new HTTPResponse();
            //change the user details if the operation needs to be done by Service user
            if (Common.isUpdateByServiceUser(isMail)) {
                req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
                req.setHeader('x-cci-profile', isMail ? Common.cci.ServiceUserMailProfile__c : Common.cci.ServiceUserMetroProfile__c);
                req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
            }
            try {
                res = http.send(req);
                ///*gar-795
                if(acc.accountType == 'Direct Advertiser' && (res.getStatusCode() == 201 || res.getStatusCode() == 200)){
                	customer = res.getBody(); 
	                customer = addAgencyRoles(customer);
	                system.debug('after agency : '+customer);
	                req.setHeader('Authorization', Common.cciToken.token_type + ' ' + Common.cciToken.access_token);
	                req.setBody(customer);
	                res = http.send(req);
	            }//*/
            } catch (System.CalloutException e) {
                System.debug('*****' + e.getMessage());
            }

            System.debug(String.ValueOf(res) == null ? null : res.getBody());

            if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {

                //Common.addChatterFeedToObject(acc.accountId, 'Account has failed to update the following in CCI '+(accountNameChange?'Account':null)+(phoneChange?', Phone':null)+(billingStreetChange?', Billing Street':null)+(billingCityChange?', Billing City':null)+(billingPostalCodeChange?', Billing Postal Code':null)+(industryMinorCategoryChange?', Industry Minor Code':null));
                String desc1 = Common.addErrorMsgToDesc(res.getBody());
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(acc.accountId, 'Account ' + acc.name + ' has failed to update the following in CCI ' + (accountNameChange ? 'Account' : '') + (phoneChange ? ', Phone' : '') + (billingStreetChange ? ', Billing Street' : '') + (billingCityChange ? ', Billing City' : '') + (billingStateChange ? ', Billing State' : '') + (billingPostalCodeChange ? ', Billing Postal Code' : '') + (billingCountryChange ? ', Billing Country' : '') + (industryMinorCategoryChange ? ', Industry Minor Code' : '')));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = acc.accountId,
                Description__c = !String.IsBlank(desc1)?desc1:'Account ' + acc.name + ' has failed to update the following in CCI ' + (accountNameChange ? 'Account' : '') + (phoneChange ? ', Phone' : '') + (billingStreetChange ? ', Billing Street' : '') + (billingCityChange ? ', Billing City' : '') + (billingStateChange ? ', Billing State' : '') + (billingPostalCodeChange ? ', Billing Postal Code' : '') + (billingCountryChange ? ', Billing Country' : '') + (industryMinorCategoryChange ? ', Industry Minor Code' : ''),
                Exception__c = res.getBody(),
                Status__c = 'Failure');
                Common.integLogs.add(intL);
            } else {
                System.debug('Update Customer:' + res.getBody());
                // Common.addChatterFeedToObject(acc.accountId, 'Account has been updated successfully in CCI.');
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(acc.accountId, 'Account ' + acc.name + ' has been updated successfully in CCI.'));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = acc.accountId,
                Description__c = 'Account ' + acc.name + ' has been updated successfully in CCI.',
                Status__c = 'Success');
                Common.integLogs.add(intL);
            }
        } catch (Exception e) {
            String errorMessage = 'Account ' + acc.name + ' has failed to update due to ' + e.getMessage();
            String desc1 = Common.addErrorMsgToDesc(e.getMessage());
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(acc.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI ' +dbType,
            Account__c = acc.accountId,
            Description__c = !String.IsBlank(desc1)?desc1:errorMessage,
            Exception__c = e.getMessage(),
            Status__c = 'Failure');
            if(intL.Description__c.length()>255)
                intL.Description__c = intL.Description__c.subString(0, 255);
            Common.integLogs.add(intL);
        }/*
        // Finanace Account creation for Direct Advertiser
        if(acc.accountType == 'Direct Advertiser' && oldAcc.accountType == 'Client'){
            map < Id, list < FinanceAccount__c >> newFinanceAccountsMap = new map < Id, list < FinanceAccount__c >> ();
            Company__c mailCompany = [SELECT ID from Company__c where name like '%Mail%' Limit 1];
            Company__c metroCompany = [SELECT ID from Company__c where name like '%Metro%' Limit 1];
            map < String, Integer > financeAccountMap = new map < String, Integer > ();
            list < FinanceAccount__c > financeAccountsToInsert = new list < FinanceAccount__c > ();
            
            for (FinanceAccount__c fA: [select id, Company__c, CCIMailCustomerID__c, CCIMetroCustomerID__c, Account__c from FinanceAccount__c where Account__c =: acc.accountId]) {
                if (fa.Company__c == mailCompany.id) {
                    if (!financeAccountMap.containsKey(fA.CCIMailCustomerID__c)) financeAccountMap.put(fA.CCIMailCustomerID__c, 0);
                    financeAccountMap.put(fA.CCIMailCustomerID__c, financeAccountMap.get(fA.CCIMailCustomerID__c) + 1);
                }
                if (fa.Company__c == metroCompany.id) {
                    if (!financeAccountMap.containsKey(fA.CCIMetroCustomerID__c)) financeAccountMap.put(fA.CCIMetroCustomerID__c, 0);
                    financeAccountMap.put(fA.CCIMetroCustomerID__c, financeAccountMap.get(fA.CCIMetroCustomerID__c) + 1);
                }
            }
            
            //if type changes from client to direct advertiser
            //check for phone and address values in old map of account 
            
            if (!(financeAccountMap.containsKey(acc.cciMailId) && financeAccountMap.get(acc.cciMailId) > 0)) {
                FinanceAccount__c newFinAcc = new FinanceAccount__c();
                newFinAcc.Account__c = acc.accountId;
                newFinAcc.Company__c = mailCompany.id;
                financeAccountsToInsert.add(newFinAcc);
                if (!newFinanceAccountsMap.containsKey(acc.accountid)) {
                    newFinanceAccountsMap.put(acc.accountid, new list < FinanceAccount__c > ());
                }
                newFinanceAccountsMap.get(acc.accountid).add(newFinAcc);
            }
            
            if (!(financeAccountMap.containsKey(acc.cciMetroId) && financeAccountMap.get(acc.cciMetroId) > 0)) {
                FinanceAccount__c newFinAcc = new FinanceAccount__c();
                newFinAcc.Account__c = acc.accountId;
                newFinAcc.Company__c = metroCompany.id;
                financeAccountsToInsert.add(newFinAcc);
                if (!newFinanceAccountsMap.containsKey(acc.accountid)) {
                    newFinanceAccountsMap.put(acc.accountid, new list < FinanceAccount__c > ());
                }
                newFinanceAccountsMap.get(acc.accountid).add(newFinAcc);
            }

            if (financeAccountsToInsert.size() > 0) {
                insert financeAccountsToInsert;
            }
            
            createFinanceAccountForDirectAdvertiser(financeAccountsToInsert);
        }*/
    }



    //added for activate/deactivate accounts

    public static void updateCustomerStatus(AccountMappingInfo mapping, String customer, Boolean isMail) {
    String dbType = IsMail?'Mail':'Metro';
        try {

            //Map<String, Object> customerMap = (Map<String, Object>) JSON.deserializeUntyped(customer);
            String statusCode;
            String statusName;

            if (!mapping.active) {
                statusCode = 'CLOSED';
                statusName = 'Closed';
            } else {
                statusCode = 'REOPEN';
                statusName = 'Re-Open';
            }
            customer = customer.substring(0, customer.indexOf('"statusCode"')) + '"statusCode" : "' + statusCode + '",' + '"statusName" : "' + statusName + '",' + customer.substring(customer.indexOf('doQuotesOnly') - 1);
            system.debug('Updated customer :' + customer);

            String endpointUrl = Common.cci.Domain__c + Common.cci.CustomerPath__c + '/' + mapping.sourceKey;

            System.debug('endpointUrl:' + endpointUrl);

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
            //set method  
            req.setMethod('PUT');
            req.setHeader('Content-Type', Common.cci.ContentType__c);

            req.setBody(customer);
            /*req.setHeader('x-cci-user', Common.userInformation.CCI_User_Id__c);
        req.setHeader('x-cci-profile', Common.userInformation.CCI_Profile__c);
        req.setHeader('x-cci-group', Common.userInformation.CCI_Group_Id__c);*/

            if (Common.sharedSecret != null) {
                //List<String> sList = common.userInformation.Email.split('@',2);
                //req.SetHeader('x-cci-user', sList[0]);    
                req.SetHeader('x-cci-user', Common.cciuser);
            }
            req.setHeader('x-cci-profile', Common.userProfile());
            req.setHeader('x-cci-group', Common.userGroup());
            //req.setHeader('Authorization', tokenInfo.token_type +' '+tokenInfo.access_token); 
            req.setHeader('Authorization', Common.cciToken.token_type + ' ' + Common.cciToken.access_token);

            req.setEndpoint(endpointUrl);
            system.debug('***req : ' + req);
            HTTPResponse res = new HTTPResponse();
            //change the user details if the operation needs to be done by Service user
            if (Common.isUpdateByServiceUser(isMail)) {
                req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
                req.setHeader('x-cci-profile', isMail ? Common.cci.ServiceUserMailProfile__c : Common.cci.ServiceUserMetroProfile__c);
                req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
            }
            try {
                res = http.send(req);
            } catch (System.CalloutException e) {
                System.debug('*****' + e.getMessage());
                Common.addChatterFeedToObject(mapping.accountId, 'Account has failed to update the Status in CCI to ' + statusName);
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(mapping.accountId, 'Account has failed to update the Status in CCI to' + statusName + '.'));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = mapping.accountId,
                Description__c = 'Account has failed to update the Status in CCI to' + statusName,
                Exception__c = res.getBody(),
                Status__c = 'Failure');
                Common.integLogs.add(intL);
            }

            System.debug(String.ValueOf(res) == null ? null : res.getBody());

            if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {

                Common.addChatterFeedToObject(mapping.accountId, 'Account has failed to update the Status in CCI to ' + statusName);
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(mapping.accountId, 'Account has failed to update the Status in CCI to' + statusName + '.'));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = mapping.accountId,
                Description__c = 'Account has failed to update the Status in CCI to' + statusName + '.',
                Exception__c = res.getBody(),
                Status__c = 'Failure');
                Common.integLogs.add(intL);
            } else {
                System.debug('Update Customer:' + res.getBody());
                // Common.addChatterFeedToObject(acc.accountId, 'Account has been updated successfully in CCI.');
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(mapping.accountId, 'Account has been updated successfully in CCI to' + statusName));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = mapping.accountId,
                Description__c = 'Account Status has been updated successfully in CCI to' + statusName + '.',
                Status__c = 'Success');
                Common.integLogs.add(intL);
            }
        } catch (Exception e) {
           // String errorMessage = 'Account Status has failed to update due to ' + e.getMessage();
             String errorMessage = 'Account Status has failed to update due to ' + Common.addErrorMsgToDesc(e.getMessage());
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(mapping.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI ' +dbType,
            Account__c = mapping.accountId,
            Description__c = errorMessage,
            Exception__c = e.getMessage(),
            Status__c = 'Failure');
            Common.integLogs.add(intL);
        }
    }

    // Query CCI for the specific Customer Account
    public static String getCustomerData(CCICustomerWrapper.AccountInfo account, CCICustomerWrapper.AccessToken tokenInfo, Boolean isMail) {

        String dbType = IsMail?'Mail':'Metro';
        System.debug('Account:' + account);

        String endpointUrl = Common.cci.Domain__c + Common.cci.CustomerPath__c + '/' + (isMail ? account.cciMailId : account.cciMetroId);

        System.debug('endpointUrl:' + endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        HTTPResponse res = new Httpresponse();
        //set method  
        req.setMethod('GET');
        try {
            // req.setHeader('Content-Type', cci.ContentType__c);
            if (Common.sharedSecret != null) {
                //List<String> sList = common.userInformation.Email.split('@',2);
                //req.SetHeader('x-cci-user', sList[0]);   
                req.SetHeader('x-cci-user', Common.cciuser);
            }
            req.setHeader('x-cci-profile', Common.userProfile());
            req.setHeader('x-cci-group', Common.userGroup());
            // req.setHeader('Authorization', tokenInfo.token_type +' '+tokenInfo.access_token);
            req.setHeader('Authorization', Common.cciToken.token_type + ' ' + Common.cciToken.access_token);


            req.setEndpoint(endpointUrl);
            if (Common.isUpdateByServiceUser(isMail)) {
                req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
                req.setHeader('x-cci-profile', isMail ? Common.cci.ServiceUserMailProfile__c : Common.cci.ServiceUserMetroProfile__c);
                req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
            }
            try {
                res = http.send(req);
            } catch (System.CalloutException e) {
                string errorMessage = 'Failed to connect to CCI.' + '(CCI ' + ((isMail == true) ? 'Mail ' : 'Metro ') + 'Customer Id is: ' + ((isMail == true) ? account.cciMailId : account.cciMetroId) + ')';
                // Common.addChatterFeedToObject(account.accountId, 'Failed to connect to CCI.');
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = account.accountId,
                Description__c = errorMessage,
                Exception__c = res.getBody(),
                Status__c = 'Failure');
                intl.Status_Code__c = '' + res.getStatusCode();
                intl.Status_Message__c = res.getStatus();
                if(intL.Description__c.length()>255)
                    intL.Description__c = intL.Description__c.subString(0, 255);
                Common.integLogs.add(intL);
                System.debug('*****' + e.getMessage());
            }
        } catch (Exception e) {
           // string errorMessage = e.getMessage() + '(CCI ' + ((isMail == true) ? 'Mail ' : 'Metro ') + 'Customer Id is: ' + ((isMail == true) ? account.cciMailId : account.cciMetroId) + ')';
            string errorMessage =Common.addErrorMsgToDesc(e.getMessage()) + '(CCI ' + ((isMail == true) ? 'Mail ' : 'Metro ') + 'Customer Id is: ' + ((isMail == true) ? account.cciMailId : account.cciMetroId) + ')';
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI ' +dbType,
            Account__c = account.accountId,
            Description__c = errorMessage,
            Exception__c = res != null ? res.getBody() : '',
            Status__c = 'Failure');
            if(intL.Description__c.length()>255)
                intL.Description__c = intL.Description__c.subString(0, 255);
            intl.Status_Code__c = '' + res.getStatusCode();
            intl.Status_Message__c = res.getStatus();
            Common.integLogs.add(intL);
        }
        System.debug('getCustomerData res:' + String.ValueOf(res) == null ? null : res.getBody());

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            string errorMessage = 'Failed to get CCI Customer data.(CCI ' + ((isMail == true) ? 'Mail ' : 'Metro ') + 'Customer Id is: ' + ((isMail == true) ? account.cciMailId : account.cciMetroId) + ')';
            //Common.addChatterFeedToObject(account.accountId, 'Failed to get CCI Customer data.');
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI ' +dbType,
            Account__c = account.accountId,
            Description__c = errorMessage,
            Exception__c = res.getBody(),
            Status__c = 'Failure');
            if(intL.Description__c.length()>255)
                intL.Description__c = intL.Description__c.subString(0, 255);
            intl.Status_Code__c = string.valueof(res.getStatusCode());
            intl.Status_Message__c = res.getStatus();
            Common.integLogs.add(intL);
            return null;

        } else {
            Map < String, Object > responseMap = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
            System.debug('responseMap:' + responseMap);

            System.debug('responseMap.keyset:' + responseMap.keyset());


            /*String jsonStr = '['+res.getBody()+']';
            JSONParser parser = JSON.createParser(jsonStr);
            List<AccessToken> deserializedContent = 
            (List<AccessToken>)JSON.deserialize(jsonStr, List<AccessToken>.class);*/

            //return deserializedContent[0];    
            return res.getBody();
        }
    }
    // work in progress this method to be used when getting customer for activation/deactivation
    public static String getCustomerDataFromAccountMapping(AccountMappingInfo mapInfo, Boolean isMail) {

        String dbType = IsMail?'Mail':'Metro';
        String endpointUrl = Common.cci.Domain__c + Common.cci.CustomerPath__c + '/' + mapInfo.sourceKey;

        System.debug('endpointUrl:' + endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        HTTPResponse res = new Httpresponse();
        //set method  
        req.setMethod('GET');
        try {
            // req.setHeader('Content-Type', cci.ContentType__c);
            if (Common.sharedSecret != null) {

                req.SetHeader('x-cci-user', Common.cciuser);
            }
            req.setHeader('x-cci-profile', Common.userProfile());
            req.setHeader('x-cci-group', Common.userGroup());
            // req.setHeader('Authorization', tokenInfo.token_type +' '+tokenInfo.access_token);
            req.setHeader('Authorization', Common.cciToken.token_type + ' ' + Common.cciToken.access_token);


            req.setEndpoint(endpointUrl);
            if (Common.isUpdateByServiceUser(isMail)) {
                req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
                req.setHeader('x-cci-profile', isMail ? Common.cci.ServiceUserMailProfile__c : Common.cci.ServiceUserMetroProfile__c);
                req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
            }
            try {
                res = http.send(req);
            } catch (System.CalloutException e) {
                string errorMessage = 'Failed to connect to CCI.' + 'Customer Id is: ' + mapInfo.accountId;
                Common.addChatterFeedToObject(mapInfo.accountId, 'Failed to connect to CCI.');
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(mapInfo.accountId, errorMessage));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI ' +dbType,
                Account__c = mapInfo.accountId,
                Description__c = errorMessage,
                Exception__c = res.getBody() + e,
                Status__c = 'Failure');
                if(intL.Description__c.length()>255)
                    intL.Description__c = intL.Description__c.subString(0, 255);
                intl.Status_Code__c = '' + res.getStatusCode();
                intl.Status_Message__c = res.getStatus();
                Common.integLogs.add(intL);
                System.debug('*****' + e.getMessage());
            }
        } catch (Exception e) {
            string errorMessage = e.getMessage() + '(CCI Customer Id is: ' + mapInfo.accountId + ')';
            String desc1 = Common.addErrorMsgToDesc(e.getMessage());
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(mapInfo.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI ' +dbType,
            Account__c = mapInfo.accountId,
            Description__c = !String.IsBlank(desc1)?desc1:errorMessage,
            Exception__c = res != null ? res.getBody() : '',
            Status__c = 'Failure');
            if(intL.Description__c.length()>255)
                intL.Description__c = intL.Description__c.subString(0, 255);
            intl.Status_Code__c = '' + res.getStatusCode();
            intl.Status_Message__c = res.getStatus();
            Common.integLogs.add(intL);
        }
        System.debug('getCustomerData res:' + String.ValueOf(res) == null ? null : res.getBody());

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            /* string errorMessage = 'Failed to get CCI Customer data.(CCI ' + ((isMail == true) ? 'Mail ' : 'Metro ') + 'Customer Id is: ' + ((isMail == true) ? account.cciMailId : account.cciMetroId) + ')';
            //Common.addChatterFeedToObject(account.accountId, 'Failed to get CCI Customer data.');
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI ' +dbType,
            Account__c = account.accountId,
            Description__c = errorMessage,
            Exception__c = res.getBody(),
            Status__c = 'Failure');
            intl.Status_Code__c = string.valueof(res.getStatusCode());
            intl.Status_Message__c = res.getStatus();
            Common.integLogs.add(intL);*/
            return null;

        } else {
            Map < String, Object > responseMap = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
            System.debug('responseMap:' + responseMap);

            System.debug('responseMap.keyset:' + responseMap.keyset());
            return res.getBody();
        }
    }

    public static void updateCustomerWithAgencyRole(String accId) {
        System.debug('Entered:updateCustomerWithAgencyRole');

        /* if((a.) && 
                        (a.CCIMailCustID__c!=null || a.CCIMetroCustID__c!=null) ){
                        
                        CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(a.Id, a.Name, a.Phone, a.BillingStreet, a.BillingCity, a.BillingPostalCode, a.BillingState, a.BillingCountry, a.Industry_Minor_Category__c, a.CCIMailCustID__c, a.CCIMetroCustID__c, a.NPA__c, a.Type, a.FirstName__c, a.Salutation__c);
                        accMap.put(a.id, JSON.serialize(ai));
                        CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(a.Id, oldAccountMap.get(a.Id).Name, oldAccountMap.get(a.Id).Phone, oldAccountMap.get(a.Id).BillingStreet, oldAccountMap.get(a.Id).BillingCity, oldAccountMap.get(a.Id).BillingPostalCode, oldAccountMap.get(a.Id).BillingState, oldAccountMap.get(a.Id).BillingCountry, oldAccountMap.get(a.Id).Industry_Minor_Category__c,  oldAccountMap.get(a.Id).CCIMailCustID__c,  oldAccountMap.get(a.Id).CCIMetroCustID__c, oldAccountMap.get(a.Id).NPA__c, oldAccountMap.get(a.ID).Type, oldAccountMap.get(a.ID).FirstName__c, oldAccountMap.get(a.ID).Salutation__c);
                        oldAccMap.put(a.id, JSON.serialize(oldai));
                        totalSync = true;
                    }
                }
                if(accMap.size()>0 && !test.isRunningTest())
                {
                    CCICustomerWebService.getCCIAccount(accMap.values(), oldAccMap.values(), totalSync);
                }
            }
            firstAttempt=false;
            //}
        }*/
    }
}