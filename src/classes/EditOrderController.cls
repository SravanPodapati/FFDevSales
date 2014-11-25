public with sharing class EditOrderController {
	public Order order;
	public String url {
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
	public String errorMessage {
		get;
		set;
	}
	public String authCode {
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

   /* public Flow.Interview.SelectCCIGroupAndProfile selectCCIGroupAndProfile {
        get;
        set;
    }*/
    
	public void editOrder() {
		renderPlugin = true;
		OrderParams__c cciOrderParams = Common.cciOrderParams;

		try {
			System.debug('before calling CCIManager....OrderId is ' + this.order.id);
			url = CCIManager.editAccountOrder(this.order.id, cciProfile, cciGroup);
			if (!String.isBlank(authCode)) {
				url += cciOrderParams.AuthCode__c + authCode + cciOrderParams.ClientId__c;
			}
			System.debug('URL generated is' + url);

		} catch (Exception e) {
			System.debug('An exception has occured' + e);
			renderPlugin = false;
			renderError = true;
			errorMessage = Label.CCI_Exception;

			ApexPages.addMessages(e);
		}


		System.debug('URL genarated is' + url);

	}

	public EditOrderController(ApexPages.StandardController controller) {

		this.order = (Order) controller.getRecord();
		system.debug('Order id is : ' + this.order);
        
		cciGroup = apexpages.currentpage().getparameters().get('group');
        cciProfile = apexpages.currentpage().getparameters().get('profile');        
        if(cciProfile!=null)
            cciProfile =cciProfile.replace( ';',' '); 
        if(cciGroup!=null)
            cciGroup =cciGroup.replace( ';',' ');        
        
		BookingSystemSettings__c setting = Common.cci;
		if (setting == null) {
			throw new BookingSystemSettingsException();
		}
		String oAuthEndpoint = setting.Domain__c + setting.AuthPath__c;
		System.debug('AuthEndpoint is..' + oAuthEndpoint);
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint(oAuthEndpoint);
		String username = setting.ClientId__c;
		String password = setting.SharedSecret__c;

		if (!String.isBlank(username) && !String.isBlank(password)) {

			Blob headerValue = Blob.valueOf(username + ':' + password);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			System.debug('AuthorizationHeader is' + authorizationHeader);
			req.setHeader('Authorization', authorizationHeader);

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
}