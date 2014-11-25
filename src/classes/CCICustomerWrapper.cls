public class CCICustomerWrapper {


	public String name;
	public String addressAs;
	public String initials;
	public String surname;
	public String companyName;
	public Telephone mainTelephone;
	public Address mainAddress;
	public BusinessUnit businessUnit;
	public CustomerCategoryExt customerCategory;
	public String externalCustomerId;
	public IndustryCodes industryCodes;


	public CCICustomerWrapper() {}

	public CCICustomerWrapper(Account acc, String dbType) {
		if (acc.Type.equals('Private Advertiser')) {
			this.addressAs = acc.Salutation__c;
			this.initials = acc.FirstName__c;
			this.surname = acc.Name;
		} else {
			this.companyName = acc.name;
		}
		this.name = acc.name;

		this.externalCustomerId = acc.id;
		List < String > minorCategories = new List < String > ();
		List < IndustryCode > codes = new List < IndustryCode > ();
		//try{
		if (!String.isBlank(acc.Industry_Minor_Category__c)) {
			minorCategories = acc.Industry_Minor_Category__c.split(';');
			System.debug('Minor categories list' + minorCategories);
			for (String s: minorCategories) {
				IndustryCode c = new IndustryCode(s.split('-')[0].trim());
				codes.add(c);
			}
		}

		if (codes.size() > 0) {
			this.industryCodes = new IndustryCodes(codes);
		}
		CustomerCategory__c categories;


		if (acc.Type.contains('Agency') && !acc.Type.contains('Holding Agency')) {
			if (acc.NPA__c) categories = CustomerCategory__c.getInstance('NPA');
			else categories = CustomerCategory__c.getInstance('NonNPA');
		} else categories = CustomerCategory__c.getInstance(acc.Type);

		this.mainAddress = new Address(acc.BillingStreet, 'UK', acc.BillingCity, acc.BillingCountry, acc.BillingPostalCode, acc.BillingState);
		this.MainTelephone = new Telephone(acc.Phone);

		if (dbType == 'Mail') {
			this.businessUnit = new BusinessUnit('ML');

		} else {
			this.businessUnit = new BusinessUnit('Global');

		}
		if (categories != null) this.customerCategory = new CustomerCategoryExt(categories.CategoryCode__c);
		else {
			throw new CCIApiException('Customer Category does not exist for this account type');
		}
		/*   }catch(Exception e){
               throw new CCIApiException(e)  ;
               }*/
	}

	public class CustomerCategoryExt {
		public String categoryCode;
		public String categoryName;
		public String categoryDesc;
		public CustomerCategoryExt() {}
		public CustomerCategoryExt(String categoryCode) {
			this.categoryCode = categoryCode;
		}
	}

	public class BusinessUnit {
		String businessUnitCode;
		String businessUnitName;
		String businessUnitDesc;

		public BusinessUnit() {}
		public BusinessUnit(String businessUnitCode) {
			this.businessUnitCode = businessUnitCode;
		}

	}

	public class Address {

		//   public String streetAddress;
		public String city;
		public String county;
		public String zipCode;
		public String countryCode;
		public String countryName;
		// public String roomNo;
		public String collection1;

		public Address() {}
		public Address(String streetAdd, String countryCode, String billingCity, String countryName, String zipCode, String billingState) {
			// this.streetAddress = streetAdd;
			//  this.roomNo = streetAdd;

			this.collection1 = streetAdd;
			BookingSystemCountryCodes__c cciCountry = new BookingSystemCountryCodes__c();
			/*try
		        {*/
			if (String.IsBlank(countryName) || countryName == 'UK' || countryName == 'England' || countryName == 'Wales' || countryName == 'Scotland') {
				countryName = 'United Kingdom';
			}
			cciCountry = BookingSystemCountryCodes__c.getInstance(countryName);
			if (cciCountry == null) {
				throw new CCIApiException('Invalid Country - ' + countryName);
			}

			/*}
		        catch(Exception e)
		        {
		        	throw new CCIApiException ('Invalid Country - '+countryName);	
		        }*/


			//this.countryCode = countryCode;
			//this.countryName = countryName;
			this.countryCode = cciCountry.CountryCode__c;
			//this.countryCode = countryCode;
			this.countryName = countryName;
			this.zipCode = zipCode;
			this.city = billingCity;
			this.county = billingState;
		}
	}
	public class Telephone {

		public String id;
		public String phNumber;
		public String description;
		public Telephone() {}
		public Telephone(String phNumber) {
			this.phNumber = phNumber;
		}
	}


	public class IndustryCodes {
		//String partiallink = null;
		List < IndustryCode > industryCode;

		public IndustryCodes() {}
		public IndustryCodes(List < IndustryCode > industryCode) {
			this.industryCode = industryCode;

		}

	}

	public class IndustryCode {
		String code;
		public IndustryCode() {}
		public IndustryCode(String code) {
			this.code = code;
		}

	}

	public class AccountInfo {
		public Id accountId {
			get;
			set;
		}
		public String name {
			get;
			set;
		}
		public String phone {
			get;
			set;
		}
		public String billingStreet {
			get;
			set;
		}
		public String billingCity {
			get;
			set;
		}
		public String billingPostalCode {
			get;
			set;
		}
		public String billingState {
			get;
			set;
		}
		public String billingCountry {
			get;
			set;
		}
		public String industry_Minor_Category {
			get;
			set;
		}
		public String cciMailId {
			get;
			set;
		}
		public String cciMetroId {
			get;
			set;
		}
		public Boolean npa {
			get;
			set;
		}
		public String accountType {
			get;
			set;
		}
		public String firstName {
			get;
			set;
		}
		public String salutation {
			get;
			set;
		}

		public AccountInfo(Id accId, String n, String ph, String bs, String bc, String bp, String bstate, String bco, String im, String cma, String cme, Boolean npa, string tempType, String tempFirstName, String tempSalutation) {
			this.accountId = accId;
			this.name = n;
			this.phone = ph;
			bs = bs != null && bs != '' ? bs.replaceAll('\r', ' ') : '';
			bs = bs != null && bs != '' ? bs.replaceAll('\n', ' ') : '';
			this.billingStreet = bs;
			this.billingCity = bc;
			this.billingPostalCode = bp;
			this.billingState = bstate;
			this.billingCountry = bco;
			this.industry_Minor_Category = im;
			this.cciMailId = cma;
			this.cciMetroId = cme;
			this.npa = npa;
			this.accountType = tempType;
			this.firstName = tempFirstName;
			this.salutation = tempSalutation;
		}
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

	/*public class IntegInfo
    {
        public String source {get; set;}
        public String account {get; set;}
        public String description {get; set;}

        public IntegInfo(String src, String acc, String descrip)
        {
            this.source=src;
            this.account=acc;
            this.description=descrip;
        
        }
    }*/

	public class ChatterInfo {
		public Id itemID {
			get;
			set;
		}
		public String message {
			get;
			set;
		}

		public ChatterInfo(Id itemID, String message) {
			this.itemID = itemID;
			this.message = message;
		}
	}
}