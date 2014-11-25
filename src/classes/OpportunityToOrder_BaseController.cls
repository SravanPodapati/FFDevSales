public with sharing class OpportunityToOrder_BaseController {
/*Variables and Constants*/ 
    /*Public variables*/ 
    //Cancel Reasons 
    public map<String, CCICancelReasons> cciCancelReasonsMap { get; set; }
    //media code settings  
    public map<String, list<FieldSettings>> mediaCodeToFieldSettingsMap { get; set; }
    //Accounts Map 
    public Map<Id, Account> allAccountsMap;
    //Product Information 
    private ConstantsH__c ch = ConstantsH__c.getInstance(Userinfo.getProfileId());
    public map<String, list<Product2>> productCodeToProductsMap { get; set; }
    
    public String currentNewIdentifier;
    //multiline 
    public boolean multiLine { get; set; }
     
    public map<String, String> curretnPageParameters;
    public ResultWrapper resultWrapper { get; set; }
    public Opportunity currentOpp { get; set; }
    public Map<String, boolean> OpportunityStageToIsClosedMap { get; set; }
    public OpportunityContactRole contactRole { get; set; }
    public static String userProfile {
        get{
            if(userProfile == null){
                userProfile = [SELECT ID, Profile.Name, name from User where ID =: UserInfo.getUserId()].Profile.Name;
            }
            return userProfile;
        } 
        private set;
    }
    public String plugInURL { get; set; }
    public list<TableWrapper> iframePrintWrapperList { get; set; }
    // TODO: determine what should be the proper object for this
    public String contractName { get; set; }
    public map<ID, OpportunityLineItem> activeLineItems { get; set; }
    
    /*Public Flags & Constants that Controles VF*/
    public boolean editOpp { get; set; }
    public boolean hasMessages { get; set; }
    public boolean openCCIPlugin { get; set; }
    public boolean hasOrdersInCCI { get; set; }
    public boolean hasActiveLineItems { get; set; }
        
    //Global Opportunity Line Item variables
    public list<Selectoption> possibleAdvertisers { get; set; }
    public map<ID, list<Selectoption>> relatedBillingAgentsMap { get; set; }
    
    /*Public Wrapper Instence Variables for Print*/
    
    public TableSort currentTable { get; set; }
    public map<String, TableSort> tableSortVariableMap;
     //Opportunity To Print table list
    public map<string, TableWrapper> printTWMap {get; set;}
    //In Progress Table
    private  boolean printCheckboxesCalculated;
    public list<TableWrapper> inProgressPrintTWList { get; set; }
    public list<TableWrapper> inProgressPrintSelectedTWList { get; set; } 
    public TableSort InProgressPrintTS { get; set; }
    public ResultWrapper inProgressPrintResultWrapper { get; set; }
    public boolean deActivateMultipleLines { get; set; }
    
    //In-Active Items Table
    public list<TableWrapper> deletedPrintTWList { get; set; }
    public TableSort deletedPrintTS { get; set; }
    public boolean selectAllInActive { get; set; }
    public ResultWrapper inActivePrintResultWrapper { get; set; }
     
    //list of available packages
    public list<CCIPackages> currentPackages { get; set; } 
/*--Variables and Constants--*/
     
/*Wrapper Class*/

    //MediaCode to glue Field's settings
    public class FieldSettings implements Comparable {
        public string conceptValuesKey { get; set; }
        public string equivalentFieldLabel { get; set; }
        public string salesforceFieldAPIName_Code { get; set; }
        public string salesforceFieldAPIName_Name { get; set; }
        public string inputType { get; set; }
        public string urlParameter { get; set; }
        public boolean isRequired { get; set; }
        public integer displayOrder { get; set; }
        
        public FieldSettings(){
            
        }
        
        public Integer compareTo(Object compareTo) {
            FieldSettings compareToObj = (FieldSettings)compareTo;
            if(this.displayOrder > compareToObj.displayOrder){
                return 1;
            }else if(this.displayOrder < compareToObj.displayOrder){
                return -1;
            }
            return 0;
        }
    }
     
    //Class for Concepct Values
    public class FieldsWrapper{
        //settings based on media code and field
        public FieldSettings setting { get; set; }
        //VF select options list
        public list<Selectoption> possibleOptions { get; set; }
        //Code to Name map
        public map<String, String> optionsMap { get; set; }
        //selected value from UI or existing value from opportunity line item
        public String selectedValue { get; set; }

        public FieldsWrapper(){
            
        }
    }
    
    public class ScheduleWrapper { 
        public String packageRuleName { get; set; }
        public String mediaCode { get; set; }
        public list<FieldsWrapper> fieldsList { get; set; }
        public String selectedInsertionDates { get; set; }
        public boolean dateFlex { get; set; }
        public String packageCode { get; set; }
        public String packageName { get; set; }
        public String poNumber {get; set;}
        public Integer columns { get; set; }
        public Integer cms { get; set; }
        public String titleCategoryCode; 
        public map<Integer, FieldsWrapper> fieldsMap { get; set; }
        
        public map<String, String> selectedDateToOpportunityID { get; set; } 
        
        public ScheduleWrapper(){
            this.selectedDateToOpportunityID = new map<String, String>();
        }
        
        public void refreshConceptValues(){
            //geting concepect values from backend . The resulting list should only contain one value
            ConceptValuesWithPackage cVWP = CCIProductManager.getConceptValues(this, this.packageName, this.packageCode)[0];
            this.titleCategoryCode = cVWP.titleCategoryCode;
            system.debug('***concepectValuesc : '+cVWP.conceptValues);
            //update all the existing fields wrappers. 
            for(FieldsWrapper fW : this.fieldsList){
                if(fW.setting.conceptValuesKey!= null && fW.setting.conceptValuesKey!=''){
                    fW.possibleOptions = new list<SelectOption>();
                    fw.possibleOptions.add(new Selectoption('',''));
                    //based on the input type the operations will be divided.
                    //if a new type is added code needs to be changed.
                    if(fW.setting.inputType != null && fW.setting.inputType.equalsIgnoreCase('picklist')){
                        //picklist type
                        for(CCIConceptValuesGeneric cVG : cVWP.conceptValues.get(fW.setting.conceptValuesKey)){
                            system.debug('cVG'+cVG);
                            //if(!cVG.name.equalsIgnoreCase('none')){
                                fW.possibleOptions.add(new SelectOption (cVG.code,cVG.name));
                                fW.optionsMap.put(cVG.code, cVG.name);
                            //}
                        }
                        if(fW.possibleOptions.Size()==2){
                            //fW.possibleOptions.remove(0);
                            fW.selectedValue = fW.possibleOptions[1].getValue();
                        }
                    }else if(fW.setting.inputType.equalsIgnoreCase('text')){
                        //text type
                        // there are no special operations need for this type of fields
                    }
                }
            }
        }
    }
    
    //Class represents a single line information.   
    public class LineWrapper {
        public OpportunityLineItem line { get; set; }
        public OrderItem item { get; set; }
        public Order ord { get; set; }
        public Inactive_Pitch_Idea__c iPI { get; set; }
                
        //TODO: need to remove following 2 
        public String selectedInsertionDates { get; set; }
        public Map<String, String> oldCombinedDates { get; set; }
        
        public Integer columns { get; set; }
        public Integer cms { get; set; }
        public boolean priceImmage { get; set; }
        public boolean yieldImmage { get; set; }
        public boolean removeLine_Print {get; set; }
        public boolean cancelLine_Print { get; set; }
        public list<CCIPackages> currentPackages;
        private map<String, String> packageMap;  
        public list<Selectoption> packages { get; set; }
        
        public list<ScheduleWrapper> scheduleWrapperList { get; set; }
        //key of the map will be packageRuleName+MediaCode.
        public map<String , ScheduleWrapper> scheduleWrapperMap { get; set; }
        
        /*constructer for In-Active Opportunity Line Items*/
        public LineWrapper(Inactive_Pitch_Idea__c tempIPI){
            this.iPI = tempIPI;
        }
        
        /*constructer for Active Opportunity Line Items*/
        public LineWrapper(OpportunityLineItem tempLine, Order tempOrd, OrderItem tempItem, list<CCIPackages> tempCurrentPackages){
            this.line = tempLine;
            this.item = tempItem;
            this.ord = tempOrd;
            this.currentPackages = tempCurrentPackages;
            this.populatePackages();
            this.oldCombinedDates = new map<String, String>();
            //selectedInsertionDates
            if(this.line.Order_Item__c == null){
                if(this.line.Dateflex__c && this.line.Dateflex_Daterange__c!=null ){
                    this.selectedInsertionDates = this.line.Dateflex_Daterange__c!= null ? this.line.Dateflex_Daterange__c:''; 
                }else{
                    this.selectedInsertionDates = this.line.ServiceDate != null?String.valueOf(this.line.ServiceDate.format()) : ''; 
                }
            }else{
                if(this.item!=null){
                    // TODO: Dateflex need to be handeled differentely. 
                    this.selectedInsertionDates = this.item.Dateflex__c == false? String.valueOf(this.item.First_Delivery_Date__c.format()) : String.valueOf(this.item.First_Delivery_Date__c.format());
                }
            } 
            if(this.line.id != null)
                this.oldCombinedDates.put(this.selectedInsertionDates, this.line.ID);
            //Sizes
            // TODO: This needs revisiting as we introducing the modules options. 
            if(this.line.Order_Item__c == null){
                this.columns = this.line.Size__c!=null && this.line.Size__c!=''?integer.valueof(this.line.Size__c.substring(0,this.line.Size__c.toupperCase().indexOf('X')).trim()):null;
                this.cms= this.line.Size__c!=null && this.line.Size__c!=''?integer.valueof(this.line.Size__c.substring(this.line.Size__c.toupperCase().indexOf('X')+1).trim()):null;
            }else{
                this.columns = this.item.Size__c!=null && this.item.Size__c!=''?integer.valueof(this.item.Size__c.substring(0,this.item.Size__c.toupperCase().indexOf('X')).trim()):null;
                this.cms= this.item.Size__c!=null && this.item.Size__c!=''?integer.valueof(this.item.Size__c.substring(this.item.Size__c.toupperCase().indexOf('X')+1).trim()):null;
            }
            
            this.scheduleWrapperList = new list<ScheduleWrapper>();
        }
        
        private void populatePackages(){
            this.packageMap = new map<String, string>();
            this.packages = new list<Selectoption>();
            this.packages.add(new Selectoption('','--None--'));
            if(this.currentPackages == null || this.currentPackages.size() == 0){
                this.currentPackages = CCIProductManager.getPackages();
            }
            for(CCIPackages pac : this.currentPackages ){
                this.packages.add(new Selectoption(pac.code, pac.name));
                this.packageMap.put(pac.code, pac.name);
            }
        }
    }
    
    public class TableWrapper implements Comparable{
        public boolean lineEditMode { get; set; }
        public boolean selected { get; set; }
        public boolean disabled { get; set; }
        public String lineType { get; set; }
        public LineWrapper lW { get; set; }
        public ResultWrapper rW { get; set; }
        public String newLineIdentifier { get; set; }
        public String addToSelectList { get; set; }
        public String cancelReasonCode { get; set; }
        private OpportunityToOrder_BaseController baseController;
        private String tableType;
        
        /*Constructer*/
        public TableWrapper (OpportunityToOrder_BaseController tempController, boolean tempSelected, boolean tempDisabled, LineWrapper templW, String tempTT){
            this.addToSelectList = null;
            this.baseController = tempController;
            this.selected = tempSelected != null ? tempSelected : false;
            this.disabled = tempDisabled != null ? tempDisabled : false;
            this.lW = templW;
            this.tableType = tempTT;
            this.rW = new ResultWrapper();
            this.lW.priceImmage = true;
            this.lW.yieldImmage = true;
            //This.lineType
            if(this.lW.Line != null && this.lW.Line.Id != null){
                if(this.lW.line.Type__c != null && this.lW.line.Type__c != ''){
                    this.lineType = this.lW.line.Type__c;
                }else{
                    if(this.lW.line.Classified_Minor_Category__c != null && this.lW.line.Classified_Minor_Category__c != ''){
                        this.lineType = 'Classified'; 
                    }else{
                        this.lineType = 'Display';
                    }
                } 
            }else{
                this.lineType = userProfile.tolowerCase().contains('classified') ? 'Classified' : 'Display';
            }
            this.lineEditMode = this.lW.Line.Order_Item__c == null || (this.lW.Line.Order_Item__c != null && (this.lW.item.Is_Cancelled__c || this.lW.item.Submitted_For_Cancellation__c)) ? true : false;
        }
        
        public void switchType(){
            if(this.tableType == 'INPROGRESS-PRINT')
                this.lineType = this.lineType != null && this.lineType.equalsIgnoreCase('Classified') ? 'Display' : 'Classified';   
        }
        
        public void dummyAction(){
            this.lW.line.Account__c = this.lW.line.Account__c == '000000000000000000' ? null : this.lW.line.Account__c;
            this.lW.line.Billing_Agent__c = this.lW.line.Billing_Agent__c == '000000000000000000' ? null : this.lW.line.Billing_Agent__c;
        }
        
        public void packageChange(){
            system.debug('*** Changed Package Value : '+this.lW.line.Package__c);
            this.lW.line.Package_Rule_Name__c = null;
            this.lW.line.Package_Name__c = this.lW.packageMap.get(this.lW.line.Package__c);
            this.lW.line.Package_Rule_Name__c = null;
            if(this.lW.line.Package_Name__c != '' && this.lW.line.Package_Name__c != null){
                this.lW.scheduleWrapperMap = new map<String, scheduleWrapper>();
                this.refreshConceptValues();
            } else {
                this.lW.scheduleWrapperList = new list<ScheduleWrapper>();
            }
        }
        
        public void refreshConceptValues(){
            this.lW.scheduleWrapperList = new list<ScheduleWrapper>();
            if(this.lW.scheduleWrapperMap == null ){
                this.lW.scheduleWrapperMap = new map<String, scheduleWrapper>();
            }
            ScheduleWrapper tempsW = new ScheduleWrapper ();
            
            //geting concepect values from backend 
            list<ConceptValuesWithPackage> cVWPList = CCIProductManager.getConceptValues(tempsW, this.lW.line.Package_Name__c, this.lW.line.Package__c);
            system.debug('***cVWPList : '+ cVWPList);
            for(ConceptValuesWithPackage cVWP : cVWPList){
                
                String packageRuleName = cVWP.packageRuleName;
                String mediaCode = cVWP.MediaCode;
                String key = packageRuleName + mediaCode;
                ScheduleWrapper sW;
                //dosenot contain key value create a new scheduleWrapper
                if(!this.lW.scheduleWrapperMap.containsKey(key)){
                    this.lW.scheduleWrapperMap.put(key, new ScheduleWrapper());
                }
                sW = this.lW.scheduleWrapperMap.get(key);
                sW.packageCode = this.lW.line.Package__c;
                sW.packageName = this.lW.line.Package_Name__c;
                sW.titleCategoryCode = cVWP.titleCategoryCode;
                sW.packageRuleName = sW.packageRuleName == null || sW.packageRuleName == '' ? packageRuleName : sW.packageRuleName;
                sW.mediaCode = sW.mediaCode == null || sW.mediaCode == '' ? mediaCode : sW.mediaCode;
                if(sW.fieldsMap == null){
                    sW.fieldsMap = new Map<Integer, FieldsWrapper>();
                }
                sW.fieldsList = new list<FieldsWrapper>();
                list<FieldSettings> tempFS = this.baseController.mediaCodeToFieldSettingsMap.get(mediaCode);
                //for all fields related to mediacode populate schedule, this list is sorted by display order
                if(tempFS != null){
                    for(FieldSettings fS : tempFS){
                        FieldsWrapper tempFW ;
                        if(!sW.fieldsMap.containsKey(fS.displayOrder)){
                            sW.fieldsMap.put(fS.displayOrder, new FieldsWrapper());
                        }
                        tempFW = sW.fieldsMap.get(fS.displayOrder);
                        tempFW.setting = fS;
                        tempFW.possibleOptions = new list<selectOption>();
                        tempFW.optionsMap = new map<String, String>();
                        tempFW.possibleOptions.add(new SelectOption ('',''));
                        
                        //if the conceptValuesKey is not null
                        if(fS.conceptValuesKey!= null && fS.conceptValuesKey!=''){
                            //based on the input type the operations will be divided.
                            //if a new type is added code needs to be changed.
                            if(fS.inputType.equalsIgnoreCase('picklist')){
                                //picklist type
                                for(CCIConceptValuesGeneric cVG : cVWP.conceptValues.get(fS.conceptValuesKey)){
                                    //if(!cVG.name.equalsIgnoreCase('none')){
                                        tempFW.possibleOptions.add(new SelectOption (cVG.code,cVG.name));
                                        tempFW.optionsMap.put(cVG.code, cVG.name);
                                    //}
                                }
                                if(tempFW.possibleOptions.Size()==2){
                                    //tempFW.possibleOptions.remove(0);
                                    tempFW.selectedValue = tempFW.possibleOptions[1].getValue();
                                }
                            }else if(fS.inputType.equalsIgnoreCase('text')){
                                //text type
                                // there are no special operations need for this type of fields
                            }
                        }
                        sW.fieldsList.add(tempFW);
                        sW.fieldsMap.put(fS.displayOrder, tempFW);
                    }
                }else{
                    sW = new scheduleWrapper();
                }
                this.lW.scheduleWrapperList.add(sW);
                this.lW.scheduleWrapperMap.put(key, sW);
            }
        }
        
        //Action when user select a checkbox on inprogress oreder lines table in print tab.  
        public void selectRow(){
            if(this.selected == true){
                this.rW = new ResultWrapper();
                //if(this.baseController.multiLine || this.baseController.inProgressPrintSelectedTWList.size() == 0){
                    //calculate line edit mode
                    this.lineEditMode = (this.lW.line.Order_Item__c == null || (this.lW.line.Order_Item__c != null && (this.lW.item.Is_Cancelled__c || this.lW.item.Submitted_For_Cancellation__c))) ? true : false; 
                    if(this.lineEditMode && this.lW.line.Package__c != null && this.lW.line.Package__c != ''){
                        this.refreshConceptValues();
                        //populating the values from the selected data. 
                        if(this.lW.line.Id != null){
                            for(ScheduleWrapper sW : this.lW.ScheduleWrapperList){
                                if(sW.fieldsList != null){
                                    for(FieldsWrapper fW : sW.fieldsList){
                                        fW.selectedValue = (String)this.lW.line.get(fW.setting.salesforceFieldAPIName_Code);
                                    }
                                    if(this.lW.line.Id != null){
                                        sW.refreshConceptValues();
                                    }
                                }
                            }
                        }
                    }
                    if(this.lW.line.id != null ){
                        //Combine the records based on schedule and package rule name.  
                        for(TableWrapper tW : this.baseController.inProgressPrintTWList){
                            if(this.lW.line.Schedule_Identifier__c == tW.lW.line.Schedule_Identifier__c){
                                for(ScheduleWrapper sW : this.lW.ScheduleWrapperList){
                                    if(sW.packageRuleName == this.lW.line.Package_Rule_Name__c){
                                        sW.selectedInsertionDates = sW.selectedInsertionDates == null || sW.selectedInsertionDates == ''? String.valueOf(tW.lW.line.ServiceDate.format()) : sW.selectedInsertionDates+','+String.valueOf(tW.lW.line.ServiceDate.format());
                                        sW.selectedDateToOpportunityID.put(String.valueOf(tW.lW.line.ServiceDate.format()), tW.lW.line.Id);
                                        tW.Selected = true;
                                        if(this.lW.line.Id != tW.lW.line.ID){
                                            tW.disabled = true;
                                        }else{
                                            tW.disabled = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    this.baseController.inProgressPrintSelectedTWList.add(this);
                /*}else{
                    this.selected=true;
                    this.baseController.inProgressPrintSelectedTWList = new list<TableWrapper>();
                }*/
            }else{
                integer removingIndex = index(this.lW.line.ID);
                if(removingIndex != null){
                    this.rW = new ResultWrapper();
                    this.baseController.inProgressPrintSelectedTWList.remove(removingIndex);
                }
                if(this.baseController.inProgressPrintSelectedTWList == null || this.baseController.inProgressPrintSelectedTWList.size() == 0){
                    this.baseController.clearInProgressPrintSelections();
                }
            }
        }
        
        //cancel the process of editing.
        public void cancelorClose(){
            this.selected = false;
            this.selectRow();
        }
        
        //return the list index for line id in inProgressPrintSelectedTWList. 
        private integer index(id lineID){
            integer index = null;
            for(integer i = 0; i< this.baseController.inProgressPrintSelectedTWList.size(); i++){
                if(this.baseController.inProgressPrintSelectedTWList[i].lW.Line.id == lineId){
                    index = i;
                    break;
                }
            }
            return index;
        }
        
        //return the posible advertisers. 
        public list<Selectoption> getLine_Advertisers(){
            return this.baseController.possibleAdvertisers;
        }
        
        //return the list of possible billing agents.
        public list<Selectoption> getLine_BillingAgents(){
            if(this.lW.line.Account__c != null){
                if(this.baseController.relatedBillingAgentsMap.containsKey(this.lW.line.Account__c))
                    return this.baseController.relatedBillingAgentsMap.get(this.lW.line.Account__c);
                else
                    return new list<Selectoption>();
            }else{
                return new list<Selectoption>();
            }
        }
        
        // will enable the Cancel resions panel.
        public void enableRemoveOptions_Print(){
            if(this.lW.line.Order_Item__c == null){
                this.lW.removeLine_Print = true;
            }
        }
        
        //create lines in CCI.
        //This is for the individual line creation
        public void submitToCCI_SingleLine(){
            OppOrderManager oOM = new OppOrderManager();
            if(this.rW.hasMessages == false){
                //reseting result wrapper
                this.rW = new ResultWrapper();
                this.rW = oOM.createOrderFromOppLineItem_new(new list<OpportunityLineItem> {this.lW.line}, this.baseController.currentOpp);
                system.debug('***resultWrapper from OOM : '+this.rW);
                if(this.rW.hasMessages == false && this.rW.URL != null && this.rW.URL != ''){
                    this.baseController.OpenCCIPlugin = true;
                    this.baseController.plugInUrl = this.rW.URL;
                    if(this.baseController.iframePrintWrapperList == null){
                        this.baseController.iframePrintWrapperList = new list<TableWrapper>();
                    }
                    this.baseController.iframePrintWrapperList.add(this);
                }else{
                    if(this.rW.hasMessages == false){
                        this.rW = this.rW.addErrorMessage(this.rW, ApexPages.Severity.ERROR, 'An unknown error occured. Please contact System Administrator.');
                    }
                    //adding to the base controller as the messages can not be displayed. 
                    this.baseController.resultWrapper = this.rW;
                    this.baseController.hasMessages = true;
                    this.baseController.handelErrorMessages();
                }
            }else{
                this.rW = rW.addErrorMessage(this.rW, ApexPages.Severity.ERROR, 'Please clear the above errors before submiting to CCI. ');
            }
        } 
        
        //Editing of an Order       
        public void editSingleLineInCCI(){
            OppOrderManager oOM = new OppOrderManager();
            if(this.rW.hasMessages == false){
                //reseting result wrapper
                this.rW = new ResultWrapper();
                this.rW = oOM.editAccountOrder(this.lW.ord, this.baseController.currentOpp);
                system.debug('resultWrapper from OOM : '+this.rW);
                if(this.rW.hasMessages == false && this.rW.URL != null && this.rW.URL != ''){
                    this.baseController.OpenCCIPlugin = true;
                    this.baseController.plugInUrl = this.rW.URL;
                    if(this.baseController.iframePrintWrapperList == null){
                        this.baseController.iframePrintWrapperList = new list<TableWrapper>();
                    }
                    this.baseController.iframePrintWrapperList.add(this);
                }else{
                    if(this.rW.hasMessages == false){
                        this.rW = this.rW.addErrorMessage(this.rW, ApexPages.Severity.ERROR, 'An unknown error occured. Please contact System Administrator.');
                    }
                }
            }else{
                this.rW = rW.addErrorMessage(this.rW, ApexPages.Severity.ERROR, 'Please clear the above errors before submiting to CCI. ');
            }
        }
        
        public PageReference ValueBack(){
            string valueBackURL = '/apex/valueBack?ordId='+this.lW.ord.Id+'&retURL=%2Fapex%2FOpportunityToOrder%3FoppID%3D'+this.baseController.currentOpp.Id;
            return new pageReference(valueBackURL);
        }
        
        //Sorting
        public Integer compareTo(Object compareTo) {
            TableWrapper compareToObj = (TableWrapper)compareTo;
            
            //Default Sort Order by default is by insertision date.
            Date compareTOInsertisionDate, thisInsertisionDate; 
            if(compareToObj.lW.line.id != null){
                if((compareToObj.lW.line.id != null && compareToObj.lW.line.Order_item__c == null) || (compareToObj.lW.line.id != null && compareToObj.lW.line.Order_item__c != null && (compareToObj.lW.item.Is_Cancelled__c || compareToObj.lW.ord.Is_Cancelled__c))){
                    compareTOInsertisionDate = compareToObj.lW.line.serviceDate;                
                }else{
                    compareTOInsertisionDate = compareToObj.lW.item.First_Delivery_Date__c;
                }
            }else{
                compareTOInsertisionDate = date.newinstance(1,1,1990);
            }
            
            if(this.lW.line.id != null){
                if((this.lW.line.id != null && this.lW.line.Order_item__c == null) || (this.lW.line.id != null && this.lW.line.Order_item__c != null && (this.lW.item.Is_Cancelled__c || this.lW.ord.Is_Cancelled__c))){
                    thisInsertisionDate = this.lW.line.serviceDate;             
                }else{
                    thisInsertisionDate = this.lW.item.First_Delivery_Date__c;
                }   
            }else{
                thisInsertisionDate = date.newinstance(1,1,1990);
            }
            
            
            if(thisInsertisionDate > compareTOInsertisionDate){
                return 1;
            }
            if(thisInsertisionDate < compareTOInsertisionDate){
                return -1;
            }
            return 0;
            
            
            /*if(baseController.currentTable.sortingObject.equalsIgnoreCase('OpportunityLineItem')){
                //Object == OpportunityLineItem 
                if((Date)this.lW.line.get(baseController.currentTable.sortingField) > (Date)compareToObj.lW.line.get(baseController.currentTable.sortingField)){ 
                if(baseController.currentTable.sortingOrder.equalsIgnoreCase('asc')) {
                    return 1;
                }else{
                    return 0;
                }
                } else {    
                if(baseController.currentTable.sortingOrder.equalsIgnoreCase('asc')) {
                    return 1;
                }else{
                    return 0;
                }
                }
            }else if(baseController.currentTable.sortingObject.equalsIgnoreCase('OrderItem')){
                //Object == OrderItem
                if((string)this.lW.item.get(baseController.currentTable.sortingField) > (string)compareToObj.lW.item.get(baseController.currentTable.sortingField)){
                    if(baseController.currentTable.sortingOrder.equalsIgnoreCase('asc')){
                        return 1;
                    }else{
                        return 0;
                    }
                } else {
                    if(baseController.currentTable.sortingOrder.equalsIgnoreCase('asc')) {
                        return 1;
                    }else{ 
                        return 0; 
                    }
                }
            }else if(baseController.currentTable.sortingObject.equalsIgnoreCase('Order')){ 
                //Object == Order
                if((string)this.lW.ord.get(baseController.currentTable.sortingField) > (string)compareToObj.lW.ord.get(baseController.currentTable.sortingField)){
                    if(baseController.currentTable.sortingOrder.equalsIgnoreCase('asc')) {
                        return 1;
                    }else{
                        return 0;
                    }
                } else {
                    if(baseController.currentTable.sortingOrder.equalsIgnoreCase('asc')) {  
                        return 1;
                    }else{
                        return 0;
                    }
                }
            }
            return -1;*/
        }
    }
    
    public class TableSort { 
        public string sortingObject { get; set; }
        public string sortingField { get; set; }
        public string sortingOrder { get; set; }
        
        public TableSort (string tempSO, string tempSF, string tempSOrd){
            this.sortingObject = tempSO;
            this.sortingField = tempSF;
            this.sortingOrder = tempSOrd;
        }
    }
    
/*--Wrapper Class Definations --*/

    /*Controller constructer*/
    public OpportunityToOrder_BaseController(){
        this.multiLine = false;
        if(this.allAccountsMap == null){
            this.allAccountsMap = new map<Id, Account>();
        } 
        //Posible URL Paramaters 
        this.curretnPageParameters = Apexpages.currentPage().getParameters();
        populateValues();
        populateDefaultTableSortingOptions();
        if(this.currentOpp != null && this.currentOpp.Id != null){
            //populate settings for media codes
            
            string result=null;
            //Fetching the resource
            List<StaticResource> resourceList = [SELECT Id, Body
                                                    FROM StaticResource
                                                    WHERE Name = 'OpportunityToOrderSettings'];
            //Checking if the result is returned or not
            if(resourceList.size() == 1) {
                result = resourceList[0].Body.toString();
            }
            
            this.mediaCodeToFieldSettingsMap = new map<String, list<FieldSettings>> ();
            this.mediaCodeToFieldSettingsMap = (map<String, list<FieldSettings>>)System.JSON.deserialize(result ,map<String, list<FieldSettings>>.class);
            
            //applying sorting for the lists 
            for(String key : this.mediaCodeToFieldSettingsMap.keyset()){
                list<FieldSettings> tempList = this.mediaCodeToFieldSettingsMap.get(key);
                tempList.sort();
                this.mediaCodeToFieldSettingsMap.put(key, tempList);
            }

            //system.debug('***this.mediaCodeToFieldSettingsMap : '+this.mediaCodeToFieldSettingsMap);

            this.currentPackages = CCIProductManager.getPackages();
            if(this.currentPackages == null){
                this.currentPackages = new list<CCIPackages>();
            }
            //Populate Wrapper variables
            this.inProgressPrintSelectedTWList = new list<OpportunityToOrder_BaseController.TableWrapper>();
            this.printTWMap = new map<string, OpportunityToOrder_BaseController.TableWrapper>();
            populateWrapperVariables();
            //populate inprogress print table.
            reevoluateTableValues('INPROGRESS-PRINT');
            
            //populate products
            populateProductsMap();
              
            //populate deleted Opportunity line Items
            populateDeletedOpportunityLineItems();
        }
        this.selectAllInActive = false;
        this.OpportunityStageToIsClosedMap = new map<String, boolean>();
        for(OpportunityStage oS: [SELECT MasterLabel, IsClosed from OpportunityStage where IsActive = true]){
            this.OpportunityStageToIsClosedMap.put(oS.MasterLabel, oS.IsClosed);
        }
    }
    
/*Public Methods*/  

    public void populateCancelResonsMap(){
        this.cciCancelReasonsMap = new map<String,CCICancelReasons>();
        
        list<CCICancelReasons> tempList = cciProductManager.getCancelReasons();
        if(tempList != null){
            for(CCICancelReasons reason : tempList){
                this.cciCancelReasonsMap.put(reason.code, reason);
            }
        } 
    }
    
    //To Select and Deselect all on In Active opportunity lines
    public void selectOrDeSelectAllDeletedList(){
        system.debug('***currentOption : '+this.selectAllInActive);
        for(TableWrapper tW : this.deletedPrintTWList){
            tW.selected = this.selectAllInActive;
        }
    }
    
    /*action support*/
    public void dummyAction(){
        this.currentOpp.AccountID = this.currentOpp.AccountID == '000000000000000000' ? null : this.currentOpp.AccountID;
        this.currentOpp.Agency__c = this.currentOpp.Agency__c == '000000000000000000' ? null : this.currentOpp.Agency__c;
        return;
    }
    
    /*reset the result wrapper */
    public void resetResultWrapper(){
        this.resultWrapper = new ResultWrapper();
        this.hasMessages = false;
    }
    
    
    /*Handel Error Messages and adds to the VF */
    public void handelErrorMessages(){
        //handels the error messages if there are any.
        if(this.hasMessages ==true){
            list<ResultWrapper.ErrorMessages> errors = this.resultWrapper.errors;
            for(ResultWrapper.ErrorMessages eM : errors){
                for(String e : eM.errorMessages){
                    Apexpages.addMessage(new ApexPages.Message(eM.severity, e));
                }
            }
        }
    }
    
    public void setCurrnetTable(String varLabel){
        this.currentTable = tableSortVariableMap.get(varLabel);
    }
    
    public void clearInProgressPrintSelections (){
        this.inProgressPrintSelectedTWList.clear();
        for(TableWrapper tW: this.inProgressPrintTWList){
            tW.selected = false;
            tW.disabled = false;
        }
        this.printCheckboxesCalculated = false;
    }
    
    //This is not handeling the in progress history & digital or print
    public void populateWrapperVariables(){
        this.activeLineItems = activeOpportunityLines(this.currentOpp.Id);
        //Set flage value for hasActiveLineItems
        this.hasActiveLineItems = activeLineItems != null && activeLineItems.size() > 0 ? true : false;
        
        set<ID> orderIdsSet = new set<ID>();
        for(OpportunityLineItem oLI : activeLineItems.values()){
            orderIdsSet.add(oLI.Order_Item__r.OrderID);
        }
        
        map<Id, Order> allOrdersMap = getOrders(orderIdsSet);
        
        //Build Relationship between Opportunity Line Item to Order Items
        map<ID, OrderItem> opportunityLineItemToOrderItemMap = new map<Id, OrderItem>(); 
        for(OpportunityLineItem oLI : activeLineItems.values()){
            if(oLI.Order_Item__r.OrderID != null){
                Order relatedOrder = allordersMap.get(oLI.Order_Item__r.OrderID);
                opportunityLineItemToOrderItemMap.put(oLI.ID, null);
                if(relatedOrder!= null){
                    for(OrderItem oI : relatedOrder.OrderItems){
                        if(oLI.Order_Item__c == oI.Id){
                            opportunityLineItemToOrderItemMap.put(oLI.ID, oI);
                        }
                    }
                }
            }
        }
        
        //adding  wrapper structure
        for(OpportunityLineItem oLI : activeLineItems.values()){
            Order relatedOrder = null;
            OrderItem relatedOrderItem = null;
            OpportunityToOrder_BaseController.TableWrapper tW;
            OpportunityToOrder_BaseController.LineWrapper lW;
            if(oLI.Order_Item__c != null){
                relatedOrder = allOrdersMap.get(oLI.Order_Item__r.OrderID);
                relatedOrderItem = opportunityLineItemToOrderItemMap.get(oLI.ID);
            }
            lW = new OpportunityToOrder_BaseController.LineWrapper(oLI, relatedOrder, relatedOrderItem, this.currentPackages);
            tW = new OpportunityToOrder_BaseController.TableWrapper(this, false, false, lW, 'INPROGRESS-PRINT');
            this.printTWMap.put(oLI.Id, tW);
            
        }
    }
    
    //Re-evoluate the values for given Tables. 
    public void reevoluateTableValues(String tableName){
        //TODO : when we add the variables for the order history and canceled orders we should add them in the following IF block. 
        if(tableName != null && (tableName.equalsIgnoreCase('INPROGRESS-PRINT') || tableName.equalsIgnoreCase('PRINT'))){
            if(this.inProgressPrintTWList != null){
                this.inProgressPrintTWList.clear();
            }else{
                this.inProgressPrintTWList = new list<TableWrapper>();
            }
            system.debug('***PrintMap : '+printTWMap);
            if(this.printTWMap != null){
                for(TableWrapper tW : this.printTWMap.values()){
                    //determine which area the order should be in among order history, opportunity to order, digital. 
                    //check the type of opportunity Item (Oppotunit To Print / Digital)
                    // as we do not have differenction between print and digital facking the condition
                    if(tW.lW.line != null){
                        if(tW.lW.ord != null){
                            //status of related Order if has one (In Progress, History, Canceled)
                            if(tW.lW.ord.Status.equalsIgnoreCase('Cancelled')){
                                //Canceled Orders Print
                                this.inProgressPrintTWList.add(tW);
                            } else if(tW.lW.ord.Status.equalsIgnoreCase('Activated') && tW.lW.Item.Is_Published__c == true){
                                //Published Orders Print
                            }else{
                                //In Progress Orders Print
                                this.inProgressPrintTWList.add(tW);
                            }
                        }else{
                            //Active Print Items
                            this.inProgressPrintTWList.add(tW);
                        } 
                    }
                }
            }
            
            /*TODO: sorting should be applied in the tables when ever new tables are added
            if(this.inProgressPrintTWList != null && (tableName.equalsIgnoreCase('INPROGRESS-PRINT') || tableName.equalsIgnoreCase('PRINT'))){
                this.setCurrnetTable('INPROGRESS-PRINT');
                this.inProgressPrintTWList.sort();
            }*/
            system.debug('***In Progress Print: '+ this.inProgressPrintTWList);
            this.inProgressPrintTWList.sort();
        }
    } 
    
    public void populateDeletedOpportunityLineItems(){
        this.selectAllInActive = false;
        this.inActivePrintResultWrapper = new ResultWrapper();
        this.deletedPrintTWList = new list<TableWrapper>();
        for(Inactive_Pitch_Idea__c iPI : queryDeletedLines()){
            LineWrapper lW = new OpportunityToOrder_BaseController.LineWrapper(iPI);
        TableWrapper tW = new OpportunityToOrder_BaseController.TableWrapper(this, false, false, lW, 'DELETED-PRINT');
        this.deletedPrintTWList.add(tW);
        }
        system.debug('***this.deletedPrintTWList : ' + this.deletedPrintTWList);
    } 
    
    public void refreshInProgressPrintTable(){
        //Populate Wrapper variables
        this.inProgressPrintSelectedTWList = new list<OpportunityToOrder_BaseController.TableWrapper>();
        this.inProgressPrintTWList = new list<OpportunityToOrder_BaseController.TableWrapper>();
        populateWrapperVariables();
        //populate inprogress print table.
        reevoluateTableValues('INPROGRESS-PRINT');
    }
    
/*--Public Methods--*/
    
    
/*Private Methods*/
    //Returns the Opportunity with all the necessory fields
    public Opportunity queryOpportunity(ID oppID){
        list<Opportunity> resultList; 
        resultList = new list<Opportunity> ([SELECT ID, Name, Account.Name, Account.Parent.ID, Account.CCIMailCustID__c, Account.CCIMetroCustID__c, AccountId, Agency__c, Agency__r.Name, 
                                                    Type, StageName, CloseDate, OwnerID, CampaignID, IsNew__c, Opportunity_Start_Date__c, Opportunity_End_Date__c, LastModifiedDate,
                                                    Estimated_Total_Opportunity_Value__c, Amount, Pitch_Contact_Phone__c, Pitch_Contact_Name__c, Pitch_Contact_ID__c, Agency__r.Parent.Id,
                                                    Agency__r.CCIMailCustID__c, Agency__r.CCIMetroCustID__c, Owner.Name, Agency__r.Parent.CCIMailCustID__c, Agency__r.Parent.CCIMetroCustID__c,
                                                    Account.Parent.CCIMailCustID__c, Account.Parent.CCIMetroCustID__c, CurrencyISOCode, Agency__r.Type, Account.Type, Schedule_Identifier__c
                                                FROM Opportunity 
                                                WHERE ID=:oppID]);
        if(resultList.size() >= 1){
            return resultList[0];
        }else{
            this.hasMessages = true;
            this.resultWrapper = this.resultWrapper.addErrorMessage(this.resultWrapper, ApexPages.severity.ERROR, 'You do not have access to view the Opportunity Or Opportunity is Deleted.');
            this.handelErrorMessages();
            return null;
        }
    }
    
    private list<Inactive_Pitch_Idea__c> queryDeletedLines(){
            list<Inactive_Pitch_Idea__c> resultList; 
            resultList = new list<Inactive_Pitch_Idea__c>([SELECT URN__c, Title__c, Size__c, Copy_Split__c, Order_Item__c, Order_Item__r.OrderID,
                                                        Publication__c, PO_Number__c, Last_Insertion_Date__c, Opportunity__c, Zone__c,
                                                        First_Insertion_Date__c, Display_Section__c, Dateflex__c, Quantity__c, Title_Name__c,
                                                        Package__c, Billing_Agent__c, Account__c, ServiceDate__c, Reason_for_Inactive2__c,
                                                        Classified_Main_Category__c, Classified_Minor_Category__c, Package_Rule_Name__c,
                                                        Package_Name__c, Publication_Name__c, Sub_Section__c, Sub_Section_Name__c, Title_Category__c,  
                                                        Classified_Sub_Category__c, Related_Order__c, Region__c, PricebookEntryId__c, Title_Category_Name__c,
                                                        Yield__c, Cost__c, Dateflex_Daterange__c, Type__c, Account__r.Salutation__c, Competitor_Title__c,
                                                        Account__r.Type, Account__r.FirstName__c, Account__r.Name, Billing_Agent__r.Name, 
                                                        Account__r.CCIMetroCustID__c, Account__r.CCIMailCustID__c, Account__r.Parent.ID, 
                                                        Account__r.Parent.CCIMetroCustID__c, Account__r.Parent.CCIMailCustID__c, Schedule_Identifier__C,
                                                        Billing_Agent__r.CCIMetroCustID__c, Billing_Agent__r.CCIMailCustID__c, Billing_Agent__r.Parent.ID,
                                                        Billing_Agent__r.Parent.CCIMetroCustID__c, Billing_Agent__r.Parent.CCIMailCustID__c, Order_Item__r.Order.Account.Name,
                                                        Related_Order__r.ID, Related_Order__r.Status, Related_Order__r.CCI_Order_ID__c, Related_Order__r.Account.Name
                                                            FROM Inactive_Pitch_Idea__c 
                                                            WHERE Opportunity__c=:this.currentOpp.Id 
                                                            ORDER BY ServiceDate__c ASC]);
            return resultList;
    }

    //Populates the basic Opportunity information 
    private void populateValues(){
        Id oppId = this.curretnPageParameters.get('oppId');
        Id advId = this.curretnPageParameters.get('advId');
        Id ageID = this.curretnPageParameters.get('ageId');
        Id conID = this.curretnPageParameters.get('conID');
        this.multiLine = this.curretnPageParameters.get('multiLine')!= null && this.curretnPageParameters.get('multiLine').equalsIgnoreCase('true') ? true : false;
        this.resetResultWrapper();
        if(oppID == null){
            ID pitchRecordTypeID = [SELECT ID, DeveloperName from RecordType where DeveloperName='New_Business' limit 1].id;
            this.currentOpp = new Opportunity(RecordTypeId=pitchRecordTypeID);
            this.currentOpp.Amount = 0;
            this.currentOpp.StageName = 'Preparation';
            this.currentOpp.OwnerID = userInfo.getUserId();
            if(advID!=null){
                this.currentOpp.AccountID = advID;
            }
            if(ageId != null){
                this.currentOpp.Agency__c = ageID;
            }
            this.editOpp = true;
        }else{
            this.currentOpp = queryOpportunity(oppID);
            if(this.currentOpp == null){
                return; 
            }
            this.editOpp = false;
        }
        //OpportunityContactRole
        if(conID != null){
            list<OpportunityContactRole> tempConRoleList;
            if(this.currentOpp.id!=null){
                tempConRoleList = new list<OpportunityContactRole>([Select Role, OpportunityId, Id, ContactId, Contact.Name From OpportunityContactRole where ContactID=:conID and OpportunityId=:this.currentOpp.ID]);
                if(tempConRoleList.size() == 1){
                    this.contactRole = tempConRoleList[0];
                }
            }else{
                this.contactRole = new OpportunityContactRole();
                this.contactRole.contactID = conID;
            }
        }else{
            if(this.currentOpp.Pitch_Contact_ID__c!= null){
                list<OpportunityContactRole> tempRoles = new list<OpportunityContactRole> ([Select Role, OpportunityId, Id, ContactId, Contact.Name, Contact.Phone From OpportunityContactRole where ContactID =:this.currentOpp.Pitch_Contact_ID__c and OpportunityID =: this.currentOpp.ID limit 1]);
                if(tempRoles.size()>0){
                    this.contactRole = tempRoles[0];
                    this.currentOpp.Pitch_Contact_Name__c = tempRoles[0].Contact.Name;
                    this.currentOpp.Pitch_Contact_Phone__c = tempRoles[0].Contact.Phone;
                    this.currentOpp.Pitch_Contact_ID__c = tempRoles[0].ContactId;
                }
            }
            if(this.contactRole == null){
                list<OpportunityContactRole> tempRoles = new list<OpportunityContactRole>([Select Role, OpportunityId, Id, ContactId, Contact.Name, Contact.Phone From OpportunityContactRole where OpportunityID=:this.currentOpp.ID and IsPrimary = true]);
                if(tempRoles.size()>0){
                    this.contactRole = tempRoles[0];
                    this.contactRole.Role = tempRoles[0].Role;
                    this.currentOpp.Pitch_Contact_Name__c = tempRoles[0].Contact.Name;
                    this.currentOpp.Pitch_Contact_Phone__c = tempRoles[0].Contact.Phone;
                    this.currentOpp.Pitch_Contact_ID__c = tempRoles[0].ContactId;
                }
            }
            if(this.contactRole == null || this.contactRole.Id == null){
                this.contactRole = new OpportunityContactRole();
            }
        }
    }
    
     //returns an opportunitylineitem map for a givem opportunity id
    public map<Id, OpportunityLineItem> activeOpportunityLines(Id oppID){
        return new map<ID, OpportunityLineItem> ([Select Account__c, Account__r.CCIMailCustID__c, Account__r.FirstName__c, Account__r.Name, Account__r.Parent.CCIMailCustID__c, PriceBookEntryId,
                                                    Account__r.Parent.ID, Account__r.Salutation__c, Billing_Agent__c, Billing_Agent__r.CCIMailCustID__c, Billing_Agent__r.Parent.CCIMailCustID__c, 
                                                    Billing_Agent__r.Parent.ID, Classified_Minor_Category__c, Copy_Split__c, Dateflex__c, Last_Insertion_Date__c, Media_Code__c, Billing_Agent__r.Parent.Type,
                                                    OpportunityID, Order_Item__c, Order_Item__r.OrderID, Package_Rule_Name__c, PO_Number__c, Publication_Name__c, Quantity, Reason_for_Inactive2__c,Billing_Agent__r.ParentID,
                                                    Region__c, Related_Order__c, Related_Order__r.CCI_Order_ID__c, Related_Order__r.Status, Schedule_Identifier__C, Section_Name__c, ServiceDate, Account__r.ParentId,
                                                    Size__c, Sub_Section__c, Title__c, Title_Category__c, Title_Category_Name__c, Title_Name__c, Type__c, UnitPrice, Yield__c, Zone__c, Order_Level_PO_Number__c,Account__r.Parent.ParentId,
                                                    Account__r.CCIMetroCustID__c, Account__r.Parent.CCIMetroCustID__c, Account__r.Type, Billing_Agent__r.CCIMetroCustID__c, Distribution__c, Account__r.Parent.Type,
                                                    Billing_Agent__r.Parent.CCIMetroCustID__c, CCI_Product__c, CCI_Product_Name__c, Classification__c, Classification_Category__c, Classification_Category_Name__c, 
                                                    Classification_Main_Category__c, Classification_Main_Category_Name__c, Classification_Name__c, Classified_Main_Category__c, Classified_Sub_Category__c, Billing_Agent__r.Parent.ParentID,
                                                    Display_Section__c, First_Insertion_Date__c, No_of_Units__c, Package__c, Package_Name__c, Product_Category__c, Product_Category_Name__c, Product_Main_Category__c, 
                                                    Product_Main_Category_Name__c, Product_Unit__c, Product_Unit_Name__c, Publication__c, Related_Order__r.ID,Billing_Agent__r.Name, Billing_Agent__r.Type,
                                                    Sub_Section_Name__c, TotalPrice , URN__c, WebSite__c, Website_Category__c, Website_Category_Name__c, Distribution_Name__c, Combined_Ad_Unit__c, Combined_Ad_Unit_Name__c,
                                                    WebSite_Name__c, Zone_Name__c, Related_Order__r.Account.Name, Order_Item__r.Order.Account.Name, Competitor_Title__c, Dateflex_Daterange__c, Order_Item__r.Is_Cancelled__c 
                                                From OpportunityLineItem 
                                                Where OpportunityID=:oppID and Active__c = true]);
    }

    
    //returns an order map for a given set of ids 
    private map<Id, Order> getOrders(set<Id> orderIdsSet){
        return new map<ID, Order> ([Select Cancel_Date__c, Is_Cancelled__c, Cancel_Reason_Code__c, Cancel_Reason_Name__c, PoNumber, CCI_Cancel_Reason__c, CCI_Cancel_Reason_Code__c, 
                                        StatusCode, No_Of_Dates__c, Id, First_Delivery_Date__c, CCI_Order_ID__c, Agency__c, Status,VB_Target__c, Value_Back__c, Ad_Hoc_VB__c, 
                                        Account.Type, Account.Salutation__c, Account.FirstName__c, Account.Name, Agency__r.Name,
                                        (Select CopySplit__c, First_Delivery_Date__c, Is_Published__c, Package_Code__c, ServiceDate, Media_Code__c, CCI_Cancel_Reason_Notes__c ,
                                            Package_Name__c, Publication_Code__c, Publication_Name__c, UnitPrice, Sub_Section_Name__c, Submitted_For_Cancellation__c, Section_Code__c,
                                            Section_Name__c, Size__c, Title_Code__c, Title_Name__c, Zone_Code__c, Zone_Name__c, Yield__c, CCI_Cancel_Reason_Code__c, Value_Back_Assigned_To__c,
                                            Dateflex__c, A_B_Copy_Split__c, Regional_Copy_Split__c, CCI_Order_Item_ID__c, Is_Cancelled__c, CCI_Cancel_Reason__c, Value_Back_Contract__c, 
                                            PO_Number__c, Height__c, Columns__c, IsCancelableOrderItem__c, CCI_Package_Item_Id__c, CCI_Schedule_Item_Id__c, Value_Back__c, Ad_Hoc_Value_Back__c,
                                            Value_Back_Contract__r.Name
                                        From OrderItems) 
                                    From Order where ID IN: orderIdsSet]);
    }
    
    private void populateDefaultTableSortingOptions(){
        this.printCheckboxesCalculated = false;
        this.tableSortVariableMap = new map<String, TableSort>();
        //In Progress Print Table
        this.InProgressPrintTS = new TableSort('OpportunityLineItem', 'ServiceDate', 'ASC');
        this.tableSortVariableMap.put('INPROGRESS-PRINT', InProgressPrintTS);
    }
    
    private void disablePrintInsertions(String disableType){
        for(TableWrapper tW: this.inProgressPrintTWList){
            if(disableType == 'line'){
                if(tW.lW.line.Order_Item__c == null ){
                    tW.disabled = true;
                }else{
                    tW.disabled = false;
                }
            }else{
                if(tW.lW.line.Order_Item__c != null ){
                    tW.disabled = true;
                }else{
                    tW.disabled = false;
                }
            }
            
        }
        this.printCheckboxesCalculated = true;
    }
    
    private void populateProductsMap(){
        if(this.resultWrapper == null){
            this.resultWrapper = new ResultWrapper();
        }
        Id pricebookId;
        try{
            if(ch != null && ch.Price_Book__c != null){
                pricebookId = [select id from Pricebook2 where name =: ch.Price_Book__c].id;
            }else{
                this.resultWrapper = this.resultWrapper.addErrorMessage(this.resultWrapper, ApexPages.Severity.ERROR, 'Price Book is not configured for this user. Please contact system administrator.');
                return;
            }
        }
        catch (Exception e)
        {
            this.resultWrapper = this.resultWrapper.addErrorMessage(this.resultWrapper, ApexPages.Severity.ERROR, 'Price Book is not configured for this user. Please contact system administrator.');
            return;
        }    
        
        if(this.productCodeToProductsMap==null){
            this.productCodeToProductsMap = new map<String, list<Product2>>();
        }
        
        List<PricebookEntry> pricebookEntries = [SELECT id, Name, Product2Id, isActive 
                                                    FROM PricebookEntry 
                                                    WHERE Pricebook2Id =: pricebookId 
                                                    AND isActive = true];
        system.debug('***pricebookEntries : '+pricebookEntries);
        set<String> productIds = new set<String>();
        for (PricebookEntry pbe : pricebookEntries) {
            productIds.add(pbe.Product2Id);
        }   
        
        list<Product2> availableProducts = new list<Product2>([SELECT id, Name, Family, CurrencyIsoCode, ProductCode,
                                                                    (SELECT id, Name, CurrencyIsoCode
                                                                        FROM PricebookEntries
                                                                        where IsActive = true
                                                                        and Pricebook2Id =: pricebookId 
                                                                        and CurrencyISOCode =: this.currentOpp.CurrencyISOCode
                                                                        limit 1)
                                                                FROM Product2 
                                                                WHERE id IN: productIds
                                                                ORDER BY ProductCode]);
        // Considering the package codes form CCI are case sensitive
        // and all packages must have a packege code configured in Glue
        // TODO : this might need to be extended and should be dividable with product types. 
        for(Product2 product : availableProducts){
            if(product.ProductCode != null && product.ProductCode != ''){
                if(!this.productCodeToProductsMap.containsKey(product.ProductCode)){
                    this.productCodeToProductsMap.put(product.ProductCode, new list<Product2>());
                }
                this.productCodeToProductsMap.get(product.ProductCode).add(product);
            }
        }
        
        //display a info to users that there are no products configured for the give pricebook 
        if(this.productCodeToProductsMap != null && this.productCodeToProductsMap.size() == 0){
            this.resultWrapper = this.resultWrapper.addErrorMessage(this.resultWrapper, ApexPages.Severity.INFO, 'NO vaild Products are available for the configured pricebook.');
        }
        if(this.resultWrapper.hasMessages == true){
            this.hasMessages = true;
            this.handelErrorMessages();
        }
    }
/*--Private Methods--*/
    
}