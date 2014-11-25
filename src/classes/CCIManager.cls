/******************
*****
Crafted by :yuvikaAggarwal
Date Created:  2014-01-24
Api Version   :v1
****************************/
public without sharing class CCIManager {

    public static String metroUser = 'Metro';
    public static String mailDisplayUser = 'MailDisplay';
    
   


    public static String createDirectAccountOrder(String accId, String selectedBillingAccount, String sopId, String cciCustomerId, String bookingAgency, String bookingcciId, String parentcciId, String holdingCoCCIId, String holdingAgencyCCIId, String cciProfile, String cciGroup) {
        List < String > accsToQuery = new List < String > ();
        accsToQuery.add(accId);
        accsToQuery.add(selectedBillingAccount);
        String domain;
        String bookingPluginPath;
        BookingSystemSettings__c setting = Common.cci;
        OrderParams__c orderParams = Common.cciOrderParams;
        if (setting != null) {
            domain = setting.Domain__c;
            bookingPluginPath = setting.BookingPluginPath__c;
            if (domain == null || bookingPluginPath == null) throw new BookingSystemSettingsException();
        }


        String url = domain + bookingPluginPath;
        System.debug('URL after bookingsettings' + url);
        String errorResponse;
        String errorResponseAcc;
        String cciAccountId;
        FinanceAccount__c newFinAcc;
        String billingCustomerId;
        Account acc = [SELECT CCIMailCustID__c, CCIMetroCustID__c, Name, Type, Phone,
        BillingStreet, Industry_Minor_Category__c, BillingPostalCode,
        Industry, BillingState, BillingCountry
        FROM Account
        WHERE ID = : accId Limit 1];

        User u = Common.getUserInfo();
        System.debug('User is' + u);
        //String userType = Common.getUserType(u);

        if (Common.sharedSecret != null) {
            List < String > sList = common.userInformation.Email.split('@', 2);
            // url = url + 'userid=' + sList[0] + '&clientid=' + Common.cci.ClientId__c + '&clientsecret=' + Common.cci.SharedSecret__c + '&group=' + Common.userGroup() + '&profile=' + Common.userProfile();
            // url = url + 'userid=' + sList[0] + '&group=' + Common.userGroup() + '&profile=' + Common.userProfile();
            // url = url + orderParams.UserId__c + Common.cciuser  + orderParams.Group__c + Common.userGroup() + orderParams.Profile__c + Common.userProfile();
            url = url + orderParams.UserId__c + Common.cciuser  + orderParams.Group__c + cciGroup + orderParams.Profile__c + cciProfile;
            //'userid='+u.CCI_User_Id__c+'&password='+u.CCI_User_Password__c+'&group='+Common.userGroup()+'&profile='+Common.userProfile();
        } else {
            if (String.IsBlank(u.CCI_User_Id__c)) {
                throw new CCIAPIException(Label.InvalidCCIUser);
            }
            // url = url + 'userid=' + u.CCI_User_Id__c + '&password=' + u.CCI_User_Password__c + '&group=' + Common.userGroup() + '&profile=' + Common.userProfile();
            // url = url + orderParams.UserId__c + u.CCI_User_Id__c + orderParams.Password__c + u.CCI_User_Password__c + orderParams.Group__c + Common.userGroup() + orderParams.Profile__c + Common.userProfile();
            url = url + orderParams.UserId__c + u.CCI_User_Id__c + orderParams.Password__c + u.CCI_User_Password__c + orderParams.Group__c + cciGroup + orderParams.Profile__c + cciProfile;
        }
        // if(Common.mailUser.equal(userType))GAR-190
        //assign mailcustomerif of topparentaccount to URL else metrocustomer of topparentacc



        // url = url + '&accountid=' + sopId + '&advertiserid=' + cciCustomerId;
        url = url + orderParams.Accountid__c + sopId + orderParams.Advertiser__c + cciCustomerId;
        if ((bookingcciId != null) || parentcciId != null|| holdingCoCCIId!=null|| holdingAgencyCCIId!=null) {
            Integer relationsCount = 0;
            url = url+orderParams.RelatedCustomers__c+'{';
            if (bookingcciId != null) {
                 if(relationsCount>0)
                    url = url + ',';
                 url = url + '"Booking Agency":"' + bookingcciId + '"';
                 relationsCount++;
                 }
            if (parentcciId != null) {
                if(relationsCount>0)
                    url = url + ',';
                url = url+'"Client":"' + parentcciId + '"';
                relationsCount++;
                }
            if (holdingCoCCIId != null){
                if(relationsCount>0) url = url + ',';
                url = url + '"Holding Company":"' + holdingCoCCIId + '"';
                relationsCount++;
             }
             if (holdingAgencyCCIId != null){
                  if(relationsCount>0)
                    url = url + ',';
                    url = url + '"Holding Agency":"' + holdingAgencyCCIId + '"';
                 }
                    
                url = url+'}';
             
                }


            
          System.debug('URLbefore creating oppportunity' + url);
        //Step 3-Create opportunity-start of comment 1
     /*   Opportunity opp = createOpportunity(acc.Id, acc.Name, selectedBillingAccount);
        //Step4 Create OpportunityLineItem
      OpportunityLineItem newOpline = CreateOppLineItem(opp.Id, opp.CurrencyIsoCode);
        boolean closed = CloseOpportunity(opp);

        Datetime firstInsertionDate = datetime.newInstance(newOpline.ServiceDate.year(), newOpline.ServiceDate.month(), newOpline.ServiceDate.day());
        url = url + orderParams.OpportunityId__c + newOpline.OpportunityId;*/
        //end of comment 1
        // url = getURLBasedOnAccountType(userType,'1','1',url,acc,newOpline,firstInsertionDate);
        System.debug('URL before exiting createDirectAccountOrder method ' + url);
        // url = url+'&confirmationurl='+ ApexPages.currentPage().getHeaders().get('Host')+'/'+accId;
        //   url = url+'&confirmationurl='+ System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) +'/'+accId;
        //  url=url+'&confirmationurl=https://cs7.salesforce.com/'+accId;
        //need to uncomment below line
        url = url + orderParams.ConfirmationURL__c + Common.GetBaseUrlForInstance() + '/' + accId;
        System.debug('URL before exiting the system ...' + url);
        return url;

    }



    //Step1-Create opportunity before creating an order
    public static Opportunity CreateOpportunity(Id accId, String accName, String agencyId) {
        System.debug('Entering CreateOpportunity....');
        Id oppId;
        Opportunity newOp = new Opportunity();
        if (accId != null) {

            newOp.AccountId = accId;
            newOp.Name = 'Direct Order for ' + +accName +' '+ System.now();
            newOp.Type = 'Proactive';
            newOp.StageName = 'Preparation';
            newOp.Agency__c = agencyId;
            newOp.closeDate = System.Today();
            newOp.CurrencyIsoCode = 'GBP';


            insert newOp;
        }

        return newOp;
    }


    public static OpportunityLineItem CreateOppLineItem(Id oppId, String CurrencyIsoCode) {
        System.debug('Entering createOppLineItem and currencyIsocode' + CurrencyIsoCode);
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = : profileId].Name;
        System.debug('Profile Name is' + profileName);
        //ConstantsH__c constant = ConstantsH__c.getInstance(profileName);
        ConstantsH__c constant = ConstantsH__c.getInstance(profileId);
        String priceBook = constant.Price_Book__c;
        System.debug('Pricebook is' + priceBook);
        List < PricebookEntry > priceBooks = [Select Id, Product2Id From PricebookEntry Where Pricebook2.Name = : priceBook and isactive = true and Product2.CustomerRef__c = 'CustomerRef3'
        and Pricebook2.CurrencyIsoCode = : CurrencyIsoCode];

        OpportunityLineItem newOpline = new OpportunityLineItem();
        newOpline.OpportunityId = oppId;
        newOpline.PriceBookEntryId = priceBooks[0].Id;
        //newOpline.PriceBookEntryId = priceBooks[0].Product2Id;
        newOpline.UnitPrice = 0.01;
        newOpline.Quantity = 1;
        newOpline.ServiceDate = System.Today();

        insert newOpLine;
        return newOpline;

    }



    public static boolean CloseOpportunity(Opportunity opp) {
        if (opp.StageName != 'Closed Won') opp.StageName = 'Closed Won';
        try {
            upsert opp;
            return true;
        } catch (Exception e) {
            System.debug('Exception while closing an opportunity.' + opp.id);
            return false;
        }
    }

/*This is a method to cancel an existing order
*/
  /*  public static String cancelOrder(Id orderId,String code,String reason){
         BookingSystemSettings__c setting = Common.cci;
         String domain;
         String orderPath;
         String accessToken;
         
         if(setting != null){
            domain = setting.Domain__c;
            orderPath = setting.OrderPath__c;
            if (domain == null || orderPath == null) throw new BookingSystemSettingsException();
        }else throw new BookingSystemSettingsException();
         
         if(Common.cciToken != null) {
                accessToken = Common.cciToken.access_token;
           } else {
                throw new CCIApiException('Can not read Access Token.');
            }
        CCIOrderCancel cancelOrder = new CCIOrderCancel(code,reason);
        String jsonreq = cancelOrder.getReqJsonBody();
        //creating HttpRequest
        HttpRequest req = new HttpRequest();  
        req.setMethod('POST');  
        req.setEndpoint(domain+orderPath+'/'+orderId+'/cancellation');   
        req.setHeader('Content-Type', 'application/json');  
        req.SetHeader('x-cci-user', Common.cciuser);
        req.SetHeader('x-cci-profile', common.userProfile());
        req.SetHeader('x-cci-group', common.userGroup());
        req.SetHeader('Authorization', 'bearer ' + accessToken);
        req.setBody(jsonreq);
        req.setTimeout(60000);
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            return 'Failure';
        }
       return 'Success';
     //   req.setCompressed(true);   
 

}*/


    public static String editAccountOrder(String orderId, String cciProfile, String cciGroup) {
        String domain;
        String bookingPluginPath;
        BookingSystemSettings__c setting = BookingSystemSettings__c.getInstance('CCI');
        OrderParams__c orderParams = Common.cciOrderParams;

        if (setting != null) {
            domain = setting.Domain__c;
            //   domain = setting.TempDomain__c;
            bookingPluginPath = setting.EditBookingPluginPath__c;
            if (domain == null || bookingPluginPath == null) throw new BookingSystemSettingsException();
        }


        String url = domain + bookingPluginPath;
        System.debug('URL after bookingsettings' + url);
        String errorResponse;
        String errorResponseAcc;


        Order order = [SELECT id, CCI_Order_ID__c
        FROM Order
        WHERE ID = : orderId Limit 1];

        User u = Common.getUserInfo();
        System.debug('User is' + u);
        String userType = Common.getUserType(u);


        if (String.IsBlank(order.CCI_Order_ID__c)) {
            throw new CCIAPIException(Label.NoOrder);
        }
        if (Common.sharedSecret != null) {
            List <String > sList = common.userInformation.Email.split('@', 2);
            //  url = url + order.CCI_Order_ID__c + '?userid=' + u.CCI_User_Id__c + '&password=' + u.CCI_User_Password__c + '&group=' + Common.userGroup() + '&profile=' + Common.userProfile();
             url = url + order.CCI_Order_ID__c + '?'+orderParams.UserId__c +Common.cciuser  + orderParams.Group__c + cciGroup + orderParams.Profile__c + cciProfile;
        } else {
            url = url + order.CCI_Order_ID__c + orderParams.UserId__c + u.CCI_User_Id__c + orderParams.Password__c + u.CCI_User_Password__c + orderParams.Group__c + cciGroup + orderParams.Profile__c + cciProfile;
        }


        System.debug('Before exiting editOrder' + url);

        // url =  url+'&confirmationurl='+ ApexPages.currentPage().getHeaders().get('Host')+'/'+order.Id;   
        url = url + '&confirmationurl=' + Common.GetBaseUrlForInstance() + '/' + order.Id;
        System.debug('Before exiting editOrder 2part' + url);
        return url;

    }
  // method to get CCI packages to display for opportunity creation
 /*  public static void getcciPackages(){
        BookingSystemSettings__c setting = Common.cci;
        String packageEndpoint = setting.Domain__c + setting.PackagePath__c;
        String contentType =  setting.ContentType__c;
        if (String.IsBlank(packageEndpoint) || String.IsBlank(contentType)) {
                    throw new BookingSystemSettingsException();
           }
      
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(packageEndpoint);
        req.setHeader('Content-Type', contentType);
        req.SetHeader('x-cci-user', Common.cciuser);
        req.SetHeader('x-cci-profile', common.userProfile());
        req.SetHeader('x-cci-group', common.userGroup());
        req.SetHeader('Authorization', 'bearer ' + common.cciToken);
        try{
            //creating an HttpRequest
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             System.debug('Response is' + res);
            if (!(res.getStatusCode() == 200)) {
                throw new CCIAPIException(Label.ErrorGettingPackages);
            } else {
              //  List<packageobject> deserializedPackages = 
           //   (List<packageobject>)JSON.deserialize(JSONString, List<packageobject>.class);
            String updatedResponse = res.getBody().replace('desc','description');
               List<CCIPackages> deserializedPackages = 
              (List<CCIPackages>)System.JSON.deserialize(updatedResponse ,List<CCIPackages>.class);
            
        }}catch(Exception e){
        
       }
       
   }*/
   

}