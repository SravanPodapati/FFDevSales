/**
 *    This is a template for custom fixtures, the existense and name of the class are irrelevant.
 *	Class name can be anything, but by default if class MockData exists then Mock will load it, unless told otherwise
 *	via Mock.MOCK_DATA variable assignment
 *
 */@isTest
public with sharing class MockData extends MockDataStandard {
	private static Map < String, Map < String, Object >> DEFAULT_VALUES_BY_TYPE = new Map < String, Map < String, Object >> ();

	public MockData() {
		super();
		addSingletonObjectType('Constants__c');
	}
	private static void setup() {}
	//add your own (new) fixture definitions here and then add their initialisation in the static section below


	//EXAMPLE
	//public static Map<String, Object> ORDER_LINE_VALUES = new Map<String, Object> {
	//	'Field_name__c' => 'value'
	//};

	//if you want to extend or overrdide standard fixture defined in MockDataStandard then do it here as well
	//EXAMPLE
	//public static Map<String, Object> ACCOUNT_VALUES = new Map<String, Object> {
	//	'Name' => 'My New Acount Name Value#{COUNTER}',//override Name definition specified in MockDataStandard
	//	'My_Field__c' => 5, //add definition for a custom field
	//	Mock.DEPENDS_ON => new Map<String, String>{'AccountId' => 'Account'} //add dependency on parent/related object
	//};

	public static Map < String, Object > CONSTANTS_VALUES = new Map < String, Object > {
		'Name' => 'All',
			'Advertiser_Record_Type__c' => 'Advertiser',
			'Agency_Record_Type__c' => 'Agency',
			'Creative_Snapshot_URL__c' => 'http://www.addynamix.co.uk/Press/Alerts/CreativeSnapshot.aspx',
			'CustomerRef1email__c' => 'ssfoperative@anmedia.co.uk.test',
			'CustomerRef2email__c' => 'ssfoperative@anmedia.co.uk.test',
			'CustomerRef3email__c' => 'ssfoperative@anmedia.co.uk.test',
			'CustomerRef4email__c' => 'ssfoperative@anmedia.co.uk.test',
			'CustomerRef5email__c' => 'ssfoperative@anmedia.co.uk.test',
			'Media_Lead_Opp_Record_Type__c' => 'Media_Opportunities',
			'Media_Partner_Record_Type__c' => 'Media_Partner',
			'Regular_Opp_Record_Type__c' => 'New_Business',
			'Wowcher_Lead_Owner__c' => 'Some Test User'
	};

	public static Map < String, Object > CAMPAIGN_VALUES = new Map < String, Object > {
		'Name' => 'Campaign #{COUNTER}',
			'IsActive' => true,
			'Status' => 'Planned',
			'Type' => 'Advertisement',
			'CurrencyIsoCode' => 'GBP',
			'StartDate' => System.today() - 365,
			'EndDate' => System.today() + 365
	};
	public static Map < String, Object > ACCOUNT_ADVERTISER_VALUES = new Map < String, Object > {
		'Name' => 'Advertiser #{COUNTER}',
			'RecordTypeId' => MockUtils.getRecordType('Account', 'Advertiser').Id,
			'Type' => 'Test Type',
			'IsActive__c' => true,
			'BillingStreet' => 'Advertiser Street',
			'BillingPostalCode' => 'A111AA',
			'Phone' => '0123654789'
	};
	public static Map < String, Object > ACCOUNT_DIRECT_ADVERTISER_VALUES = new Map < String, Object > {
		'Name' => 'Advertiser #{COUNTER}',
			'RecordTypeId' => MockUtils.getRecordType('Account', 'Advertiser').Id,
			'Type' => 'Direct Advertiser',
			'IsActive__c' => true,
			'BillingStreet' => 'Advertiser Street',
			'BillingPostalCode' => 'A111AA',
			'Phone' => '0123654789'
	};
	public static Map < String, Object > ACCOUNT_AGENCY_VALUES = new Map < String, Object > {
		'Name' => 'Agency #{COUNTER}',
			'RecordTypeId' => MockUtils.getRecordType('Account', 'Agency').Id,
			'Type' => 'Billing Agency',
			'IsActive__c' => true,
			'Phone' => '000000',
			'BillingStreet' => 'Agency Street',
			'BillingPostalCode' => 'A111AA',
			'Phone' => '0123654789'
	};

	public static Map < String, Object > OPPORTUNITY_VALUES = new Map < String, Object > {
		'StageName' => 'Prospecting',
			'CloseDate' => System.today(),
		Mock.DEPENDS_ON => new Map < String, String > {
			'AccountId' => 'Account#DirectAdvertiser'
		}
	};

	public static Map < String, Object > AGENCY_ADVERTISER_RELATIONSHIP_VALUES = new Map < String, Object > {
		'Name' => 'Agency <-> Advertiser #{COUNTER}',
			'Active__c' => true,
			'Role__c' => 'Creative',
			'Visibility__c' => 'Group - read/write',
		Mock.DEPENDS_ON => new Map < String, String > {
			'Account_A__c' => 'Account#Agency', 'Account_B__c' => 'Account#Advertiser'
		}
	};
	public static Map < String, Object > ADVERTISER_AGENCY_RELATIONSHIP_VALUES = new Map < String, Object > {
		'Name' => 'Agency <-> Advertiser #{COUNTER}',
			'Active__c' => true,
			'Role__c' => 'Creative',
			'Visibility__c' => 'Group - read/write',
		Mock.DEPENDS_ON => new Map < String, String > {
			'Account_B__c' => 'Account#Agency', 'Account_A__c' => 'Account#Advertiser'
		}
	};

	public static Map < String, Object > PRICEBOOK_VALUES = new Map < String, Object > {
		'Name' => 'Pricebook #{COUNTER}',
			'IsActive' => true
	};
	public static Map < String, Object > PRODUCT2_VALUES = new Map < String, Object > {
		'Name' => 'Product #{COUNTER}',
		/*'CurrencyIsoCode' => 'GBP',*/
		'IsActive' => true
	};

	public static Map < String, Object > PRICEBOOKENTRY_VALUES = new Map < String, Object > {
		'CurrencyIsoCode' => 'GBP',
			'UnitPrice' => 0.0,
			'IsActive' => true,
			'UseStandardPrice' => false,
		Mock.DEPENDS_ON => new Map < String, String > {
			'Pricebook2Id' => 'Pricebook2', 'Product2Id' => 'Product2'
		}
	};

	public static map < String, Object > ORDER_VALUES = new map < String, Object > {
		'EffectiveDate' => System.Today(),
			'Booking_Source__c' => 'CCIBookingPlugin',
			'Status' => 'Draft',
			'First_Delivery_Date__c' => System.Today(),
			'Last_Delivery_Date__c' => System.today(),
			'CurrencyIsoCode' => 'GBP',
			'Base_Price__c' => 0.0,
			'CCI_Order_ID__c' => 'Test#{COUNTER}',
			'CCI_Account_ID__c' => 'TestCCIAccountID#{COUNTER}',
		Mock.DEPENDS_ON => new Map < String, String > {
			'AccountID' => 'Account#Advertiser', 'Opportunity__c' => 'Opportunity'
		}
	};

	public static map < String, Object > ORDERLINEITEM_VALUES = new map < String, Object > {
		'Publication_Name__c' => 'test brand',
			'UnitPrice' => 100,
			'Quantity' => 1,
			'CCI_Order_Item_ID__c' => 'TestOrderItemID#{COUNTER}'
	};

	static {

		setup();
		//all fixture maps specified above need to be added here

		DEFAULT_VALUES_BY_TYPE.put('Constants__c', CONSTANTS_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Campaign', CAMPAIGN_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Opportunity', OPPORTUNITY_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Account#Advertiser', ACCOUNT_ADVERTISER_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Account#DirectAdvertiser', ACCOUNT_DIRECT_ADVERTISER_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Account#Agency', ACCOUNT_AGENCY_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Relationship__c#AgencyAdvertiser', AGENCY_ADVERTISER_RELATIONSHIP_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Relationship__c#AdvertiserAgency', ADVERTISER_AGENCY_RELATIONSHIP_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Pricebook2', PRICEBOOK_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Product2', PRODUCT2_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('PricebookEntry', PRICEBOOKENTRY_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('Order', ORDER_VALUES);
		DEFAULT_VALUES_BY_TYPE.put('OrderItem', ORDERLINEITEM_VALUES);
	}

	public override Map < String, Object > getValueMap(final String objApiName, final Map < String, Object > fieldValues) {
		return MockData.DEFAULT_VALUES_BY_TYPE.get(objApiName);
	}

	public static User getTestUserWithConstantsH(String profileName, String department) {
		return getTestUserWithConstantsH(profileName, department, null);
	}
	public static User getTestUserWithConstantsH(String profileName, String department, String priceBookName) {
		Profile p = MockUtils.getProfile(profileName);
		System.assertNotEquals(null, p, 'Invalid profile name: ' + profileName);
		User usr = (User) Mock.one('User', new Map < String, Object > {
			'ProfileId' => p.Id
		}, true);
		//if SeeAllData=true is used then delete existing setting
		final ConstantsH__c chExisting = ConstantsH__c.getInstance(usr.ProfileId);
		if (null != chExisting && null != chExisting.Id) {
			Database.delete(chExisting);
		}

		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = usr.lastname;
		ch.Department__c = department;
		ch.IsManager__c = false;
		if (null != priceBookName) {
			ch.Price_Book__c = priceBookName;
		}
		ch.SetupOwnerId = usr.ProfileId;
		System.debug('agX ch=' + ch);

		Database.insert(ch);
		if (BookingSystemSettings__c.getAll().get('CCI') == null) {
			insert TestData.createBookingSystemSettings();
		}
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();

		return usr;
	}
}