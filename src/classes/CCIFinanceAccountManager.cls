/************************************************************************************************************************                                                                                         
 
 

 
 Code purpose  : Class reponsible for synchronizing changes on account with CCI(external system):
   
 Api version   : v1

****************************************************************************************************************************/
public without sharing class CCIFinanceAccountManager {


    /*  @future (callout=true)
    public static void createCCIMailAccountAsync(List<Id> accIds){
      //  createCCIAccount(accIds,'Mail');
    
    }*/

    public static Id firstAccountId {
        get;
        set;
    }



    // Method does call out to CCI creating new customer account

    public static Map < String, String > createCCIAccount(List < FinanceAccount__c > accs, User user, boolean directOrder) {
        System.debug('Entered createCCIAccount.........and Accs is' + accs);
        string errorResponse = null;
        List < FinanceAccount__c > actErrors = new List < FinanceAccount__c > ();
        Map < String, String > mErrorResponse = new Map < String, String > (); // key - account id
        Map < ID, FinanceAccount__c > mNewAccounts = new Map < ID, FinanceAccount__c > (); // key - account id
        List < FinanceAccount__c > liupdatedAccounts = new List < FinanceAccount__c > ();
        String username = user.CCI_User_Id__c;
        String password = user.CCI_User_Password__c;
        String domain;
        String accPath;
        String authString;
        String contentType;
        Map < String, String > responseMap = new Map < String, String > ();
        String strResponse = null;
        // List<Integration_Logs__c> integLogs = new List<Integration_Logs__c> ();
        Map < FinanceAccount__c, Exception > errorMap = new Map < FinanceAccount__c, Exception > ();
        List < FinanceAccount__c > liAccs = new List < FinanceAccount__c > ();
        List < Id > accIds = new List < Id > ();
        String dbType = 'Mail';


        try {
            BookingSystemSettings__c setting = Common.cci; //BookingSystemSettings__c.getInstance('CCI');
            if (setting != null) {
                domain = setting.Domain__c;
                accPath = setting.AccountPath__c;
                authString = setting.AuthenticationPath__c;
                /*authString  = authString.replace('<username>',username);
                authString = authString.replace('<password>',password);*/
                contentType = setting.ContentType__c;
                //if(domain==null ||accPath==null||authString==null||contentType==null){
                if (domain == null || accPath == null || contentType == null) {
                    throw new BookingSystemSettingsException();
                }
                if (String.IsBlank(Common.sharedSecret) && (String.ISBlank(username) || String.ISBlank(user.CCI_Profile__c) || String.ISBlank(password) || String.ISBlank(user.CCI_Group_Id__c))) throw new CCIApiException(Label.Missing_Shared_Secret);

            } else {

                throw new BookingSystemSettingsException();
            }

            // String query = getAccountQuery (accIds); // get all fields for query

            // liAccs = Database.query(query);
            liAccs = accs;
            System.debug('LiAccs is' + liAccs);
            //String accessToken = getAccessTokenForCustomer(domain+authString,contentType);
            String accessToken = Common.cciToken.access_token;
            System.debug('Token is' + accessToken);

            String userType = common.getUserType(user);
            if (userType == 'Metro') dbType = 'Metro';
            for (FinanceAccount__c acc: liAccs) {
                System.debug('Entered for loop for liaccs');
                String  finAccInCCI='';
                try {
                   // String customerId= dbType=='Mail'?acc.Account__r.CCIMailCustId__c:acc.Account__r.CCIMetroCustId__c;
                    //check if fin acc already eixst in CCI for this customer and company
                   /* try{
                        finAccInCCI = finAccFromCCIExists(customerId,domain+accPath,accessToken,contentType,user, dbType);
                        }catch(Exception e){
                            System.debug('Caught in Exception');
                            System.debug('Exception is'+e);
                        }
                    //if exists update sop id to the account
                    if(!String.IsBlank(finAccInCCI) ){
                    responseMap.put(acc.id,finAccInCCI );
                    
                    }else{*/
                    CCIAccountCreation account = new CCIAccountCreation(acc);
                    System.debug('Fin Account is' + account);
                    strResponse = sendAccountCreateRequest(account, accessToken, domain + accPath, contentType, user,dbType);
                    String response = ObjectUpdateFromCCIResponse.updateFinanceMapping(strResponse);
                    System.debug('Got response sucess' + response);

                    responseMap.put(acc.id, response);
                  //  }
                    accIds.add(acc.id);



                } catch (CCIApiException e) {
                    System.debug('CCIApiException' + e);
                    errorMap.put(acc, e);
                    actErrors.add(acc);
                    if ((e.getMessage()).contains('The zip code is invalid')) {

                        mErrorResponse.put(acc.id, Label.Invalid_Zip);
                    } else {

                        mErrorResponse.put(acc.id, Label.CCI_Exception);

                    }
                } catch (Exception e) {
                    System.debug('Exception' + e);
                    errorMap.put(acc, e);
                    actErrors.add(acc);
                    mErrorResponse.put(acc.id, Label.CCI_Exception);

                }
            }


            if (actErrors != null && actErrors.size() > 0) {
                System.debug('Inside AcctError' + actErrors);
                for (FinanceAccount__c acc: actErrors) {
                    Integration_Logs__c log = new Integration_Logs__c();
                    log.Source__c = 'CCI';
                    log.Finance_Account__c = acc.Id;
                    log.Description__c = Common.addErrorMsgToDesc(errorMap.get(acc).getMessage());
                    if(String.IsBlank(log.Description__c))log.Description__c=Label.CCI_Exception;
                    if(log.Description__c.length()>255)
                        log.Description__c = log.Description__c.subString(0, 255);
                    log.Status__c = 'Failure';
                    log.Exception__c = errorMap.get(acc).getMessage();
                    //  log.timeRecorded4Order__c = time4Order;
                    Common.integLogs.add(log);
                }

                insert Common.integLogs;
            }

            for (FinanceAccount__c acc: liAccs) {
                System.debug('Inside for loop to update Finance Account');
                System.debug('Response Map is' + responseMap);
                String response = responseMap.get(acc.id);
                System.debug('Response is' + response);
                if (response != null && response != '') {
                    acc.SOP_ID__c = response;
                    acc.SOP_Source__c = 'CCI';
                    //   acc.RecordType.Id = '012M0000000D1KX';
                }



                System.debug('before upset finance accounts');
                upsert liAccs;
            }
        } catch (BookingSystemSettingsException e) {
            System.debug('BookingSystem Setting Exception' + e);

            List < Integration_Logs__c > integrationLogList = new List < Integration_Logs__c > ();
            
            for (Id id: accIds) {
               
                mErrorResponse.put(id, Label.No_Custom_Setting_Value + 'for Booking System settings');
                integrationLogList.add(
                new Integration_Logs__c(
                Source__c = 'CCI',
                Finance_Account__c = id,
                Description__c = Label.CCI_Exception,
                Exception__c = e.getMessage(),
                Status__c = 'Failure'
                //, timeRecorded4Order__c = time4Order
                ));
            }
            if (integrationLogList.size() > 0) {
                insert integrationLogList;
            }



        } catch (Exception e) {
            System.debug('Exception' + e);
            List < Integration_Logs__c > integrationLogList = new List < Integration_Logs__c > ();
            for (Id id: accIds) {
                mErrorResponse.put(id, Label.CCI_Exception);
                integrationLogList.add(
                new Integration_Logs__c(
                Source__c = 'CCI',
                Finance_Account__c = id,
                Description__c = Label.CCI_Exception,
                Status__c = 'Failure',
                Exception__c = e.getMessage()
                // ,timeRecorded4Order__c = time4Order
                ));
            }
            if (integrationLogList.size() > 0) {
                insert integrationLogList;
            }

        }





        if (directOrder) return responseMap;
        System.debug('MErrorResponse is' + mErrorResponse);
        return mErrorResponse;
    }



   public static String finAccFromCCIExists(String customerId,String accPath,String accessToken,String contentType,User u,String dbType){
   
       HttpRequest req = new HttpRequest();
       req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
       req.setMethod('GET');
       req.setEndpoint(accPath+'?q='+customerId);
       req.setHeader('Content-Type', contentType);
       if(u.Virtual_Data_Team_Member__c){
             System.debug('Virtual Data Team Member');
              req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
              req.setHeader('x-cci-profile', dbType=='Mail' ? Common.cci.ServiceUserMailProfile__c : Common.cci.ServiceUserMetroProfile__c);
              req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
         
         }
       else{
            if (Common.sharedSecret != null) {
            //List<String> sList = common.userInformation.Email.split('@',2);
            //req.SetHeader('x-cci-user', sList[0]);   
                req.SetHeader('x-cci-user', Common.cciuser);
                req.SetHeader('x-cci-profile', common.userProfile());
                req.SetHeader('x-cci-group', common.userGroup());
             }

            
        }

        req.SetHeader('Authorization', 'bearer ' + accessToken);
        //   req.setCompressed(true);   
        //req.setBody();
      
        system.debug('req to ckeck fin acc in CCI...' + req.toString());
        
        String response = handleResponse(req);
        Map<String, Object> mWholeResponse = (Map<String, Object>) JSON.deserializeUntyped(response  );
        String accountId = (String) mWholeResponse.get('accountId') ;
        return accountId ;
        

        
   
   
   }
    public static String sendaccountCreateRequest(CCIAccountCreation acc, String accessToken, String accPath, String contentType, User user,String dbType) {
        System.debug('CCIAccountCreation is' + acc);
        String jsonreq = acc.getReqJsonBody();
        System.debug('jsonReq is' + jsonreq);
        String updatedjson = jsonreq.replace('ExternalSystem', 'system');
        updatedjson = updatedjson.replace('"id"', '"externalId"');
        System.debug('updatedjson:' + updatedjson);
        HttpRequest req = buildRequest(accPath, updatedjson, accessToken, contentType, user,dbtype=='Mail'?true:false);

        return handleResponse(req);
        return null;

    }


    /*  public static String getAccessTokenForCustomer(String authPath,String contentType){

  //   HttpRequest req = buildAccessTokenRequest('api/authentication/oauth/token?grant_type=password&client_id=app&username=male&password=dmg2013', 
   //                                    '');
                                       
       HttpRequest req = buildAccessTokenRequest(authPath, 
                                       '',contentType);
        
        
        String response  = handleResponse(req);
        Map<String, Object> mWholeResponse = (Map<String, Object>) JSON.deserializeUntyped(response  );
        String accessToken  = (String) mWholeResponse.get('access_token') ;
        return accessToken  ;
    
    }
    
     private static HttpRequest buildAccessTokenRequest(String path, String requestXML,String contentType) {
       System.debug('Entered buildRequest'+ requestXML);
         System.debug('Path is'+ path);

        
                 
               //create a new instance of httprequest  
        HttpRequest req = new HttpRequest();  
        //set method  
        req.setMethod('POST');  
        req.setEndpoint(path);   
        req.setHeader('Content-Type', contentType);  
        
       
     //   req.setCompressed(true);   
        req.setBody(requestXML);  
       // req.setTimeout(60000); // timeout in milliseconds 
        system.debug('Envelope is...'+requestXML);
        system.debug('req...' + req.toString());
           
        return req;
    } */

    private static HttpRequest buildRequest(String cusPath, String requestXML, String accessToken, String contentType, User u,Boolean isMail) {
        System.debug('Entered buildRequest' + requestXML);


        //create a new instance of httprequest  
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        //set method  
        req.setMethod('POST');
        req.setEndpoint(cusPath);
        req.setHeader('Content-Type', contentType);
        if(u.Virtual_Data_Team_Member__c){
             System.debug('Virtual Data Team Member');
              req.SetHeader('x-cci-user', Common.cci.ServiceUserName__c);
              req.setHeader('x-cci-profile', isMail ? Common.cci.ServiceUserMailProfile__c : Common.cci.ServiceUserMetroProfile__c);
              req.setHeader('x-cci-group', Common.cci.ServiceUserGroup__c);
         
         }
       else{
            if (Common.sharedSecret != null) {
            //List<String> sList = common.userInformation.Email.split('@',2);
            //req.SetHeader('x-cci-user', sList[0]);   
                req.SetHeader('x-cci-user', Common.cciuser);
        }

            req.SetHeader('x-cci-profile', common.userProfile());
            req.SetHeader('x-cci-group', common.userGroup());
        }

        //req.SetHeader('x-cci-profile',u.CCI_Profile__c);
        //req.SetHeader('x-cci-group',u.CCI_Group_Id__c);
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
        //if (!Test.isRunningTest()){
        res = http.send(req);
        // }

        system.debug('res....' + res);
        System.debug('Response is ' + res.getBody());
        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            throw new CCIApiException(res.getBody());
        }

        return res.getBody();
    }

    /* public static String getAccountQuery (List<Id> accIds){
       
        String retVal = Database.getQueryLocator([SELECT Id, 
                                             CCIMailCustomerID__c , CCIMetroCustomerID__c,Company__r.Name,SOP_ID__c,SOP_Source__c,RecordType.Id        
                                                                                   
                                    FROM FinanceAccount__c 
                                      WHERE ID in :accIds]).getQuery();
        System.debug('>>>Query = ' + retVal);
        return retVal;
    }*/

    public static String getAccountData(CCIAccountCreation.AccountInfo account, CCICustomerWrapper.AccessToken tokenInfo) {
        System.debug('Account:' + account);

       String endpointUrl = Common.cci.Domain__c + Common.cci.AccountPath__c + '/' + account.sopId;

        System.debug('endpointUrl:' + endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        HTTPResponse res = new HTTPResponse();
        //set method  
        req.setMethod('GET');
       
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

            try {
                res = http.send(req);
            } catch (System.CalloutException e) {
                string errorMessage = 'Failed to integrate with CCI.' + 'Account Id is: ' + account.sopId;
                // Common.addChatterFeedToObject(account.accountId, 'Failed to connect to CCI.');
                Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
                Integration_Logs__c intL = new Integration_Logs__c(
                Source__c = 'CCI',
                Finance_Account__c = account.accountId,
                Description__c = errorMessage,
                Exception__c = res.getBody() + '-' + e,
                Status__c = 'Failure');
                intl.Status_Code__c = '' + res.getStatusCode();
                intl.Status_Message__c = res.getStatus();
                Common.integLogs.add(intL);
                System.debug('*****' + e.getMessage());
                return null;
            
        } catch (Exception e) {
            string errorMessage = 'Failed to integrate with CCI.' + 'Account Id is: ' + account.sopId;
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI',
            Finance_Account__c = account.accountId,
            Description__c = errorMessage,
            Exception__c = res.getBody()+'-'+e,
            Status__c = 'Failure');
            intl.Status_Code__c = '' + res.getStatusCode();
            intl.Status_Message__c = res.getStatus();
            Common.integLogs.add(intL);
            return null;
        }
        System.debug('getCustomerData res:' + String.ValueOf(res) == null ? null : res.getBody());

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            string errorMessage = 'Failed to connect to CCI.' + 'Account Id is: ' + account.sopId;
            //Common.addChatterFeedToObject(account.accountId, 'Failed to get CCI Customer data.');
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(account.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI',
            Finance_Account__c = account.accountId,
            Description__c = errorMessage,
            Exception__c = res.getBody(),
            Status__c = 'Failure');
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



    @future(callout = true)
    public static void getCCIAccount(List < String > accountList, List < String > oldAccountList) {

        if (CCIFinanceAccountManager.firstAccountId == null) {
            List < CCIAccountCreation.AccountInfo > firstAccountList = (List < CCIAccountCreation.AccountInfo > ) JSON.deserialize('[' + accountList[0] + ']', List < CCIAccountCreation.AccountInfo > .class);

            CCIFinanceAccountManager.firstAccountId = firstAccountList[0].accountId;
        }
        try {

            CCICustomerWrapper.AccessToken tokenInfo; {
                set < Id > accountIds = new set < ID > ();
                // System.debug(tokenInfo.access_token);
                Integer accSize = accountList.Size();
                for (Integer i = 0; i < accSize; i++) {

                    List < CCIAccountCreation.AccountInfo > deserializedAccountList = (List < CCIAccountCreation.AccountInfo > ) JSON.deserialize('[' + accountList[i] + ']', List < CCIAccountCreation.AccountInfo > .class);

                    //  List<CCIAccountCreation.AccountInfo> deserializedOldAccountList = 
                    //         (List<CCIAccountCreation.AccountInfo>)JSON.deserialize('['+oldAccountList[i]+']', List<CCIAccountCreation.AccountInfo>.class);
                    System.debug('deserializedAccountList:' + deserializedAccountList);
                    //  System.debug('deserializedOldAccountList:'+deserializedOldAccountList);

                    accountIds.add(deserializedAccountList[0].accountId);
                    if (!String.IsBlank(deserializedAccountList[0].sopId)) {
                        String accountJson = CCIFinanceAccountManager.getAccountData(deserializedAccountList[0], tokenInfo);
                        if (accountJson != null) {
                            CCIFinanceAccountManager.updateAccountData(deserializedAccountList[0], accountJson, tokenInfo);
                        }
                    }

                }

                if (accountIds.size() > 0) {
                    list < FinanceAccount__c > updateAccountList = new list < FinanceAccount__c > ([select id, DoCCIInt__c from FinanceAccount__c where ID in : accountIds and DoCCIInt__c = true]);
                    for (FinanceAccount__c a: updateAccountList) {
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


    public static void updateAccountData(CCIAccountCreation.AccountInfo acc, String account, CCICustomerWrapper.AccessToken tokenInfo) {


        /*if(account.indexOf('"externalIds":null')<0)
        {System.debug('do nothing');}
        else{*/
        CCIAccountCreation.ExternalIds externalIds = new CCIAccountCreation.ExternalIds (acc.accountId);
        String externalIdsJson= Json.serialize(externalIds );
        externalIdsJson = externalIdsJson.replace('"id"','"externalId"');
        externalIdsJson = externalIdsJson.replace('"ExternalSystem"','"system"');
        String newacc1 =    account.substring(0,account.indexOf('"externalIds"'));
        String acc2 =    account.substring(account.indexOf('"externalIds"'));
        System.debug('Acc1 str:'+ newacc1 +'Acc2Str:'+acc2+'externalJson:'+externalIdsJson);
        acc2 = acc2.substring(0, acc2.indexOf('"externalIds":')+'"externalIds":'.length()) + externalIdsJson+','+acc2.substring(acc2.indexOf('"businessUnit"'));
        newacc1 +=acc2;

        account= newacc1 ;
        //account= account.replace('"id"','"externalId"');             
        //}

        system.debug('Updated Account:' + account);


        String endpointUrl = Common.cci.Domain__c + Common.cci.AccountPath__c + '/' + acc.sopId;

        System.debug('endpointUrl:' + endpointUrl);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        //set method  
        req.setMethod('PUT');
        req.setHeader('Content-Type', Common.cci.ContentType__c);

        req.setBody(account);
       

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
        try {
            res = http.send(req);
        } catch (System.CalloutException e) {
            string errorMessage = 'Failed to integrate with CCI.' + 'Account Id is: ' + acc.sopId;
            // Common.addChatterFeedToObject(account.accountId, 'Failed to connect to CCI.');
            Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(acc.accountId, errorMessage));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI',
            Finance_Account__c = acc.accountId,
            Description__c = errorMessage,
            Exception__c = res.getBody() + '-' + e,
            Status__c = 'Failure');
            intl.Status_Code__c = '' + res.getStatusCode();
            intl.Status_Message__c = res.getStatus();
            Common.integLogs.add(intL);
            System.debug('*****' + e.getMessage());
            return;
        }

        System.debug(String.ValueOf(res) == null ? null : res.getBody());

        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {

            Common.addChatterFeedToObject(acc.accountId, 'Finance Account' + acc.accountId + 'has failed to update the external id in CCI ');
            //    Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(acc.accountId, 'Account '+acc.name+' has failed to update the following in CCI '+(accountNameChange?'Account':'')+(phoneChange?', Phone':'')+(billingStreetChange?', Billing Street':'')+(billingCityChange?', Billing City':'')+(billingStateChange?', Billing State':'')+(billingPostalCodeChange?', Billing Postal Code':'')+(billingCountryChange?', Billing Country':'')+(industryMinorCategoryChange?', Industry Minor Code':'')));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI',
            Finance_Account__c = acc.accountId,
            Description__c = 'Account has failed to update the externalIdin CCI',
            Exception__c = res.getBody(),
            Status__c = 'Failure');
            Common.integLogs.add(intL);
        } else {
            System.debug('Update Account:' + res.getBody());
            Common.addChatterFeedToObject(acc.accountId, 'Finance account has been updated successfully with external id in CCI.');
            //  Common.chatterList.add(new CCICustomerWrapper.ChatterInfo(acc.accountId, 'Account '+acc.name+' has been updated successfully in CCI.'));
            Integration_Logs__c intL = new Integration_Logs__c(
            Source__c = 'CCI',
            Finance_Account__c = acc.accountId,
            Description__c = 'Account has been updated successfully with externalid in CCI.',
            Status__c = 'Success');
            Common.integLogs.add(intL);
        }

    }


    public class CCIApiException extends Exception {}
    public class BookingSystemSettingsException extends Exception {}
}