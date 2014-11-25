public with sharing class CCIAccountCreation {

	public FinanceAccount__c acc;


	public CCIAccountCreation() {}
	public CCIAccountCreation(FinanceAccount__c acc) {
		this.acc = acc;

	}
	public CCIAccountCreation(FinanceAccount__c acc, String customerId, String dbType) {
		System.debug('Entered CCIAccountCreation and Acc is' + acc);
		this.acc = acc;


	}

	public String getReqJsonBody() {
		System.debug('Inside getReqJsonBody');
		String retVal;
		retVal = Json.serialize(new CCIAccountWrapper(acc));
		System.debug('before exiting getReqJsonBody' + retVal);
		return retVal;
	}

	public class AccountInfo {
		public Id accountId {
			get;
			set;
		}
		public String sopId {
			get;
			set;
		}

		public AccountInfo(Id accId, String sopId) {
			this.accountId = accId;
			this.sopId = sopId;

		}
	}


	public class CCIAccountWrapper {

		public Owner owner;
		public ExternalIds externalIds;
		public BusinessUnit businessUnit;
		public String financeId;
		// public PaymentTerm  paymentTerm;
		// public CollectionMethod collectionMethod;



		public CCIAccountWrapper() {}
		public CCIAccountWrapper(FinanceAccount__c acc) {

			if (acc.Company__r.Name.contains('Mail')) {
				this.owner = new Owner(acc.CCIMailCustomerID__c);
				this.BusinessUnit = new BusinessUnit('ML');
			} else if (acc.Company__r.Name.contains('Metro')) {
				this.owner = new Owner(acc.CCIMetroCustomerID__c);
				this.BusinessUnit = new BusinessUnit('Global');
			}
			this.ExternalIds = new ExternalIds(acc.Id);
			if (acc.Neo_ID__c != null || acc.Neo_ID__c != '') this.financeId = acc.Neo_ID__c;
			//  this.paymentTerm = new PaymentTerm('PREPAYMENT');
			// this.collectionMethod = new CollectionMethod('Prepay');




		}
	}






	/*public class PaymentTerm{
    public String code;
    public PaymentTerm(){}
    public PaymentTerm(String code){this.code = code;}
    }
public class CollectionMethod{
    public String code;
    public CollectionMethod(){}
    public CollectionMethod(String code){this.code = code;}
    }
*/

	public class Owner {
		public String customerId;

		public Owner() {}
		public Owner(String cusId) {
			this.customerId = cusId;
		}
	}
	public class BusinessUnit {

		String businessUnitCode;

		public BusinessUnit() {}
		public BusinessUnit(String code) {

			this.businessUnitCode = code;
		}


	}

	public Class ExternalIds {


		public List < ExternalId > externalId = new List < ExternalId > ();
		public ExternalIds() {}
		public ExternalIds(String id) {
			externalId.add(new ExternalId(id));
		}


	}


	public Class ExternalId {


		public String id;
		public String ExternalSystem;
		public ExternalId() {}
		public ExternalId(String Id) {
			this.ExternalSystem = 'Salesforce';
			this.id = Id;

		}
	}



}