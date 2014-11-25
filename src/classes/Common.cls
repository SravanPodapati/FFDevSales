public with sharing class Common {
    public class CommonException extends Exception {}

    public static String metroUser = 'Metro';
    public static String mailUser = 'Mail';
    public static String systemAdministrator = 'System Administrator';
    public static String groupClientSales = 'Group Client Sales';
    public static String londonClassified = 'London Classified';
    public static String creditController = 'Credit Controller';
	
    public static String userProfile {
        get;
        set;
    }
    
    public static String userGroup {
        get;
        set;
    }

    
    public static OrderParams__c cciOrderParams {
        get {
             System.debug('Existing CCiOrderParams'+cciOrderParams);
            if (cciOrderParams== null) {
                cciOrderParams= OrderParams__c.getInstance('CCI');
                System.debug('cciOrderParams now'+cciOrderParams);
            }
            return cciOrderParams;
        }
        set;
    }

    public static set < string > cciProfiles;
    public static set < string > cciGroups;
    public static integer cciProfilesSize;
    public static integer cciGroupsSize;


    //set of user profile names from Glue that are having equivalent Metro access in CCI. 
    public static set < String > cciMetroEquivelentProfiles {
        get {
            if (cciMetroEquivelentProfiles == null) {
                cciMetroEquivelentProfiles = new set < String > ();
                for (String s: Label.CCI_Equivalent_Metro_Profiles.split(';')) {
                    String temp = s != null ? s.replaceAll(';', '') : '';
                    cciMetroEquivelentProfiles.add(temp.trim());
                }
            }
            return cciMetroEquivelentProfiles;
        }
        set;
    }

    //set of user profile names from Glue that are having equivalent Mail access in CCI. 
    public static set < String > cciMailEquivelentProfiles {
        get {
            if (cciMailEquivelentProfiles == null) {
                cciMailEquivelentProfiles = new set < String > ();
                for (String s: Label.CCI_Equivalent_Mail_Profiles.split(';')) {
                    String temp = s != null ? s.replaceAll(';', '') : '';
                    cciMailEquivelentProfiles.add(temp.trim());
                }
            }
            return cciMailEquivelentProfiles;
        }
        set;
    }

    //set of user profile names from Glue that are having equivalent system admin profiles in CCI.  
    public static set < string > cciSystemAdminEquivalentProfiles {
        get {
            if (cciSystemAdminEquivalentProfiles == null) {
                cciSystemAdminEquivalentProfiles = new set < String > ();
                for (String s: Label.CCI_Equivalent_System_Admin_Profiles.split(';')) {
                    string temp = s != null ? s.replaceAll(';', '') : '';
                    cciSystemAdminEquivalentProfiles.add(temp);
                }
            }
            return cciSystemAdminEquivalentProfiles;
        }
    }


    //returns if the operation needs to be done by Service user or not     
    public static boolean isUpdateByServiceUser(boolean isMAil) {
        String profileName = Common.getUserInfo().Profile.Name;
        if( Common.getUserInfo().Virtual_Data_Team_Member__c){
            System.debug('FinancialForce Profile');
            return true;
        }
        //weather the logged in user has system admin profile in Glue
        if (cciSystemAdminEquivalentProfiles.contains(profileName)) {
            return false;
            //if the update is for mail mapping and logged in user has mail equivalent profile in GLue 
        } else if (cciMailEquivelentProfiles.contains(profileName) && isMAil) {
            return false;
            //if the update is for metro mapping and logged in user has metro equivalent profile in GLue
        } else if (cciMetroEquivelentProfiles.contains(profileName) && !isMAil) {
            return false;
        } else {
            return true;
        }
    }

    public common() {

    }

    public static List < CCICustomerWrapper.ChatterInfo > chatterList {
        get {
            if (chatterList == null) {
                chatterList = new List < CCICustomerWrapper.ChatterInfo > ();
            }
            return chatterList;
        }
        set;
    }

    public static List < Integration_Logs__c > integLogs {
        get {
            if (integLogs == null) {
                integLogs = new List < Integration_Logs__c > ();
            }
            return integLogs;
        }
        set;
    }

    public static User getUserInfo() {

        User u = [Select id, Name, CCI_User_Id__c, Virtual_Data_Team_Member__c, CCI_Profile__c, CCI_User_Password__c, CCI_Group_Id__c, Profile.Name, Email, FederationIdentifier
        From User
        Where Id = : UserInfo.getUserId()];
        return u;
    }

    public static String getUserType(User u) {

        String profileName = u.Profile.Name;
        System.debug('Profile Name is' + profileName);
        if (profileName.contains(metroUser)) return metroUser;
        else if (profileName.contains(mailUser)) return mailUser;
        else if (profileName.contains(systemAdministrator)) return systemAdministrator;
        else if (profileName.contains(groupClientSales)) return groupClientSales;
        else if (profileName.contains(londonClassified)) return londonClassified;
        else if (profileName.contains(creditController)) return creditController;

        return null;
    }





    public static set < string > CCIProfiles() {
        if(test.isRunningtest())
        {
            Set<String>  profileSet = new Set<String>();
            profileSet.add('md manager');
            profileSet.add('md sales');
            profileSet.add('system administrator');
            profileSet.add('system user');           
            return profileSet;
        }
        else  
        if (cciProfiles == null) {
            String endpointUrl = Common.cci.Domain__c + Common.cci.UserProfilePath__c;

            system.debug('***endpointUrl: ' + endpointUrl);
            userProfile = invokeCCI(endpointURL);
			cciProfilesSize = cciProfiles.size();
            return cciProfiles;
        } else {
            return cciProfiles;
        }
    }

    public static String userProfile() {
        if(test.isRunningtest())
        {
            return 'md manager';
        }
        else        
        if (String.IsBlank(userProfile)) {
            String endpointUrl = Common.cci.Domain__c + Common.cci.UserProfilePath__c;

            system.debug('***endpointUrl: ' + endpointUrl);
            userProfile = invokeCCI(endpointURL);

            return userProfile;
        } else {
        	cciProfilesSize = cciProfiles.size();
            return userProfile;
        }

    }

    public static set < string > CCIGroups() {
        if(test.isRunningtest())
        {
            Set<String>  grpSet = new Set<String>();
            grpSet.add('mail display');
            grpSet.add('mail classified');
            grpSet.add('systems support');
            grpSet.add('system administrator');           
            return grpSet;
        }
        else
        if (cciGroups == null) {
            String endpointUrl = Common.cci.Domain__c + Common.cci.UserGroupPath__c;

            system.debug('***endpointUrl: ' + endpointUrl);
            userGroup = invokeCCI(endpointURL);
			cciGroupsSize = cciGroups.size();
            return cciGroups;
        } else {
            cciGroupsSize = cciGroups.size();
            return cciGroups;
        }
    }

    public static String userGroup() {
        if(test.isRunningtest())
        {
            return 'mail display';
        }
        else        
        if (String.IsBlank(userGroup)) {
            String endpointUrl = Common.cci.Domain__c + Common.cci.UserGroupPath__c;


            userGroup = invokeCCI(endpointURL);

            return userGroup;
        } else {
            return userGroup;
        }
    }

    public static BookingSystemSettings__c cci {
        get {
             System.debug('Existing CCi'+cci);
            if (cci == null) {
                cci = BookingSystemSettings__c.getInstance('CCI');
                System.debug('CCi now'+cci);
            }
            return cci;
        }
        set;
    }

    public static String sharedSecret {
        get {
            if (String.IsBlank(sharedSecret)) {
                sharedSecret = cci.SharedSecret__c;
                return sharedSecret;
            } else {
                return sharedSecret;
            }
        }
        set;
    }

    public static User userInformation {
        get {
            if (userInformation == null) {
                userInformation = Common.getUserInfo();
            }
            return userInformation;
        }
        set;
    }

    public static String cciuser {
        get {
            if (String.IsBlank(cciuser)) {
                if (String.IsBlank(userInformation.FederationIdentifier)) {
                    List < String > sList = common.userInformation.Email.split('@', 2);
                    cciuser = sList[0];
                } else {
                    List < String > sList = common.userInformation.FederationIdentifier.split('@', 2);
                    cciuser = sList[0];
                }
                return cciuser;
            } else {
                return cciuser;
            }
        }
        set;
    }
    public class AccessToken {
        public String access_token {
            get;
            set;
        }
        public String token_type {
            get;
            set;
        }
        public String refresh_token {
            get;
            set;
        }
        public String expires_in {
            get;
            set;
        }
        public String read {
            get;
            set;
        }

        public AccessToken(String ato, String tto, String rto, String exp, String rd) {
            this.access_token = ato;
            this.token_type = tto;
            this.refresh_token = rto;
            this.expires_in = exp;
            this.read = rd;
        }
    }
    
    public static void delayTime(integer sec){
        Datetime targetTime = DateTime.now().addSeconds(sec);
        delayTime(targetTime );
    }
    public static void delayTime(DateTime targetTime) {

        long targetTimeValue = targetTime.getTime();
        long i = dateTime.now().getTime();
        while (i < targetTimeValue) {
            i = dateTime.now().getTime();
        }
        return;
    }
    public static DateTime tokenExperiationTime;

    public static AccessToken cciToken {
        get {
            System.debug('cciToken:' + cciToken);
            //check wether the CCI token is valid or not.
            if (tokenExperiationTime != null) {
                //verify wether the token is valid or not
                integer minimumTokenValidatyPeriod = integer.valueOf(cci.MinimumTokenValidity__c == null ? 5 : cci.MinimumTokenValidity__c);
                if (tokenExperiationTime <= DateTime.now().addSeconds(minimumTokenValidatyPeriod)) {
                    delayTime(tokenExperiationTime);
                    cciToken = null;
                }
            }
            if (cciToken == null) {
                String endpointUrl;

                if (!String.IsBlank(sharedSecret)) {
                    endpointUrl = Common.cci.Domain__c + Common.cci.AuthenticationPathClient__c;
                    endpointUrl = endpointUrl.replace('<clientId>', cci.ClientId__c);
                    endpointUrl = endpointUrl.replace('<clientsecret>', cci.SharedSecret__c);
                } else {
                    endpointUrl = Common.cci.Domain__c + Common.cci.AuthenticationPath__c;
                    // String endpointUrl = cci.TempDomain__c+cci.AuthenticationPath__c;
                    endpointUrl = endpointUrl.replace('<username>', userInformation.CCI_User_Id__c);
                    endpointUrl = endpointUrl.replace('<password>', userInformation.CCI_User_Password__c);
                }


                System.debug('endpointUrl:' + endpointUrl);

                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
                //set method  
                req.setMethod('GET');
                req.setHeader('Content-Type', Common.cci.ContentType__c);

                req.setEndpoint(endpointUrl);
                HTTPResponse res = new HTTPResponse();
                try {
                    res = http.send(req);
                } catch (System.CalloutException e) {
                    System.debug('*****' + e.getMessage());
                }

                System.debug('Get Token:' + String.ValueOf(res) == null ? null : res.getBody());

                if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
                    // Common.addChatterFeedToObject(firstAccountId, 'Failed to get CCI Token.');
                    chatterList.add(new CCICustomerWrapper.ChatterInfo(CCICustomerManager.firstAccountId, 'Failed to get CCI Token.'));
                    Integration_Logs__c intL = new Integration_Logs__c(
                    Source__c = 'CCI',
                    Account__c = CCICustomerManager.firstAccountId,
                    Description__c = 'Failed to get CCI Token.',
                    Exception__c = res.getBody(),
                    Status__c = 'Failure');
                    integLogs.add(intL);
                    return null;

                } else {
                    String jsonStr = '[' + res.getBody() + ']';
                    System.debug('Json String is..'+ jsonStr);
                    //JSONParser parser = JSON.createParser(jsonStr);
                    List < AccessToken > deserializedContent = (List < AccessToken > ) JSON.deserialize(jsonStr, List < AccessToken > .class);
                    System.debug('deserialized content..'+ deserializedContent );
                    cciToken = deserializedContent[0];
                    tokenExperiationTime = DateTime.now().addSeconds(integer.valueOf(deserializedContent[0].expires_in));
                    if (tokenExperiationTime != null) {
                        //verify wether the token is valid or not
                        integer minimumTokenValidatyPeriod = integer.valueOf(cci.MinimumTokenValidity__c == null ? 5 : cci.MinimumTokenValidity__c);
                        if (tokenExperiationTime <= DateTime.now().addSeconds(minimumTokenValidatyPeriod)) {
                            delayTime(tokenExperiationTime);
                            cciToken = null;
                            cciToken = common.cciToken;
                        }
                    }
                    //return deserializedContent[0];          
                    return cciToken;
                }

            } else {
                return cciToken;
            }
        }
    }


    /*  public static String Instance {
    public get {
        if (Instance == null) {
            //
            // Possible Scenarios:
            //
            // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
            // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
            // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable

            // Split up the hostname using the period as a delimiter
            List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
            if (parts.size() == 3) Instance = parts[0];
            else if (parts.size() == 5) Instance = parts[1];
            else Instance = null;
        } return Instance;
    } public  set;
}

// And you can then get the Salesforce base URL like this:
public static String GetBaseUrlForInstance() {

     return 'https://' + Instance + '.salesforce.com';

} */
    public static String Instance {
        public get {
            if (Instance == null) {
                //
                // Possible Scenarios:
                //
                // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
                // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
                // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable

                // Split up the hostname using the period as a delimiter
                System.debug('BaseURL' + System.URL.getSalesforceBaseUrl().toExternalForm());
                Instance = System.URL.getSalesforceBaseUrl().toExternalForm();
                //System.debug('BaseURL'+ System.URL.getSalesforceBaseUrl().getHost());
                // List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
                // System.debug('Parts are'+ parts);
                //  if (parts.size() == 3) Instance = parts[0];
                //  else if (parts.size() == 5) Instance = parts[1];
                //  else Instance = null;
            }
            return Instance;
        }
        public set;
    }

    // And you can then get the Salesforce base URL like this:
    public static String GetBaseUrlForInstance() {

        // return 'https://' + Instance + '.salesforce.com';
        return Instance;

    }

    public static String invokeCCI(String endpointURL) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        //set method            
        req.setMethod('GET');
        req.setHeader('Content-Type', Common.cci.ContentType__c);

        system.debug('cciToken in invokeCCI : ' + cciToken);
        AccessToken tokenInfo = cciToken; // CCICustomerManager.getCCIToken();
        
        if (Common.sharedSecret != null) {
            // List<String> sList = common.userInformation.Email.split('@',2);
            // req.SetHeader('x-cci-user', sList[0]);
            req.SetHeader('x-cci-user', Common.cciuser);
        }

        req.setHeader('Authorization', cciToken.token_type + ' ' + cciToken.access_token);

        req.setEndpoint(endpointUrl);
        HTTPResponse res = new HTTPResponse();
        try {
            res = http.send(req);
        } catch (System.CalloutException e) {
            System.debug('*****' + e.getMessage());
        }

        system.debug('***res : ' + res);
        String jsonStr = res.getBody();
        if (jsonStr != null && jsonStr.toUpperCase().contains('INVALID_X-CCI-USER_HEADER')) {
            throw new CommonException(System.Label.User_Access_CCI);
        }
        System.debug('jsonStr:' + jsonStr);
        jsonStr = jsonStr.replace('desc', 'descrip');

        List < Common.UserInfoWrapper > deserializedContent = (List < Common.UserInfoWrapper > ) JSON.deserialize(jsonStr, List < Common.UserInfoWrapper > .class);
        
        System.debug('******deserializedContent:' + deserializedContent);
        
        if (endpointURL != null && endpointURL.tolowerCase().contains(Common.cci.UserProfilePath__c.tolowerCase())) {
            for (Common.UserInfoWrapper uI: deserializedContent) {
                if ((uI.Name != null) && (cciProfiles == null))
                	 cciProfiles = new set < String > ();
                cciProfiles.add(uI.Name);
            }
        }
        else
        {
            for (Common.UserInfoWrapper uI: deserializedContent) {
                if ((uI.Name != null) && (cciGroups == null))
                	 cciGroups = new set < String > ();
                cciGroups.add(uI.Name);
            }        	
        }
        
        return deserializedContent[0].name;
    }

    // Use ConnectAPI to send messages to a Chatter Object
    public static void addChatterFeedToObject(ID itemId, String message) {
        // ConnectAPI is not supported in "siloed" Tests.
        if (!Test.isRunningTest()) {
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = message;
            messageInput.messageSegments.add(textSegment);
            //ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            //mentionSegment.id = itemId;
            //messageInput.messageSegments.add(mentionSegment);
            //textSegment = new ConnectApi.TextSegmentInput();
            //textSegment.text = '!';
            //messageInput.messageSegments.add(textSegment);

            //Create FeedItemInput to hold message body and @mentions//
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;
            try {
                ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, itemId, Input, null);
            } catch (Exception e) {
                System.debug('Error: ' + e);
            }
        }
    }

    public class UserInfoWrapper {
        public String recordid {
            get;
            set;
        }
        public String revision {
            get;
            set;
        }
        public String creationTime {
            get;
            set;
        }
        public String creationUser {
            get;
            set;
        }
        public String modifierTime {
            get;
            set;
        }
        public String modifierUser {
            get;
            set;
        }
        public String code {
            get;
            set;
        }
        public String name {
            get;
            set;
        }
        public String descrip {
            get;
            set;
        }

        public UserInfoWrapper(String recordid, String revision, String creationTime, String creationUser, String modifierTime, String modifierUser, String code, String name, String descrip) {
            this.recordid = recordid;
            this.revision = revision;
            this.creationTime = creationTime;
            this.creationUser = creationUser;
            this.modifierTime = modifierTime;
            this.modifierUser = modifierUser;
            this.code = code;
            this.name = name;
            this.descrip = descrip;
        }
    }

    //Returns the ID of Root Account based on the member Id 
    public static Id rootAccount(Id memberId) {
        Account memberAccount = [SELECT ID from Account Where ID = : memberId];
        return rootAccount(memberAccount);
    }
    
    // method to add exception message to the description in Integ Logs
    
    public static String addErrorMsgToDesc(String exMsg){
        String errorSub2='' ;
        try{
        If(!String.IsBlank(exMsg)){
            Integer index1 =exMsg.indexOf('errorString');
            Integer index2 = exMsg.indexOf('errorDetails');
            if(index1>0&&index2>0){
                String errorSubstring = exMsg.subString(index1,index2);
                if(errorSubstring!=null){
                     errorSub2 = errorSubstring.subString(errorSubstring.indexOf(':')+1,errorSubstring.indexOf(','));
                } }
            }}catch(Exception e){
                //do nothing 
            }
            if(errorSub2==null) 
                errorSub2='';
            return errorSub2;
    
       
   } 
    

    //Returns the ID of root Account based on the Member Account
    public static Id rootAccount(Account memberAccount) {
        if (memberAccount.Id != null) {
            string tempInstance;
            List < String > parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api', '').split('\\.');
            if (parts.size() == 3) tempInstance = parts[0];
            else if (parts.size() == 5) tempInstance = parts[1];
            else tempInstance = null;
            //build Account Hierarchy URL
            string hierarchyURL;
            hierarchyURL = 'https://';
            if (tempInstance != null) {
                hierarchyURL += tempInstance;
            }
            //get the string form of salesforce base url
            hierarchyURL += '.salesforce.com';
            //build Account Hierarchy URL
            hierarchyURL += '/acc/account_hierarchy.jsp?id=' + memberAccount.ID;

            //Create Account Hierarchy Page 
            PageReference accountHierarchyPage = new PageReference(hierarchyURL);

            //Convert Account Hierarchy Page into a string
            String accountHierarchyString;
            if (Test.isRunningtest()) {
                accountHierarchyString = [select id, name, body from StaticResource where name = 'RootAccountTestData'
                Limit 1].body.tostring();
            } else {
                try {
                    accountHierarchyString = accountHierarchyPage.getContent().tostring();
                    accountHierarchyString = accountHierarchyString.substring(accountHierarchyString.indexOf('bodyCell'));
                } catch (Exception e) {
                    return null;
                }
                system.debug('***accountHierarchyString: ' + accountHierarchyString);
            }

            //split the resulting accountHierarchyString ever time a link is defined
            list < String > splitList = accountHierarchyString.split('href=', -1);

            //Patterns for account ids 
            Pattern accountIdPattern15 = Pattern.compile('[0]{2}[1]{1}[a-zA-Z0-9]{12}');
            Pattern accountIdPattern18 = Pattern.compile('[0]{2}[1]{1}[a-zA-Z0-9]{15}');

            //set of Account ids that are in the accountHirearchyString 
            set < String > resultAccountIdSet = new set < string > ();
            //process the splitList
            for (String s: splitList) {

                //considering 15 digit id is provided by SF
                string s15;
                //substring of first 18 characters 
                s15 = s.substring(0, 18);
                //remove "
                s15 = s15.replaceAll('\"', '');
                //remove /
                s15 = s15.replaceAll('/', '');
                //build batcher for 15 digit id
                Matcher idMatcher15 = accountIdPattern15.matcher(s15);
                //add it to the set if match is found 
                if (idMatcher15.matches()) {
                    resultAccountIdSet.add(s15);
                }

                //considering 18 digit id is provided by SF
                string s18;
                //substring of first 18 characters 
                s18 = s.substring(0, 21);
                //remove "
                s18 = s18.replaceAll('\"', '');
                //remove /
                s18 = s18.replaceAll('/', '');
                //build batcher for 15 digit id
                Matcher idMatcher18 = accountIdPattern18.matcher(s18);
                //add it to the set if match is found 
                if (idMatcher18.matches()) {
                    resultAccountIdSet.add(s18);
                }
            }
            system.debug('***resultAccountIdSet : ' + resultAccountIdSet);
            ID rootAccountID;

            if (resultAccountIdSet.size() != 0) {
                list < Account > resultAccounts = new list < Account > ([SELECT ID, ParentId from Account where ID IN: resultAccountIdSet and parentID = null]);
                if (resultAccounts.size() != 0) {
                    rootAccountId = resultAccounts[0].id;
                }
            }
            if (Test.isRunningtest()) {
                id dummyid = '001M000000XHE4v';
                return dummyid;
            } else {
                if (rootAccountID != null) {
                    return rootAccountID;
                } else {
                    return null;
                }
            }
        } else {
            throw new CommonException(System.Label.Root_Account_Exception);
        }
    }
    
    public set<String> allIdsInHirearchy (Id memberAccount){
        if(memberAccount != null){
            string tempInstance;
            List < String > parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api', '').split('\\.');
            if (parts.size() == 3) tempInstance = parts[0];
            else if (parts.size() == 5) tempInstance = parts[1];
            else tempInstance = null;
            //build Account Hierarchy URL
            string hierarchyURL;
            hierarchyURL = 'https://';
            if (tempInstance != null) {
                hierarchyURL += tempInstance;
            }
            //get the string form of salesforce base url
            hierarchyURL += '.salesforce.com';
            //build Account Hierarchy URL
            hierarchyURL += '/acc/account_hierarchy.jsp?id=' + memberAccount;

            //Create Account Hierarchy Page 
            PageReference accountHierarchyPage = new PageReference(hierarchyURL);

            //Convert Account Hierarchy Page into a string
            String accountHierarchyString;
            if (Test.isRunningtest()) {
                accountHierarchyString = [select id, name, body from StaticResource where name = 'RootAccountTestData'
                Limit 1].body.tostring();
            } else {
                try {
                    accountHierarchyString = accountHierarchyPage.getContent().tostring();
                    accountHierarchyString = accountHierarchyString.substring(accountHierarchyString.indexOf('bodyCell'));
                } catch (Exception e) {
                    return null;
                }
                system.debug('***accountHierarchyString: ' + accountHierarchyString);
            }

            //split the resulting accountHierarchyString ever time a link is defined
            list < String > splitList = accountHierarchyString.split('href=', -1);

            //Patterns for account ids 
            Pattern accountIdPattern15 = Pattern.compile('[0]{2}[1]{1}[a-zA-Z0-9]{12}');
            Pattern accountIdPattern18 = Pattern.compile('[0]{2}[1]{1}[a-zA-Z0-9]{15}');

            //set of Account ids that are in the accountHirearchyString 
            set < String > resultAccountIdSet = new set < string > ();
            //process the splitList
            for (String s: splitList) {

                //considering 15 digit id is provided by SF
                string s15;
                //substring of first 18 characters 
                s15 = s.substring(0, 18);
                //remove "
                s15 = s15.replaceAll('\"', '');
                //remove /
                s15 = s15.replaceAll('/', '');
                //build batcher for 15 digit id
                Matcher idMatcher15 = accountIdPattern15.matcher(s15);
                //add it to the set if match is found 
                if (idMatcher15.matches()) {
                    resultAccountIdSet.add(s15);
                }

                //considering 18 digit id is provided by SF
                string s18;
                //substring of first 18 characters 
                s18 = s.substring(0, 21);
                //remove "
                s18 = s18.replaceAll('\"', '');
                //remove /
                s18 = s18.replaceAll('/', '');
                //build batcher for 15 digit id
                Matcher idMatcher18 = accountIdPattern18.matcher(s18);
                //add it to the set if match is found 
                if (idMatcher18.matches()) {
                    resultAccountIdSet.add(s18);
                }
            }
            
            return resultAccountIdSet;
        }
        return null;
    }
    
    public static String handelExceptionMessage(String exceptionMessage){
		String result;
		// handels the validation rules 
		if(exceptionMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
			result = exceptionMessage.subString(exceptionMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,'));
    		result = result.replace('FIELD_CUSTOM_VALIDATION_EXCEPTION,','');
    		if(result.indexOf(': [')>0)
    			result = result.subString(0, result.indexof(': ['));
		}else if(exceptionMessage.contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
			result = exceptionMessage.subString(exceptionMessage.indexOf('FIELD_FILTER_VALIDATION_EXCEPTION,'));
    		result = result.replace('FIELD_FILTER_VALIDATION_EXCEPTION,','');
    		if(result.indexOf(': [')>0)
    			result = result.subString(0, result.indexof(': ['));
		}else{
			result = exceptionMessage;
		}
		
		return result;
	}
	
}