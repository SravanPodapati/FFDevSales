/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2013-11-11 14:46:11 
 *	@description:
 *		main handler for Opportunity Trigger events
 *	
 *	Version History :   
 *	2013-11-11 - Jira Gl-38 - AG
 *	Opportunity Auto-Follow
 *	
 *		
 */
public without sharing class OpportunityHandler {
	private static OpportunityHandler handler;

	public static OpportunityHandler getHandler() {
		if (null == handler) {
			handler = new OpportunityHandler();
		}
		return handler;
	}

	/*
	public void beforeInsert () {
		//nothing currently
	}

	public void beforeUpdate () {
		//nothing currently
	}

	public void beforeDelete () {
		//nothing currently
	}
	*/

	public void afterInsert () {
		autoFollow((Map<Id, Opportunity>)Trigger.newMap, null);
	}

	public void afterUpdate () {
		autoFollow((Map<Id, Opportunity>)Trigger.newMap, (Map<Id, Opportunity>)Trigger.oldMap);
	}

	public void afterDelete () {
		//nothing currently
	}

	public void afterUnDelete () {
		autoFollow((Map<Id, Opportunity>)Trigger.newMap, null);
	}

	/**
	 * Jira Gl-38
	 *
	 *	Auto-Follow Rules:
	 *
	 *	1. Opportunity Created
	 *	2. Take Opportunity Account and collect everyone who follows that Account
	 *	3. For every user collected on step #2
	 *		a. check global custom setting - to see if opportunity stage is valid
	 *		b. check hierarchical (per user profile) custom setting - to see if Opportunity.Amount >= threshold defined for given User Profile
	 *		c check if current user can see Opportunity
	 *		if a), b) and c) are OK then have that User follow this Opportunity
	 *
	 */
	private static void autoFollow(Map<Id, Opportunity> newOppsMap, Map<Id, Opportunity> oldOppsMap) {
		final Set<Id> oppIds = new Set<Id>();
		final Set<Id> accountIds = new Set<Id>();
		for(Opportunity opp : newOppsMap.values()) {
			if (isChangedForAutoFollow(opp, oldOppsMap)) {
				oppIds.add(opp.Id);
				accountIds.add(opp.AccountId);
			}
		}

		final Set<Id> allUserIds = new Set<Id>();
		final Map<Id, Set<Id>> existingFollowersByParentId = new Map<Id, Set<Id>>();//Opp.Id -> Ids of Users who already follow given Opportunity
		for(EntitySubscription subscription : [select Id, SubscriberId, ParentId from EntitySubscription 
											where (ParentId in:oppIds or ParentId in: accountIds) ]) {
			addToMap(existingFollowersByParentId, subscription.ParentId, subscription.SubscriberId);
			allUserIds.add(subscription.SubscriberId);
		}
		//make sure we know what users are the Active ones
		final Map<Id, User> activeUserMap = new Map<Id, User>([select Id from User where IsActive = true and Id in: allUserIds]);
		/*
		//find out what records users have access to
		final Map<Id, Set<Id>> readableIdsByUserId = new Map<Id, Set<Id>>();
		//for(UserRecordAccess ura : [select UserId, RecordId from UserRecordAccess where HasReadAccess = true and UserId in:activeUserMap.keySet() and RecordId =:oppIds]) {
		for(OpportunityShare share : [select UserOrGroupId, OpportunityId from OpportunityShare 
										where OpportunityAccessLevel in ('Read', 'Edit', 'All') and UserOrGroupId in:activeUserMap.keySet() and OpportunityId =:oppIds]) {
			addToMap(readableIdsByUserId, share.UserOrGroupId, share.OpportunityId);
		}
		*/

		final List<EntitySubscription> subscriptionsToInsert = new List<EntitySubscription>();
		for(Id oppId : oppIds) {
			Opportunity opp = newOppsMap.get(oppId);
			//all users who follow account of this Opportunity
			final Set<Id> userIds = existingFollowersByParentId.get(opp.AccountId);
			if (null != userIds) {
				//all users who already follow this opportunity
				final Set<Id> skipUserIds = existingFollowersByParentId.get(oppId);
				if (null != skipUserIds) {
					userIds.removeAll(skipUserIds);
				}
				// now check every user if they are eligible for following this opportunity 
				// and add to followers list if Yes
				for(Id userId : userIds) {
					//Set<Id> readableIds = readableIdsByUserId.get(userId);
					//Boolean hasAccess = null != readableIds && readableIds.contains(oppId) || Test.isRunningTest();
					if (activeUserMap.containsKey(userId) && shouldFollow(userId, opp)) {
						subscriptionsToInsert.add(new EntitySubscription(ParentId = oppId, SubscriberId = userId));
					}
				}
			}

		}
		//Database.insert(subscriptionsToInsert);
	}

	private static Boolean isChangedForAutoFollow(final Opportunity newOpp, Map<Id, Opportunity> oldOpps) {
		if (null == oldOpps) {
			return true;
		}
		final Opportunity oldOpp = oldOpps.get(newOpp.Id);
		//check if Stage or Amount has changed
		return newOpp.Amount != oldOpp.Amount || newOpp.StageName != oldOpp.StageName;
	}

	/**
	 * return defined ConstantsH__c for given user, or setup a default one
	 */
	private static ConstantsH__c getUserConfig(final Id userId) {
		ConstantsH__c config = ConstantsH__c.getInstance(userId);
		if (null == config) {
			config = new ConstantsH__c(SetupOwnerId = userId);
		}
		if (null == config.Opportunity_Auto_Follow_Threshold__c) {
			config.Opportunity_Auto_Follow_Threshold__c = 99999999999999999.0;// 18 digits
		}
		if (null == config.Opportunity_Auto_Follow_Stages__c) {
			config.Opportunity_Auto_Follow_Stages__c = '';//no stages defined
		}
		return config;

	}

	private static Boolean shouldFollow(final Id userId, final Opportunity opp) {
		System.debug('agX userId=' + userId);
		ConstantsH__c config = getUserConfig(userId);
		//this part may hit "too many script statements" limit if there are lots of users and opportunities involved in a single batch
		//potential workaround (at the expence of extra RAM) is to cache stages per user once.
		final Set<String> autoFollowStages = new Set<String>();
		for(String stageName : config.Opportunity_Auto_Follow_Stages__c.split(',')) {
			String stageTrimmed = stageName.trim();
			if (!String.isBlank(stageTrimmed)) {
				autoFollowStages.add(stageTrimmed);
			}
		}
		return opp.Amount >= config.Opportunity_Auto_Follow_Threshold__c && autoFollowStages.contains(opp.StageName);
	}

	private static void addToMap(final Map<Id, Set<Id>> valueMap, final Id key, final Id value) {
		final Set<Id> values = valueMap.get(key);
		if (null == values) {
			values = new Set<Id>();
			valueMap.put(key, values);
		}
		values.add(value);
	}
}