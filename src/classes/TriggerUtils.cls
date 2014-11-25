/**
 *    @author: Andrey Gavrikov (westbrook)
 *	@date: 2013-11-11 
 *	@description:
 *	    various utilities useful in many triggers
 *	
 *	Version History :   
 *		
 */
public without sharing class TriggerUtils {

	/**
	 * use this method in each trigger to check if trigger should be executed at all
	 */
	public static Boolean canSkipTrigger() {
		return canSkipTriggers(UserInfo.getUserId());
	}
	/**
	 * use this method when need to check if triggers can be skipped by a user other than current
	 */
	public static Boolean canSkipTriggers(final Id userOrProfileId) {
		final No_Triggers__c notriggers = No_Triggers__c.getInstance(userOrProfileId);
		return notriggers != null && true == notriggers.Flag__c;
	}

	/**
	 * Use this method in data preparation when unit test does not rely on triggers logic
	 */
	public static void setSkipTriggers(final Id userOrProfileId, final Boolean flag) {
		No_Triggers__c config = No_Triggers__c.getInstance(userOrProfileId);
		if (null == config || null == config.Id) {
			Database.insert(new No_Triggers__c(SetupOwnerId = userOrProfileId, Flag__c = flag));
		} else {
			config.Flag__c = flag;
			Database.update(config);
		}

	}
	/**
	 * Use this method in data preparation when unit test does not rely on validation business logic
	 */
	public static void setSkipValidations(final Id userOrProfileId, final Boolean flag) {
		No_Validations__c config = No_Validations__c.getInstance(userOrProfileId);
		if (null == config || null == config.Id) {
			Database.insert(new No_Validations__c(SetupOwnerId = userOrProfileId, Flag__c = flag));
		} else {
			config.Flag__c = flag;
			Database.update(config);
		}

	}

	/**
	 * check how canSkipTrigger works
	 */
	static testMethod void testSkipTrigger() {
		System.assertEquals(false, canSkipTrigger(), 'Default value must be OFF');
		Id userId = UserInfo.getUserId();
		setSkipTriggers(userId, true);
		System.assertEquals(true, canSkipTriggers(userId), 'value must be On');

		setSkipTriggers(userId, false);
		System.assertEquals(false, canSkipTriggers(userId), 'value must be Off');
	}
	/**
	 * check how setSkipValidations works
	 */
	static testMethod void testSetSkipValidations() {
		Id userId = UserInfo.getUserId();
		setSkipValidations(userId, false);
		System.assertEquals(false, No_Validations__c.getInstance(userId).Flag__c, 'value must be Off');

		setSkipValidations(userId, true);
		System.assertEquals(true, No_Validations__c.getInstance(userId).Flag__c, 'value must be On');
	}
}