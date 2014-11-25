public with sharing class DirectOrderController {
    public Account acc {get; set;}
    public Static String CLIENT_ID = 'clientId';
    public Static String AGENCY_ID = 'agencyId';
    public static String SOP_ID = 'sopId';
    public static String CCI_CUS_ID = 'cciCusId';
    public static String BOOKING_ID = 'bookingId';
    public static String CCI_BOOKING_ID = 'bookingcciId';
    public static String CCI_PARENT_ID = 'parentcciId';
    public static String CCI_HOLDCOMP_ID = 'holdingCompanycciId';
    public static String CCI_HOLDAGENCY_ID = 'holdingAgencycciId';
    public String url1 {
        get;
        set;
    }
    public String clientId {
        get;
        set;
    }
    public String agencyId {
        get;
        set;
    }
    public String cciGroup {
        get;
        set;
    }
    public String cciProfile {
        get;
        set;
    }
    public String errorMessage {
        get;
        set;
    }
    public Boolean renderPlugin {
        get;
        set;
    }
    public Boolean renderError {
        get;
        set;
    }
    public String sopId {
        get;
        set;
    }
    public String cciCusId {
        get;
        set;
    }
    public String bookingAgencyId {
        get;
        set;
    }
    public String bookingcciId {
        get;
        set;
    }
    public String parentcciId {
        get;
        set;
    }
    public String holdingCompanycciId {
        get;
        set;
    }
    public String holdingAgencycciId {
        get;
        set;
    }
    public String authCode {
        get;
        set;
    }
    public String contactName {
        get;
        set;
    }
    public String contactPhone {
        get;
        set;
    }
    public String contactId {
        get;
        set;
    }




    public void createOrder() {
        OrderParams__c cciOrderParams = Common.cciOrderParams;
        renderPlugin = true;
        if (agencyId == '') agencyId = null;
        if (bookingAgencyId == '') bookingAgencyId = null;
        if (bookingcciId == '') bookingcciId = null;
        if (parentcciId == '') parentcciId = null;
        if (holdingCompanycciId == '') holdingCompanycciId = null;
        if (holdingAgencycciId == '') holdingAgencycciId = null;


        try {
            if (cciCusId == null || cciCusId == '' || sopId == null || sopId == '') throw new CCIApiException();
            //url1 = CCIManager.createDirectAccountOrder(clientId, agencyId, sopId, cciCusId, bookingAgencyId, bookingcciId, parentcciId, holdingCompanycciId, holdingAgencycciId);
            url1 = CCIManager.createDirectAccountOrder(clientId, agencyId, sopId, cciCusId, bookingAgencyId, bookingcciId, parentcciId, holdingCompanycciId, holdingAgencycciId, cciProfile, cciGroup);
            // url1 = url1+'&authorizationcode'+authCode+'&clientid=app&redirecturi=http';
            if(contactId!=null || contactId!=''){
            Contact c = [Select id,Name,Phone from Contact where id=:contactId];
            System.debug('contact is.'+ c);
            contactName = c.Name;
            contactPhone = c.Phone;
            } 
            if (authCode != null && authCode != '') {
                url1 = url1 + cciOrderParams.AuthCode__c + authCode + cciOrderParams.ClientId__c+'&callername='+contactName+'&callerphone='+contactPhone;
            }
            System.debug('url1 is' + url1);

        } catch (Exception e) {
            System.debug('An exception has occured' + e);
            renderPlugin = false;
            renderError = true;
            errorMessage = Label.CCI_Exception;

            ApexPages.addMessages(e);
        }


        System.debug('URL generated is' + url1);

    }

    public DirectOrderController(ApexPages.StandardController controller) {

        clientId = apexpages.currentpage().getparameters().get(CLIENT_ID);
        agencyId = apexpages.currentpage().getparameters().get(AGENCY_ID);
        sopId = apexpages.currentpage().getparameters().get(SOP_ID);
        cciCusId = apexpages.currentpage().getparameters().get(CCI_CUS_ID);
        bookingAgencyId = apexpages.currentpage().getparameters().get(BOOKING_ID);
        bookingcciId = apexpages.currentpage().getparameters().get(CCI_BOOKING_ID);
        parentcciId = apexpages.currentpage().getparameters().get(CCI_PARENT_ID);
        holdingCompanycciId = apexpages.currentpage().getparameters().get(CCI_HOLDCOMP_ID);
        holdingAgencycciId = apexpages.currentpage().getparameters().get(CCI_HOLDAGENCY_ID);
        contactName = apexpages.currentpage().getparameters().get('contactName');
        contactPhone= apexpages.currentpage().getparameters().get('contactPhone');
        contactId = apexpages.currentpage().getparameters().get('contactId');
        cciGroup = apexpages.currentpage().getparameters().get('cciGroup');
        cciProfile = apexpages.currentpage().getparameters().get('cciProfile');
 
        if(cciProfile!=null)
        {
            cciProfile = cciProfile.replace( ';',' '); 
        }
        if(cciGroup!=null)
        {
            cciGroup = cciGroup.replace( ';',' ');
        }
        System.debug('Client Id...' + clientId + 'Agency Id...' + agencyId + 'sop Id...' + sopId + 'CCiCus Id...' + cciCusId + 'BookingId' + bookingAgencyId + 'BookingCCIId' + bookingcciId + 'parentcciId' + parentcciId + 'holdingCompanycciId' + holdingCompanycciId + 'holdingAgencycciId' + holdingAgencycciId+'ContactId..'+contactId+'cciGroup..'+cciGroup+'cciProfile...'+cciProfile);
        this.acc = (Account) controller.getRecord();
        BookingSystemSettings__c setting = Common.cci;
        if (setting == null) {
            throw new BookingSystemSettingsException();
        }
        String oAuthEndpoint = setting.Domain__c + setting.AuthPath__c;
        System.debug('AuthEndpoint is..' + oAuthEndpoint);
        //'https://test.cci-webaccess-dmgmedia.co.uk/api/authentication/oauth/authorize?response_type=code&client_id=app&redirect_uri=http';
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());

        req.setMethod('GET');
        req.setEndpoint(oAuthEndpoint);

        String username = setting.ClientId__c;
        String password = setting.SharedSecret__c;
        System.debug('username..' + username + ' Password..' + password);

        if (!String.isBlank(username) && !String.isBlank(password)) {

            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            System.debug('AuthorizationHeader is' + authorizationHeader);
            req.setHeader('Authorization', authorizationHeader);

            //creating an HttpRequest
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            System.debug('Request is' + req + 'headers' + req.getHeader('Authorization'));
            res = http.send(req);
            System.debug('Response is' + res);
            if (!(res.getStatusCode() == 302)) {
                throw new CCIAPIException(Label.ErrorAuthCode);
            } else {
                string[] headerkeys = res.getHeaderKeys();
                String location = res.getHeader('Location');
                System.debug('Location is' + location);
                authCode = location.subString(location.indexof('='));
                System.debug('authCode is' + authCode);
            }
        }

    }
    
    public string getClientName(){
        Account acc; 
        if(clientID != null )
            acc = [SELECT ID, name from Account where id =: clientID];
        if(acc != null && acc.Name != null && acc.Name != ''){
            return acc.Name;
        }
        return 'No Account is identified'; 
    }
    
}