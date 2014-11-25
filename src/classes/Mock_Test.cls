/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */@isTest
private class Mock_Test {

	static testMethod void One_Test1() {
		test.startTest();
		Mock.one('Lead', new map < String, Object > {
			'LastName' => 'Test Lead000#{COUNTER}', 'Company' => 'Account-000#{COUNTER}'
		});
		test.stopTest();
	}

	static testmethod void many_Test() {
		test.startTest();
		Mock.many('Lead', 1, false);
		test.stopTest();
	}

	static testmethod void clone_Test() {
		Account testAccount = TestData.buildAccount('Agency', 'Billing Agency');
		list < Account > testAccounts = new list < Account > ();
		testAccounts.add(testAccount);
		test.startTest();
		Mock.clone(testAccounts, new map < String, Object > (), false);
		test.stopTest();
	}

	static testmethod void populateNulls_Test() {
		Account testAccount = TestData.buildAccount('Agency', 'Billing Agency');
		list < Account > testAccounts = new list < Account > ();
		testAccounts.add(testAccount);
		test.startTest();
		Mock.populateNulls(testAccount);
		test.stopTest();
	}

	static testmethod void merge_Test() {
		Account testAccount = TestData.buildAccount('Agency', 'Billing Agency');
		list < Account > testAccounts = new list < Account > ();
		testAccounts.add(testAccount);
		test.startTest();
		Mock.mergeValue('val');
		test.stopTest();
	}
}