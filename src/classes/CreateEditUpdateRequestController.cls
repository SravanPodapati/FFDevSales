public  without sharing class CreateEditUpdateRequestController {
        
    /*constants*/
    private String relatedObject = 'Related Object';
    public String specialAction_Industry {
	    	get{
	    		return 'industry';
	    	} 
	    	set{
	    		specialAction_Industry = 'industry';
	    	}
    }
    private map<String, Schema.SObjectType> objectDescripbe = Schema.getGlobalDescribe();      
    private map<String, Schema.Sobjectfield> fieldsMap;

    /*flags*/
    //public boolean isRelatedObjectValid {get; set;}
    //public boolean isRelatedRecordValid {get; set;}
    public boolean isUpdateRequestCreated {get; set;}
    public boolean hasErrors {get; set;}    
    
    /*input Values*/
    public string relatedObjectName {get; Set;}
    public sObject relatedRecord {get; set;}
    public sObject relatedRecord2 {get; set;}
    
    /*Wrapper Objects*/
    public map<String, FieldWrapper> fieldWrapperMap {get; Set;}
    public list<FieldWrapper> fieldWrapperList {get; Set;}
    public Apexpages.Message pageMessage {get; set;}
    public sObject tempUR {get; Set;}
    public string errorMessage {get; set;}
    public String currentFieldAPIName {get; set;}
    public String currentSpecialActionFieldAPIName {get; set;}
    public String currentSpecialAction {get; set;} 
    
    /*private Variables*/
    private ID relatedRecordID;
    private map<String, list<String>> relatedObjectsToFieldsMap;
    private map<String, String> relatedObjectFieldTOUpdateRequestFieldMap; 
    private map<String, String> relatedObjectToRelatedURFieldMap;
    private list<string> informationBlockFieldSet; 
    private set<String> queryFieldSet;
    private map<String, map<String, String>> relatedObjectsToSpecialFieldsMap;
    private map<String, map<String,set<String>>> relatedObjectsToSpecialFieldGroupMap;
    
    /*constructure*/
    public CreateEditUpdateRequestController(){
    	this.isUpdateRequestCreated = this.isUpdateRequestCreated == null ? false : this.isUpdateRequestCreated;
    	this.errorMessage = this.errorMessage == null ? null : this.errorMessage;
        this.tempUR = new Update_Request__c();
        this.fieldWrapperList = new list<FieldWrapper>();
        //this.currentFieldAPIName = this.currentFieldAPIName == null? '' : this.currentFieldAPIName;
        relatedObjectsToFieldsMap = new map<String, list<String>>();
        relatedObjectFieldTOUpdateRequestFieldMap = new map<String, string>();
        relatedObjectToRelatedURFieldMap = new map<String, String>();
        informationBlockFieldSet = new list<string>();
        relatedObjectsToSpecialFieldsMap = new map<String, map<String, String>>();
        queryFieldSet = new set<String>();
        relatedObjectsToSpecialFieldGroupMap = new map<String, map<String,set<String>>> ();
        constructMaps();
        populateIndustryMaps();
        
        String currentURL = Apexpages.currentPage().getUrl();
        if(Apexpages.currentPage().getParameters().get('rObj') != null){
            this.relatedObjectName = Apexpages.currentPage().getParameters().get('rObj').tolowerCase();
            this.fieldsMap = objectDescripbe.get(this.relatedObjectName).getDescribe().fields.getMap();
        }
        this.relatedRecordID = Apexpages.currentPage().getParameters().get('rId');
        if(this.relatedRecordID != null){
            this.tempUR.put(relatedObjectToRelatedURFieldMap.get(this.relatedObjectName), this.relatedRecordID );
        }
        
        //query the related record
        if(this.relatedRecordID != null){
            queryRelatedRecord();
            this.relatedRecord2 = this.relatedRecord.clone(true,true,true,true);
        }
        
        if(this.relatedRecord != null){
            buildFieldWrapper();
        }
    }
    
    /*Conver the custom labels in to apex understandable maps*/
    private void constructMaps(){
        for(String line: Label.Related_Object_Field_to_Update_Request_Field.split(';')){
            //Populate relatedObjectFieldTOUpdateRequestFieldMap
            list<String> tempList_ROFToURFMap = line.split('=>',2);
            String mapKey_ROFToURFMap = tempList_ROFToURFMap[0].toLowerCase().trim();
            String mapValue_ROFToURFMap = tempList_ROFToURFMap[1].replace(';','').toLowerCase().trim();
            
            relatedObjectFieldTOUpdateRequestFieldMap.put(mapKey_ROFToURFMap, mapValue_ROFToURFMap);
            
            //populate relatedObjectsToFieldsMap
            list<String> tempList_ROToFMap = mapKey_ROFToURFMap.split('\\.',2);
            String mapKey_ROToFMap = tempList_ROToFMap[0].toLowerCase().trim();
            String mapValue_ROToFMap = tempList_ROToFMap[1].toLowerCase().trim();
            
            if(!relatedObjectsToFieldsMap.containsKey(mapKey_ROToFMap)){
                relatedObjectsToFieldsMap.put(mapKey_ROToFMap, new list<String>());
            }
            relatedObjectsToFieldsMap.get(mapKey_ROToFMap).add(mapValue_ROToFMap);
            queryFieldSet.add(mapValue_ROToFMap);
        }
        //from Label Related_Object_to_Information_Block_Field
        for(string line: Label.Related_Object_to_Information_Block_Field.split(';')){
            list<String> temp_ROToIBFLable = line.split('=>',2);
            String mapKey_ROToIBFLable = temp_ROToIBFLable[0].toLowerCase().trim();
            
            for(String mapValue_ROToIBFLable:temp_ROToIBFLable[1].split(',')){
                mapValue_ROToIBFLable = mapValue_ROToIBFLable.toLowerCase().trim();
                informationBlockFieldSet.add(mapValue_ROToIBFLable);
                queryFieldSet.add(mapValue_ROToIBFLable);
            }
        }
        
        //construct relatedObjectToRelatedURFieldMap
        for(String line: Label.Related_Object_to_Related_UR_Field.split(';')){
            list<String> tempList_ROToRURFMap = line.split('=>',2);
            String mapKey_ROToRURFMap = tempList_ROToRURFMap[0].toLowerCase().trim();
            String mapValue_ROToRURFMap = tempList_ROToRURFMap[1].replace(';','').toLowerCase().trim();
            
            relatedObjectToRelatedURFieldMap.put(mapKey_ROToRURFMap, mapValue_ROToRURFMap);
        }
        
        for(String line : Label.Related_Object_to_special_Fields_Map.split(';')){
        	String outerMapKey, innerMapKey, innerMapValue;
        	map<String, String> innerMap = new map<String, String>();
        	
        	list<String> tempList = line.split('=>',2);
        	
        	list<String> tempList2 = tempList[0].split('\\.',2);
        	outerMapKey = tempList2[0].toLowerCase().trim();
        	innerMapValue = tempList2[1].toLowerCase().trim();
        	
        	set<string> innerMapValue2 = new set<String>();
        	string innerMapKey2 = innerMapValue; 
        	map<String, Set<String>> innerMap2 = new map<String, Set<String>>();
        	for(String temp : tempList[1].replace(';','').split(',')){
        		innerMApKey = temp.toLowerCase().trim();
        		innerMap.put(innerMApKey, innerMapValue);
        		innerMapValue2.add(innerMApKey);
        	}
        	innerMap2.put(innerMapKey2, innerMapValue2);
        	relatedObjectsToSpecialFieldsMap.put(outerMapKey, innerMap);
        	relatedObjectsToSpecialFieldGroupMap.put(outerMapKey,innerMap2);
        	
        }
        
        system.debug('***relatedObjectToRelatedURFieldMap : '+relatedObjectToRelatedURFieldMap);
        system.debug('***relatedObjectsToFieldsMap : '+relatedObjectsToFieldsMap);
        system.debug('***relatedObjectFieldTOUpdateRequestFieldMap : '+relatedObjectFieldTOUpdateRequestFieldMap);
        system.debug('***queryFieldSet : '+queryFieldSet);
        system.debug('***relatedObjectsToSpecialFieldsMap : '+relatedObjectsToSpecialFieldsMap);
        system.debug('***relatedObjectsToSpecialFieldGroupMap : '+relatedObjectsToSpecialFieldGroupMap);
    }
    
    public void specialAction(){
    	system.debug('***specialAction function');
    	this.currentSpecialAction = ApexPages.CurrentPage().getParameters().get('currentGroup_Parm');
    	system.debug('***currentSpecialAction : '+this.currentSpecialAction);
    }
    
    public void selectCheckBox(){
    	system.debug('***selectCheckBox function');
    	this.currentFieldAPIName = ApexPages.CurrentPage().getParameters().get('currentFieldWrapper_Parm');
    	system.debug('***currentFieldAPIName : '+this.currentFieldAPIName);
    	FieldWrapper currentFW = this.fieldWrapperMap.get(this.currentFieldAPIName);
    	//verify wether the selected field is in the special field map or not 
    	if(relatedObjectsToSpecialFieldsMap.get(this.relatedObjectName).containsKey(this.currentFieldAPIName)){
    		String groupName = relatedObjectsToSpecialFieldsMap.get(this.relatedObjectName).get(this.currentFieldAPIName);
    		for(String fieldAPI : relatedObjectsToSpecialFieldGroupMap.get(this.relatedObjectName).get(groupName)){
    			if(this.fieldWrapperMap.get(fieldAPI).Selected == false && currentFW.selected==true){
    				this.fieldWrapperMap.get(fieldAPI).Selected = true;
    			}else if(this.fieldWrapperMap.get(fieldAPI).Selected == true && currentFW.selected==false){
    				this.fieldWrapperMap.get(fieldAPI).Selected = false;
    			}
    		}
    	}
    	
    }
    
    public list<FieldWrapper> getTempFieldWrapperList(){
        return this.fieldWrapperMap.values();
    }
        
    /*Dynamic information for the related record*/
    public Component.Apex.PageBlock getInformationBlock() {
        Component.Apex.PageBlock pB = new Component.Apex.PageBlock();
        if(objectDescripbe.get(this.relatedObjectName)!=null){
            pB.title = objectDescripbe.get(this.relatedObjectName).getDescribe().getLabel()+' Information';
        }
        Component.Apex.PageBlockSection pbs = new Component.Apex.PageBlockSection();
                
        //Create a multiple output fileds 
        for(String field: informationBlockFieldSet){
                Component.Apex.OutputField oField = new Component.Apex.OutputField();
        oField.expressions.Value = '{!relatedRecord.'+field+'}';
        pbs.childComponents.add(oField);
        }
        
        pB.childComponents.add(pbs);
            
        return pB;
    }
    
    /*Page block that consists list of fields to choose*/
    public Component.Apex.PageBlock getFieldSelectBlock(){
        Component.Apex.PageBlock pB = new Component.Apex.PageBlock();
        pB.title = 'Select Field to Edit';
		       
        Component.Apex.PageBlockSection pBS = new Component.Apex.PageBlockSection();
		Component.Apex.Repeat repeat = new Component.Apex.Repeat();
		repeat.expressions.Value = '{!TempFieldWrapperList}';
		repeat.var='fW';
    	//inputCheckBox
    	Component.Apex.InputCheckbox iC = new Component.Apex.InputCheckbox();
		iC.expressions.Value = '{!fW.selected}';
		iC.expressions.Label = '{!fW.fieldLable}';
		//action Support
		Component.Apex.ActionSupport actionSupport = new Component.Apex.ActionSupport();
		actionSupport.event = 'onchange';
		//rerender must be as a set of strings.
		set<String> actionSupportRerender = new set<String>();
		actionSupportRerender.add('fildEditPanel');
		actionSupport.rerender = actionSupportRerender;
	
		iC.childComponents.add(actionSupport);
		
		repeat.childComponents.add(iC);
        
        pBS.childComponents.add(repeat);
        pB.childComponents.add(pBS);
        
        return pB;
    }
    
    /*Page block that consists list of fields to choose*/
    public Component.Apex.PageBlock getEditBlock(){
    	
    	Component.Apex.PageBlock pageBlock = new Component.Apex.PageBlock();
    	pageBlock.title = 'Please change the values';
		
		Component.Apex.PageBlockSection pageBlockSection = new Component.Apex.PageBlockSection();
				
		Component.Apex.Repeat repeat = new Component.Apex.Repeat();
		repeat.expressions.Value = '{!TempFieldWrapperList}';
		repeat.var='fW';
		
		Component.Apex.InputField inputField = new Component.Apex.InputField();
		inputField.expressions.Value = '{!relatedRecord[fW.fieldAPIName]}';
		inputField.expressions.rendered = '{!fW.Selected}';
		
		repeat.childComponents.add(inputField);
		pageBlockSection.childComponents.add(repeat);
		pageBlock.childComponents.add(pageBlockSection);
		
    	return pageBlock;
    }
        
	/*Updates the page URL and returns the new destination*/
    public Pagereference actionMethod(){
        system.debug('In Action Method');
        Pagereference resultPage = Page.CreateEditUpdateRequest;
        resultPage.getParameters().put('rObj',this.relatedObjectName);
        resultPage.setRedirect(true);
        return resultPage;
    }
    
    /*returns the available related objects for Update Requests*/ 
    public list<Selectoption> getObjectNames(){
        list<Selectoption> resultList = new list<Selectoption>();
        system.debug(objectDescripbe);
        for(String objName:relatedObjectToRelatedURFieldMap.KeySet()){
        	resultList.add(new Selectoption(objName, objectDescripbe.get(objName).getDescribe().getLabel()));
        }
        return resultList;
    }
    
    /*Selects the record and returns an updated URL*/
    public Pagereference selectRecord(){
        queryRelatedRecord();
        
        Pagereference resultPage = Page.CreateEditUpdateRequest;
        resultPage.getParameters().put('rId',this.relatedRecordID);
        resultPage.getParameters().put('rObj',this.relatedObjectName);
        resultPage.setRedirect(true);
        return resultPage;
    }
    
    /*Query the related Record based on the ID*/
    private void queryRelatedRecord(){
        this.relatedRecordID = (id) this.tempUR.get(relatedObjectToRelatedURFieldMap.get(this.relatedObjectName));
        
        if(this.relatedRecordID != null && this.relatedObjectName != null){
            this.relatedRecord = Database.query(buildQuery(relatedObject));
            Id recordTypeID = (ID) this.relatedRecord.get('RecordTypeID');
            this.relatedRecord2 = objectDescripbe.get(this.relatedObjectName).newsObject(recordTypeID, false);
        }
    }
    
    /*Builds the query based on the options available*/
    private String buildQuery(String option){
        String resultQuery = 'SELECT ID, RecordTypeID, '.tolowercase();
        if(option == relatedObject){
            for(String fieldAPI : queryFieldSet){
            	if(!resultQuery.contains(fieldAPI+', '))
                    resultQuery += fieldAPI+', ';
            }
            resultQuery = resultQuery.substring(0, resultQuery.lastIndexOf(', '));
            resultQuery += ' From '+this.relatedObjectName+' Where ID = \''+this.relatedRecordID+'\'';
        }
        
        system.debug('*** resultQuery for '+ option +': '+resultQuery);
        return resultQuery;
    }
    
    /*Saves the Update Request record*/ 
    public Pagereference saveUpdateRequest(){
        Pagereference resultPage;
        this.hasErrors = false;
        this.errorMessage = null;
        boolean atLestOnefieldSeleced = false; 
        Update_Request__c updateRequest = new Update_Request__c();
        updateRequest.put(relatedObjectToRelatedURFieldMap.get(this.relatedObjectName), this.relatedRecordID );
        if(this.currentSpecialAction != null){
        		errorMessage = 'Can not create an update request while <b>'+this.currentSpecialAction+' Panel</b> is still active. To apply changes please click on Save changes button.';
        		this.hasErrors = true;
        }else{
	        for(FieldWrapper fW : fieldWrapperMap.values()){
		        if(fW.selected == true){
			        	fW.newValue = this.relatedRecord2.get(fW.fieldAPIName);
			        	//fW.newValue = fW.newValue == null? '': fw.newValue;
			        	
			        	if(fW.previousValue == fW.newValue && !fW.isSpecial){
			        		if(errorMessage == null){
			        			errorMessage = 'There are no difference between previous value and new value for the following selected fields. ';
			        		}
			        		errorMessage += '<br/>';
			        		errorMessage += '<b>'+fW.fieldLable+'</b>';
			        		this.hasErrors = true;
			        	}
			        	
			        	if(fW.fieldAPIName_UR.equalsIgnoreCase('npa__c')){
			        		String npaValue = (boolean)fW.newValue?'Yes':'No';
			        		fw.newValue = npaValue;
			        	}
			        	
			        	system.debug('***fW.fieldAPIName_UR : '+fW.fieldAPIName_UR);
			        	system.debug(' ***fW.newValue : '+fW.newValue);
			        	
		        		updateRequest.put(fW.fieldAPIName_UR, fW.newValue);
			        	
			        	String selectedAPIName = fW.fieldAPIName_UR.replace('__c','');
			        	selectedAPIName += '_S__c';
			        	updateRequest.put(selectedAPIName, true);
			        	atLestOnefieldSeleced = true;
		        }
	        }
	        updateRequest = populateParentAccount(updateRequest);	
        }
        try{
        	if(atLestOnefieldSeleced == false && errorMessage == null){
        		errorMessage = 'You must select at least one Field to Create a new update request';
        		this.hasErrors = true;
        	}
        	if(this.hasErrors == true){
        		system.debug('***In Error Message');
        		//add messge to VF
        		this.isUpdateRequestCreated = false; 
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMessage));
        		return null;
        	}else{
        		upsert updateRequest;
        		this.isUpdateRequestCreated = true;
        		resultPage = new pageReference('/'+updateRequest.id);
        		resultPage.setRedirect(true);
        		return resultPage;
        	}
        }catch(Exception e){
        	this.isUpdateRequestCreated = false;
        	this.hasErrors = true;
        	system.debug('***Exception on Upsert of UR : '+e);
        	// add Error message to VF
        	string consoludatedMessge;
        	String exceptionString = e.getMessage();
        	if(exceptionString.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
        		consoludatedMessge = exceptionString.subString(exceptionString.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,'));
        		consoludatedMessge = consoludatedMessge.replace('FIELD_CUSTOM_VALIDATION_EXCEPTION,','');
        		consoludatedMessge = consoludatedMessge.replace(': []',''); 
        	}else{
        		consoludatedMessge = e.getMessage() +'.<br/> Please contact Administrator to resolve the above issue.';
        	}
        	//consoludatedMessge += ;
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,consoludatedMessge));
        	return null;
        }
    }
    
    private Update_Request__c populateParentAccount (Update_Request__c updateRequest){
		if(updateRequest.Parent_Account__c != null){
			updateRequest.New_Parent_Account__c = updateRequest.Parent_Account__c;
			Account parentAccount = [SELECT ID, Name from Account Where ID=:updateRequest.New_Parent_Account__c];
			updateRequest.Parent_Account__c = parentAccount.Name;
		}
    		return updateRequest;
    }

    private void buildFieldWrapper(){
        this.fieldWrapperMap = new map<String, FieldWrapper>();
        integer i = 0;
        for(String fieldAPI : relatedObjectsToFieldsMap.get(this.relatedObjectName)){
        	i++;
            Schema.DescribeFieldResult fieldDescribe = this.fieldsMap.get(fieldAPI).getDescribe();
            string keyValue = this.relatedObjectName+'.'+fieldAPI;
            string tempSpecialGroupName = relatedObjectsToSpecialFieldsMap.get(this.relatedObjectName).containsKey(fieldAPI) == true ? relatedObjectsToSpecialFieldsMap.get(this.relatedObjectName).get(fieldAPI):null;
            FieldWrapper tempFW = new FieldWrapper(false, fieldDescribe.getLabel(),fieldAPI, this.relatedRecord.get(fieldAPI), null, fieldDescribe.getInlineHelpText(), this.relatedObjectFieldTOUpdateRequestFieldMap.get(keyValue), fieldDescribe.getType(), i, relatedObjectsToSpecialFieldsMap.get(this.relatedObjectName).containsKey(fieldAPI), tempSpecialGroupName);
            //As we can not display grayed out previous values for the following field types, 
            //we avoid making them to null
            if(fieldDescribe.getType() != Schema.Displaytype.Picklist && fieldDescribe.getType() != Schema.Displaytype.Boolean && fieldDescribe.getType() != Schema.Displaytype.MultiPicklist && fieldDescribe.getType() != Schema.Displaytype.Reference){
	            	this.relatedRecord2.put(fieldAPI, null);	
	            	system.debug('*** nullfying field : '+fieldAPI);
            }
            
            system.debug(tempFW );
            this.fieldWrapperMap.put(fieldAPI, tempFW);
            this.fieldWrapperList.add(tempFW);
            
        }
        system.debug('***fieldWrapperMap : '+this.fieldWrapperMap);
    }
        
    public class FieldWrapper implements Comparable {
        public boolean selected {get; set;}
        public string fieldLable {get; set;}
        public string fieldAPIName {get; set;}
        public Schema.Displaytype fieldType {get; Set;}
        public object previousValue {get; set;}
        public object newValue {get; set;}
        public string helpText {get; set;}
        public string fieldAPIName_UR {get; set;}
        public boolean isSpecial {get; set;}
        public integer displayOrder {get; set;}        
        public String specialGroupName {get; set;}
        
        public FieldWrapper (boolean tempSelected, string tempFieldLable, string tempFieldAPIName, object tempPreviousValue, object tempNewValue, String tempHelpText, String tempfieldAPIName_UR, Schema.Displaytype tempFieldType, integer tempDisplayOrder, boolean tempIsSpecial, string tempSpecialGroupName){
            this.selected = tempSelected != null? tempSelected : false;
            this.fieldLable = tempFieldLable != null ? tempFieldLable : '';
            this.fieldAPIName = tempFieldAPIName != null ? tempFieldAPIName : '';
            this.previousValue = tempPreviousValue;
            this.newValue = tempNewValue;
            this.helpText = tempHelpText != null ? tempHelpText : '';
            this.fieldAPIName_UR = tempfieldAPIName_UR != null ? tempfieldAPIName_UR : '';
            this.fieldType = tempFieldType;
            this.isSpecial = tempIsSpecial == null? false : tempIsSpecial;
            this.displayOrder = tempDisplayOrder;
            this.specialGroupName = tempSpecialGroupName;
        }
        
        public integer compareTo(Object compareTo) {
	        FieldWrapper compareToEmp = (FieldWrapper)compareTo;
	        if (this.displayOrder == compareToEmp.displayOrder) 
	        	return 0;
	        if (this.displayOrder > compareToEmp.displayOrder) 
	        	return 1;
	        	
	        return -1;        
    	}
    }
    
    /*Special Functions*/
    public String displayMainCategory {
    	get{
    		system.debug('***this.displayMainCategory'+this.displayMainCategory);
    		if(this.displayMainCategory == null){
	    		if(this.relatedRecord2 != null){
	    			this.displayMainCategory = (String) this.relatedRecord2.get('Industry');
	    		}else{
	    			this.displayMainCategory = null;
	    		}
    		}
    		return this.displayMainCategory;
    	}
    	set;
    }
    public list<String> displaySubCategory {
    	get{
    		system.debug('***this.displaySubCategory '+this.displaySubCategory );
    		if(this.displaySubCategory==null){
    			if(this.relatedRecord2 != null){
	    			this.displaySubCategory = (String) this.relatedRecord2.get('Industry_Sub_Category__c')!=null?((String) this.relatedRecord2.get('Industry_Sub_Category__c')).split(';') : null;
	    		}else{
	    			this.displaySubCategory = null;
	    		}
    		}
    		return this.displaySubCategory;
    	}
    	set;
    }
    public list<String> displayMinorCategory {
    	get{
    		system.debug('***this.displayMinorCategory'+this.displayMinorCategory);
    		if(this.displayMinorCategory== null){
	    		if(this.relatedRecord2 != null){
	    			this.displayMinorCategory = (String) this.relatedRecord2.get('Industry_Minor_Category__c') != null ? ((String) this.relatedRecord2.get('Industry_Minor_Category__c')).split(';'):null;
	    		}else{
	    			this.displayMinorCategory = null;
	    		}
    		}
			return this.displayMinorCategory;
    	}
    	set;
    }
    
    private map<String, set<String>> mainCategoryToSubCategoryMap = new map<String, set<String>>();
    private map<String, set<String>> subCategoryToMinorCategoryMap = new map<String, set<String>>();
	
	private void populateIndustryMaps(){
		//this.displayMainCategory = new list<Selectoption>();
		list<Industry_Category_Mapping__c> allIndustryMapplingsList = new list<Industry_Category_Mapping__c>([Select Industry__c,Name,Minor_Category__c from Industry_Category_Mapping__c order by Industry__c]);
		for(Industry_Category_Mapping__c iCM : allIndustryMapplingsList){
			//Populate mainCategoryToSubCategoryMap
			if(!mainCategoryToSubCategoryMap.containsKey(iCM.Industry__c)){
				mainCategoryToSubCategoryMap.put(iCM.Industry__c, new set<String>());
			}
			mainCategoryToSubCategoryMap.get(iCM.Industry__c).add(iCM.Name);
			
			//Populate subCategoryToMinorCategoryMap
			if(!subCategoryToMinorCategoryMap.containsKey(iCM.name)){
				subCategoryToMinorCategoryMap.put(iCM.name, new set<String>());
			}
			subCategoryToMinorCategoryMap.get(iCM.name).addAll(iCM.Minor_Category__c.split(';'));
		}
	}	
    
    public list<Selectoption> getDisplayMainCategoryOptions(){
    	list<String> tempMainCategoryList = new list<String>();
		tempMainCategoryList.AddAll(mainCategoryToSubCategoryMap.keySet());
		tempMainCategoryList.sort();
		list<Selectoption> displayMainCategory = new list<Selectoption>();
		//populate displayMainCategory options list 
		for(String s : tempMainCategoryList){
			displayMainCategory.add(new Selectoption(s,s));
		}
		return displayMainCategory;
    }
    
    public list<Selectoption> getDisplaySubCategoryOptions(){
    	list<Selectoption> displaySubCategory = new list<Selectoption> ();
    	string accountMainCategory = this.displayMainCategory;
    	//populating displayMinorCategory
		if(accountMainCategory != null){
			list<String> tempSubCategoryList = new list<String>();
			tempSubCategoryList.AddAll(mainCategoryToSubCategoryMap.get(accountMainCategory));
			tempSubCategoryList.sort();
			for(String s:tempSubCategoryList){
				displaySubCategory.add(new Selectoption(s,s));
			}
		}
		return displaySubCategory;
    }
    
    public list<Selectoption> getDisplayMinorCategoryOptions(){
    	list<Selectoption> displayMinorCategory = new list<Selectoption>();
    	list<string> accountSubCategory = this.displaySubCategory;
    	
		if(accountSubCategory != null){
			list<String> tempMinorCategoryList = new list<String>();
			for(String sub : accountSubCategory){ 
				set<String> tempList = subCategoryToMinorCategoryMap.get(sub);
				if(tempList != null){
					for(String tempMinor : tempList){
						if(tempMinor!= null)
						tempMinorCategoryList.addAll(tempMinor.split(';'));
					}
				}
			}
			tempMinorCategoryList.sort();
			for(String s : tempMinorCategoryList){
				displayMinorCategory.add(new Selectoption(s,s));
			}
		}
    	return displayMinorCategory; 
    } 
    
    public void saveIndustryChanges(){
	    	system.debug('***this.displayMainCategory : '+this.displayMainCategory+'***this.displaySubCategory'+this.displaySubCategory+'***this.displayMinorCategory : '+this.displayMinorCategory);
	    	boolean isChanged = false;
	    	String errorMessage = 'There are no changes to '+this.currentSpecialAction+' values. <br/> You must either change the values or deselect the check boxes.';
	    	
	    	if(!isChanged && (String) this.relatedRecord.get('Industry')!=null && this.displayMainCategory != (String) this.relatedRecord2.get('Industry'))
	    		isChanged = true;
	    	if(!isChanged && ((String) this.relatedRecord.get('Industry_Sub_Category__c')) != null ){
	    		list<String> tempValues = ((String) this.relatedRecord.get('Industry_Sub_Category__c')).split(';');
	    		tempValues.sort();
	    		isChanged = this.displaySubCategory != tempValues;
	    	}
	    	if(!isChanged && ((String) this.relatedRecord.get('Industry_Minor_Category__c')) != null ){
	    		list<String> previousValues = ((String) this.relatedRecord.get('Industry_Minor_Category__c')).split(';');
	    		previousValues.sort();
	    		isChanged = this.displayMinorCategory != previousValues;
	    	}
	    	
	    	if(!isChanged){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMessage));
	    		this.hasErrors = true;
	    		return;
	    	}
	    	
	    	this.relatedRecord2.put('Industry', this.displayMainCategory);
	    	//sub category string
	    	String subCategory = '';
	    	for(String s : this.displaySubCategory){
	    		subCategory += s+';';
	    	}
	    	this.relatedRecord2.put('Industry_Sub_Category__c', subCategory);
	    	//minor category 
	    	String minorCategory = '';
	    	for(String s : this.displayMinorCategory){
	    		minorCategory += s+';';
	    	}
	    	this.relatedRecord2.put('Industry_Minor_Category__c', minorCategory);
	    	this.currentSpecialAction = null;
    }
}