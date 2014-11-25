public with sharing class ValueBackController {
	
    public String retURL;
    public Order currentOrder { get; set; }
    public list<OrderItem> itemsList;

    public list<PackageWrapper> packageWrappersList { get; set; }
    public ValueBackWrapper orderLevelVB { get; set; }
    //public boolean differentOrdVBs  { get; set; }

    public String applyChanges { get; set; }
    public list<SelectOption> applyChangesToAllRelatedRecords { get; set;}
    
    public list<Account> accountsList  = new list<Account> ();
    public list<SelectOption> relatedAccountsSelectOptions = new list<SelectOption>();
    public map<String, map<String, list<Value_Back_Contract__c>>> relatedContractsMap = new map<String, map<String, list<Value_Back_Contract__c>>>();
    public map<String, map<String, list<SelectOption>>> relatedContractSelectOptionsMap = new map<String, map<String, list<SelectOption>>>();
    public map<Id, Value_Back_Contract__c> allValueBackContractsMap = new map<id, Value_Back_Contract__c>();
    public set<id> allparentsSet = new set<Id>();
    
    /*Wrapper Calss*/
    
    //packa wrpper holds list of insertision wrappers.
    public class PackageWrapper {
        public String packageName { get; set; }
        public String firstDate;
        public String lastDate;
        public list<InsertionWrapper> insertionWrapperList { get; set; }
        public ValueBackWrapper packageVBW { get; set; }
        //public boolean differentVBs { get; set; }
        public boolean showIWs { get; set; }
        public String applyChange { get; set; }
        public PackageWrapper(){
            this.insertionWrapperList = new list<InsertionWrapper>();
            this.packageName = '';
            //this.differentVBs = false;
            this.showIWs = true;
        }
        public void applyChanges_PackeLevel(){
            if(this.applyChange == 'YES'){
                for(InsertionWrapper iW : this.insertionWrapperList ){
                    /*iW.insertisionVBW = this.packageVBW;*/
                    //iW.insertisionVBW = null; 
                    if(iW.item.Value_Back__c != 0){
                    	iW.insertisionVBW = new ValueBackWrapper(iW.insertisionVBW, this.packageVBW.selectedAccount, this.packageVBW.selectedContract, this.packageVBW.adHoc);
                    }
                }
            }
        }
        public void changeFlag(){

        }
    }

    //Wrapper class holds information related to Order items dates and its assinement to value back options
    public class InsertionWrapper implements Comparable{
        public String insertisionDate { get; set; }
        public OrderItem item { get; set; }
        public ValueBackWrapper insertisionVBW { get; set; }
        public InsertionWrapper(OrderItem tempItem, list<SelectOption> temprelatedAccountsSelectOptions, map<String, map<String, list<Value_Back_Contract__c>>> trempRelatedContractsMap){
            this.insertisionDate = tempItem.First_Delivery_Date__c != null ? String.valueOf(tempItem.First_Delivery_Date__c.format()) : '';
            this.item = tempItem;
            this.insertisionVBW = new ValueBackWrapper (this.item, temprelatedAccountsSelectOptions, trempRelatedContractsMap);
        }

        public Integer compareTo(Object compareTo) {
            InsertionWrapper compareToObj = (InsertionWrapper)compareTo;
            if(this.insertisionDate > compareTOObj.insertisionDate){
                return 1;
            }
            if(this.insertisionDate < compareTOObj.insertisionDate){
                return -1;
            }
            return 0;
        }
    }
    
    //value back Wrapper
    public class ValueBackWrapper { 
        public String selectedAccount { get; set; }
        public list<SelectOption> accountsList { get; set; }
        public boolean adHoc { get; set; }
        public String selectedContract { get; set; }
        public double valueBackAmount { get; set; }
        public double basePrice { get; set; }
        public map<String, map<String, list<SelectOption>>> relatedContractSelectOptionsMap;
        public map<String, map<String, list<Value_Back_Contract__c>>> relatedContractsMap;
        public Date relatedDate; 

        public ValueBackWrapper (OrderItem item, list<SelectOption> temprelatedAccountsSelectOptions, map<String, map<String, list<Value_Back_Contract__c>>> trempRelatedContractsMap){
            this.valueBackAmount = item.Value_Back__c != null ? item.Value_Back__c : 0;
            if(this.valueBackAmount != 0){
                this.selectedAccount = item.Value_Back_Assigned_To__c == null ? '' : item.Value_Back_Assigned_To__c;
                this.adHoc = item.Ad_Hoc_Value_Back__c;
                this.selectedContract = item.Value_Back_Contract__c == null ? '' : item.Value_Back_Contract__c;
            }
            this.basePrice = item.UnitPrice != null ? item.UnitPrice : 0;
            this.accountsList = temprelatedAccountsSelectOptions == null ? new list<SelectOption>() : temprelatedAccountsSelectOptions;
            this.relatedContractsMap = trempRelatedContractsMap;
            this.relatedDate = item.First_Delivery_Date__c; 
        }

        public ValueBackWrapper(ValueBackWrapper tempVBW, String tempAccount, String tempContract, boolean tempAdhoc){
            this.selectedAccount = tempAccount;
            this.selectedContract = tempContract;
            this.adHoc = tempAdhoc;
            this.accountsList = tempVBW.accountsList;
            this.valueBackAmount = tempVBW.valueBackAmount;
            this.basePrice = tempVBW.basePrice;
            this.relatedContractsMap = tempVBW.relatedContractsMap; 
            this.relatedDate = tempVBW.relateddate;
        }

        public boolean getIsValid(){
            if(this.valueBackAmount == 0){
                return false;
            }
            return true;
        }

        public list<SelectOption> getContractsList(){
            list<SelectOption> resultList = new list<SelectOption>(); 
            resultList.add(new Selectoption('', ' -- None -- '));
            if(this.selectedAccount == null || this.selectedAccount == ''){
                return resultList;
            }else if(this.relatedContractsMap != null && this.relatedContractsMap.containsKey(this.selectedAccount) != null){
                if(this.adHoc == true){
                    resultList.add(new Selectoption('New', 'Create New Ad Hoc Contract'));
                    if(this.relatedContractsMap.get(this.selectedAccount).get('Ad Hoc') != null && this.relatedContractsMap.get(this.selectedAccount).get('Ad Hoc').size() > 0){
                        for(Value_Back_Contract__c vbc : this.relatedContractsMap.get(this.selectedAccount).get('Ad Hoc')){
                            resultList.add(new Selectoption(vbc.id, vbc.Name));
                        }
                    }
                    return resultList;
                }else{
                    if(this.relatedContractsMap.get(this.selectedAccount).get('Deal') != null && this.relatedContractsMap.get(this.selectedAccount).get('Deal').size() > 0){
                        for(Value_Back_Contract__c vbc : this.relatedContractsMap.get(this.selectedAccount).get('Deal')){
                            if(vbc.Start_Date__c >= this.relatedDate && vbc.End_Date__c <= this.relatedDate){
                                resultList.add(new Selectoption(vbc.id, vbc.Name));
                            }
                        }
                    }
                    return resultList;
                }
            }else{
                return resultList;
            }
        }
        public void dummyAction(){
            system.debug('dummyAction');
        }
    }

    /*constructure*/
    public ValueBackController(){
        Id tempOrdID = Apexpages.currentPage().getParameters().get('ordID');
        this.retURL = Apexpages.currentPage().getParameters().get('retURL');
        if(this.retURL == null || this.retURL == ''){
            this.retURL = '/'+tempOrdID;
        }
        if(tempOrdID != null){
            this.currentORder = queryOrder(tempOrdID);
            this.itemsList = queryOrderItems(tempOrdID);
        }
        if(this.currentORder != null && this.itemsList != null && this.itemsList.size() > 0 ){
            //this.differentOrdVBs = false;
            this.applyChanges = 'NO';
            this.populateRelatedInfo();
            this.populateWrapperVariables();
        }

        this.applyChangesToAllRelatedRecords = new list<SelectOption>();

        this.applyChangesToAllRelatedRecords.add(new SelectOption ('YES', 'Yes'));
        this.applyChangesToAllRelatedRecords.add(new SelectOption ('NO', 'No'));
    }
    
    public void populateWrapperVariables (){
        system.debug('***populateWrapperVariables Method; '+'***Order : '+this.currentOrder+'***Order Items : '+this.ItemsList);
        this.packageWrappersList = new list<PackageWrapper>();
        map<String, PackageWrapper> tempPWMap = new map<String, PackageWrapper>();
        for(OrderItem item : this.itemsList){
            //if(this.differentOrdVBs!= null && !this.differentOrdVBs){
                if(this.orderLevelVB == null){
                    this.orderLevelVB = new ValueBackWrapper (item, this.relatedAccountsSelectOptions, this.relatedContractsMap);
                }else{
                    if(item.Value_Back__c != 0 && ((item.Value_Back_Contract__c != null && this.orderLevelVB.selectedContract != (String)item.Value_Back_Contract__c) || (item.Value_Back_Assigned_To__c != null && this.orderLevelVB.selectedAccount != (String)item.Value_Back_Assigned_To__c) || (item.Ad_Hoc_Value_Back__c != this.orderLevelVB.adHoc))){
                        //this.differentOrdVBs = true;
                        //this.differentOrdVBs = null;
                        this.orderLevelVB.selectedContract = '';
                        this.orderLevelVB.selectedAccount = '';
                        this.orderLevelVB.adHoc = false;
                    }else{
                        //update Price
                        this.orderLevelVB.valueBackAmount += item.Value_Back__c != null ? item.Value_Back__c : 0;
                        this.orderLevelVB.basePrice += item.UnitPrice!= null ? item.UnitPrice : 0;
                    }
                }
            //}
            InsertionWrapper iW = new InsertionWrapper(item, this.relatedAccountsSelectOptions, this.relatedContractsMap);
            PackageWrapper pW = tempPWMap.get(item.CCI_Package_Item_ID__c);
            if(pW == null){
                pW = new PackageWrapper();
                pW.firstDate = item.First_Delivery_Date__c != null ? String.valueOf(item.First_Delivery_Date__c.format()) : '';
                pW.packageVBW = new ValueBackWrapper (item, this.relatedAccountsSelectOptions, this.relatedContractsMap);
            }
            pW.insertionWrapperList.add(iW);
            //system.debug('***before'+'***Date : '+ iW.insertisionDate+'***pW.packageVBW.selectedAccount is : '+pW.packageVBW.selectedAccount+'***pW.packageVBW.selectedContract : '+pW.packageVBW.selectedContract+'***iW.insertiVBW.selectedAccount is : '+iW.insertisionVBW.selectedAccount+'***iW.insVBW.selectedContract : '+iW.insertisionVBW.selectedContract);            
            if(item.First_Delivery_Date__c!= null && pW.firstDate != String.valueOf(item.First_Delivery_Date__c.format())){
                pW.lastDate = String.valueOf(item.First_Delivery_Date__c.format());
            }
            if(pW.lastDate != null && pW.lastDate != ''){
                pW.packageName = item.Package_Name__c +'('+pW.firstDate+' - '+pW.lastDate+')';
            }else{
                pW.packageName = item.Package_Name__c +'('+pW.firstDate+')';
            }
            if(pW.insertionWrapperList.size() > 1){
                //if(!pW.differentVBs){
                    if(item.Value_Back__c != 0 && ((item.Value_Back_Contract__c != null && item.Value_Back_Contract__c != pW.packageVBW.selectedContract) || (item.Value_Back_Assigned_To__c != null && pW.packageVBW.selectedAccount != (String)item.Value_Back_Assigned_To__c) || (item.Ad_Hoc_Value_Back__c != pW.packageVBW.adHoc))){
                        //pW.differentVBs = true;
                        //pW.packageVBW = null;
                        pW.packageVBW.selectedAccount = '';
                        pW.packageVBW.selectedContract = '';
                        pW.packageVBW.adHoc = false;
                    }else{
                        //Update Price
                        pW.packageVBW.valueBackAmount += item.Value_Back__c != null ? item.Value_Back__c : 0;
                        pW.packageVBW.basePrice += item.UnitPrice!= null ? item.UnitPrice : 0;
                    }
                //}
            }
            tempPWMap.put(item.CCI_Package_Item_ID__c, pW);
            //system.debug('***after'+'***Date : '+ iW.insertisionDate+'***pW.packageVBW.selectedAccount is : '+pW.packageVBW.selectedAccount+'***pW.packageVBW.selectedContract : '+pW.packageVBW.selectedContract+'***iW.insertiVBW.selectedAccount is : '+iW.insertisionVBW.selectedAccount+'***iW.insVBW.selectedContract : '+iW.insertisionVBW.selectedContract);
        }
        list<String> tempList = new list<String>();
        tempList.addAll(tempPWMap.keySet());
        tempList.sort();
        for(String key : tempList){
            this.packageWrappersList.add(tempPWMap.get(key));
        }
        system.debug('***packageWrappersList : '+this.packageWrappersList);
    }
    
    public PageReference saveAction(){
        PageReference returnPage = new PageReference(retURL);
        system.debug('***Save Function '+'***Order Level VBW : '+this.orderLevelVB+'***packageWrappersList : '+this.packageWrappersList);
        //creating a set of that should have new ad hoc contracts. 
        map<Id, OrderItem> orderItemsToUpdate = new map<Id, OrderItem>();
        map<id, Value_Back_Contract__c> accountIdToValeBackMap = new map<Id, Value_Back_Contract__c>();
        /*/Order Level VB - Ad Hoc new contracts
        if(this.orderLevelVB.getIsValid() && this.orderLevelVB.selectedAccount != null && this.orderLevelVB.selectedAccount != ''){
            if(this.orderLevelVB.adHoc && this.orderLevelVB.selectedContract == 'New'){
                if(!accountIdToValeBackMap.containsKey(this.orderLevelVB.selectedAccount)){
                    accountIdToValeBackMap.put(this.orderLevelVB.selectedAccount, new Value_Back_Contract__c(Name='Ad Hoc Contract',Account__c = this.orderLevelVB.selectedAccount, Type__c = 'Ad Hoc'));
                }
            }
        }*/
        //handeling only insertision level as we do not care about order level
        //Insertision Levle - Ad Hoc new Contracts
        boolean errors = false;
        
        for(PackageWrapper pW : this.packageWrappersList){
            for(InsertionWrapper iW : pW.insertionWrapperList){
                if((iW.insertisionVBW.selectedAccount != null && iW.insertisionVBW.selectedAccount != '' && (iW.insertisionVBW.selectedContract == null || iW.insertisionVBW.selectedContract ==''))){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Value Back Contract for Package : '+pW.packageName+', Insertision : '+ iW.insertisionDate));
                    errors = true;
                }
            }
        }
        if(errors){
            return null;
        }
        
        for(PackageWrapper pW : this.packageWrappersList){
            for(InsertionWrapper iW : pW.insertionWrapperList){
                if(iW.insertisionVBW.getIsValid()){
                    if(iW.insertisionVBW.selectedAccount != null && iW.insertisionVBW.selectedAccount != ''){
                        if(iW.insertisionVBW.adHoc && iW.insertisionVBW.selectedContract == 'New'){
                            if(!accountIdToValeBackMap.containsKey(iW.insertisionVBW.selectedAccount)){
                                accountIdToValeBackMap.put(iW.insertisionVBW.selectedAccount, new Value_Back_Contract__c(Name='Ad Hoc Contract',Account__c = iW.insertisionVBW.selectedAccount, Type__c = 'Ad Hoc'));
                            }
                        }
                    }
                }
            }
        }
        //system.debug('***before insert accountIdToValeBackMap : '+ accountIdToValeBackMap); 
        if(accountIdToValeBackMap != null && accountIdToValeBackMap.size() > 0 && accountIdToValeBackMap.values() != null && accountIdToValeBackMap.values().size() > 0){
            //Inserting New ValueBAck records
            try{
            	insert accountIdToValeBackMap.values();
            }catch (Exception eX){
                return null;
            }
            system.debug('***after insert insert accountIdToValeBackMap : '+ accountIdToValeBackMap); 
            for(PackageWrapper pW : this.packageWrappersList){
                for(InsertionWrapper iW : pW.insertionWrapperList){
                    if(iW.insertisionVBW.getIsValid()){
                        if(iW.insertisionVBW.selectedAccount != null && iW.insertisionVBW.selectedAccount != ''){
                            if(iW.insertisionVBW.adHoc && iW.insertisionVBW.selectedContract == 'New'){
                                iW.item.Value_Back_Contract__c = accountIdToValeBackMap.get(iW.insertisionVBW.selectedAccount).id;
                                iW.item.Value_Back_Assigned_To__c = iW.insertisionVBW.selectedAccount;
                                iW.item.Ad_Hoc_Value_Back__c = iW.insertisionVBW.adHoc == null ? false : iW.insertisionVBW.adHoc; 
                                orderItemsToUpdate.put(iW.item.id, iW.item);
                            }else{
                                iW.item.Value_Back_Assigned_To__c = iW.insertisionVBW.selectedAccount;
                                iW.item.Value_Back_Contract__c = iW.insertisionVBW.selectedContract;
                                iW.item.Ad_Hoc_Value_Back__c = iW.insertisionVBW.adHoc == null ? false : iW.insertisionVBW.adHoc; 
                                orderItemsToUpdate.put(iW.item.id, iW.item);
                            }
                        }else{
                            iW.item.Value_Back_Assigned_To__c = null;
                            iW.item.Value_Back_Contract__c = null;
                            iW.item.Ad_Hoc_Value_Back__c = false; 
                            orderItemsToUpdate.put(iW.item.id, iW.item);
                        }
                    }
                }
            }
            system.debug('*** before updating the order items : '+orderItemsToUpdate.values());
            try{
            	update orderItemsToUpdate.values();
            }catch(exception ex){
                return null;
            }
            system.debug('*** after updating the order items : '+orderItemsToUpdate.values());
        }
        return returnPage;
    }

    public void dummyAction(){
        system.debug('***dummyAction');
    }

    private Order queryOrder(Id ordID){
        Order tempOrd = [select id, CCI_ORDER_ID__c, Account.Name, Agency__r.Name, Booking_Agency__r.Name, Finance_Account__r.Name, Finance_Account__r.Company__r.Name,
                            Base_Price__c
                        from ORDER 
                        where Id =: ordID];
        return tempOrd; 
    }
    
    private list<OrderItem> queryOrderItems(Id ordID){
        list<OrderItem> resultList = new list<OrderItem>([select id, Value_Back__c, Value_Back_Assigned_To__c, Ad_Hoc_Value_Back__c, CCI_Package_Item_ID__c, 
                                                            Package_Name__c, First_Delivery_Date__c, Value_Back_Contract__c, UnitPrice
                                                        from OrderItem 
                                                        where ORDERID =: ordID 
                                                        ORDER By First_Delivery_Date__c ASC]);
        return resultList;
    }

    private set<id> allParents(ID accId, set<id> resultSet){
        if(resultSet == null){
            resultSet = new set<id>();
        }
        Account acc = [select Id, ParentID, Parent.ParentId, Parent.Parent.ParentID, Parent.Parent.Parent.ParentID, 
                            Parent.Parent.Parent.Parent.ParentID, Parent.Parent.Parent.Parent.Parent.ParentID
                        from Account Where id=:accId];
        if(acc.Parent.Parent.Parent.Parent.Parent.ParentID != null ){
            resultSet.addAll(allParents(acc.Parent.Parent.Parent.Parent.Parent.ParentID, resultSet));
        }
        resultSet.add(acc.Id);
        resultSet.add(acc.ParentID);
        resultSet.add(acc.Parent.ParentId);
        resultSet.add(acc.Parent.Parent.ParentID);
        resultSet.add(acc.Parent.Parent.Parent.ParentID);
        resultSet.add(acc.Parent.Parent.Parent.Parent.ParentID);
        resultSet.add(acc.Parent.Parent.Parent.Parent.Parent.ParentID );
        return resultSet;
    }

    public set<Id> getAllParentID (){
        set<Id> relatedAccountIdsSet = new set<Id>();
        if(this.currentOrder.AccountID != null){
            relatedAccountIdsSet.addAll(allParents(this.currentOrder.AccountID, null));
        }
        if(this.currentOrder.Agency__c!= null && this.currentOrder.AccountId != this.currentOrder.Agency__c){
            relatedAccountIdsSet.addAll(allParents(this.currentOrder.Agency__c, null));
        }
        if(this.currentOrder.Booking_Agency__c != null && 
            this.currentOrder.Booking_Agency__c != this.currentOrder.AccountId && 
            this.currentOrder.Booking_Agency__c != this.currentOrder.Agency__c){
            
            relatedAccountIdsSet.addAll(allParents(this.currentOrder.Booking_Agency__c, null));
        }
        system.debug('***relatedAccountIdsSet : '+relatedAccountIdsSet);
        return relatedAccountIdsSet;
    }

    //Poplates both related accounts and its contacts
    public void populateRelatedInfo(){
        list<Id> allAccountIdsList = new list<Id>();
        allAccountIdsList.addAll(getAllParentID());
        accountsList = new list<Account>([select id, name, (SELECT ID, Name, End_Date__c, Start_Date__c, Type__c FROM Value_Back__r ORDER By Name) 
                                            FROM Account 
                                            WHERE id IN:allAccountIdsList 
                                            Order By Name]);
        this.relatedAccountsSelectOptions.add(new SelectOption('',' -- None -- '));
        for(Account acc : accountsList){
            if(!this.relatedContractsMap.containsKey(acc.Id)){
                map<String, list<Value_Back_Contract__c>> tempMap = new map<String, list<Value_Back_Contract__c>>();
                tempMap.put('Ad Hoc', new list<Value_Back_Contract__c>());
                tempMap.put('Deal', new list<Value_Back_Contract__c>());
                /*map<String, list<SelectOption>> tempMap = new map<String, list<SelectOption>>();
                tempMap.put('Ad Hoc', new list<SelectOption>());
                tempMap.get('Ad Hoc').add(new SelectOption('',' -- None -- '));
                tempMap.get('Ad Hoc').add(new SelectOption('New','Create New Ad Hoc Contract'));
                tempMap.put('Deal', new list<SelectOption>());
                tempMap.get('Deal').add(new SelectOption('',' -- None -- '));*/
                this.relatedContractsMap.put(acc.Id, tempMap);
            }
            for(Value_Back_Contract__c vbc : acc.Value_Back__r){
                this.relatedContractsMap.get(acc.Id).get(vbc.Type__c).add(vbc);
                //this.relatedContractsMap.get(acc.Id).get(vbc.Type__c).add(new SelectOption(vbc.Id, vbc.Name));
            }
            this.relatedAccountsSelectOptions.add(new SelectOption(acc.id, acc.Name));
        }
    }
    
    public void applyChanges_OrderLevel(){
        for(PackageWrapper pW : packageWrappersList ){
            //pW.packageVBW = null;
            if(pW.packageVBW.valueBackAmount != 0){
            	pW.packageVBW = new ValueBackWrapper(pW.packageVBW, this.orderLevelVB.selectedAccount, this.orderLevelVB.selectedContract, this.orderLevelVB.adHoc);
                
            	for(InsertionWrapper  iW : pW.insertionWrapperList){
                	//iW.insertisionVBW = null; 
                	if(iW.item.Value_Back__c != 0){
                		iW.insertisionVBW = new ValueBackWrapper(iW.insertisionVBW, this.orderLevelVB.selectedAccount, this.orderLevelVB.selectedContract, this.orderLevelVB.adHoc);
                	}
            	}
            }
        }
    }
	
    public PageReference cancelAction (){
        return new pageReference(retURL);
    }
}