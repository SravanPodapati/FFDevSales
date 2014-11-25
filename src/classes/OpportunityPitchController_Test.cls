/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2013-11-08 11:43:04 
 *  @description:
 *      Test methods for OpportunityPitchController
 *  
 *  Version History :   
 *      
 */@isTest(SeeAllData = true) //There's no way to create a Standard Price Book in Apex, hence SeeAllData=true
public class OpportunityPitchController_Test {
	private static Pricebook2 stdPricebook;
	private static List < PricebookEntry > stdPBEntries;
	static {
		//standard price book and product prices
		stdPricebook = [select id from Pricebook2 where isStandard = true];
		stdPBEntries = Mock.many('PricebookEntry', new Map < String, Object > {
			'UnitPrice' => new Decimal[] {
				1, 2, 3
			},
				'Pricebook2Id' => stdPricebook.Id
		}, 3, true);
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
	}
	/**
	 * Jira: Gl-10
	 * check when loading from Advertiser account
	 */
	static testMethod void testAsAsvertiser() {

		Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

		//create pricebook
		Pricebook2 pricebook = (Pricebook2) Mock.one('Pricebook2', true);

		String department = 'Test Dep 1';
		User usr = MockData.getTestUserWithConstantsH('System Administrator', department, pricebook.Name);
		List < User > teamMembers = Mock.many('User', new Map < String, Object > {
			'LastName' => 'Member #{COUNTER}',
				'ProfileId' => MockUtils.getProfile('System Administrator').Id
		}, 3, true);

		System.runAs(usr) {

			//create couple of Agency <-> Advertiser relationships
			List < Relationship__c > rels = Mock.many('Relationship__c#AdvertiserAgency', 2, true);
			final Id advertiser_Id = rels[0].Account_A__c;
			final Id agency_Id = rels[0].Account_B__c;

			//campaigns must belong to selected advertiser
			List < Campaign > campaigns = Mock.many('Campaign', new Map < String, Object > {
				'Account__c' => advertiser_Id
			}, 3, true);

			//add few products
			List < PricebookEntry > pbes = Mock.many('PricebookEntry', new Map < String, Object > {
				'UnitPrice' => new Decimal[] {
					10, 20, 30
				},
					'Product2Id' => Mock.toIds(stdPBEntries, 'Product2Id')
			}, 3, true);


			PageReference ref = Page.OpportunityPitch;
			Test.setCurrentPage(ref);
			Account acc = new Account(Id = advertiser_Id, Name = 'Acc1',
			RecordType = MockUtils.getRecordType('Account', 'Advertiser'));
			OpportunityPitchController con = new OpportunityPitchController(new ApexPages.StandardController(acc));
			test.startTest();
			Opportunity opp = con.getOpportunity();
			System.assertEquals(usr.Id, opp.OwnerId, 'Owner Id must be set to current user');
			System.assertEquals(advertiser_Id, opp.AccountId, 'Advertiser must not be blank, because there is existing relationship');
			System.assertEquals(agency_Id, opp.Agency__c, 'Agency must not be blank, because there is existing relationship');


			//following methods are difficult to verify for exact results because we have to work in SeeAllData environment
			System.assert(con.getCampaigns().size() >= campaigns.size(), 'Expected at least ' + campaigns.size() + ' campaigns');
			System.assert(con.getAdvertisers().size() > 0, 'Expected at least one Advertiser');
			System.assert(con.getAgencies().size() > 0, 'Expected at least one Agency');
			System.assert(con.getProductIconRows().size() > 0, 'Expected at least one product icon row');
			System.assert(OpportunityPitchController.getProductsByIcon(OpportunityPitchController.NO_ICON).size() >= 3,
				'Expected at least 3 products, because this many we created above');

			System.assert(OpportunityPitchController.getAvailableUserMap().size() >= 1, 'Expected some users');


			opp.CloseDate = Date.newInstance(2013, 01, 09);
			opp.Name = 'Test Opp';

			String productJSON = '';
			//'[{"pbeId":"01tD0000002McPgIAK", "id":"01tD0000002McPgIAK","name":"Daily Mail newspaper - Advertorials","amount":1,"startDate":"10/01/2013, 10/02/2013,...", "endDate":"10/01/2013"}]'
			for (PricebookEntry pbe: pbes) {
				String val = '';
				val += '"pbeId":"' + pbe.Id + '",';
				val += '"id":"' + pbe.Id + '",';
				val += '"name":" not used ",';
				val += '"startDate":"10/01/2013",';
				val += '"endDate":"11/01/2013",';
				val += '"amount":10';
				if ('' != productJSON) {
					productJSON += ',';
				}
				productJSON += '{' + val + '}';
			}
			con.productDataJSON = '[' + productJSON + ']';

			con.teamMemberIds = String.join(Mock.toIds(teamMembers), ',');
			con.selectedAdvertiserId15 = advertiser_Id;
			con.selectedAgencyId15 = agency_Id;
			con.selectedCampaign15 = campaigns[0].Id;
			System.assertEquals(advertiser_Id, con.selectedAdvertiserId15);
			System.assertEquals(agency_Id, con.selectedAgencyId15);
			System.assertEquals(campaigns[0].Id, con.selectedCampaign15);

			con.save();
			if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
				//check if this is about "scheduling not enabled on product" or something else
				for (ApexPages.Message msg: ApexPages.getMessages()) {
					if (msg.getDetail().contains('scheduling not enabled on product')) {
						continue; //can safely ignore this message
					}
					System.assert(false, 'Did not expect any errors, but got this: ' + msg + '; productJSON=' + productJSON);
				}

			}
			//just code coverage for methods not containing any logic
			con.getUserLocale();
			con.cancel();
			con.reloadCampaigns();
			con.getAdvertiserType();
			test.stopTest();
		}
	}
	/**
	 * Jira: Gl-10
	 * check when loading from Agency account
	 */
	static testMethod void testAsAgency() {

		Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

		//create pricebook
		Pricebook2 pricebook = (Pricebook2) Mock.one('Pricebook2', true);

		String department = 'Test Dep 1';
		User usr = MockData.getTestUserWithConstantsH('System Administrator', department, pricebook.Name);

		System.runAs(usr) {

			//create couple of Agency <-> Advertiser relationships
			List < Relationship__c > rels = Mock.many('Relationship__c#AdvertiserAgency', 2, true);

			//add few products
			List < PricebookEntry > pbes = Mock.many('PricebookEntry', new Map < String, Object > {
				'UnitPrice' => new Decimal[] {
					10, 20, 30
				},
					'Product2Id' => Mock.toIds(stdPBEntries, 'Product2Id')
			}, 3, true);

			final Id advertiser_Id = rels[0].Account_A__c;
			final Id agency_Id = rels[0].Account_B__c;

			PageReference ref = Page.OpportunityPitch;
			Test.setCurrentPage(ref);
			Account acc = new Account(Id = agency_Id, Name = 'Acc1',
			RecordType = MockUtils.getRecordType('Account', 'Agency'), BillingPostalCode = 'a111aa',
			Phone = '01236547896');
			OpportunityPitchController con = new OpportunityPitchController(new ApexPages.StandardController(acc));

			Opportunity opp = con.getOpportunity();
			System.assertEquals(advertiser_Id, opp.AccountId, 'Advertiser must not be blank, because there is existing relationship');
			System.assertEquals(agency_Id, opp.Agency__c, 'Agency must not be blank, because there is existing relationship');

			opp.CloseDate = Date.newInstance(2013, 01, 09);
			opp.Name = 'Test Opp';
			con.productDataJSON = '[{invalid product JSON}]';

			con.save();
			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Expected error message, because product JSON is invalid');

		}
	}
}