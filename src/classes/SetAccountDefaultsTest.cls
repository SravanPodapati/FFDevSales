@isTest
private class SetAccountDefaultsTest {

	static testMethod void testInsertTrigger()
	{
		Account acc = new Account();
		acc.Name = 'TESTACCOUNT123';
		insert acc;
	}
}