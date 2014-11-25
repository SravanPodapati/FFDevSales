/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2013-10-24 
 *  @description:
 *      Test methods for TaskHandler
 *  
 *  Version History :   
 *  2013-10-24 - Jira: GI-1 - AG
 *  Conditional reassignment to BTA activity
 *      
 */@isTest
public class TaskHandler_Test {

	/**
	 * Jira: GI-1
	 * On hitting ‘Create’ a task will be created, either against the relevant
	 * BTA record for that user and Account (if ‘BTA Activity?’ is checked) or
	 * directly against the Account (if ‘BTA Activity?’ is not checked).
	 */
	static testMethod void testTaskInsertAndReassign() {
		String department = 'Test Dep 1';
		User usr = MockData.getTestUserWithConstantsH('System Administrator', department);
		System.runAs(usr) {
			Mock.MOCK_DATA.addSingletonObjectType('Account');
			List < Account > accs = Mock.many('Account', new Map < String, Object > {
				'Type' => 'Client'
			}, 1, true);
			//check that the above created BTA activity which we can use
			List < Business_Team_Activity__c > btas = [select Id from Business_Team_Activity__c where Account__c = : accs[0].Id and Owner_s_Department__c = : department];
			System.assert(!btas.isEmpty(), 'Looks like the trigger which creates Account BTAs is disabled.');

			List < Task > tasks = Mock.many('Task', new Map < String, Object > {
				'BTA_Activity__c' => new Boolean[] {
					true, false, true
				},
					'WhatId' => accs[0].Id
			}, 3, true);

			//check that task 1 is created against its Account
			System.assertEquals(accs[0].Id, [select WhatId from Task where Id = : tasks[1].Id].WhatId, 'Expected this task to stay assigned to its original account');
			//check that tasks 0 and 2 are created against BTA Activity
			final Set < Id > btaTasks = new Set < Id > ();
			btaTasks.add(tasks[0].Id);
			btaTasks.add(tasks[2].Id);

			System.assertEquals(2, [select count() from Task where Id in : btaTasks and WhatId = : btas[0].Id], 'Expected tasks 0 and 2 to be re-assigned to BTA');

			//dummy coverage
			//there is no update or delete logic in TaskHandler presently, so just provide 
			//dummy coverage for beforeUpdate and beforeDelete methods
			Database.update(tasks[0]);
			Database.delete(tasks[0]);
		}
	}
	/**
	 * Jira: GI-1
	 * On hitting ‘Create’ an EVENT will be created, either against the relevant
	 * BTA record for that user and Account (if ‘BTA Activity?’ is checked) or
	 * directly against the Account (if ‘BTA Activity?’ is not checked).
	 */
	static testMethod void testEventInsertAndReassign() {
		String department = 'Test Dep 1';
		User usr = MockData.getTestUserWithConstantsH('System Administrator', department);
		System.runAs(usr) {
			Mock.MOCK_DATA.addSingletonObjectType('Account');
			List < Account > accs = Mock.many('Account', new Map < String, Object > {
				'Type' => 'Client'
			}, 1, true);
			//check that the above created BTA activity which we can use
			List < Business_Team_Activity__c > btas = [select Id from Business_Team_Activity__c where Account__c = : accs[0].Id and Owner_s_Department__c = : department];
			System.assert(!btas.isEmpty(), 'Looks like the trigger which creates Account BTAs is disabled.');

			List < Event > events = Mock.many('Event', new Map < String, Object > {
				'BTA_Activity__c' => new Boolean[] {
					true, false, true
				},
					'WhatId' => accs[0].Id
			}, 3, true);

			//check that Event 1 is created against its Account
			System.assertEquals(accs[0].Id, [select WhatId from Event where Id = : events[1].Id].WhatId, 'Expected this Event to stay assigned to its original account');
			//check that Event 0 and 2 are created against BTA Activity
			final Set < Id > btaEventIds = new Set < Id > ();
			btaEventIds.add(events[0].Id);
			btaEventIds.add(events[2].Id);

			System.assertEquals(2, [select count() from Event where Id in : btaEventIds and WhatId = : btas[0].Id], 'Expected Events 0 and 2 to be re-assigned to BTA');

		}
	}
}