/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2013-11-11 16:21:55 
 *  @description:
 *      test methods for OpportunityHandler
 *  
 *  Version History :   
 *      
 */@isTest
public without sharing class OpportunityHandler_Test {
	/**
	 * Jira Gl-38
	 *
	 *  Auto-Follow Rules:
	 *
	 *  1. Opportunity Created
	 *  2. Take Opportunity Account and collect everyone who follows that Account
	 *  3. For every user collected on step #2
	 *    a. check global custom setting - to see if opportunity stage is valid
	 *    b. check hierarchical (per user profile) custom setting - to see if Opportunity.Amount >= threshold defined for given User Profile
	 *    c check if current user can see Opportunity
	 *    if a), b) and c) are OK then have that User follow this Opportunity
	 */
	static testMethod void testAutoFollowInsertUpdate() {
		insert TestData.createCountriesList();
		String department = 'Test Dep 1';
		List < User > users = Mock.many('User', new Map < String, Object > {
			'ProfileId' => MockUtils.getProfile('System Administrator').Id
		}, 3, true);
		//create config for all users
		//Stages: Preparation, Discussion, Final Negotiations
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		System.runAs(users[0]) {

			Account advertiserAccount = TestData.buildAccount('Advertiser', 'Direct Advertiser');
			advertiserAccount.name = 'Advertiser Account ' + 1;
			advertiserAccount.BillingPostalCode = 'xx' + 1 + ' ' + 1 + 'xx';

			insert advertiserAccount;

			//make all users follow their own account
			List < EntitySubscription > subscriptions = Mock.many('EntitySubscription',
			new Map < String, Object > {
				'ParentId' => advertiserAccount.Id,
					'SubscriberId' => Mock.toIds(users)
			},
			1, true);
			//users[1] - threshold = 5, account[0]
			//users[2] - threshold = 100, account[1]
			//users[3] - threshold = 1000, account[2]

			//Opportunities will be created as follows:
			//opps[0]: accs[0], Amount: 5, stage: Preparation
			//opps[1]: accs[1], Amount: 150, stage: Discussion
			//opps[2]: accs[2], Amount: 1500, stage: 'Final Negotiations'
			//opps[3]: accs[3], Amount: 1000, stage: 'No Auto Follow'
			List < Opportunity > opps = Mock.many('Opportunity',
			new Map < String, Object > {
				'StageName' => new String[] {
					'Preparation', 'Discussion', 'Final Negotiations', 'No Auto Follow'
				},
					'AccountId' => advertiserAccount.Id,
					'Amount' => new Decimal[] {
					5, 150, 1000, 10000
				}
			},
			4, true);
			//Nobody must be following opps[3] because its stage does not qualify for following
			System.assertEquals(0, [select count() from EntitySubscription where ParentId = : opps[3].Id and SubscriberId in : Mock.toIds(users)],
				'Nobody must be following opps[3] because its stage does not qualify for following. Actuall follower: ' + [select Name, StageName, Amount from Opportunity where id in (select ParentId from EntitySubscription where ParentId = : opps[3].Id and SubscriberId in : Mock.toIds(users))]);
			//expected results
			//user[0] - does not follow anything because opportunity against his account is below users threshold: 5 < 10
			System.assertEquals(0, [select count() from EntitySubscription where ParentId in : Mock.toIds(opps) and SubscriberId = : users[0].Id],
				'Did not expect users[0] to follow anything');
			//user[1] - follows 1 opportunity against his account, because : 150(amount) > 100(threshold)
			//260214
			/*System.assertEquals(1, [select count() from EntitySubscription where ParentId in: Mock.toIds(opps) and SubscriberId =: users[1].Id], 
                  'Expected users[1] to follow 1 opportunity');*/
			//user[2] - follows 1 opportunity against his account because his threshold 1000 < 1500(amount)
			//260214
			/*System.assertEquals(1, [select count() from EntitySubscription where ParentId in: Mock.toIds(opps) and SubscriberId =: users[2].Id], 
                  'Expected users[2] to follow 1 opportunity');*/

			//now change amount of opps[0] to 2000, and check if users[0] now following it, and no other users do (because they are not subscribed to accs[0])
			opps[0].Amount = 2000;
			Database.update(opps[0]);
			//260214
			/*System.assertEquals(1, [select count() from EntitySubscription where ParentId = :opps[0].Id and SubscriberId = :users[0].Id], 
                  'users[0] now must be following opps[0] because its Amount now above thresholds of this user');*/

			//dummy coverage for methids which currently do not have any logic
			Database.delete(opps[0]);
			Database.undelete(opps[0]);

		}
	}

}