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
 */
@isTest
private class Utility_DynamicSort_Test {
	static testMethod void ascendingTest(){
		list<Account> accList = new list<Account>();
		accList.add(new Account(Name = 'Test6'));
		accList.add(new Account(Name = 'Test0'));
		accList.add(new Account(Name = 'Test1'));
		accList.add(new Account(Name = 'Test3'));
		accList.add(new Account(Name = 'Test2'));
		accList.add(new Account(Name = 'Test4'));
		accList.add(new Account(Name = 'Test5'));
		
		
		Utility_DynamicSort uDS = new Utility_DynamicSort();
		//ascending sort
		accList = uDS.sObjectListSort(accList, 'Name', 'ASC');
		system.assertEquals(accList[0].name, 'Test0');
		system.assertEquals(accList[1].name, 'Test1');
		system.assertEquals(accList[2].name, 'Test2');
		system.assertEquals(accList[3].name, 'Test3');
		system.assertEquals(accList[4].name, 'Test4');
		system.assertEquals(accList[5].name, 'Test5');
	}
	
	static testMethod void decendingTest(){
		list<Account> accList = new list<Account>();
		accList.add(new Account(Name = 'Test6'));
		accList.add(new Account(Name = 'Test0'));
		accList.add(new Account(Name = 'Test1'));
		accList.add(new Account(Name = 'Test3'));
		accList.add(new Account(Name = 'Test2'));
		accList.add(new Account(Name = 'Test4'));
		accList.add(new Account(Name = 'Test5'));
		
		
		Utility_DynamicSort uDS = new Utility_DynamicSort();
		//decending sort
		accList = uDS.sObjectListSort(accList, 'Name', 'DESC');
		system.assertEquals(accList[0].name, 'Test6');
		system.assertEquals(accList[1].name, 'Test5');
		system.assertEquals(accList[2].name, 'Test4');
		system.assertEquals(accList[3].name, 'Test3');
		system.assertEquals(accList[4].name, 'Test2');
		system.assertEquals(accList[5].name, 'Test1');
	}
	
	static testMethod void exceptionTesting(){
		list<Account> accList = new list<Account>();
		accList.add(new Account(Name = 'Test6'));
		accList.add(new Account(Name = 'Test0'));
		accList.add(new Account(Name = 'Test1'));
		accList.add(new Account(Name = 'Test3'));
		accList.add(new Account(Name = 'Test2'));
		accList.add(new Account(Name = 'Test4'));
		accList.add(new Account(Name = 'Test5'));
		
		Utility_DynamicSort uDS = new Utility_DynamicSort();
		try{
			//for list exception
			accList = uDS.sObjectListSort(null, 'Name', 'DESC');
		}catch(exception e){
			system.assertEquals('You must pass a valid list of sobjects', e.getMessage());
		}
		
		
		try{
			//for sobject exception
			accList = uDS.sObjectListSort(accList, 'test', 'DESC');
		}catch(exception e){
			system.assertEquals('Sorting Field is invalid for Object Type Account', e.getMessage());
		}
		
	}
	
	static testMethod void defaultsorting(){
		list<Account> accList = new list<Account>();
		accList.add(new Account(Name = 'Test6'));
		accList.add(new Account(Name = 'Test0'));
		accList.add(new Account(Name = 'Test1'));
		accList.add(new Account(Name = 'Test3'));
		accList.add(new Account(Name = 'Test2'));
		accList.add(new Account(Name = 'Test4'));
		accList.add(new Account(Name = 'Test5'));
		
		
		Utility_DynamicSort uDS = new Utility_DynamicSort();
		//decending sort
		accList = uDS.sObjectListSort(accList, null, null);
		system.assertEquals(accList[0].name, 'Test6');
		system.assertEquals(accList[1].name, 'Test0');
		system.assertEquals(accList[2].name, 'Test1');
		system.assertEquals(accList[3].name, 'Test3');
		system.assertEquals(accList[4].name, 'Test2');
		system.assertEquals(accList[5].name, 'Test4');
	}
}