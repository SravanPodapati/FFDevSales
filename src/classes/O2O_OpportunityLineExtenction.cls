public with sharing class O2O_OpportunityLineExtenction  {
    /*Private variables*/
    OpportunityToOrder_BaseController currentController;
    set<Id> possibleAdvertiserIds;
    private set<String> requiredFieldsForFinanaceAccountSet = new set<String>(Label.Finance_Account_Creation_Required_Fields_On_Account.split(','));
    private set<String> allowedAccountTypesToFinanaceAccountSet = new set<String>(Label.Account_Type_vs_Finance_Account_Creation.split(','));
    private ConstantsH__c ch = ConstantsH__c.getInstance(Userinfo.getProfileId());
    private id pricebookID;
    private List<Product2> filteredProducts;
    private boolean copyCurrentLine;
    private boolean createNewLine;              
    private boolean haveSaveErrors;
    private boolean multiLineCCISubmit;
    private boolean updateInprogressTable;
    private boolean deSelecteLine;
    private OpportunityToOrder_BaseController.TableWrapper submitingSingleLine;

    public String currentLineId {get; set;}
    public boolean removeFromSelectedList { get; set; }
    public string submitingOpportunityLineID { get; set; }
    public integer noOfSelectedLines { get; set; }
    public integer noOfSelectedItems { get; set; }
    public list<Selectoption> cancelReason { get; set; }
/*public variables*/
    
/*--Public variables--*/
    /*Constructure*/
    public O2O_OpportunityLineExtenction(OpportunityToOrder_BaseController controller) {
        this.currentController = controller;
        this.noOfSelectedItems = 0;
        possibleAdvertiserIds = new set<ID>();
        this.removeFromSelectedList = true;
        this.updateInprogressTable = true;
        this.deSelecteLine = false;
        this.currentController.possibleAdvertisers = this.currentController.possibleAdvertisers == null ? new list<Selectoption>() : this.currentController.possibleAdvertisers ;
        this.currentController.relatedBillingAgentsMap = this.currentController.relatedBillingAgentsMap  == null ? new map<ID, list<Selectoption>>() : this.currentController.relatedBillingAgentsMap ;
        
        if(this.currentController.currentOpp != null && this.currentController.currentOpp.id!=null){
            if(this.currentController.possibleAdvertisers.size() == 0)
                populateLine_Advertisers();
            if(this.currentController.relatedBillingAgentsMap.size() == 0)
                populateLine_BillingAgents();
        }
        this.noOfSelectedLines = 0;
    }

/*Public Methods Includes actions for VF related to Opportunity*/
    //select or deselect rows - in progress print table only
    public void update_InProgressPrinttable(){
    	//updating the line information 
    	//resons are as follows
    	//Saving the records dose not update the Schedule Identifer information
    	this.currentController.activeLineItems = this.currentController.activeOpportunityLines(this.currentController.currentOpp.Id);
	   	list<integer> indexes = new list<integer>();
    	integer i = 0;
    	for(OpportunityToOrder_BaseController.TableWrapper tW: this.currentController.inProgressPrintTWList){
    		boolean setForRemoved = false; 
    		//for the deleted/de-activated lines, remove them from the list
    		if(!this.currentController.activeLineItems.containsKey(tW.lW.line.Id)){
    			indexes.add(i);
    			setForRemoved = true;
    		}
    		//update the record
    		if(!setForRemoved && (tW.lW.line.Schedule_Identifier__c == null || tW.lW.line.Schedule_Identifier__c == '')){
    			tW.lW.line = this.currentController.activeLineItems.get(tW.lW.line.Id);
    		}
    		i++;
    	}
    	if(indexes!= null && indexes.size()>0){
			indexes.sort();
			for(integer j = indexes.size()-1; j >= 0; j--){
				this.currentController.inProgressPrintTWList.remove(indexes[j]);
			}
		}
		this.updateInprogressTable = false;
    }
    //selecting line in edit mode.
    public void selectLine_InProgressPrint_Line(){
    	system.debug('***currentLineId - selectLine_InProgressPrint : '+this.currentLineId);
    	if(this.updateInprogressTable){
    		update_InProgressPrinttable();
    	}
    	//Get the current TW
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index;
    	if(this.currentLineID != null && this.currentLineID.contains('_')){
    		integer i =0;
            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
                if(this.currentLineId == tW.newLineIdentifier){
                    currentTW = tW;
                    index = i;
                    break;
                }
                i++;
            }
        }else{
        	integer i =0;
            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
                if(this.currentLineId == tW.lW.line.id){
                	index = i;
                    currentTW = tW;
                    break;
                }
                i++;
            }
        }
        //forcing system to deselect the currentTW
        if(this.deSelecteLine && currentTW != null){
        	currentTW.selected = false;
        }
        //Selected Action
        if(currentTW!= null ){
	        if(currentTW.selected){
	        	currentTW.rW = new ResultWrapper();
	            //if(currentTW.baseController.multiLine || currentTW.baseController.inProgressPrintSelectedTWList.size() == 0){
	            //calculate line edit mode 
	            currentTW.lineEditMode = (currentTW.lW.line.Order_Item__c == null || (currentTW.lW.line.Order_Item__c != null && (currentTW.lW.item.Is_Cancelled__c || currentTW.lW.item.Submitted_For_Cancellation__c))) ? true : false;
	            if(currentTW.lineEditMode && currentTW.lW.line.Package__c != null && currentTW.lW.line.Package__c != ''){
	                //gets the values 
                	currentTW.refreshConceptValues();
	            }
	            if(currentTW.lW.line.id != null ){
	                //Combine the records based on schedule and package rule name.  
	                for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
	                	if(currentTW.lW.line.Schedule_Identifier__c == tW.lW.line.Schedule_Identifier__c){
	                		for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.ScheduleWrapperList){
	                			if(sW.packageRuleName == tW.lW.line.Package_Rule_Name__c && tW.lineEditMode == true){
	                				if(tW.lW.line.DateFlex__c){
	                					sW.selectedInsertionDates = tW.lW.line.Dateflex_Daterange__c.replaceAll(' ','');
	                					sW.dateFlex = true;
	                				}else{
	                					sW.selectedInsertionDates = sW.selectedInsertionDates == null || sW.selectedInsertionDates == ''? String.valueOf(tW.lW.line.ServiceDate.format()) : sW.selectedInsertionDates+','+String.valueOf(tW.lW.line.ServiceDate.format());
	                				}
	                				sW.selectedDateToOpportunityID.put(String.valueOf(tW.lW.line.ServiceDate.format()), tW.lW.line.Id);
	                				sW.poNumber = tW.lW.line.PO_Number__c;
	                				if(tW.lW.line.size__c!= null && tW.lW.line.size__c!= '' && tW.lW.line.size__c.contains('x') ){
	                					list<String> tempList = tW.lW.line.size__c.split('x');
	                					sW.columns = integer.valueOf(tempList[0]);
	                					sW.cms = integer.valueOf(tempList[1]);
	                				}else{
	                					sW.columns = 0;
	                					sW.cms = 0;
	                				}
	                				
	                				
	                				tW.Selected = true;
	                				this.noOfSelectedLines++;
	                				for(OpportunityToOrder_BaseController.FieldsWrapper fW : sW.fieldsList){
	                        			fW.selectedValue = (String)tW.lW.line.get(fW.setting.salesforceFieldAPIName_Code);
	                        		}
	                				if(currentTW.lW.line.Id != tW.lW.line.ID){
	                					tW.disabled = true;
	                				}else{
	                					tW.disabled = false;
	                				}
	                				//update the concepect values only if it is being edited. 
	                				if(currentTW.addToSelectList == 'YES'){
	                					sW.refreshConceptValues();
	                				}
	                			}
	                		}
	                	}
	                }
	            }
	            system.debug('***Selected Current SWs : '+currentTW.lW.ScheduleWrapperList);
	            if(currentTW.addToSelectList == 'YES'){
	            	this.currentController.inProgressPrintSelectedTWList.add(currentTW);
	            	currentTW.addToSelectList = 'ADDED';
	            }	            
	        	/*}else{
	        		currentTW.selected=true;
	        		currentTW.baseController.inProgressPrintSelectedTWList = new list<TableWrapper>();
	        	}*/
	        }else{//de-Selected actions
	        	integer index_selected = 0;
	        	//get the index from inProgressPrintSelectedTWList list
	        	if(this.currentLineID != null && this.currentLineID.contains('_')){
		    		integer i = 0;
		            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
		                if(this.currentLineId == tW.newLineIdentifier){
		                    index_selected = i;
		                    break;
		                }
		                i++;
		            }
		        }else{
		        	integer i =0;
		            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
		                if(this.currentLineId == tW.lW.line.id){
		                	index_selected = i;
		                    break;
		                }
		                i++;
		            }
		        }
		        currentTW.selected = false;
		        //this.noOfSelectedLines--;
		        currentTW.addToSelectList = null;
		        currentTW.disabled = false;
		        for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.scheduleWrapperList){
		        	for(String s : sW.selectedDateToOpportunityID.values()){
		        		if(this.currentController.printTWMap.containsKey(s)){
		        			this.currentController.printTWMap.get(s).selected = false;
		        			this.noOfSelectedLines--;
		        			this.currentController.printTWMap.get(s).disabled = false;
		        		} 
		        	}
		        }
		        if(index_selected < this.currentController.inProgressPrintSelectedTWList.size()){
		        	this.currentController.inProgressPrintSelectedTWList.remove(index_selected);
		        }
		        
		        if(this.currentController.inProgressPrintSelectedTWList.size() == 0){
		        	this.currentController.inProgressPrintSelectedTWList.clear();
		        }
		        if(this.currentLineID != null && this.currentLineID.contains('_')){
		        	this.currentController.inProgressPrintTWList.remove(index);
		        	this.currentController.printTWMap.remove(currentTW.newLineIdentifier);
		        }
	        }
        }
    }
    
    //creates a new object for new oppoetunity line. 
    public void newPrintOpportunityLine(){
        
        OpportunityLineItem currentLineItem = new OpportunityLineItem();
        currentLineItem.Account__c = this.currentController.currentOpp.AccountID != null? this.currentController.currentOpp.AccountID : null;
        currentLineItem.opportunityID = this.currentController.currentOpp.ID;
        currentLineItem.Quantity = 1;
        
        OpportunityToOrder_BaseController.LineWrapper tempLW = new OpportunityToOrder_BaseController.LineWrapper(currentLineItem, null, null, this.currentController.currentPackages);
        OpportunityToOrder_BaseController.TableWrapper tempTW = new OpportunityToOrder_BaseController.TableWrapper(this.currentController, true, false, tempLW, 'INPROGRESS-PRINT');
        
        if(this.currentController.currentNewIdentifier != null && this.currentController.currentNewIdentifier != ''){
            list<String> tempList = this.currentController.currentNewIdentifier.split('_');
            integer index = tempList.size() - 1;
            integer value = integer.valueof(tempList[index]);
            value++;
            this.currentController.currentNewIdentifier = 'NEW_TABLEWRAPPER_'+value;
        }else{
            this.currentController.currentNewIdentifier = 'NEW_TABLEWRAPPER_1';
        }
        tempTW.newLineIdentifier = this.currentController.currentNewIdentifier;
        this.currentController.printTWMap.put(tempTW.newLineIdentifier, tempTW);
        this.currentController.inProgressPrintTWList.add(tempTW);
        this.currentController.inProgressPrintSelectedTWList.add(tempTW);
    }
    
    //create and copy information from the givenline 
    public void newPrintOpportunityLine(OpportunityToOrder_BaseController.TableWrapper tempTW){
        
        OpportunityLineItem currentLineItem = tempTW.lW.line.clone(true, true, true, true);
        system.debug('***currentLineItem : '+currentLineItem );
        currentLineItem.Quantity = 1;
        currentLineItem.Id=null;
        if(currentLineItem.TotalPrice == null || currentLineItem.Quantity == null){
            currentLineItem.UnitPrice = 0;
        }else{
            currentLineItem.UnitPrice = currentLineItem.TotalPrice / currentLineItem.Quantity;
        }
        
        OpportunityToOrder_BaseController.LineWrapper tempLW = new OpportunityToOrder_BaseController.LineWrapper(currentLineItem, null ,null, this.currentController.currentPackages);
        tempLW.selectedInsertionDates = tempTW.lW.selectedInsertionDates;
        tempLW.columns = tempTW.lW.columns;
        tempLW.cms = tempTW.lW.cms;
        //tempLW.conceptValuesList = tempTW.lW.conceptValuesList;
        OpportunityToOrder_BaseController.TableWrapper newTW = new OpportunityToOrder_BaseController.TableWrapper(this.currentController, true, false, tempLW, 'INPROGRESS-PRINT');
        
        if(this.currentController.currentNewIdentifier != null && this.currentController.currentNewIdentifier != ''){
            list<String> tempList = this.currentController.currentNewIdentifier.split('_');
            integer index = tempList.size() - 1;
            integer value = integer.valueof(tempList[index]);
            value++;
            this.currentController.currentNewIdentifier = 'NEW_TABLEWRAPPER_'+value;
        }else{
            this.currentController.currentNewIdentifier = 'NEW_TABLEWRAPPER_1';
        }
        newTW.newLineIdentifier = this.currentController.currentNewIdentifier;
        this.currentController.printTWMap.put(newTW.newLineIdentifier, newTW);
        this.currentController.inProgressPrintTWList.add(newTW);
        this.currentController.inProgressPrintSelectedTWList.add(newTW);
    }
    
    //cancel Or Close the line
    public void cancelPrintLine(){
        system.debug('***currentLineID - cancelPrintLine: '+this.currentLineID);
        this.updateInprogressTable = false;
        this.deSelecteLine = true;
        this.selectLine_InProgressPrint_Line();
        this.updateInprogressTable = true;
        this.deSelecteLine = false;
    }
    
    //Single Line Save Changes
    public void savePrintLine(){
        this.copyCurrentLine = this.copyCurrentLine==null?false:this.copyCurrentLine;
        this.createNewLine = this.createNewLine = true==null?false:this.createNewLine;
        system.debug(this.currentLineID);
        OpportunityToOrder_BaseController.TableWrapper currentTW;
        list<OpportunityToOrder_BaseController.TableWrapper> newPrintRows = new list<OpportunityToOrder_BaseController.TableWrapper>();
        list<OpportunityLineItem> newLines = new list<OpportunityLineItem>();
        if(this.currentLineID != null && this.currentLineID.contains('_')){
            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
                if(this.currentLineId == tW.newLineIdentifier){
                    currentTW = tW;
                    break;
                }
            }
        }else{
            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
                if(this.currentLineId == tW.lW.line.id){
                    currentTW = tW;
                    break;
                }
            }
        }
        currentTW.rW = new ResultWrapper();
        system.debug('selectedTW = '+currentTW);
        
        if(currentTW.lW.line.Account__c == '000000000000000000'){
            currentTW.lW.line.Account__c = null;
        }
        if(currentTW.lW.line.Billing_Agent__c == '000000000000000000'){
            currentTW.lW.line.Billing_Agent__c = null;
        }
        
        //Required fields and validations
        //Due to the new messageing system required fields are need to be verified in apex rather than in VF.  
        //Required Field 1
        if(currentTW.lW.line.Account__c == null){
            currentTW.rW.hasMessages = true;
            currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'You must select an Advertiser or a Brand.');
        }
        //Required Field 2
        if(currentTW.lW.line.Package__c == null){
            currentTW.rW.hasMessages = true;
            currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'You must select a package.');
        }
        
        //Required Field 3
        if(currentTW.lW.line.Billing_Agent__c == null){
            currentTW.rW.hasMessages = true;
            currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'You Must select a billing agent.');
        }
        integer noOfSchedules = currentTW.lW.scheduleWrapperList!= null ? currentTW.lW.scheduleWrapperList.size() : 0;
        //rules for all schedules 
        for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.scheduleWrapperList){
        	String identifier = noOfSchedules > 1 ? sW.packageRuleName + ' - ': '';
	        //Required Field 4
	        if(sW.selectedInsertionDates == null || sW.selectedInsertionDates == ''){
	            currentTW.rW.hasMessages = true;
	            currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, identifier + 'At least one Insertion Date must be selected.');
	        }
	
	        //validation 1
	        // if Date flex is selected-> check at least 2 dates are selected in the date range. 
	        if(sW.dateflex == true && sW.selectedInsertionDates!= null && sW.selectedInsertionDates!= '' && sW.selectedInsertionDates.split(',').size()<=1){
	            currentTW.rW.hasMessages = true;
	            currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, identifier+'When Dateflex is selected, We must have at least 2 dates selected for Insertion Date or Date Range');
	        }
	        
	        //Validation 2
	        //Insertion date must be after close date of opportunity.
	        //insertion date must be between start date and end date of the opportunity 
	        if(sW.selectedInsertionDates != null && sW.selectedInsertionDates != ''){
	            boolean errorOccured = false; 
	            for(String s : sW.selectedInsertionDates.split(',')){
	                if(this.currentController.currentOpp.CloseDate > Date.parse(s)){
	                    currentTW.rW.hasMessages = true;
	                    currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, identifier+'The Insertion Date or Date Range values must be greater than or equal to the Pitch Close Date.');
	                    errorOccured = true;
	                }
	                if(!(Date.parse(s) >= this.currentController.currentOpp.Opportunity_Start_Date__c && Date.parse(s) <= this.currentController.currentOpp.Opportunity_End_Date__c)){
	                    currentTW.rW.hasMessages = true;
	                    currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, identifier+'The selected Insertion Dates must be between opportunity start date and opportunity end date.');
	                    errorOccured = true;
	                }
	                if(errorOccured == true){
	                    break;
	                }
	            }
	        }
        }
        //Validation 3 
        // Brand or Advertiser (Account__c) must be in relation with Billing Agent (Billing_Agent__c) of type Billing
        if(currentTW.lW.line.Account__c != null && currentTW.lW.line.Billing_Agent__c != null && currentTW.lW.line.Account__c != currentTW.lW.line.Billing_Agent__c){
            list<Relationship__c> relationshipsList = new list<Relationship__c>([Select Role__c, Name, Id, Active__c, Account_B__c, Account_A__c 
                                                                                    From Relationship__c
                                                                                    WHERE ((Account_A__c =: currentTW.lW.line.Account__c AND Account_B__c =: currentTW.lW.line.Billing_Agent__c) 
                                                                                    OR (Account_B__c =: currentTW.lW.line.Account__c AND Account_A__c =: currentTW.lW.line.Billing_Agent__c))
                                                                                    AND Role__c = 'Billing'
                                                                                    AND Active__c = true]);
            if(relationshipsList == null || relationshipsList.size() == 0){
                currentTW.rW.hasMessages = true;
                currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'Selected Brand or Advertiser and Billing Agent must be in an active relationship of type Billing');
            }
        }
        
        //if there are no messages to dispaly
        if(currentTW.rW.hasMessages == false){
            if(currentTW.lW.line.ID == null){
                list<Product2> availableProducts =  this.currentController.productCodeToProductsMap.get(currentTW.lW.line.Package__c);
                if(availableProducts!= null && availableProducts.size()>0){
                    Id PricebookEntryId;
                    for(Product2 product : availableProducts){
                        if(!product.PricebookEntries.isEmpty() && product.PricebookEntries.size() > 0){
                            PricebookEntryId = product.PricebookEntries[0].Id;
                            system.debug('***Selected Price book : '+ PricebookEntryId);
                            break;
                        }
                    }
                    if(PricebookEntryId != null){
                        currentTW.lW.line.PricebookEntryId = PricebookEntryId != currentTW.lW.line.PricebookEntryId ? PricebookEntryId : currentTW.lW.line.PricebookEntryId;
                    }else{
                        currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'Price book entry is not configured for the selected opportunity currency.');
                    }
                }else{
                    currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'Products are not configured for the current package. ');
                }
            
                //update the Account with all values os that these will be available when a new line got created.
                // this should only happen if the entire line is new.  
                if(this.currentController.allAccountsMap.get(currentTW.lW.line.Account__c)!=null){
                    currentTW.lW.line.Account__r = this.currentController.allAccountsMap.get(currentTW.lW.line.Account__c);
                }else{
                    Account tempAdvertiser = [SELECT ID, Name, Type, CCIMailCustID__c, CCIMetroCustID__c, Salutation__c, FirstName__c, ParentID, Parent.ID,  
                                                    Parent.CCIMailCustID__c, Parent.CCIMetroCustID__c, Parent.Name, Parent.Type, Parent.Salutation__c, Parent.FirstName__c 
                                                From Account where ID =: currentTW.lW.line.Account__c limit 1];
                    currentTW.lW.line.Account__r = tempAdvertiser;
                }
                
                if(this.currentController.allAccountsMap.get(currentTW.lW.line.Billing_Agent__c)!=null){
                    currentTW.lW.line.Billing_Agent__r = this.currentController.allAccountsMap.get(currentTW.lW.line.Billing_Agent__c);
                }else{
                    Account tempBillingAgent = [SELECT ID, Name, Type, CCIMailCustID__c, CCIMetroCustID__c, Salutation__c, FirstName__c, ParentID, Parent.ID,  
                                                        Parent.CCIMailCustID__c, Parent.CCIMetroCustID__c, Parent.Name, Parent.Type, Parent.Salutation__c, Parent.FirstName__c 
                                                    From Account where ID =: currentTW.lW.line.Billing_Agent__c limit 1];
                    currentTW.lW.line.Billing_Agent__r = tempBillingAgent;
                }
            }
            
            currentTW.lW.line.Quantity = 1;
            //currentTW.lW.line.Size__c = currentTW.lW.columns+'x'+currentTW.lW.cms;
            
            list<OpportunityLineItem> lineItemList = new list<OpportunityLineItem>();
            set<id> recordsToDelete = new set<Id>();
            
            //iterate through schedules
            for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.scheduleWrapperList){
            	OpportunityLineItem sWLine = currentTW.lW.line.clone(true, true, true, true);
            	sWLine.Title_Category__c = sW.titleCategoryCode;
            	sWLine.Package_Rule_Name__c = sW.packageRuleName;
            	sWLine.Media_Code__c = sW.mediaCode;
            	sWLine.Po_Number__c = sW.poNumber;
            	sWLine.Size__c = sW.columns+'x'+sW.cms;
            	system.debug('***sWLine : '+sWLine);
            	//populate the concepect values to opportunity line items 
            	for(OpportunityToOrder_BaseController.FieldsWrapper fW : sW.fieldsList){
            		sWline.put(fW.setting.salesforceFieldAPIName_Code, fW.selectedValue);
            		if(fW.setting.salesforceFieldAPIName_Name != null && fW.setting.salesforceFieldAPIName_Name!= ''){
                    	sWline.put(fW.setting.salesforceFieldAPIName_Name, fW.optionsMap.get(fW.selectedValue));
                    }
            	}
            	
            	//handel the date flex.
            	if(sW.dateflex == false){
            		sWLine.DateFlex__c = false;
            		sWLine.DateFlex_DateRange__c = '';
            		list<String> dateList = new list<String> (sW.selectedInsertionDates.split(','));
            		list<String> SelectedRecordsIdsList = sW.selectedDateToOpportunityID.values();
            		if(SelectedRecordsIdsList!=null){
	            		//for the records created together
	            		for(String recordID: SelectedRecordsIdsList ){
	            			if(dateList.size()>=1){
	            				OpportunityLineItem oLI = sWLine.clone(true,true,true,true);
		                		oLI.ID = recordID; 
		                		oLi.ServiceDate = Date.Parse(dateList[0]);
		                		lineItemList.add(oLI);
		                		dateList.remove(0);
	            			}else{
	            				//need to delete the lines
		                		recordsToDelete.add(recordID);  
	            			}
	            		}
            		}
            		//if there are still remining dates
	                for(String dateString : dateList){
	                	if(dateString!=null && dateString!=''){
		                	OpportunityLineItem tempNewLine = sWLine.clone(true, true, true, true);
		                    tempNewLine.ServiceDate = Date.Parse(dateString);
		                    tempNewLine.Id = null;
		                    tempNewLine.TotalPrice = null;
		                    tempNewLine.PriceBookEntryId = currentTW.lW.line.PriceBookEntryId;
		                    lineItemList.add(tempNewLine);
		                    newlines.add(tempNewLine);
	                	}
	                }
            	}else {
            		sWLine.ServiceDate = Date.Parse(sW.SelectedInsertionDates.split(',')[0]);
            		if(sW.SelectedInsertionDates.contains(',')){
	                	sWLine.Dateflex_Daterange__c = sW.SelectedInsertionDates.replaceAll(',', ', ');
            		}else{
            			sWLine.Dateflex_Daterange__c = sW.SelectedInsertionDates;
            		}
	                sWLine.Dateflex__c = true;
	                if(sW.selectedDateToOpportunityID != null && sW.selectedDateToOpportunityID.values() != null && sW.selectedDateToOpportunityID.values().size() > 0){
		                //adding a date flex, hence removing all other records. 
		                list<String> selectedRecordIDsList = sW.selectedDateToOpportunityID.values();
		                sWLine.Id = selectedRecordIDsList[0];
		                //lineItemList.add(sWLine);
		                selectedRecordIDsList.remove(0);
		                for(String recordID : selectedRecordIDsList){
		                	if(recordID != sWLine.Id){
		                		recordsToDelete.add(recordID);
		                	}
		                }
	                }
	                if(sWLine.Id == null){
	                	sWLine.PriceBookEntryId = currentTW.lW.line.PriceBookEntryId;
	                	newlines.add(sWLine);
	                }
	                lineItemList.add(sWLine);
	                
            	}
            }
            try{
            	if(recordsToDelete.size() > 0){
            		//not deleting records but deactivating records.
	                //delete the lines that dates are removed.
	                //delete [select id from OpportunityLineItem where ID IN: recordsToDelete];
	                for(OpportunityLineItem oLI : [SELECT ID from OpportunityLineItem where ID IN: recordsToDelete]){
	                	oLI.Active__c = false;
	                	oLI.Reason_for_Inactive2__c = 'User deselected a date';
	                	lineItemList.add(oLI);
	                }
                }
                this.currentController.currentOpp = this.currentController.queryOpportunity(this.currentController.currentOpp.Id);
                //TODO : before updating the list We need to populate the schedule Identifier information, As triggers will run differentely for insert and update operations
                system.debug('***opportunity Schedule Identifier _ before : '+this.currentController.currentOpp.Schedule_Identifier__c);
                // Handeling the schedule identifiers
                for(OpportunityLineItem oLI : lineItemList){
                	oLI.Schedule_Identifier__c = this.currentController.currentOpp.Schedule_Identifier__c;
                }
                //Increment opportunity's schedule identifier. 
                String currentSI = this.currentController.currentOpp.Schedule_Identifier__c;
                integer value = integer.valueof(currentSI.substring(currentSI.indexof('-')+1));
                value++;
                currentSI = 'SCH-'+value;
                this.currentController.currentOpp.Schedule_Identifier__c = currentSI;
                
                system.debug('***lineItemList : '+lineItemList);
                upsert lineItemList;
                this.updateInprogressTable = true;
                
                update this.currentController.currentOpp;
                
                if(this.copyCurrentLine){
                    newPrintOpportunityLine(currentTW);
                    this.copyCurrentLine = false;
                }
                
                //when a new lines are created including the values for multi line creation because of the multidate selections, 
                //Add them to proper lists.
                //also update the total price after upsert completed, as it will be needed 
                if(newlines != null && newLines.size()>0){
	                for(OpportunityLineItem oLI : newLines){
	                    oLI.TotalPrice = oLI.UnitPrice;
	                    OpportunityToOrder_BaseController.LineWrapper tempLW = new OpportunityToOrder_BaseController.LineWrapper(oLI, null, null, this.currentController.currentPackages);
	                    OpportunityToOrder_BaseController.TableWrapper tempTW = new OpportunityToOrder_BaseController.TableWrapper(this.currentController, false, false, tempLW, 'INPROGRESS-PRINT');
	                    this.currentController.printTWMap.put(oLI.Id, tempTW);
	                    this.currentController.inProgressPrintTWList.add(tempTW);
	                    if(!this.removeFromSelectedList){
	                        tempTW.selected = true;
	                        tempTW.selectRow();
	                    }
	                }
                }
                
                //removing the deselected records
                if(recordsToDelete.size() > 0){
                	for(ID removeingID: recordsToDelete){
                		integer index;
                		if(this.currentController.inProgressPrintTWList.size()>1){
	                		for(integer i=0; i<this.currentController.inProgressPrintTWList.size(); i++){
	                			if(this.currentController.inProgressPrintTWList[i].lW.line.Id == removeingID){
	                				index = i;
	                				break;
	                			}
	                		}
                		}
                		if(index != null){
	                		this.currentController.inProgressPrintTWList.remove(index);
	                		this.currentController.printTWMap.remove(removeingID);
                		}
                	}
                }
                this.currentController.inProgressPrintTWList.sort();
                //deselect the currentline values
                this.cancelPrintLine();
                
                if(this.createNewLine == true){
                    newPrintOpportunityLine();
                    this.createNewLine = false;
                }
                this.submitingSingleLine = currentTW;
                
            }catch(Exception ex){
                currentTW.rW.hasMessages = true;
                currentTW.rW = currentTW.rW.addExceptionMessage(currentTW.rW, ApexPages.severity.ERROR, ex);
            }
        }else{
            this.haveSaveErrors = true;
        }
    }
    
    public void saveAndNew(){
        system.debug(this.currentLineID);
        this.removeFromSelectedList = true;
        this.copyCurrentLine = false;
        this.createNewLine = true;
        savePrintLine();
    }
    
    public void saveAndCopy(){
        system.debug(this.currentLineID);
        this.removeFromSelectedList = true;
        this.copyCurrentLine = true;
        this.createNewLine = false;
        savePrintLine();
    }
    
    //Save All selected lines, If changes are allowed. 
    public void saveAllPrintLines(){
        this.copyCurrentLine = false;
        set<String> possibleIds = new set<String>();
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
            //Set the current line ID
            if(tW.lW.line.ID != null){
                if(tW.lW.line.Order_Item__c == null ){
                    possibleIDs.add(tW.lW.line.ID);
                }
            }else{
                possibleIDs.add(tW.newLineIdentifier);
            }
        }
        for(String s : possibleIDs){
            this.removeFromSelectedList = this.multiLineCCISubmit == true? false : true; 
            this.currentLineID = s;
            savePrintLine();
        }
    }
    
    //cancel All selected lines print table 
    public void cancelAllSelectedLines_Print(){
        this.currentController.clearInProgressPrintSelections();        
    }
    
    public void enableDeActivateResions_single(){
    	system.debug('***this.currentLineID : '+ this.currentLineID);
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(this.currentLineId == tW.lW.line.id){
                currentTW = tW;
                break;
            }
        }
        system.debug('***currentTW : '+currentTW);
        //order item do not exist or order item is canceled - Enable opportunity item delete reasons
        //else enable order item delete reasons
        if((currentTW.lW.line.Order_Item__c == null) || (currentTW.lW.line.Order_Item__c != null && currentTW.lW.line.Order_Item__r.Is_Cancelled__c)){
        	currentTW.lW.removeLine_Print = true;
        	currentTW.lW.cancelLine_Print = false;
        }else{
        	currentTW.lW.removeLine_Print = false;
        	currentTW.lW.cancelLine_Print = true;
        }
        
        //check wether the line already exist in selected list or not, If not add it
        boolean existInSelectedList = false;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
        	if(this.currentLineId == tW.lW.line.id){
                existInSelectedList = true;
                break;
            }
        }
        
        if(!existInSelectedList){
        	this.currentController.inProgressPrintSelectedTWList.add(currentTW);
        }
        if(this.cancelReason == null){
        	this.cancelReason = new list<SelectOption>();
        	populatecancelReasonSelectoptions();
        }
    }
    
    public void enableDeActivateResions(){
    	this.currentController.inProgressPrintResultWrapper = new ResultWrapper();
    	integer numberOfValidLines = 0;
    	for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
			if(tW.Selected == true && tW.lineEditMode == true){
				tW.lW.removeLine_Print = true;
				numberOfValidLines++;
			}else{
				tW.selected = false;
				tW.selectRow();
			}
		}
		if(numberOfValidLines == 0){
			this.currentController.inProgressPrintResultWrapper.hasMessages = true;
			this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addErrorMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.Severity.ERROR, 'You must select at least one line before clicking on <b>"De-Activate Selected"</b> button.');
			return;
		}
		this.currentController.deActivateMultipleLines = true;
    }
    
    public void deActivateSelectedLines(){
    	boolean errorsInDelete = false;
    	if(this.currentLineId != null && this.currentLineId !=''){
    		OpportunityToOrder_BaseController.TableWrapper currentTW;
    		// single invocation of record
    		system.debug('currentLineId : '+ this.currentLineId);
    		for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
				if(tW.lW.line.ID == this.currentLineID){
					currentTW = tW;
					break;
				}
			}
			if(currentTW != null){
				list<OpportunityLineItem> deActivatelineList = new list<OpportunityLineItem >();
				for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.scheduleWrapperList){
					for(String S : sW.selectedDateToOpportunityID.values()){
						OpportunityLineItem line;
						if(this.currentController.activeLineItems.containsKey(s)){
							line = this.currentController.activeLineItems.get(s);
							line.Competitor_Title__c = currentTW.lW.line.Competitor_Title__c;
							line.Reason_for_Inactive2__c = currentTW.lW.line.Reason_for_Inactive2__c;
							line.Active__c = false;
							deActivatelineList.add(line);
						}
					}
				}
				try{
					update deActivatelineList;
					currentTW.rW.hasMessages = true;
		            currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.INFO, 'Please click on Refesh Table  button to update Tables.');
				}catch(exception ex){
					errorsInDelete = true;
					currentTW.rW.hasMessages = true;
					currentTW.rW = currentTW.rW.addExceptionMessage(currentTW.rW, ApexPages.Severity.ERROR, ex);
				}
			}
			if(errorsInDelete){
				this.currentLineID = currentTW.lW.line.id;
				this.cancelPrintLine();
			}
    	}else{
			this.currentController.inProgressPrintResultWrapper = new ResultWrapper();
			list<OpportunityLineItem> selectedRecordsList = new list<OpportunityLineItem>();
			list<String> linesToDeselect = new list<String>();
			for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
				if(tW.Selected == true && tW.lineEditMode == true && tW.lW.removeLine_Print == true){
					for(OpportunityToOrder_BaseController.ScheduleWrapper sW : tW.lW.scheduleWrapperList){
						for(String S : sW.selectedDateToOpportunityID.values()){
							OpportunityLineItem line;
							if(this.currentController.activeLineItems.containsKey(s)){
								line = this.currentController.activeLineItems.get(s);
								line.Competitor_Title__c = tW.lW.line.Competitor_Title__c;
								line.Reason_for_Inactive2__c = tW.lW.line.Reason_for_Inactive2__c;
								line.Active__c = false;
								selectedRecordsList.add(line);
							}
						}
					}
					linestoDeselect.add(tW.lW.line.id);
				}
			}
			if(selectedRecordsList.size()>0){
				try{
					update selectedRecordsList;
					this.currentController.inProgressPrintResultWrapper.hasMessages = true;
					this.currentController.inProgressPrintResultWrapper = this.currentController.inActivePrintResultWrapper.addErrorMessage(this.currentController.inActivePrintResultWrapper, ApexPages.Severity.Info, 'Please click on Refesh Table button to update the in-progress print lines table.');
				}catch(Exception ex){
					errorsInDelete = true;
					this.currentController.inProgressPrintResultWrapper.hasMessages = true;
					this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addExceptionMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.severity.ERROR, ex);
				}
			}else{
				errorsInDelete = true;
				this.currentController.inProgressPrintResultWrapper.hasMessages = true;
				this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addErrorMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.Severity.ERROR, 'You must select at least one line to de-activate before click on the button de-Activate Selected Lines.');
			}
			if(errorsInDelete){
				for(string s : linesToDeselect){
					this.currentLineID = s;
					this.cancelPrintLine();
				}
			}
    	}
    	//update the deleted opportunity line items
		this.currentController.populateDeletedOpportunityLineItems();
		//remove the selected from all lists and maps. 
    }
    
    public void closeLine_InprogressPrint_Item(){
    	system.debug('***currentLineId - selectLine_InProgressPrint_Item : '+this.currentLineId);
    	this.deSelecteLine = true;
    	this.selectLine_InProgressPrint_Item();
    	this.deSelecteLine = false;
    }
    
    //selecting view mode for the lines that are in CCI.
    public void selectLine_InProgressPrint_Item(){
    	system.debug('***currentLineId - selectLine_InProgressPrint_Item : '+this.currentLineId);
    	
    	//Get the current TW
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index;
	
    	integer i =0;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(tW.lW.item!= null && this.currentLineId == tW.lW.item.id){
            	index = i;
                currentTW = tW;
                break;
            }
            i++;
        }
    
        //forcing system to deselect the currentTW
        if(this.deSelecteLine && currentTW != null){
        	currentTW.selected = false;
        }
        //Selected Action
        if(currentTW!= null ){
	        if(currentTW.selected){
	        	currentTW.rW = new ResultWrapper();
	            //if(currentTW.baseController.multiLine || currentTW.baseController.inProgressPrintSelectedTWList.size() == 0){
	            //calculate line edit mode 
	            currentTW.lineEditMode = (currentTW.lW.line.Order_Item__c == null || (currentTW.lW.line.Order_Item__c != null && (currentTW.lW.item.Is_Cancelled__c || currentTW.lW.item.Submitted_For_Cancellation__c))) ? true : false;
	            currentTW.lW.scheduleWrapperList = new list<OpportunityToOrder_BaseController.ScheduleWrapper>();
	            
	            String packageIdentifier = currentTW.lW.item.CCI_Package_Item_Id__c;
	            //create the initial schedule. 
	            OpportunityToOrder_BaseController.ScheduleWrapper initialSW = new OpportunityToOrder_BaseController.ScheduleWrapper();
	            initialSW.packageRuleName = currentTW.lW.item.CCI_Schedule_Item_Id__c;
	            //based on media code add the field settings
	            initialSW.mediaCode = currentTW.lW.item.Media_Code__c;
				initialSW.fieldsMap = new map<Integer, OpportunityToOrder_BaseController.FieldsWrapper> ();
	            initialSW.fieldsList = new list<OpportunityToOrder_BaseController.FieldsWrapper>();
	            list<OpportunityToOrder_BaseController.FieldSettings> tempFS = this.currentController.mediaCodeToFieldSettingsMap.get(initialSW.mediaCode);
				//for all fields related to mediacode populate schedule, this list is sorted by display order
				if(tempFS != null){
					for(OpportunityToOrder_BaseController.FieldSettings fS : tempFS){
						OpportunityToOrder_BaseController.FieldsWrapper tempFW ;
						if(!initialSW.fieldsMap.containsKey(fS.displayOrder)){
							initialSW.fieldsMap.put(fS.displayOrder, new OpportunityToOrder_BaseController.FieldsWrapper());
						}
						tempFW = initialSW.fieldsMap.get(fS.displayOrder);
						tempFW.setting = fS;
						tempFW.selectedValue = tempFW.setting.salesforceFieldAPIName_Name != null && tempFW.setting.salesforceFieldAPIName_Name!= '' ? (String)currentTW.lW.item.get(tempFW.setting.salesforceFieldAPIName_Name) : (String)currentTW.lW.item.get(tempFW.setting.salesforceFieldAPIName_Code);  
						initialSW.fieldsList.add(tempFW);
						initialSW.fieldsMap.put(fS.displayOrder, tempFW);
					}
				}
	            initialSW.columns = currentTW.lW.item.height__c!= null ? integer.valueof(currentTW.lW.item.height__c)/100000 : 0;
	            initialSW.cms = currentTW.lW.item.Columns__c != null ? integer.valueOf(currentTW.lW.item.Columns__c) : 0;
	            currentTW.lW.scheduleWrapperList.add(initialSW);
	            
	             for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
	            	if(tW.lW.item != null && tW.lW.item.id != null){
		            	if(packageIdentifier == tW.lW.item.CCI_Package_Item_Id__c && !tW.lW.item.Is_Cancelled__c && !tW.lW.item.Submitted_For_Cancellation__c){
		            		OpportunityToOrder_BaseController.ScheduleWrapper newSW;
		            		boolean addnew = true;
		            		for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.scheduleWrapperList){
		            			if(sW.packageRuleName == tW.lW.item.CCI_Schedule_Item_Id__c){
		            				string dateString = String.valueOf(tW.lW.item.First_Delivery_Date__c.format());
                					sW.selectedInsertionDates = sW.selectedInsertionDates == null || sW.selectedInsertionDates == ''? dateString: (sW.selectedInsertionDates.contains(dateString) ? sW.selectedInsertionDates : sW.selectedInsertionDates+','+dateString) ;
                					sW.dateFlex = sW.dateFlex == null ? tW.lW.item.DateFlex__c : sW.dateFlex;
                					sW.selectedDateToOpportunityID.put(String.valueOf(tW.lW.line.ServiceDate.format()), tW.lW.line.Id);
                					sW.poNumber = tW.lW.item.PO_Number__c;
                					addnew = false;
                					break;
		            			}
		            		}
		            		if(addnew){
		            			newSW = new OpportunityToOrder_BaseController.ScheduleWrapper();
	            				newSW.packageRuleName = tW.lW.item.CCI_Schedule_Item_Id__c;
	            				string newDateString = tW.lW.item.First_Delivery_Date__c != null ? String.valueOf(tW.lW.item.First_Delivery_Date__c.format()) : '';
                				newSW.selectedInsertionDates = (newSW.selectedInsertionDates == null || newSW.selectedInsertionDates == '') && newDateString != '' ? newDateString : (newSW.selectedInsertionDates.contains(newDateString) ? newSW.selectedInsertionDates : newSW.selectedInsertionDates+', '+newDateString) ;
	            				newSW.dateFlex = newSW.dateFlex == null ? tW.lW.item.DateFlex__c : newsW.dateFlex;
            					newSW.selectedDateToOpportunityID.put(String.valueOf(tW.lW.line.ServiceDate.format()), tW.lW.line.Id);
		            			initialSW.columns = integer.valueOf(tW.lW.item.height__c)/100000;
	            				initialSW.cms = integer.valueOf(tW.lW.item.Columns__c);
		            			//populate the field settings and values
					            newSW.mediaCode = tW.lW.item.Media_Code__c;
								newSW.fieldsMap = new map<Integer, OpportunityToOrder_BaseController.FieldsWrapper> ();
					            newSW.fieldsList = new list<OpportunityToOrder_BaseController.FieldsWrapper>();
					            list<OpportunityToOrder_BaseController.FieldSettings> tempFS2 = this.currentController.mediaCodeToFieldSettingsMap.get(newSW.mediaCode);
								//for all fields related to mediacode populate schedule, this list is sorted by display order
								if(tempFS2 != null){
									for(OpportunityToOrder_BaseController.FieldSettings fS : tempFS2){
										OpportunityToOrder_BaseController.FieldsWrapper tempFW ;
										if(!newSW.fieldsMap.containsKey(fS.displayOrder)){
											newSW.fieldsMap.put(fS.displayOrder, new OpportunityToOrder_BaseController.FieldsWrapper());
										}
										tempFW = newSW.fieldsMap.get(fS.displayOrder);
										tempFW.setting = fS;
										tempFW.selectedValue = tempFW.setting.salesforceFieldAPIName_Name != null && tempFW.setting.salesforceFieldAPIName_Name!= '' ? (String)tW.lW.item.get(tempFW.setting.salesforceFieldAPIName_Name) : (String)tW.lW.item.get(tempFW.setting.salesforceFieldAPIName_Code);  
										newSW.fieldsList.add(tempFW);
										newSW.fieldsMap.put(fS.displayOrder, tempFW);
									}
								}

		            			tW.lW.scheduleWrapperList.add(newSW);
		            		}
		            		tW.selected = true;
		            		this.noOfSelectedItems++;
		            		if(currentTW.lW.item != tW.lW.item){
            					tW.disabled = true;
            				}else{
            					tW.disabled = false;
            				}
		            	}
	            	}
	            }
	            

	            
	            system.debug('***Selected Current SWs : '+currentTW.lW.ScheduleWrapperList);
	            if(currentTW.addToSelectList == 'YES'){
	            	this.currentController.inProgressPrintSelectedTWList.add(currentTW);
	            	currentTW.addToSelectList = 'ADDED';
	            }else{
	            	currentTW.addToSelectList = 'NOT ADDED';
	            }
	        	/*}else{
	        		currentTW.selected=true;
	        		currentTW.baseController.inProgressPrintSelectedTWList = new list<TableWrapper>();
	        	}*/
	        }else{//de-Selected actions
	        	integer index_selected = 0;
	        	//get the index from inProgressPrintSelectedTWList list
        	   	
        	   	integer j =0;
	            for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
	                if(this.currentLineId == tW.lW.line.id){
	                	index_selected = j;
	                    break;
	                }
	                j++;
	            }
    	   	
	        
	            currentTW.selected = false;
	            //this.noOfSelectedItems--;
		        currentTW.addToSelectList = null;
		        currentTW.disabled = false;
		        for(OpportunityToOrder_BaseController.ScheduleWrapper sW : currentTW.lW.scheduleWrapperList){
		        	for(String s : sW.selectedDateToOpportunityID.values()){
		        		if(this.currentController.printTWMap.containsKey(s)){
		        			this.currentController.printTWMap.get(s).selected = false;
		        			this.noOfSelectedItems--;
		        			this.currentController.printTWMap.get(s).disabled = false;
		        		} 
		        	}
		        }
		        if(this.currentController.inProgressPrintSelectedTWList.size()-1 >=  index_selected){
		        	this.currentController.inProgressPrintSelectedTWList.remove(index_selected);
		        }
		        if(this.currentController.inProgressPrintSelectedTWList.size() == 0){
		        	this.currentController.inProgressPrintSelectedTWList.clear();
		        }
	        }
        }
    }
    
    //diable and keep the view or edit panel. 
    public void disableCancelResons(){
    	system.debug('***currentLineId - cancelOrderItem_Single : '+this.currentLineId);
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index, i = 0;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
            if(tW.lW.item != null && this.currentLineId == tW.lW.item.id){
            	index = i;
                currentTW = tW;
                break;
            }
            i++;
        }
        system.debug('currentLine : '+ currentTW);
        currentTW.lW.removeLine_Print = false;
        currentTW.lW.cancelLine_Print = false;
        currentTW.selected = false;
        this.selectLine_InProgressPrint_Item();
    }
    
/*CCI Print Line Actions*/
    //multi lines - submit to cci 
    public void submitToCCI_MultiLine(){
    	//Gather the schedule wrappers. 
    	list<OpportunityToOrder_BaseController.ScheduleWrapper> selectedScheduleWrappers = new list<OpportunityToOrder_BaseController.ScheduleWrapper>();
    	this.multiLineCCISubmit = true;
        if(this.haveSaveErrors == true){
            return;
        }
        this.currentController.resetResultWrapper();
        list<OpportunityLineItem> selectedLines = new list<OpportunityLineItem>();
        //OpportunityLineItem firstLine = this.currentController.inProgressPrintSelectedTWList != null && this.currentController.inProgressPrintSelectedTWList.size() > 0 ? this.currentController.inProgressPrintSelectedTWList[0].lW.line : null;
        boolean hasdifferentSelections = false;
        //if(firstLine != null){
        string accountID, billingAgent, poNumber; 
        integer i = 0;
        for(OpportunityToOrder_BaseController.TableWrapper tW: this.currentController.inProgressPrintTWList){
        	if(tW.selected && tW.lW.line.Order_Item__c == null){
        		if(i == 0){
        			accountID = tW.lW.line.Account__c ;
        			billingAgent = tW.lW.line.Billing_Agent__c;
        			poNumber = tW.lW.line.Order_Level_PO_Number__c;
        			i++;
        		}
        		if(accountID != tW.lW.line.Account__c || billingAgent != tW.lW.line.Billing_Agent__c || poNumber != tW.lW.line.Order_Level_PO_Number__c){
	                hasdifferentSelections = true;
	            }
	            selectedLines.add(tW.lW.line);
	            if(!tW.disabled){
	            	selectedScheduleWrappers.addAll(tW.lW.scheduleWrapperList);
	            }
        	}
        }
        
        if(hasdifferentSelections){
            this.currentController.hasMessages = true;
            this.currentController.resultWrapper = this.currentController.resultWrapper.addErrorMessage(this.currentController.resultWrapper, ApexPages.Severity.ERROR, 'To Open plugin, You must select any number of lines with identical values for fields Brand Or Advertiser, Billing Agent and Order level PO Number.');
            this.currentController.handelErrorMessages();
        }else if(selectedLines != null && selectedLines.size()>0){
        
            OppOrderManager oOM = new OppOrderManager();
            if(this.currentController.resultWrapper.hasMessages == false){
                //reseting result wrapper
                
                this.currentController.resultWrapper = oOM.createOrderFromOppLineItem_new(selectedScheduleWrappers, selectedLines, this.currentController.currentOpp);
                system.debug('resultWrapper from OOM : '+this.currentController.resultWrapper);
                if(this.currentController.resultWrapper.hasMessages == false && this.currentController.resultWrapper.URL != null && this.currentController.resultWrapper.URL != ''){
                    this.currentController.OpenCCIPlugin = true;
                    this.currentController.plugInUrl = this.currentController.resultWrapper.URL;
                    if(this.currentController.iframePrintWrapperList == null){
                        this.currentController.iframePrintWrapperList = new list<OpportunityToOrder_BaseController.TableWrapper>();
                    }
                    this.currentController.iframePrintWrapperList.addAll(this.currentController.inProgressPrintSelectedTWList);
                }else{
                    this.currentController.hasMessages = true;
                    if(this.currentController.resultWrapper.hasMessages == false){
                        this.currentController.resultWrapper = this.currentController.resultWrapper.addErrorMessage(this.currentController.resultWrapper, ApexPages.Severity.ERROR, 'An unknown error occured. Please contact System Administrator.');
                    }
                    this.currentController.handelErrorMessages();
                }
            }else{
                this.currentController.resultWrapper = this.currentController.resultWrapper.addErrorMessage(this.currentController.resultWrapper, ApexPages.Severity.ERROR, 'Please clear the above errors before submiting to CCI. ');
                this.currentController.hasMessages = true;
                this.currentController.handelErrorMessages();
            }
        }else{
            this.currentController.resultWrapper = this.currentController.resultWrapper.addErrorMessage(this.currentController.resultWrapper, ApexPages.Severity.ERROR, 'Please select at least one line that is not available in CCI.');
            this.currentController.hasMessages = true;
            this.currentController.handelErrorMessages();
        }
        this.multiLineCCISubmit = false;
    }
    
    //Edit Order Multi Line
    public void editOrder_Multi(){
    	
    	this.currentController.resultWrapper = new ResultWrapper();
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index;
    	integer i =0;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(tW.lW.item!= null && tW.selected == true){
            	index = i;
                currentTW = tW;
                break;
            }
            i++;
        }
        boolean hasMultiOrderSelection = false;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
        	if(tW.selected && tW.lW.line.Order_Item__c != null && !tW.lW.item.Is_Cancelled__c){
				if(currentTW.lW.ord.CCI_Order_ID__c != tW.lW.ord.CCI_Order_ID__c){
					hasMultiOrderSelection = true;
					break;
				}
        	}
        }
        
        if(hasMultiOrderSelection){
        	this.currentController.resultWrapper = this.currentController.resultWrapper.addErrorMessage(this.currentController.resultWrapper, ApexPages.Severity.ERROR, 'Can not edit multiple orders at a time. Please select lines related to one order.');
            this.currentController.hasMessages = true;
            this.currentController.handelErrorMessages();
            return;
        }
        
        OppOrderManager oOM = new OppOrderManager();
        
        this.currentController.resultWrapper = oOM.editAccountOrder(currentTW.lW.ord, this.currentController.currentOpp);
        if(this.currentController.resultWrapper.url == null || currentTW.rW.url == ''){
            this.currentController.hasMessages = true;
            this.currentController.handelErrorMessages();
        }else{
        	this.currentController.hasMessages = false;
        	this.currentController.OpenCCIPlugin = true;
        	this.currentController.plugInUrl = this.currentController.resultWrapper.URL;
        }
    }
    
    //Edit order that is in view
    public void editOrder_Single(){
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index;
    	integer i =0;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(tW.lW.item!= null && this.currentLineId == tW.lW.item.id){
            	index = i;
                currentTW = tW;
                break;
            }
            i++;
        }
        OppOrderManager oOM = new OppOrderManager();
        this.currentController.resultWrapper = oOM.editAccountOrder(currentTW.lW.ord, this.currentController.currentOpp);
        if(this.currentController.resultWrapper.url == null || currentTW.rW.url == ''){
            this.currentController.hasMessages = true;
            this.currentController.handelErrorMessages();
        }else{
        	this.currentController.hasMessages = false;
        	this.currentController.OpenCCIPlugin = true;
        	this.currentController.plugInUrl = this.currentController.resultWrapper.URL;
        }
    }
    
    //Edit Order Item In CCI plugin
    public void editOrderItem_Single(){
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index;
    	integer i =0;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(tW.lW.item!= null && this.currentLineId == tW.lW.item.id){
            	index = i;
                currentTW = tW;
                break;
            }
            i++;
        }
        OppOrderManager oOM = new OppOrderManager();
        currentTW.rW = oOM.editOrderItem(currentTW.lW.item, currentTW.lW.ord, this.currentController.currentOpp);
        if(currentTW.rW.url == null || currentTW.rW.url == ''){
        	currentTW.rW.hasMessages = true;
        }else{
        	currentTW.rW.hasMessages = false;
        	this.currentController.OpenCCIPlugin = true;
        	this.currentController.plugInUrl = currentTW.rW.URL;
        }
    }
    
    public void changeBrand_Order(){
        system.debug('***Change Brand for whole order');
        boolean hasErrors = false;
        this.currentController.inProgressPrintResultWrapper = new ResultWrapper();
        String firstOrderID; 
        //Validation of selection for multiple orders
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(tW.Selected){
                if(firstOrderID == null && tW.lW.line.Order_Item__c != null){
                    firstOrderID = tW.lW.ord.CCI_Order_ID__c;
                }
                if(firstOrderID != null && tW.lW.line.Order_Item__c != null && firstOrderID != tW.lW.ord.CCI_Order_ID__c){
                    this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addErrorMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.Severity.ERROR, 'Please select lines that are related to a single order. ');
                    hasErrors = true;
                }
            }
        } 
        list<OpportunityToOrder_BaseController.TableWrapper> selectedTWs = new list<OpportunityToOrder_BaseController.TableWrapper>();
        //validation of seletions for lines before changing the brand
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintTWList){
            if(tW.Selected){
                if(tW.lW.line.Order_Item__c == null){
                    this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addErrorMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.Severity.ERROR, 'Please select lines that have orders in CCI (Represented as Blcak colored text) .');
                    hasErrors = true;
                    break;
                }
                if(hasErrors == false){
                    selectedTWs.add(tW);
                }
            }
        }
        //Status of the cancelitation
        String result = null; 
        if(!hasErrors){
            OppOrderManager oom = new OppOrderManager();
            result = oom.cancelOrder(firstOrderID, 'MISC', 'Miscellaneous');
        }
        if(result!= null && result.equalsIgnoreCase('Success')){
            try{
                Order relatedOrderToUpdate = [select id, Submitted_For_Cancellation__c from Order where CCI_Order_ID__c =: firstOrderID limit 1];
                relatedOrderToUpdate.Submitted_For_Cancellation__c = true; 
                update relatedOrderToUpdate; 
                list<OrderItem> relatedOrderItems = new list<OrderItem>(); 
                list<OpportunityLineItem> relatedLineItems = new list<OpportunityLineItem>();
                //proceeed with changeing of brand
                for(OpportunityToOrder_BaseController.TableWrapper tW : selectedTWs){
                    tW.lW.item.Submitted_For_Cancellation__c = true;
                    relatedOrderItems.add(tW.lW.item);
                    tW.lW.line.Account__c = null;
                    tW.lW.line.Billing_Agent__c = null;
                    relatedLineItems.add(tW.lW.line);
                }
                update relatedOrderItems;
                update relatedLineItems;
            }catch(Exception ex){
                this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addExceptionMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.Severity.ERROR, ex);
            }
        }else{
            this.currentController.inProgressPrintResultWrapper = this.currentController.inProgressPrintResultWrapper.addErrorMessage(this.currentController.inProgressPrintResultWrapper, ApexPages.Severity.ERROR, 'Faild to Cancel this Order Item. Please contact System Admin for more information.');
        }
    }

    public void cancelOrderItem_Single(){
    	system.debug('***currentLineId - cancelOrderItem_Single : '+this.currentLineId);
    	OpportunityToOrder_BaseController.TableWrapper currentTW;
    	integer index, i = 0;
        for(OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.inProgressPrintSelectedTWList){
            if(tW.lW.item != null && this.currentLineId == tW.lW.item.id){
            	index = i;
                currentTW = tW;
                break;
            }
            i++;
        }
        system.debug('currentLine : '+ currentTW);
        currentTW.rW = new ResultWrapper();
        //cancellation Save Point 
        
        //validation for cancel reasons
        if(currentTW.cancelreasonCode == null || currentTW.cancelreasonCode == ''){
        	currentTW.rW.hasMessages = true;
        	currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'You must select Cancel Reason and Cancel Code before click on Submit button.'); 
        }
        
        if(!currentTW.rW.hasMessages){
        	String code, name; 
        	code = currentTW.cancelreasonCode;
        	name = this.currentController.cciCancelReasonsMap.get(code).name;
        	OppOrderManager oOM = new OppOrderManager();
        	String result  = oOM.cancelOrderItem(currentTW.lW.item.CCI_Order_Item_ID__c, currentTW.lW.ord.CCI_Order_ID__c, code, name);
        	Savepoint cancellationSP = Database.setSavepoint();
        	if(result!= null && result.equalsIgnoreCase('Success')){
        		try{
        			//update the item with success submision. 
        			currentTW.lW.item.Submitted_For_Cancellation__c = true;
        			currentTW.lW.item.CCI_Cancel_Reason_Code__c = code;
        			currentTW.lW.item.CCI_Cancel_Reason__c = name;
        			update currentTW.lW.item;
        			currentTW.lineEditMode = false;
        		}catch (Exception Ex){
        			currentTW.rW.hasMessages = true;
        			currentTW.rW = currentTW.rW.addExceptionMessage(currentTW.rW, ApexPages.Severity.ERROR, ex);
        		}
        		if(currentTW.rW.hasMessages){
        			Database.rollback(cancellationSP);
        		}else{
        			//Deselect the line and update the information
        			currentTW.selected = false;
        			this.currentController.inProgressPrintSelectedTWList.remove(index);
        		}
        	}else{
        		//dispaly an error message and roll back the save point
        		currentTW.rW = currentTW.rW.addErrorMessage(currentTW.rW, ApexPages.Severity.ERROR, 'Faild to Cancel this Order Item. Please contact System Admin for more information.');
        		currentTW.rW.hasMessages = true;
        		Database.rollback(cancellationSP);
        	}
        }
    }
    
    
/*--CCI Print Line Actions--*/

/*In Active Table Actions */
	//Activate selected 
	public void activateSelected (){
		this.currentController.inActivePrintResultWrapper = new ResultWrapper();
		list<Inactive_Pitch_Idea__c> selectedRecordsList = new list<Inactive_Pitch_Idea__c>();
		for( OpportunityToOrder_BaseController.TableWrapper tW : this.currentController.deletedPrintTWList){
			if(tW.selected){
				tW.lW.ipi.Active__c = true;
				selectedRecordsList.add(tW.lW.ipi);
			}
		}
		if(selectedRecordsList.size()>0){
			try{
				update selectedRecordsList;
				this.currentController.inActivePrintResultWrapper.hasMessages = true;
				this.currentController.inActivePrintResultWrapper = this.currentController.inActivePrintResultWrapper.addErrorMessage(this.currentController.inActivePrintResultWrapper, ApexPages.Severity.Info, 'Please click on Refesh Table button to see the updated list of In-Active lines.');
			}catch(Exception ex){
				this.currentController.inActivePrintResultWrapper.hasMessages = true;
				this.currentController.inActivePrintResultWrapper = this.currentController.inActivePrintResultWrapper.addExceptionMessage(this.currentController.inActivePrintResultWrapper, ApexPages.severity.ERROR, ex);
			}
		}else{
			this.currentController.inActivePrintResultWrapper.hasMessages = true;
			this.currentController.inActivePrintResultWrapper = this.currentController.inActivePrintResultWrapper.addErrorMessage(this.currentController.inActivePrintResultWrapper, ApexPages.Severity.ERROR, 'You must select at least one line to activate before click on the button Activate Selected.');
		}
		//Populate Wrapper variables
        this.currentController.inProgressPrintSelectedTWList = new list<OpportunityToOrder_BaseController.TableWrapper>();
        this.currentController.printTWMap = new map<string, OpportunityToOrder_BaseController.TableWrapper>();
        this.currentController.populateWrapperVariables();
        //populate inprogress print table.
        this.currentController.reevoluateTableValues('INPROGRESS-PRINT');
	}
/*In Active Table Actions */
	
	public void populatecancelReasonSelectoptions(){
		
		if(this.currentController.cciCancelReasonsMap == null){
			this.currentController.populateCancelResonsMap();
		}
		this.cancelReason.add(new SelectOption('',''));
		list<CCICancelReasons> sortedList = this.currentController.cciCancelReasonsMap.values();
		sortedList.sort();
		for(CCICancelReasons reason : sortedList){
			this.cancelReason.add(new Selectoption(reason.code,reason.name));
		}
		system.debug('***this.cancelReason : '+this.cancelReason);
	} 
	
/*--Public Methods--*/

/*Private Methods*/
    
    //returns the set of immidieat childs for given current id, 
    private set<ID> subChilds(id currentID, set<ID> result, map<ID, set<ID>> inputMap){
        result.add(currentID);
        if(inputMap.containsKey(currentID)){
            for(id tempid2 : inputMap.get(currentID)){
                result.add(tempid2);
                if(inputMap.containsKey(tempid2)){
                    result.addAll(subChilds(tempid2, result, inputMap));
                }
            }
        }
        return result;
    }
    
    //Returns the advertisers based on the opportunity Account Id. 
    private void populateLine_Advertisers(){
        Common com = new Common();
        map<Id, Account> allAccountsMap = new map<Id, Account>([SELECT ID, Name, Type, CCIMailCustID__c, CCIMetroCustID__c, Salutation__c, FirstName__c, ParentID, Parent.ID,  
                                                                    Parent.CCIMailCustID__c, Parent.CCIMetroCustID__c, Parent.Name, Parent.Type, Parent.Salutation__c, Parent.FirstName__c 
                                                                From Account Where ID IN: com.allIdsInHirearchy(this.currentController.currentOpp.AccountID) And IsActive__c=true]);
        this.currentController.allAccountsMap.putAll(allAccountsMap);
        map<Id, set<ID>> accountIdToAllChildIdsMap = new map<Id, set<Id>>();
        for(Account a : allAccountsMap.values()){
            if(a.ParentID != null){
                if(!accountIdToAllChildIdsMap.containsKey(a.ParentId))
                    accountIdToAllChildIdsMap.put(a.ParentId, new set<ID>());
                accountIdToAllChildIdsMap.get(a.ParentId).add(a.ID);
            }
        }
        list<Id> childIds = new list<Id> (subChilds(this.currentController.currentOpp.AccountID, new set<Id>(), accountIdToAllChildIdsMap));
        this.currentController.possibleAdvertisers.add(new SelectOption('000000000000000000', '-- None --'));
        
        list<Account> subAccounts = new list<Account>([SELECT ID, Name, Type, CCIMailCustID__c, CCIMetroCustID__c, Salutation__c, FirstName__c, ParentID, Parent.ID,  
                                                            Parent.CCIMailCustID__c, Parent.CCIMetroCustID__c, Parent.Name, Parent.Type, Parent.Salutation__c, Parent.FirstName__c 
                                                        From Account Where ID IN: childIds And IsActive__c=true AND RecordType.Name = 'Advertiser' Order BY Name ASC]);
        this.currentController.allAccountsMap.putAll(subAccounts);
        for(Account currentAccount : subAccounts){
            if(currentAccount != null){
                this.currentController.possibleAdvertisers.add(new SelectOption(currentAccount.id, currentAccount.Name +' -- '+currentAccount.Type));
                possibleAdvertiserIds.add(currentAccount.id);
            }
        }
    }
    
    /*Returns the list of selest options for billing agents based on selected advertiser.*/ 
    private void populateLine_BillingAgents(){
        
        list<Relationship__c> relationshipsList = new list<Relationship__c>([Select Role__c, Name, Id, Active__c, Account_B__c, Account_A__c, 
                                                                                Account_B__r.Name, Account_A__r.Name, Account_B__r.Type, Account_A__r.Type 
                                                                                From Relationship__c
                                                                                WHERE ((Account_A__c IN: possibleAdvertiserIds) 
                                                                                OR (Account_B__c IN: possibleAdvertiserIds))
                                                                                AND Role__c = 'Billing'
                                                                                AND Active__c = true]);
        map<Id, Account> advMap= getAccountsMap(possibleAdvertiserIds);
        set<ID> advertiserBillingAgentsSet = new set<ID>();
        for(Id advertiserId : possibleAdvertiserIds){
            this.currentController.relatedBillingAgentsMap.put(advertiserId, new list<SelectOption>());
            //Adding None as a default value
            this.currentController.relatedBillingAgentsMap.get(advertiserId).add(new SelectOption('000000000000000000', '-- None --'));
            
            //Self Billing options
            Account currentAccount = advMap.get(advertiserId);
            if(currentAccount != null){
                if(allowedAccountTypesToFinanaceAccountSet.contains(currentAccount.Type)){
                    boolean haserror = false;
                    for(String s: requiredFieldsForFinanaceAccountSet){
                        if(currentAccount.get(s) == null ){
                            haserror = true;
                            break;
                        }
                    }
                    if(!hasError){
                        this.currentController.relatedBillingAgentsMap.get(advertiserId).add(new SelectOption(advertiserId, '--Self Billing--'));
                    }
                }
            }
        }
        
        for(Relationship__c rel : relationshipsList){
            if(possibleAdvertiserIds.contains(rel.Account_A__c)){
                this.currentController.relatedBillingAgentsMap.get(rel.Account_A__c).add(new SelectOption(rel.Account_B__c, rel.Account_B__r.Name + ' -- '+rel.Account_B__r.Type));
                advertiserBillingAgentsSet.add(rel.Account_B__c);
            }
            if(possibleAdvertiserIds.contains(rel.Account_B__c)){
                this.currentController.relatedBillingAgentsMap.get(rel.Account_B__c).add(new SelectOption(rel.Account_A__c, rel.Account_A__r.Name + ' -- '+rel.Account_A__r.Type));
                advertiserBillingAgentsSet.add(rel.Account_A__c);
            }
        }
        
        //looking for billing agents of booking agency if opportunity agency is booking agency 
        if(this.currentController.currentOpp != null && this.currentController.currentOpp.Agency__c != null && this.currentController.currentOpp.Agency__r.Type.equalsIgnoreCase('Booking Agency')){
            list<Relationship__c> bookingAgencyRelationShips = new list<Relationship__c>([Select Role__c, Name, Id, Active__c, Account_B__c, Account_A__c, 
                                                                                Account_B__r.Name, Account_A__r.Name, Account_B__r.Type, Account_A__r.Type 
                                                                                From Relationship__c
                                                                                WHERE ((Account_A__c =: this.currentController.currentOpp.Agency__c) 
                                                                                OR (Account_B__c =: this.currentController.currentOpp.Agency__c))
                                                                                AND Role__c = 'Billing'
                                                                                AND Active__c = true]);
            
            list<Selectoption> newBillingAgencies = new list<Selectoption>();
            for(Relationship__c rel : bookingAgencyRelationShips){
                if(rel.Account_A__c == this.currentController.currentOpp.Agency__c && !advertiserBillingAgentsSet.contains(rel.Account_B__c)){
                    newBillingAgencies.add(new Selectoption(rel.Account_B__c, rel.Account_B__r.Name + ' -- '+rel.Account_B__r.Type));
                }
                if(rel.Account_B__c == this.currentController.currentOpp.Agency__c && !advertiserBillingAgentsSet.contains(rel.Account_A__c)){
                    newBillingAgencies.add(new Selectoption(rel.Account_A__c, rel.Account_A__r.Name + ' -- '+rel.Account_A__r.Type));
                }
            }
            //Add the list of selection options to all entity values in billing agents map. 
            if(newBillingAgencies != null && newBillingAgencies.size() > 0){
                for(ID advID : this.currentController.relatedBillingAgentsMap.keySet()){
                    this.currentController.relatedBillingAgentsMap.get(advID).addAll(newBillingAgencies);
                }
            }
        }
         
    }
    
    //returns map of accounts for requested account ids with required fields for finanace accounts. 
    private map<Id, Account> getAccountsMap(set<id> accountIDs){
        String query = 'SELECT ID, Name, Type  ';
        for(String s : requiredFieldsForFinanaceAccountSet){
            query += ','+s; 
        }
        query += ' From Account Where ID IN  (';
        for(Id tempId : accountIDs){
            query += '\''+tempID+'\', ';
        }
        query = query.substring(0, query.lastIndexOf(','));
        query += ')';
        system.debug('***query : '+query);
        list<Account> accountList = Database.query(query);
        map<Id, Account> resultMap = new map<Id, Account>(accountList );
        
        return resultMap;
    }
/*--Private Methods--*/
}