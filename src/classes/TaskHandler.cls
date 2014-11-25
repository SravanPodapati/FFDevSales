/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2013-10-24 
 *	@description:
 *	    handler for all Task trigger actions
 *	
 *	Version History :   
 *	2013-10-24 - Jira: GI-1 - AG
 *	Conditional reassignment to BTA activity
 *
 *		
 */
public without sharing class TaskHandler {
	private static TaskHandler handler;

	public static TaskHandler getHandler() {
		if (null == handler) {
			handler = new TaskHandler();
		}
		return handler;
	}

	public void beforeInsert () {
		reassignToBTA(Trigger.new);
	}

	/*
	public void beforeUpdate () {
		//nothing currently
	}

	public void beforeDelete () {
		//nothing currently
	}
	*/

	/*
	public void afterInsert () {
		//nothing currently
	}

	public void afterUpdate () {
		//nothing currently
	}

	public void afterDelete () {
		//nothing currently
	}

	public void afterUnDelete () {
		//nothing currently
	}
	*/

	final static String ACCOUNT_ID_PREFIX = '001';
	/**
	 * On hitting ‘Create’ a task will be created, either against the relevant
	 * BTA record for that user and Account (if ‘BTA Activity?’ is checked) or
	 * directly against the Account (if ‘BTA Activity?’ is not checked).
	 */
	public static void reassignToBTA(List<SObject> activities) {
		final List<SObject> activitiesToReassign = new List<SObject>();
		Map<Id, User> ownerMap = new Map<Id, User>();
		final Set<Id> accountIds = new Set<Id>();
		for(SObject tsk : activities) {
			String whatId  = (String)tsk.get('WhatId');
			if ((Boolean)tsk.get('BTA_Activity__c') && null != tsk.get('WhatId') && whatId.startsWith(ACCOUNT_ID_PREFIX)) {
				activitiesToReassign.add(tsk);
				ownerMap.put((Id)tsk.get('OwnerId'), null);
				accountIds.add((Id)tsk.get('WhatId'));
			} 
		}
		//load profiles of all users
		ownerMap = new Map<Id, User>([select Id, ProfileId from User where Id in :ownerMap.keySet() and IsActive = true]);
		//load map of all BTAs
		final Map<String, Id> btaIdByAccountAndDepartment = new Map<String, Id>();
		for(Business_Team_Activity__c bta : [select Id, Owner_s_Department__c, Account__c from Business_Team_Activity__c where Account__c in:accountIds ]) {
			String key = bta.Account__c + '' + bta.Owner_s_Department__c;
			btaIdByAccountAndDepartment.put(key, bta.Id);
		}

		for(SObject tsk : activitiesToReassign) {
			User owner = ownerMap.get((Id)tsk.get('OwnerId'));
			if (null != owner) {
				ConstantsH__c ch = ConstantsH__c.getInstance(owner.ProfileId);   
				if (null != ch) {
					String key = tsk.get('WhatId') + '' + ch.Department__c;
					Id btaId = btaIdByAccountAndDepartment.get(key);
					if (null != btaId) {
						tsk.put('WhatId', btaId);
					}
				}
			}
		}
	}
}