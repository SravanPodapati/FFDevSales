public class ResultWrapper {
	public boolean hasMessages {get; set;}
	public list<errorMessages> errors {get; set;}
	public String URL {get; set;}
	
	public ResultWrapper (){
		this.hasMessages = false;
		this.errors = new list<errorMessages>();
		this.URL = null;
	}
	
	public ResultWrapper (String tempURL){
		this.URL = tempURL;
		this.errors = null;
		this.hasMessages = false;
	}
	
	public ResultWrapper (list<ErrorMessages> tempErrors){
		this.URL = null;
		this.errors = tempErrors;
		this.hasMessages = true;
	}
	
	public ResultWrapper (Exception ex, ApexPages.severity tempSeverity){
		ErrorMessages eM = new ErrorMessages(tempSeverity, new list<String>());
		em.errorMessages.add(handelExceptionMessage(ex.getMessage()));
		list<ErrorMessages> tempErrors = new list<ErrorMessages>();
		tempErrors.add(eM);
		
		this.URL = null;
		this.errors = tempErrors;
		this.hasMessages = true;
	}
	
	public class ErrorMessages{
		public ApexPages.severity severity {get; set;}
		public list<String> errorMessages {get; set;}
		
		/*Constructer with values*/
		public ErrorMessages(ApexPages.Severity tempSeverity, list<String> tempErrorMessges){
			this.severity = tempSeverity;
			this.errorMessages = tempErrorMessges;
		}
		/*constructer with out any values*/
		public ErrorMessages(){
			this.severity = null;
			this.errorMessages = new list<String>();
		}
	}
	
	private String handelExceptionMessage(String exceptionMessage){
		list<String> predefinedExceptions = new list<String>{'FIELD_CUSTOM_VALIDATION_EXCEPTION', 'FIELD_INTEGRITY_EXCEPTION'};
		String result;
		for(String s : predefinedExceptions){
			if(exceptionMessage.contains(s)){
				result = exceptionMessage.subString(exceptionMessage.indexOf(s+','));
	    		result = result.replace(s+',','');
	    		break;
			}	
		}
		
		if(result != null){
			if(result.indexOf(': [')>0)
    			result = result.subString(0, result.indexof(': ['));
		}else{
			result = exceptionMessage;
		}
		
		return result;
	}
	
	public ResultWrapper addErrorMessage(ResultWrapper rW, ApexPages.Severity tempSeverity, list<String> tempErrorMessges){
		rW.errors.add(new ErrorMessages(tempSeverity, tempErrorMessges));
		rW.hasMessages = true;
		return rW;
	}
	
	public ResultWrapper addErrorMessage(ResultWrapper rW, ApexPages.Severity tempSeverity, String tempErrorMessge){
		list<String> tempErrorMessges = new list<String>();
		tempErrorMessges.add(tempErrorMessge);
		rW.hasMessages = true;
		return addErrorMessage(rW, tempSeverity, tempErrorMessges);
	}
	
	public ResultWrapper addExceptionMessage(ResultWrapper rW, ApexPages.Severity tempSeverity, Exception e){
		return addErrorMessage(rW, tempSeverity, handelExceptionMessage(e.getMessage()));
	}
	
	public map<string, integer> groupedMessagesSize { get; set; } 
	
	public map<String, list<String>> getGroupedPageMessages(){
		this.groupedMessagesSize = new map<string, integer> (); 
		map<String, list<String>> resultMap = new map<string, list<String>>();
		for(ErrorMessages eM: this.errors){
			String key;
			if(eM.severity == ApexPages.Severity.ERROR){
				key='Error';
			}else if(eM.severity == ApexPages.Severity.CONFIRM){
				key='Success';
			}else if(eM.severity == ApexPages.Severity.WARNING){
				key='Warning';
			}else if(eM.severity == ApexPages.Severity.FATAL){
				key='Error';
			}else if(eM.severity == ApexPages.Severity.INFO){
				key='Message';
			}
			if(!resultMap.containsKey(key)){
				resultMap.put(key, new list<String>());
			}
			resultMap.get(key).addAll(eM.errorMessages);
			this.groupedMessagesSize.put(key, resultMap.get(key).size());
		}
		
		return resultMap; 
	}
}