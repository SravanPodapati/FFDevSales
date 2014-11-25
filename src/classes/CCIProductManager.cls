public class CCIProductManager{


// method to get valid packages for a user from CCI
public static List<CCIPackages>   getPackages(){
    System.debug('Entering getPackages..');  
    List<CCIPackages> packages = new List<CCIPackages>();  
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
    req.SetHeader('x-cci-user', Common.cciUser);
    req.SetHeader('x-cci-profile', Common.userProfile());
    req.SetHeader('x-cci-group', common.userGroup());
    req.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
    System.debug('Req is..'+ req);
    try{
    //creating an HttpRequest
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        System.debug('Response is' + res);
        if(!(res.getStatusCode() == 200)&&!(res.getStatusCode() == 201)) {
            //throw new CCIAPIException(Label.ErrorGettingPackages);
        } else {
            String updatedResponse = res.getBody().replace('desc','Description');
            packages = (List<CCIPackages>)System.JSON.deserialize(updatedResponse ,List<CCIPackages>.class);
            System.debug(packages);
            if(packages != null)
                packages.sort();
              
            }
    }catch(Exception e){
        System.debug('An exception occured in getting Packages ..'+ e);
        throw new CCIAPIException(Label.ErrorGettingPackages);
             }
    return packages;
                 
    
   
   }
   /*
   //TODO: At the time of deployment comment the following method and then do the deployment.
   public static List<ConceptValuesWithPackage> getConceptValues(OpportunityToOrder_BaseController2.ScheduleWrapper scheduleWrapper, String packageName,String packageCode ){
        OpportunityToOrder_BaseController.ScheduleWrapper tempScheduleWrapper = new OpportunityToOrder_BaseController.ScheduleWrapper();
       if(scheduleWrapper!= null && scheduleWrapper.packageRuleName != null){
       tempScheduleWrapper.packageRuleName = ScheduleWrapper.packageRuleName;
       tempScheduleWrapper.mediaCode = ScheduleWrapper.mediaCode;
       tempScheduleWrapper.selectedInsertionDates = ScheduleWrapper.selectedInsertionDates;
       tempScheduleWrapper.dateFlex = ScheduleWrapper.dateFlex;
       tempScheduleWrapper.packageCode = ScheduleWrapper.packageCode;
       tempScheduleWrapper.packageName = ScheduleWrapper.packageName;
       tempScheduleWrapper.titleCategoryCode = ScheduleWrapper.titleCategoryCode;
       tempScheduleWrapper.selectedDateToOpportunityID = ScheduleWrapper.selectedDateToOpportunityID;
       tempScheduleWrapper.fieldsList = new list<OpportunityToOrder_BaseController.FieldsWrapper>();
       for(OpportunityToOrder_BaseController2.FieldsWrapper fW : scheduleWrapper.fieldsList ){
           OpportunityToOrder_BaseController.FieldsWrapper tempFW = new OpportunityToOrder_BaseController.FieldsWrapper();
           tempFW.possibleOptions = fW.possibleOptions;
           tempFW.optionsMap = fW.optionsMap;
           tempFW.selectedValue = fW.selectedValue;

           OpportunityToOrder_BaseController.FieldSettings tempSetting = new OpportunityToOrder_BaseController.FieldSettings();
           tempSetting.conceptValuesKey = fW.setting.conceptValuesKey;
           tempSetting.equivalentFieldLabel = fW.setting.equivalentFieldLabel;
           tempSetting.salesforceFieldAPIName_Code = fW.setting.salesforceFieldAPIName_Code;
           tempSetting.salesforceFieldAPIName_Name = fW.setting.salesforceFieldAPIName_Name;
           tempSetting.inputType = fW.setting.inputType ;
           tempSetting.urlParameter = fW.setting.urlParameter;
           tempSetting.isRequired = fW.setting.isRequired;
           tempSetting.displayOrder = fW.setting.displayOrder;
           tempFW.setting = tempSetting;
           tempScheduleWrapper.fieldsList.add(tempFW);
       }
       }
        List<ConceptValuesWithPackage> resultList = getConceptValues(tempScheduleWrapper, packageName, packageCode );
        
        return resultList;
   }*/
   
   public static List<ConceptValuesWithPackage>   getConceptValues(OpportunityToOrder_BaseController.ScheduleWrapper scheduleWrapper, String packageName,String packageCode ){
       System.debug('Entering getConceptValues.');  
       Boolean firstCall = false;
       List<ConceptValuesWithPackage> conceptValues = new List<ConceptValuesWithPackage>();
       List<CCIOrder.Schedule> scList = new List<CCIOrder.Schedule>();
       List<String> packageRuleNames = new List<String>();
       Map<String,list<CCIConceptValuesGeneric>> cValMap = new Map<String,List<CCIConceptValuesGeneric >>();
       BookingSystemSettings__c setting = Common.cci; 
       String contentType =  setting.ContentType__c;
       String user = Common.cciUser;
       String grp = Common.userGroup();
       String profile = Common.userProfile();
       String accessToken;
      /* String packageRuleName = oli.Package_Rule_Name__c;
       String packageName  = oli.Package_Name__c;
       String packageCode=oli.Package__c;
       String pub = oli.Publication_Name__c;
       String section =oli.Section_Name__c ;
       String subsection=oli.Sub_Section_Name__c;
       String title=oli.Title_Name__c;
       String titleCategory = oli.Title_Category_Name__c;
       String mediaCode =oli.Media_Code__c; */
       
       if (Common.cciToken != null) {
                accessToken = Common.cciToken.access_token;
             } else {
                throw new CCIApiException('Can not read Access Token.');
             }
       //if this is the first call we need to create order first to get packagerulename and packagename
       if(scheduleWrapper==null ||String.IsBlank(scheduleWrapper.packageRuleName)){
                 firstCall = true;
           try{    
               CCIOrder  order = new CCIOrder(packageCode);
               String requestBody = Json.serialize(order);
               System.debug('Basic order is..'+order);
               HttpRequest req = new HttpRequest();  
            //set method  
               req.setMethod('POST');  
               req.setEndpoint(setting.Domain__c+setting.OrderPath__c+'/local');   
               req.setHeader('Content-Type', contentType );  
               req.SetHeader('x-cci-user', user);
               req.SetHeader('x-cci-profile',profile);
               req.SetHeader('x-cci-group', grp);
               req.SetHeader('Authorization', 'bearer ' + accessToken);
               req.setBody(requestBody);  
               req.setTimeout(60000); // timeout in milliseconds 
               System.debug('req...' + req.toString());
        
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             if(res.getStatusCode()!=400){
                System.debug('Order Response is'+res.getBody());
                 CCIOrder orderCreated  =(CCIOrder) Json.deserialize(res.getBody(),CCIOrder.class);
                 System.debug('OrderCreated is..'+ orderCreated);
                 scList  = orderCreated.Packageitems.PackageItem[0].Schedules.Schedule;
                 System.debug('List of schedules..'+ scList);
                            
              /*packageRuleName = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].packageRuleName;
              title = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].titleCode;
              titleCategory = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].titleCategoryCode;
              mediaCode = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].mediaCode;
              System.debug('packagerulename is..'+ packageRuleName);
              System.debug('Title category is..'+ titleCategory);
              if(String.isBlank(packageRuleName)) {        
                  throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
                  }*/
             }else throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
              
         }catch(Exception e){
             throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
         }
    }else{
       
          scList.add(new CCIOrder.Schedule(scheduleWrapper.packageRuleName,scheduleWrapper.mediaCode,scheduleWrapper.titleCategoryCode));
    }
   
   for(CCIOrder.Schedule sc:scList){
       /*
       String publi = sc.publicationCode;
       String sec = sc.SectionCode;
       String subSec  = sc.subSectionCode;
       String titCat = sc.titleCode;*/
         
       String packageRule = sc.packageRuleName;
       String media = sc.mediaCode;
       String titlecategory = sc.titleCategoryCode;
       String endpoint ;
   
      if(String.isBlank(packageRule))         
          throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
          
   
       if(packageRule.contains(' '))
           packageRule = packageRule .replace(' ','+');
      
      if(packageName.contains('+'))
           packageName = packageName.replace('+','%2B');
      else if(packageName.contains(' '))
           packageName = packageName.replace(' ','+');
        
         endPoint = setting.domain__c+setting.ConceptValuePath__c+'?packagerule='+packageRule+'@'+packageName;
         if(!firstCall){
             List<OpportunityToOrder_BaseController.FieldsWrapper> fieldList = scheduleWrapper.fieldsList;
             for(OpportunityToOrder_BaseController.FieldsWrapper fieldw: fieldList){
                 endpoint=endpoint+fieldw.setting.urlParameter +fieldw.selectedValue ;   
        }}
        /*else{
            String scheduleStr = Json.serialize(sc);
            Map<String, String> resultMap = new map<String,String>();
            set<string> tempSet = new set<string>{'sectionCode','subSectionCode','titleCode','titleCategoryCode','adUnitCode','webSiteCode','webSiteCategoryCode','distributionCode','productCategoryCode', 'productMainCategoryCode', 'productUnitCode', 'productCode', 'noOfUnits', 'publicationCode' };
            resultMap = (Map<String, String>) system.JSON.deserialize(scheduleStr, map<String,String>.class);
            for(String s : tempSet){
                if(resultMap.containsKey(s) && resultMap.get(s) != null && resultMap.get(s) != ''){
                String key = s.replace('Code','');
                endpoint= endpoint+'&'+key+'='+resultMap.get(s);
           }
           }

        }*/
        
        System.debug('endpoint is..'+ endpoint)                   ;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', contentType);
        req.SetHeader('x-cci-user', user);
        req.SetHeader('x-cci-profile',profile);
        req.SetHeader('x-cci-group', grp);
        req.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
        System.debug('Req is..'+ req);
        try{
            //creating an HttpRequest
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             System.debug('Response is' + res);
           if (!(res.getStatusCode() == 200)&&!(res.getStatusCode() == 201)) {
                throw new CCIAPIException(Label.ErrorGettingconceptValues);
            } else {
               String updatedResponse = res.getBody().replace('desc','Description');
               System.debug('Updatedresponse is..'+ updatedResponse);
             cValMap = 
             // (CCIConceptValues)System.JSON.deserialize(updatedResponse ,CCIConceptValues.class);
             (map<String, list<CCIConceptValuesGeneric>>) JSON.deserialize(updatedResponse ,map<String,list<CCIConceptValuesGeneric>>.class);
               
               
              ConceptValuesWithPackage cValPack = new ConceptValuesWithPackage(packageRule,cValMap,titleCategory);
              cValPack.mediaCode = media;
              System.debug('CValWithpackage..'+cValPack);
              conceptValues.add(cValPack);
               
            }}catch(Exception e){
                System.debug('An exception occured..'+ e);
                 throw new CCIAPIException(Label.ErrorGettingconceptValues);
                
            }
            }
              
      System.debug('Concept values with package list..'+ conceptValues)  ;
      return conceptValues;
   
   }
   
   
   
 /*  public static List<ConceptValuesWithPackage> getConceptValues(OpportunityLineItem oli){
       System.debug('Entering getConceptValues.');  
       List<ConceptValuesWithPackage> conceptValues = new List<ConceptValuesWithPackage>();
       List<CCIOrder.Schedule> scList = new List<CCIOrder.Schedule>();
       List<String> packageRuleNames = new List<String>();
       Map<String,list<CCIConceptValuesGeneric>> cValMap = new Map<String,List<CCIConceptValuesGeneric >>();
       BookingSystemSettings__c setting = Common.cci; 
       String contentType =  setting.ContentType__c;
       String user = Common.cciUser;
       String grp = Common.userGroup();
       String profile = Common.userProfile();
       String accessToken;
       String packageRuleName = oli.Package_Rule_Name__c;
       String packageName  = oli.Package_Name__c;
       String packageCode=oli.Package__c;
       String pub = oli.Publication_Name__c;
       String section =oli.Section_Name__c ;
       String subsection=oli.Sub_Section_Name__c;
       String title=oli.Title_Name__c;
       String titleCategory = oli.Title_Category_Name__c;
       String mediaCode =oli.Media_Code__c; 
       if (Common.cciToken != null) {
                accessToken = Common.cciToken.access_token;
             } else {
                throw new CCIApiException('Can not read Access Token.');
             }
       //if this is the first call we need to create order first to get packagerulename and packagename
       if(String.IsBlank(packageRuleName)){
                 
           try{    
               CCIOrder  order = new CCIOrder(packageCode);
               String requestBody = Json.serialize(order);
               System.debug('Basic order is..'+order);
               HttpRequest req = new HttpRequest();  
            //set method  
               req.setMethod('POST');  
               req.setEndpoint(setting.Domain__c+setting.OrderPath__c+'/local');   
               req.setHeader('Content-Type', contentType );  
               req.SetHeader('x-cci-user', user);
               req.SetHeader('x-cci-profile',profile);
               req.SetHeader('x-cci-group', grp);
               req.SetHeader('Authorization', 'bearer ' + accessToken);
               req.setBody(requestBody);  
               req.setTimeout(60000); // timeout in milliseconds 
               System.debug('req...' + req.toString());
        
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             if(res.getStatusCode()!=400){
                System.debug('Order Response is'+res.getBody());
                 CCIOrder orderCreated  =(CCIOrder) Json.deserialize(res.getBody(),CCIOrder.class);
                 System.debug('OrderCreated is..'+ orderCreated);
                 scList  = orderCreated.Packageitems.PackageItem[0].Schedules.Schedule;
                 System.debug('List of schedules..'+ scList);
                            
              //packageRuleName = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].packageRuleName;
            //  title = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].titleCode;
            //  titleCategory = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].titleCategoryCode;
            //  mediaCode = orderCreated.PackageItems.PackageItem[0].Schedules.Schedule[0].mediaCode;
           //   System.debug('packagerulename is..'+ packageRuleName);
            //  System.debug('Title category is..'+ titleCategory);
            //  if(String.isBlank(packageRuleName)) {        
           //       throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
           //       }
             }else throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
              
         }catch(Exception e){
             throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
         }
    }else{
        scList.add(new CCIOrder.Schedule(packageRuleName,title,titleCategory,pub,section,subSection));
    }
   
   for(CCIOrder.Schedule sc:scList){
       String packageRule = sc.packageRuleName;
       String publi = sc.publicationCode;
       String sec = sc.SectionCode;
       String subSec  = sc.subSectionCode;
       String tit = sc.titleCode;
       String titCat = sc.titleCategoryCode;
       String media = sc.mediaCode;
   
      if(String.isBlank(packageRule))         
          throw new CCIAPIException(Label.ErrorCreatingOrderInCCILocal);
          
   
       if(packageRule .contains(' '))
           packageRule = packageRule .replace(' ','+');
       if(packageName.contains(' '))
           packageName = packageName.replace(' ','+');
          
        String endpoint = setting.domain__c+setting.ConceptValuePath__c+'?packagerule='+packageRule+'@'+packageName+'&publication='+publi+'&section='+sec+'&subsection='+subsec+'&title='+tit+'&titlecategory='+titCat ;   
                            
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', contentType);
        req.SetHeader('x-cci-user', user);
        req.SetHeader('x-cci-profile',profile);
        req.SetHeader('x-cci-group', grp);
        req.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
        System.debug('Req is..'+ req);
        try{
            //creating an HttpRequest
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             System.debug('Response is' + res);
           if (!(res.getStatusCode() == 200)&&!(res.getStatusCode() == 201)) {
                throw new CCIAPIException(Label.ErrorGettingconceptValues);
            } else {
               String updatedResponse = res.getBody().replace('desc','Description');
               System.debug('Updatedresponse is..'+ updatedResponse);
             cValMap = 
             // (CCIConceptValues)System.JSON.deserialize(updatedResponse ,CCIConceptValues.class);
             (map<String, list<CCIConceptValuesGeneric>>) JSON.deserialize(updatedResponse ,map<String,list<CCIConceptValuesGeneric>>.class);
               
               
              ConceptValuesWithPackage cValPack = new ConceptValuesWithPackage(packageRule,cValMap,null);
              cValPack.mediaCode = media;
              System.debug('CValWithpackage..'+cValPack);
              conceptValues.add(cValPack);
               
            }}catch(Exception e){
                System.debug('An exception occured..'+ e);
                 throw new CCIAPIException(Label.ErrorGettingconceptValues);
                
            }
            }
              
      System.debug('Concept values with package list..'+ conceptValues)  ;
      return conceptValues;
   
   }*/
   
    public static List<CCIModule> getModules(List<OpportunityToOrder_BaseController.FieldsWrapper> fieldList,String packageCode,String packageRuleName,String packageName,String titleCategoryCode){

     //check none of the input parameters are blank
       BookingSystemSettings__c setting = Common.cci; 
       String contentType =  setting.ContentType__c;
       List<CCIModule> modules = new List<CCIModule>();
       String user = Common.cciUser;
       String grp = Common.userGroup();
       String profile = Common.userProfile();
       if((setting==null)|| String.IsBlank(setting.domain__c)|| String.IsBlank(setting.ProductKeyPath__c))   {
         throw new CCIAPIException(Label.No_booking_system_settings);       
       }
       
         if(packageRuleName.contains(' '))
           packageRuleName= packageRuleName.replace(' ','+');
      
      if(packageName.contains('+'))
           packageName = packageName.replace('+','%2B');
      else if(packageName.contains(' '))
           packageName = packageName.replace(' ','+');
       // String endpoint = setting.domain__c+setting.ProductKeyPath__c+'?packagerule='+packageRuleName+'@'+packageName+'&publication='+pub+'&section='+section+'subsection='+subsection+'&title='+title+'titlecategory='+titleCategory+'&Zone='+zone ;   
        String endpoint = setting.domain__c+setting.ProductKeyPath__c+'?packagerule='+packageRuleName+'@'+packageName+'&titleCategory='+titleCategoryCode ;   
        for(OpportunityToOrder_BaseController.FieldsWrapper fieldw: fieldList){
            if(fieldw.selectedValue!=null)
                 endpoint=endpoint+fieldw.setting.urlParameter +fieldw.selectedValue ;   
             else if(fieldw.setting.IsRequired && fieldw.selectedValue==null){
                // throw new CCIAPIException(Label.BlankConceptValues);
                return null;
                }
                 
        }  
        System.debug('endpoint is..'+endpoint);
        System.debug('User is..'+user);
        System.debug('profile is..'+profile);
        System.debug('grp is..'+ grp);
        //creating a request        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', contentType);
        req.SetHeader('x-cci-user', user);
        req.SetHeader('x-cci-profile', profile);
        req.SetHeader('x-cci-group', grp);
        req.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
        System.debug('Req is..'+ req);
        try{
            //creating an HttpRequest
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             System.debug('Response is' + res);
            if(!(res.getStatusCode() == 200)&&!(res.getStatusCode() == 201)) {
               if(res.getStatusCode() ==204){
                //throw new CCIAPIException(Label.BlankConceptValues);
                return null;
                
                }
                else{
                // throw new CCIAPIException(Label.ErrorGettingModules);
                return null;
                }
            } 
              //  List<packageobject> deserializedPackages = 
           //   (List<packageobject>)JSON.deserialize(JSONString, List<packageobject>.class);
            String response = res.getBody();
            System.debug('response..'+ response);
            Map < String, Object > mWholeResponse = (Map < String, Object > ) JSON.deserializeUntyped(response );
            System.debug('Whole response is' + response );
            String productKey= (String)mWholeResponse.get('productKey');
            if(productKey.contains('&#124;')) productKey = productkey.replace('&#124;','%7c');
            System.debug('Product key is..'+ productKey);
    
    
            String moduleEndpoint = setting.domain__c+'/api/setup/product/modules/'+productKey+'?package='+packageCode+'&packagerule='+packageRuleName ;   
            System.debug('Module endpoint is..'+ moduleEndpoint);
            HttpRequest reqModules = new HttpRequest();
            reqModules.setMethod('GET');
            reqModules.setEndpoint(moduleEndpoint );
            reqModules.setHeader('Content-Type', contentType);
            reqModules.SetHeader('x-cci-user', user);
            reqModules.SetHeader('x-cci-profile', profile);
            reqModules.SetHeader('x-cci-group', grp);
            reqModules.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
            System.debug('Req is..'+ reqModules);
            Http httpModules = new Http();
            HttpResponse resModules = new HttpResponse();
            resModules = httpModules.send(reqModules );
            if(!(resModules.getStatusCode() == 200)) {
                  return null;
            
            }
            String resModStr = resModules.getBody();
            String updatedResModules = resModStr.replace('desc','description');
           
             modules= 
              (List<CCIModule>)System.JSON.deserialize(updatedResModules,List<CCIModule>.class);
               
            }catch(Exception e){
                System.debug('An exception occured..'+ e);
                throw new CCIAPIException(e.getMessage());
                
                 
            }
                 
     return modules;
   
         }
   
   
   // method to get valid publishing dates for a particular selection of package,publication,section,subsection,title and zone
     public static Set<String> getValidPublishingDates(List<OpportunityToOrder_BaseController.FieldsWrapper> fieldList,List<String> insertionDates,String packageRuleName,String packageName,String titleCategoryCode){

      
      
       BookingSystemSettings__c setting = Common.cci; 
       Set<String> validDates = new Set<String>();
       String contentType =  setting.ContentType__c;
       String user = Common.cciUser;
       String grp = Common.userGroup();
       String profile = Common.userProfile();
       
            
       if((setting==null)|| String.IsBlank(setting.domain__c)|| String.IsBlank(setting.ProductKeyPath__c))   {
         throw new CCIAPIException(Label.No_booking_system_settings);       
       }
       
         if(packageRuleName.contains(' '))
           packageRuleName= packageRuleName.replace(' ','+');
      
      if(packageName.contains('+'))
           packageName = packageName.replace('+','%2B');
      else if(packageName.contains(' '))
           packageName = packageName.replace(' ','+');
       // String endpoint = setting.domain__c+setting.ProductKeyPath__c+'?packagerule='+packageRuleName+'@'+packageName+'&publication='+pub+'&section='+section+'subsection='+subsection+'&title='+title+'titlecategory='+titleCategory+'&Zone='+zone ;   
        String endpoint = setting.domain__c+setting.ProductKeyPath__c+'?packagerule='+packageRuleName+'@'+packageName+'&titleCategory='+titleCategoryCode ;   
        for(OpportunityToOrder_BaseController.FieldsWrapper fieldw: fieldList){
            if(fieldw.selectedValue!=null)
                 endpoint=endpoint+fieldw.setting.urlParameter +fieldw.selectedValue ;   
           else if(fieldw.setting.IsRequired && fieldw.selectedValue==null){
             throw new CCIAPIException(Label.BlankConceptValues);
             }
                 
        }  
        System.debug('endpoint is..'+endpoint);
        System.debug('User is..'+user);
        System.debug('profile is..'+profile);
        System.debug('grp is..'+ grp);
        //creating a request        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', contentType);
        req.SetHeader('x-cci-user', user);
        req.SetHeader('x-cci-profile', profile);
        req.SetHeader('x-cci-group', grp);
        req.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
        System.debug('Req is..'+ req);
        try{
            //creating an HttpRequest
             Http http = new Http();
             HttpResponse res = new HttpResponse();
             res = http.send(req);
             System.debug('Response is' + res);
            if(!(res.getStatusCode() == 200)&&!(res.getStatusCode() == 201)) {
               if(res.getStatusCode() ==204)
                throw new CCIAPIException(Label.BlankConceptValues);
                else
                 throw new CCIAPIException(Label.ErrorGettingDates);
            } 
              //  List<packageobject> deserializedPackages = 
           //   (List<packageobject>)JSON.deserialize(JSONString, List<packageobject>.class);
            String response = res.getBody();
            System.debug('response..'+ response);
            Map < String, Object > mWholeResponse = (Map < String, Object > ) JSON.deserializeUntyped(response );
            System.debug('Whole response is' + response );
            String productKey= (String)mWholeResponse.get('productKey');
            if(productKey.contains('&#124;')) productKey = productkey.replace('&#124;','%7c');
            System.debug('Product key is..'+ productKey);
    
    
        String calendarEndpoint = setting.domain__c+setting.CalendarPath__c+productKey+'?first='+System.Now().format('yyyy-MM-dd')+'&last='+System.Now().addYears(1).format('yyyy-MM-dd') ;   
        HttpRequest reqDates = new HttpRequest();
        reqDates.setMethod('GET');
        reqDates.setEndpoint(calendarEndpoint );
        reqDates.setHeader('Content-Type', contentType);
        reqDates.SetHeader('x-cci-user', user);
       reqDates.SetHeader('x-cci-profile', profile);
        reqDates.SetHeader('x-cci-group', grp);
        reqDates.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
        System.debug('Req is..'+ reqDates);
        Http httpModules = new Http();
        HttpResponse resDates = new HttpResponse();
        resDates = httpModules.send(reqDates);
        if(!(resDates.getStatusCode() ==200)) throw new CCIAPIException(Label.ErrorGettingDates);
             
        response = resDates.getBody();
        System.debug('date response is..'+ response);
          validDates= 
              (Set<String>)System.JSON.deserialize(response,Set<String>.class);
       
            }catch(Exception e){
                System.debug('An exception occured..'+ e);
                throw new CCIAPIException(Label.ErrorGettingDates);
                 
            }
                 
     return validDates;
   
         }
         
         
       public static List<CCICancelReasons> getCancelReasons(){
      
      
       BookingSystemSettings__c setting = Common.cci; 
       Set<String> validDates = new Set<String>();
       String contentType =  setting.ContentType__c;
       String user = Common.cciUser;
       String grp = Common.userGroup();
       String profile = Common.userProfile();
       String endPoint = setting.domain__c+'/api/setup/order/cancelreasons';
       List<CCICancelReasons> cancelReasons = new List<CCICancelReasons>();
      
       HttpRequest req = new HttpRequest();
       req.setMethod('GET');
       req.setEndpoint(endPoint);
       req.setTimeout(60000);
       req.setHeader('Content-Type', contentType);
       req.SetHeader('x-cci-user', user);
       req.SetHeader('x-cci-profile', profile);
       req.SetHeader('x-cci-group', grp);
       req.SetHeader('Authorization', 'bearer ' + common.cciToken.access_token);
       
         try{
            
              
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                 res = http.send(req);
                System.debug('Response is' + res);
            if (!(res.getStatusCode() == 200)) {
                throw new CCIAPIException('Error getting cancel reasons');
            } else {
                String updatedResponse = res.getBody().replace('desc','Description');
                 cancelReasons = (List<CCICancelReasons>)System.JSON.deserialize(updatedResponse ,List<CCICancelReasons>.class);
       }
   }catch(Exception e){
        
   }
       return cancelReasons;
   }
   
   
   


}