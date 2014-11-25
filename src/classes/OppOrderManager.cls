/*******
Date Created:  2014-07-22
Api Version   :v1
****************************/
    
public with sharing class OppOrderManager {
      
    public OppOrderManager(){}


    
    /*//TODO: Remove the following method as this is only valid in ordmandev
    public ResultWrapper createOrderFromOppLineItem_new(list<OpportunityToOrder_BaseController2.ScheduleWrapper> swList, List<OpportunityLineItem> oppLItems,Opportunity opp) {
        //type cast from ScheduleWrapper2 to ScheduleWrapper
            list<OpportunityToOrder_BaseController.ScheduleWrapper> tempList = new list<OpportunityToOrder_BaseController.ScheduleWrapper>();
            for(OpportunityToOrder_BaseController2.ScheduleWrapper scheduleWrapper : swList){
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
                tempList.add(tempScheduleWrapper);
            }
            return createOrderFromOppLineItem_new(tempList, oppLItems, opp);
    }*/
    
   
    public ResultWrapper createOrderFromOppLineItem_new(list<OpportunityToOrder_BaseController.ScheduleWrapper> swList, List<OpportunityLineItem> oppLItems,Opportunity opp) {
        ResultWrapper rW = new ResultWrapper();
        if(swList != null && swList.size()>0){
            for(OpportunityToOrder_BaseController.ScheduleWrapper sW : swList){
                List<OpportunityToOrder_BaseController.FieldsWrapper> fldWrapper =  sw.fieldsList;
                String insertionDates = sw.selectedInsertionDates;
                System.debug('insertion dates are ..'+ insertionDates);
                List<String> datesSelected = insertionDates.split(',');
                try{
                Set<String > validDates = CCIProductManager.getValidPublishingDates(fldWrapper,datesSelected,sw.packageRuleName,sw.packageName,sw.titleCategoryCode) ;
                for(String s : datesSelected){
                    Date date1  = date.parse(s);
                    System.debug('date1  ..'+date1  );
                   // Date dt2 = date1.date();
                   // System.debug('newDate..'+newDate);
                    String date2 = datetime.newInstance(date1.year(),date1.month(), date1.day()).format('yyyy-MM-dd');
                    System.debug('date2..'+ date2);
                   // String dtString = date1.year()+'-'+date1.month()+'-'+date1.day()    ;
                   String dtString = String.valueOf(date1);
                    System.debug('dtString is..'+ dtString);
                    //Date newDate = Datetime
                    if(!validDates.contains(dtString)){
                        rW = rW.addErrorMessage(rW, ApexPages.Severity.ERROR, 'Selected Date '+ dtString+' is  not valid for Package '+sW.packageName);
                        rW.hasMessages = true;
                        //return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'Date selected is not valid for this opportunity'})});
                    }
                }
                }catch(Exception e){
                  rW = rW.addErrorMessage(rW, ApexPages.Severity.ERROR, e.getMessage());
                        rW.hasMessages = true;
                }
            }
        }
        if(rW.hasMessages == true){
            return rW;
        }else{
            rW = createOrderFromOppLineItem_new(oppLItems, opp);
            return rW;
        }
    }
   
     //a  method called by user on opportunityline item to create an order and open edit order booking plugin 
     public ResultWrapper createOrderFromOppLineItem_new(List<OpportunityLineItem> oppLItems,Opportunity opp) {
        System.debug('Entered createOrderFromOppLineItem_new..'+ oppLItems);
        
         String editPluginPath;
         String url;
         FinanceAccount__c finAcc;
         BookingSystemSettings__c setting;
         String cciAdvertiserId;
         String cciAgencyId;
         String userType;
         String cciFinAccId;
         String domain;
         String cciBookingAgencyId;
         String cciClient;
         String cciHoldingCo;
         String cciHoldingAgency;
         String cciBookingAgency;
         String holdingCo;
         String holdingAgency;
         Account oliAgency;
         Account bookingAgency;
         Account  acc;
         Account parentAcc; 
         Account parentAgency;
         String accessToken;
        
        
      
        
         try{
         setting = Common.cci;
         OrderParams__c orderParams = Common.cciOrderParams;
         acc = oppLItems[0].Account__r;
         parentAcc = acc.Parent;
         
         if (setting != null) {
             domain = setting.Domain__c;
             editPluginPath = setting.EditBookingPluginPath__c;
            if (String.IsBlank(domain) || String.IsBlank(editPluginPath) ) {
                    throw new BookingSystemSettingsException();
         }
         }
        
         if (Common.cciToken != null) {
                accessToken = Common.cciToken.access_token;
         } else {
                throw new CCIApiException('Can not read Access Token.');
         }
         System.debug('Token is' + accessToken);
         if(oppLItems[0].Billing_Agent__c!=null && oppLItems[0].Billing_Agent__r.id!=acc.id){
                 System.debug('billing agency is different for account');
                 oLIAgency = oppLItems[0].Billing_Agent__r;
                 parentAgency = OLIAgency.Parent;
       
         }
         if(opp.Agency__c!=null&&opp.Agency__r.Type=='Booking'){
             bookingAgency = opp.Agency__r;
             parentAgency = bookingAgency.parent;
          }
     
         User u = Common.getUserInfo();
         String cciGroup = Common.userGroup();
         String cciProfile = Common.userProfile();
         String user = Common.cciUser;
         if(Common.cciMailEquivelentProfiles.contains(u.profile.Name)||Common.cciSystemAdminEquivalentProfiles.contains(u.profile.Name)){
            usertype='Mail';
         }else if(common.cciMetroEquivelentProfiles.contains(u.profile.Name))
              userType='Metro';
     
        if(userType==null) return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'User is not valid to create CCI Opportunity Order'})});
        cciAdvertiserId = userType=='Mail'?acc.CCIMailCustId__c:acc.CCIMetroCustID__c;
        if(OLIAgency!=null)
        cciAgencyId =  userType=='Mail'?oLIAgency.CCIMailCustId__c:oLIAgency.CCIMetroCustID__c;
        if(bookingAgency!=null){cciBookingAgencyId =  userType=='Mail'?bookingAgency.CCIMailCustId__c:bookingAgency.CCIMetroCustID__c;
        if(String.IsBlank(cciBookingAgencyId)) return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.UnSynchedAccOrAgency})}); 
        }
        if(cciAdvertiserId==null|| (OLIAgency!=null &&cciAgencyId==null)) return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.UnSynchedAccOrAgency})}); 
       Account billingAgent = OLIAgency!=null?OLIAgency:acc;
       String billingAgentID =  OLIAgency!=null?cciAgencyId:cciAdvertiserId ;
       System.debug('billingAgent is..'+ billingAgent+'..billingAgentID..'+billingAgentID);
        if(userType=='Mail'){
            finAcc=[Select id,SOP_ID__c,SOP_Source__c from FinanceAccount__c where Account__c =:billingAgent.Id and SOP_Source__c ='CCI' and CloseStatus__c='Live'and Account__r.CCIMailCustID__c =: billingAgentID ];
            }
        else{
          finAcc=[Select id,SOP_ID__c,SOP_Source__c from FinanceAccount__c where Account__c =:billingAgent.Id and SOP_Source__c ='CCI' and CloseStatus__c='Live'and  Account__r.CCIMetroCustID__c =: billingAgentID ];
         }   
        if(finAcc!=null){
            System.debug('Entering finAcc not null');
            cciFinAccId = finAcc.SOP_ID__c;
                   
       }else return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'Finance Account does not exist for'+billingAgent.name})});
       if(cciFinAccId==null)return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'CCI Finance Account does not exist for'+billingAgent.name})});
       
       if(parentAcc!=null && parentAcc.Type!='Holding Company'){
             cciClient = userType=='Mail'?parentAcc.cciMailCustId__c:parentAcc.CCIMetroCustId__c;
             if(String.IsBlank(cciClient)) return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.NoParentCCI})});
             }
        else if(parentAcc!=null && parentAcc.Type=='Holding Company'){
              cciHoldingCo = userType=='Mail'?parentAcc.cciMailCustId__c:parentAcc.CCIMetroCustId__c;
              if(String.IsBlank(cciHoldingCo )) return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.NoHoldingCoCCI})});
              }
        
       if(parentAcc!=null &&!String.IsBlank(parentAcc.parentId)&&String.IsBlank(cciHoldingCo)){
         String rootId = Common.rootAccount(parentAcc.Id);
         System.debug('Holding co for acc is..'+ rootId);
         if(rootId!=parentAcc.id)
             holdingCo = rootId;
         }
         if(parentAgency!=null){
            holdingAgency = Common.rootAccount(parentAgency);
             }
         
         if(!String.IsBlank(holdingCo)&&!String.IsBlank(holdingAgency)){
             List<String> holdingAccIds = new List<String>();
             holdingAccIds.add(holdingCo);
             holdingAccIds.add(holdingAgency);
             Map<Id,Account> holdingAccMap =  new Map<Id,Account>([Select id,CCIMailCustId__c,CCIMetroCustId__c from Account where id in :holdingAccIds]);
             cciHoldingCo = userType=='Mail'?holdingAccMap.get(holdingCo).cciMailCustId__c:holdingAccMap.get(holdingCo).cciMetroCustId__c;
             cciHoldingAgency = userType=='Mail'?holdingAccMap.get(holdingAgency).cciMailCustId__c:holdingAccMap.get(holdingAgency).cciMetroCustId__c;
             if(String.IsBlank(cciHoldingCo))
                 return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.NoHoldingCoCCI})});
             if(String.IsBlank(cciHoldingAgency) )
                 return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.NoHoldingAgencyCCI})});

         }
         else if(!String.IsBlank(holdingCo)){
             Account holdingCoAcc =  [Select id,CCIMailCustId__c,CCIMetroCustId__c from Account where id=:holdingCo limit 1];
             cciHoldingCo = userType=='Mail'?holdingCoAcc.CCIMailCustId__c:holdingCoAcc.cciMetroCustId__c;
             if(String.IsBlank(cciHoldingCo))
                 return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.NoHoldingCoCCI})});
            
         
         }else if(!String.IsBlank(holdingAgency)){
           Account holdingAgencyAcc =  [Select id,CCIMailCustId__c,CCIMetroCustId__c from Account where id=:holdingAgency limit 1];
           cciHoldingAgency = userType=='Mail'?holdingAgencyAcc.CCIMailCustId__c:holdingAgencyAcc.CCIMetroCustId__c;
            if(String.IsBlank(cciHoldingAgency))
             return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.NoHoldingAgencyCCI})});
         }
         
       //creating an order in CCI with all the information in opportunity and oppLine Item
       String orderId   = createOrderForEdit(opp,oppLItems,cciAdvertiserId,cciAgencyId,cciFinAccId,cciClient,cciHoldingCo,cciHoldingAgency,cciBookingAgency,setting,cciProfile,cciGroup); 
       System.debug('Order Id is..'+orderId);
       if(String.IsBlank(orderId)){
        return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'An error has occured in creating an order in CCI'})});
       }
       url = domain + editPluginPath+orderId+'?'+orderParams.UserId__c + user+ orderParams.Group__c + cciGroup + orderParams.Profile__c + cciProfile+orderParams.AuthCode__c + getAuthCode(setting) + orderParams.ClientId__c;
       url = url + '&confirmationurl=' + Common.GetBaseUrlForInstance() + '/apex/OpportunityToOrder%3Foppid%3D' + opp.Id;
       }catch(Exception e){
       System.debug('Found an exception..'+ e);
        return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.CCI_Exception})});
       }
       System.debug('Before exiting createOrderFromOppLineItem_new..' + url);
       return new ResultWrapper(url);
     
     }
  
   // this method will create an order in cci and return newly created order id 
    public Static String createOrderForEdit(Opportunity opp,List<OpportunityLineItem> oppLItems,String cciAdvertiserId,String cciAgencyId,String cciFinAcc,String cciClient,String cciHoldingCo,String cciHoldingAgency,String cciBookingAgency, BookingSystemSettings__c setting,String profile,String cciGroup){
       System.debug('Entered createOrderForEdit..');
       String domain;
       String orderPath;
       String contentType;
       String orderId;
        if (setting != null) {
             domain = setting.Domain__c;
             orderPath = setting.OrderPath__c;
             contentType = setting.ContentType__c;
             if (String.IsBlank(domain) || String.IsBlank(orderPath) || String.IsBlank(contentType)) {
                    throw new BookingSystemSettingsException();
         }}
        
           
           CCIOrder  order = new CCIOrder(opp, oppLItems,cciAdvertiserId,cciAgencyId,cciFinAcc,cciClient,CCIHoldingCo,CCiHoldingAgency,cciBookingAgency);
           System.debug('CCI Order is'+ order);
           return  executeRequest(opp,oppLItems,domain+orderPath,contentType,Common.cciUser,profile,cciGroup, order);
         
         }
    
    
   
    public static String  executeRequest(Opportunity opp, List<OpportunityLineItem> olItems,String path,String contentType,String user,String profile,String grp,CCIOrder order){
        String requestBody = Json.serialize(order);
        System.debug('req body is..'+ requestBody);
        String jsonReq = requestBody.replace('num','number');
        String orderId;
        String firstOrderId;
        HttpRequest req = new HttpRequest();  
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());

        //set method  
        req.setMethod('POST');  
        req.setEndpoint(path+'/local');   
        req.setHeader('Content-Type', contentType);  
        req.SetHeader('x-cci-user', user);
        req.SetHeader('x-cci-profile',profile);
        req.SetHeader('x-cci-group', grp);
        req.SetHeader('Authorization', 'bearer ' + Common.cciToken.access_token);
        req.setBody(jsonReq);  

        system.debug('Envelope is...'+jsonReq);
        system.debug('req...' + req.toString());
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        string[] headerkeys = res.getHeaderKeys();
        String session = res.getHeader('x-cci-session');
       
        System.debug('session is..'+ session);
        if(res.getStatusCode()!=400){
           
            String  OrderStr = res.getBody();
             Map < String, Object > mWholeResponse = (Map < String, Object > )Json.deserializeUntyped(res.getBody());
                    System.debug('Whole response is' + mWholeResponse);
                    firstOrderId = (String) mWholeResponse.get('orderId');
            try{
               String commitResp =  
               updateOrder(opp,oLItems,orderStr,firstOrderId,path,user,profile,grp,contentType,session);
               Map <String, Object > finalResponse = (Map < String, Object > )Json.deserializeUntyped(commitResp);
                    System.debug('Whole response is' + mWholeResponse);
                    orderId = (String) finalResponse.get('orderId');
         
            }catch(Exception e){
            // throw an exception
            }
        }else{
        //throw an exception
        }
                  
        return orderId;
       
    }
    
    
       //method to update orderItem with correcr oportunity id,date flex and po no
       public static String updateOrder(Opportunity opp,List<OpportunityLineItem> oppLItems,String order,String orderId,String path,String user,String profile,String grp,String contentType,String session){
             System.debug('Entered update order..');
             String commitResponse;
             Boolean requiresUpdate;
             Set<String> schedules = new Set<String>();
             Map<String,List<OpportunityLineItem>> sOppMap = new Map<String,List<OpportunityLineItem>>();
             for (OpportunityLineItem oli:oppLItems){
                 if(schedules.contains(oli.Schedule_Identifier__c))
                    sOppMap.get(oli.Schedule_Identifier__c).add(oli);
                 else{
                      schedules.add(oli.Schedule_identifier__c);
                      List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                      oliList.add(oli);
                      sOppMap.put(oli.Schedule_Identifier__c,oliList);
             }
             }
             Set<String> schedulesToUpdate = new Set<String>();
             Set<String> packSch = new Set<String>();
             for(String schedule:schedules){
                 for (OpportunityLineItem opp1:sOppMap.get(schedule)){
                      if(packSch.contains(opp1.Package_Rule_Name__c+schedule)){
                         schedulesToUpdate.add(schedule);
                         break;
                         }
                         else{
                         packSch.add(opp1.Package_Rule_Name__c+schedule);
                         }
                 }
                 }
             System.debug('SchedulesToUpdate..'+ schedulesToUPdate);
             for(String scForUpdate:schedulesToUpdate){
                 System.debug('schedule to update is..'+ scForUpdate);
                 if(order.indexof('"'+scForUpdate+'"')>0){
                     String p1 =  order.subString(order.indexOf('"'+scForUpdate+'"'),order.length()-1);
                     String p2 = order.subString(0,order.indexOf('"'+scForUpdate+'"'));
                     Integer i1 = p2.lastIndexOf('"scheduleId"');
                     Integer i2 = p1.indexOf('"packageItemRepetitions"');
                     Integer i3 = p2.length()-1;
                
                     String partStr = order.SubString(i1,(i3+i2));
                     System.debug('partStr is..'+ partStr);
                
               //  String partStr1 =partStr.SubString(0,partStr.indexof('orderItems')-1);
               //  String partStr2 = partStr.SubString(partStr.indexOf('"orderItems"'),partStr.length());
                     List<OpportunityLineitem> oppLineItems = sOppMap.get(scForUpdate);
                     System.debug('opps..'+ oppLineItems);
                     for(OpportunityLineItem oli: oppLineItems ){
                         System.debug('Enter opp..'+ oli);
                         String packageruleName = oli.package_rule_name__c;
                         if(packageruleName.contains('+'))
                         packageRuleName = packageRuleName.replace('+',' ');
                         System.debug('Packagerulename is..'+ packagerulename);
                         try{
                         String partStr1 = partStr.subString (0,partStr.indexOf('"'+packageruleName+'"'));
                         System.debug('partStr1is..'+ partStr1);
                         String partStr2 = partStr.subString(partStr.indexOf('"'+packageruleName+'"'),partStr.length());
                         System.debug('partStr2 is..'+ partStr2);
                         String partStr3 =partStr2.SubString(0,partStr2.indexof('orderItems')-1);
                         System.debug('partStr3 is..'+ partStr3);
                         String partStr4 = partStr2.SubString(partStr2.indexOf('"orderItems"'),partStr2.length());
                                           
                         System.debug('partStr4..'+ partStr4);
                     
                       
                         String date1 = datetime.newInstance(oli.ServiceDate.year(), oli.ServiceDate.month(), oli.ServiceDate.day()).format('yyyy-MM-dd');
                         System.debug('date is..'+ date1);
                         Integer dateIndex = partStr4.indexOf('"'+date1+'"');
                         if(dateIndex>0){
                       //if(partStr2.contains('"firstDeliveryDate":"+date1){
                             requiresUpdate = true;
                             String tempStr1 = partStr4.subString(0,partStr4.indexOf('"'+date1+'"'));
                             System.debug('TempStr1..'+ tempStr1);
                             String tempStr4 = partStr4.subString(partStr4.indexOf('"'+date1+'"'),partStr4.length());
                             String tempStr3 =tempStr4.Substring(tempStr4.indexOf('"purchaseOrderNo"'),tempStr4.length()); 
                             System.debug('TempStr3 is..'+ tempStr3 );
                             String tempStr2=  tempStr4.subString(tempStr4.indexOf('"'+date1+'"'),tempStr4.indexOf('"opportunityId"'))+'"opportunityId":"'+ oli.id+'",'+tempStr3 ;
                             System.debug('tempStr2 after opp update..'+ tempStr2);
                        // tempStr2=  partStr.subString(partStr.indexOf('"'+date1+'"'),partStr.indexOf('"purchaseOrderNo"'))+'"purchaseOrderNo":'+ oli.PO_Number__c+partStr.Substring(partStr.indexOf('"PO_Number__c"')+3,partStr.length()-1);
                         
         //             // tempStr2=  partStr.subString(partString.indexOf('"'+date1+'"'),partString.indexOf('"isFlexDate"'))+'"isFlexDate":'+ oli.Dateflex__c+partString.Substring(partString.indexOf('"PO_Number__c"')+3,partString.length()-1);
                       
                             partStr4 = tempStr1+tempStr2;
                             System.debug('partStr4..'+ partStr4);
                             partStr = partStr1+partStr3+partStr4;
                             System.debug('partString after update..'+ partStr);
                             }
                         }catch(Exception e){
                             System.debug('An exception has occured..'+ e);
                        }
                     }
                     
                     
                   System.debug('requiresUpdate..'+ requiresUpdate)             ;
                   if(requiresUpdate){
                       System.debug('Entered requiresUpdate');
                       System.debug('a1..'+ order.subString(0,i1));
                       System.debug('a3 is..'+order.subString(i3+i2,order.length()) );
                       order = order.subString(0,i1)+partStr+order.subString(i3+i2,order.length());
                       }
                       }
                       }
                       
                 
               //  if(schedulesToUpdate.size()>0 && requiresUpdate ){
                   System.debug('Entered OrdertoUpdate..');
                    HttpRequest req = new HttpRequest(); 
                    req.setTimeout(Common.cci.ReadTimeout__c.IntValue());

                    req.setMethod('PUT');  
                    //req.setMethod('POST');  
                    // req.setEndpoint(path+'/local/'+orderId);
                    req.setEndpoint(path+'/'+orderId);   
                    // req.setEndpoint(path);
                    req.setHeader('Content-Type', contentType);  
                    req.SetHeader('x-cci-user', user);
                    req.SetHeader('x-cci-profile',profile);
                    req.SetHeader('x-cci-group', grp);
                    req.setHeader('x-cci-session',session);
                    req.SetHeader('Authorization', 'bearer ' + Common.cciToken.access_token);
           
                    system.debug('x-cci-session:'+req.getHeader('x-cci-session'));
           
                    req.setBody(order);  

                    system.debug('Envelope is...'+order);
                    system.debug('req...' + req.toString());
                    
                    Http http = new Http();
                    HttpResponse res = new HttpResponse();
                    res = http.send(req);
                    if(res.getStatusCode()!=400){
                        //throw an exception
                    }
                    commitResponse = res.getBody();
           System.debug('commitResponse:'+commitResponse);
                    
              //   }
         
         return commitResponse;
           
     
     }
   
  
    //This is a non static method to cancel Order
     public String cancelOrderItem(String orderItemId,String orderId,String code,String reason){
         BookingSystemSettings__c setting = Common.cci;
         String domain;
         String orderPath;
         String accessToken;
         
         if(setting != null){
            domain = setting.Domain__c;
            orderPath = setting.OrderPath__c;
            if (domain == null || orderPath == null) throw new BookingSystemSettingsException();
        }else throw new BookingSystemSettingsException();
         
         //if(Common.cciToken != null) {
                accessToken = Common.cciToken.access_token;
           //} else {
             //   throw new CCIApiException('Can not read Access Token.');
            //}
        //CCIOrderCancel cancelOrder = new CCIOrderCancel(code,reason);
       // String jsonreq = cancelOrder.getReqJsonBody();
        //creating HttpRequest
        HttpRequest req = new HttpRequest();  
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());

        req.setMethod('GET');  
        req.setEndpoint(domain+orderPath+'/'+orderId);   
        req.setHeader('Content-Type', 'application/json');  
        req.SetHeader('x-cci-user', Common.cciuser);
        req.SetHeader('x-cci-profile', common.userProfile());
        req.SetHeader('x-cci-group', common.userGroup());
        req.SetHeader('Authorization', 'bearer ' + accessToken);
       // req.setBody(jsonreq);
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            return 'Failure';
        }
      String   orderStr = res.getbody();
     
     // adding cancel reasoncode
      orderStr = orderStr.substring(0,orderStr.indexof('"cancelReasonCode"'))+'"cancelReasonCode":'+'"'+code+'",'+orderStr.subString(orderStr.indexOf('"cancelReasonName"'),orderStr.length());
     
      String orderStr1 = orderStr.subString(0,orderStr.indexOf('"'+orderItemId+'"'));
      String orderStr2 = orderStr.subString(orderStr.indexOf('"'+orderItemId+'"'),orderStr.length());
      String orderStr3 = orderStr2.subString(0,orderStr2.indexOf('"priceItemReference"'));
      String deliveryDateStr = orderStr3.subString(orderStr3.indexOf('"firstDeliveryDate"'),orderStr3.indexOf('"lastDeliveryDate"'));
      String deliverydate = deliveryDateStr.subString(deliveryDateStr.indexOf(':'),deliveryDateStr.length());
      orderStr3 = orderStr3.subString(0,orderStr3.indexOf('"cancelDate"'))+ '"cancelDate"'+ deliveryDate +orderStr3.subString(orderStr3.indexOf('"initialCreationTime"'),orderStr3.length());
      String orderStr4 = orderStr2.subString(orderStr2.indexOf('"priceItemReference"'),orderStr2.length());
      
      String cancelledStr = orderStr1+orderStr3+orderStr4;
      
      HttpRequest cancelReq = new HttpRequest();  
        cancelReq.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        cancelReq.setMethod('PUT');  
        cancelReq.setEndpoint(domain+orderPath+'/'+orderId);   
        cancelReq.setHeader('Content-Type', 'application/json');  
        cancelReq.SetHeader('x-cci-user', Common.cciuser);
        cancelReq.SetHeader('x-cci-profile', common.userProfile());
        cancelReq.SetHeader('x-cci-group', common.userGroup());
        cancelReq.SetHeader('Authorization', 'bearer ' + accessToken);
        cancelReq.setBody(cancelledStr);
        
        Http cancelHttp = new Http();
        HttpResponse cancelRes = new HttpResponse();
        cancelRes = cancelHttp.send(cancelReq);
        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            return 'Failure';
        }
     
       return 'Success';
     //   req.setCompressed(true);   
      
   

}
//This method return booking plug in URL for editing an order
  public ResultWrapper editAccountOrder(Order order,Opportunity opp){
        String domain;
        String url ;
        String bookingPluginPath;
        try{
        BookingSystemSettings__c setting = BookingSystemSettings__c.getInstance('CCI');
        OrderParams__c orderParams = Common.cciOrderParams;

        if (setting != null) {
            domain = setting.Domain__c;
            //   domain = setting.TempDomain__c;
            bookingPluginPath = setting.EditBookingPluginPath__c;
            if (domain == null || bookingPluginPath == null)return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'No booking system settings found'})});
        }else
        return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{'No booking system settings found'})});


        url = domain + bookingPluginPath;
        System.debug('URL after bookingsettings' + url);
        String errorResponse;
        String errorResponseAcc;
        User u = Common.getUserInfo();
        System.debug('User is' + u);
        String userType = Common.getUserType(u);


        if (String.IsBlank(order.CCI_Order_ID__c)) {
          //  throw new CCIAPIException(Label.NoOrder);
          return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{Label.NoOrder})});
        }
        if (Common.sharedSecret != null) {
            List <String > sList = common.userInformation.Email.split('@', 2);
            url = url + order.CCI_Order_ID__c + '?'+orderParams.UserId__c +Common.cciuser  + orderParams.Group__c + Common.userGroup() + orderParams.Profile__c + Common.userProfile();
        } else {
             if (String.IsBlank(u.CCI_User_Id__c)) {
               return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.InvalidCCIUser})});
            }
            url = url + order.CCI_Order_ID__c +'?'+ orderParams.UserId__c + u.CCI_User_Id__c + orderParams.Password__c + u.CCI_User_Password__c + orderParams.Group__c + Common.userGroup() + orderParams.Profile__c + Common.userProfile();
        }

        url+= orderParams.AuthCode__c + getAuthCode(setting) + orderParams.ClientId__c;
        url = url + '&confirmationurl=' +Common.GetBaseUrlForInstance() + '/apex/OpportunityToOrder%3Foppid%3D' + opp.Id;
        System.debug('Before exiting editOrder 2part' + url);
        }catch(Exception e){
            System.debug('Some exception occured..'+ e);
            return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.CCI_Exception})});
        }
       // return url;
        return new ResultWrapper(url);

    }
    
    //method to edit insertion level
    
    public ResultWrapper editOrderItem(OrderItem orderItem, Order order,Opportunity opp){
        String domain;
        String url ;
        String bookingPluginPath;
        String errorResponse;
        String errorResponseAcc;
        User u = Common.getUserInfo();
        String userType = Common.getUserType(u);
        try{
        BookingSystemSettings__c setting = BookingSystemSettings__c.getInstance('CCI');
        OrderParams__c orderParams = Common.cciOrderParams;

        if (setting != null) {
            domain = setting.Domain__c;
            bookingPluginPath = setting.EditBookingPluginPath__c;
            if (domain == null|| bookingPluginPath ==null )return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.No_booking_system_settings})});
        }else
        return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.No_booking_system_settings})});
    
        url = domain + bookingPluginPath;
        if (String.IsBlank(order.CCI_Order_ID__c)|| String.IsBlank(orderItem.CCI_Order_Item_ID__c) ) {
           return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{Label.NoOrder})});
        }
        if (Common.sharedSecret != null) {
            List <String > sList = common.userInformation.Email.split('@', 2);
            url = url + order.CCI_Order_ID__c + '?'+orderParams.UserId__c +Common.cciuser  + orderParams.Group__c + Common.userGroup() + orderParams.Profile__c + Common.userProfile();
        } else {
             if (String.IsBlank(u.CCI_User_Id__c)) {
               return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.InvalidCCIUser})});
            }
            url = url + order.CCI_Order_ID__c +'?'+ orderParams.UserId__c + u.CCI_User_Id__c + orderParams.Password__c + u.CCI_User_Password__c + orderParams.Group__c + Common.userGroup() + orderParams.Profile__c + Common.userProfile();
        }

        url+= orderParams.AuthCode__c + getAuthCode(setting) + orderParams.ClientId__c;
        url+='&subview=schedule&packageitem='+orderItem.CCI_Package_Item_Id__c+'&schedule='+orderItem.CCI_Schedule_Item_Id__c+'&orderitem='+orderItem.CCI_Order_Item_ID__c;
        url = url + '&confirmationurl=' +Common.GetBaseUrlForInstance() + '/apex/OpportunityToOrder%3Foppid%3D' + opp.Id;
        System.debug('url before exiting EditOrderItem..'+ url);
        }catch(Exception e){
            System.debug('Some exception occured..'+ e);
            return new ResultWrapper(new List<ResultWrapper.ErrorMessages>{new ResultWrapper.ErrorMessages(ApexPages.Severity.ERROR,new List<String>{System.Label.CCI_Exception})});
        }
       
        return new ResultWrapper(url);

    }
    
    
     public String cancelOrder(String orderId,String code,String reason){
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
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        req.setMethod('POST');  
        req.setEndpoint(domain+orderPath+'/'+orderId+'/cancellation');   
        req.setHeader('Content-Type', 'application/json');  
        req.SetHeader('x-cci-user', Common.cciuser);
        req.SetHeader('x-cci-profile', common.userProfile());
        req.SetHeader('x-cci-group', common.userGroup());
        req.SetHeader('Authorization', 'bearer ' + accessToken);
        req.setBody(jsonreq);
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        if (!(res.getStatusCode() == 201 || res.getStatusCode() == 200)) {
            return 'Failure';
        }
       return 'Success';
     //   req.setCompressed(true); 
     }  
 

    

   
   public static String getAuthCode(BookingSystemSettings__c setting){
        String authCode;
        String oAuthEndpoint = setting.Domain__c + setting.AuthPath__c;
        HttpRequest req = new HttpRequest();
        req.setTimeout(Common.cci.ReadTimeout__c.IntValue());
        req.setMethod('GET');
        req.setEndpoint(oAuthEndpoint);

        String username = setting.ClientId__c;
        String password = setting.SharedSecret__c;
        System.debug('username..' + username + ' Password..' + password);
         try{
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
       }
   }}catch(Exception e){
        
   }
       return authCode;
   }
   
   
   

}