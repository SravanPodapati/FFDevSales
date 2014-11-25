/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2013-11-12 15:22:38 
 *  @description:
 *      test methods for OpportunityUnfollowBatch
 *  
 *  Version History :   
 *      
 */@isTest
public class OpportunityUnfollowBatch_Test {
	/**
	 * Gl-39 - automatically unsubscribe users from Opportunities when certain THRESHOLD is reached
	 *
	 */
	static testMethod void testUnsubscribe() {
		String department = 'Test Dep 1';
		List < User > users = Mock.many('User', new Map < String, Object > {
			'ProfileId' => MockUtils.getProfile('System Administrator').Id
		}, 3, true);
		final List < Id > userIds = Mock.toIds(users);
		//create config for all users
		//Stages: Preparation, Discussion, Final Negotiations
		List < ConstantsH__c > cofigs = Mock.many('ConstantsH__c', new Map < String, Object > {
			'Department__c' => department,
				'Opportunity_Auto_Follow_Threshold__c' => new Decimal[] {
				10, 100, 1000
			},
				'Opportunity_Auto_Follow_Stages__c' => 'Preparation,Discussion, Final Negotiations',
				'SetupOwnerId' => Mock.toIds(users)
		},
		3, true);
		//set THRESHOLD
		List < Constants__c > constConfig = Mock.many('Constants__c', new Map < String, Object > {
			'Opportunity_Auto_UnFollow_Threshold__c' => 2
		}, 1, true);


		TriggerUtils.setSkipValidations(users[0].Id, true);
		TriggerUtils.setSkipTriggers(users[0].Id, true);

		System.runAs(users[0]) {
			//3 Closed Won opportunity 
			List < Opportunity > wonOpps = Mock.many('Opportunity', new Map < String, Object > {
				'StageName' => 'Closed Won'
			}, 3, true);
			//change Actual_Close_Date__c for this test
			wonOpps[0].Actual_Close_Date__c = System.now() - 8;
			wonOpps[1].Actual_Close_Date__c = System.now() - 6;
			wonOpps[2].Actual_Close_Date__c = System.now() - 4;
			Database.update(wonOpps);

			//3 Open opportunity
			final Date TODAY = System.today();
			List < Opportunity > openOpps = Mock.many('Opportunity', new Map < String, Object > {
				'StageName' => 'Preparation',
					'CloseDate' => new Date[] {
					TODAY - 10, TODAY - 5, TODAY
				},
					'Amount' => new Decimal[] {
					10, 100, 50
				}
			}, 3, true);

			final List < Opportunity > allOpps = new List < Opportunity > ();
			allOpps.addAll(wonOpps);
			allOpps.addAll(openOpps);

			//now subscribe all users to these opportunities
			final List < EntitySubscription > subscriptions = new List < EntitySubscription > ();
			for (Opportunity opp: allOpps) {
				for (User usr: users) {
					EntitySubscription es = new EntitySubscription();
					es.ParentId = opp.Id;
					es.SubscriberId = usr.Id;
					subscriptions.add(es);
				}
			}
			Database.insert(subscriptions);

			//at this point we have: 3 users, each subscribed to all opportunities

			//now try to unsubscribe and see what happens
			OpportunityUnfollowBatch batch = new OpportunityUnfollowBatch();
			//split in three batches, to simulate batch processing
			//deliberatly start from the end, because last records will actually have to stay
			//and we want ot test what happens if records provided in the next batch have been deleted in the previous one
			Integer index = subscriptions.size() - 1;
			while (index > 0) {
				batch.unsubscribe(new List < EntitySubscription > {
					subscriptions[index--], subscriptions[index--]
				});
			}
			//batch.unsubscribe(subscriptions);

			//expect each user to have no more than Constants__c.Opportunity_Auto_Follow_Threshold__c = 3 Subscriptions
			System.assertEquals(2, [select count() from EntitySubscription where SubscriberId = : users[0].Id],
				'Expected reduced number of subscriptions');

			//all users must have no more than 2 subscriptions each
			System.assertEquals(2 * users.size(), [select count() from EntitySubscription where SubscriberId in : userIds],
				'all users must have no more than 2 subscriptions each');

			//check what subscriptions left
			//users[0] - expect to follow only Open Opportunities with highest Amount (i.e. openOpps[1] & openOpps[2])
			System.assertEquals(2, [select count() from EntitySubscription where SubscriberId = : users[0].Id and ParentId in (: openOpps[1].Id, : openOpps[2].Id)],
				'expect to follow only Open Opportunities with highest Amount (i.e. openOpps[1] & openOpps[2])');

		}
	}
	/**
	 * Gl-39 there is no logic in batch and schedulable methods of OpportunityUnfollowBatch
	 * so this is just to provide code coverage
	 */
	static testMethod void testBatchMethods() {
		OpportunityUnfollowBatch batch = new OpportunityUnfollowBatch();
		Test.startTest();
		Database.executebatch(batch);
		Test.stopTest();

	}
	/**
	 * Gl-39 there is no logic in batch and schedulable methods of OpportunityUnfollowBatch
	 * so this is just to provide code coverage
	 */
	static testMethod void testSchedulableMethod() {
		OpportunityUnfollowBatch batch = new OpportunityUnfollowBatch();
		Test.startTest();
		String sch = '0 0 8 13 2 ?';
		System.schedule('One Time', sch, batch);
		Test.stopTest();

	}
}