/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2013-11-12 12:18:09 
 *
 *	@description:
 *	    Jira: Gl-39
 *	MAX_FOLLOW = 400 (configurable globally, single value for ALL users)
 *	To ensure that a user has the ability to follow new pitches, accounts and
 *	people, whilst remaining within the four hundred cap, dmg media require the
 *	following process to occur:
 *	
 *	IF user follows more than MAX_FOLLOW records then:
 *	1.	Automatically search and un-follow a pitch that has been closed for seven days or longer
 *	
 *	IF after #1 user still follows more than MAX_FOLLOW records then:
 *	2.	Automatically search and un-follow a pitch that has been closed for highest number of days.
 *	e.g. if opportunity has been closed for 6 days then unfollow it BEFORE Opportunity which has been closed for 5 days
 *	
 *	IF after #2 user still follows more than MAX_FOLLOW records then:
 *	3.	Automatically un-follow the lowest value pitch. In the scenario where multiple pitches of the same lowest value exists, the following rule applies:
 *		a.	Find and un-follow a pitch of the lowest value (by Amount) which has the furthest end date (Close Date).*
 *	
 *	Version History :   
 *		
 */
global without sharing class OpportunityUnfollowBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
	final Map<Id, Integer> subscriptionsByUserId = new Map<Id, Integer>();
	static Decimal THRESHOLD = 400;
	static {
		Constants__c config = Constants__c.getInstance('All');
		if (null != config && null != config.Opportunity_Auto_UnFollow_Threshold__c) {
			THRESHOLD = config.Opportunity_Auto_UnFollow_Threshold__c;
		}
	}
	global void execute(SchedulableContext SC) {
		OpportunityUnfollowBatch batch = new OpportunityUnfollowBatch();
		Database.executebatch(batch);
	}

	global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator([select Id, SubscriberId, ParentId from EntitySubscription 
											where Parent.Type = 'Opportunity' and IsDeleted = false order by SubscriberId]);
	}

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
		unsubscribe((List<EntitySubscription>)scope);
	}

    global void finish(Database.BatchableContext ctx) {
	}

	@TestVisible
	private void unsubscribe(final List<EntitySubscription> subscriptions) {
		//collect all users involved in current batch of EntitySubscription-s
		final Set<Id> userIdsToProcess = new Set<Id>();
		for(EntitySubscription es : subscriptions) {
			if (incrementSubscriptionCount(subscriptionsByUserId, es.SubscriberId, +1) > THRESHOLD) {
				userIdsToProcess.add(es.SubscriberId);
			}
		}
		if (!userIdsToProcess.isEmpty()) {
			//all users in userIdsToProcess set must be unsubscribed from N Opportunities
			final Map<Id, User> activeUserMap = new Map<Id, User>([select Id from User where IsActive = true and Id in: userIdsToProcess]);
			// Automatically un-follow a pitch that has been closed for highest number of days, starting from 7+
			Integer daysAgo = 7;
			while (daysAgo > 0 && !userIdsToProcess.isEmpty()) {
				DateTime cutOffDate = System.now() - daysAgo;
				//find all opportunities closed more than daysAgo days
				for (List<EntitySubscription> ess : [select Id, SubscriberId, ParentId from EntitySubscription where Parent.Type = 'Opportunity' 
														and SubscriberId in: userIdsToProcess
														and 
														ParentId in (select Id from Opportunity where IsClosed = true and Actual_Close_Date__c <= :cutOffDate)]) {

					final List<EntitySubscription> subscriptonsToDelete = new List<EntitySubscription>();
					for(EntitySubscription es : ess) {
						if (userIdsToProcess.contains(es.SubscriberId)) {
							//register the fact that current User has one less Subscription
							if (incrementSubscriptionCount(subscriptionsByUserId, es.SubscriberId, -1) <= THRESHOLD) {
								userIdsToProcess.remove(es.SubscriberId);
							}
							subscriptonsToDelete.add(es);
						}
						
					}
					Database.delete(subscriptonsToDelete, false);//allow failures because some EntitySubscription-s might have been deleted in the eralier batch
				}
				daysAgo -= 1;
			}

		}
		if (!userIdsToProcess.isEmpty()) {
			//3. Automatically un-follow the lowest value pitch. In the scenario where multiple pitches of the same lowest value exists, the following rule applies:
			//	a. Find and un-follow a pitch of the lowest value (by Amount) which has the furthest end date (Close Date).
			final Set<Id> oppIds = new Set<Id>();
			final Map<Id, Set<Id>> userIdsByOpportunityId = new Map<Id, Set<Id>>();
			final Map<String, EntitySubscription> subscriptionByKey = new Map<String, EntitySubscription>();//userId.oppId -> EntitySubscription

			for (EntitySubscription es : [select Id, SubscriberId, ParentId from EntitySubscription where Parent.Type = 'Opportunity' 
														and SubscriberId in: userIdsToProcess ]) {
				addToMap(userIdsByOpportunityId, es.ParentId, es.SubscriberId);
				String key = es.SubscriberId + '' + es.ParentId;
 				subscriptionByKey.put(key, es);


			}
			final List<EntitySubscription> subscriptonsToDelete = new List<EntitySubscription>();
			for(Opportunity opp : [select Id from Opportunity where Id in: userIdsByOpportunityId.keySet() order by Amount asc, CloseDate desc]) {
				//unsubscribe all users from this Opportunity
				final Set<Id> userIds = userIdsByOpportunityId.get(opp.Id);
				if (null != userIds) {
					for(Id userId : userIds) {
						if (userIdsToProcess.contains(userId)) {
							String key = userId + '' + opp.Id;
							EntitySubscription es = subscriptionByKey.get(key);
							if (null != es) {
								if (incrementSubscriptionCount(subscriptionsByUserId, es.SubscriberId, -1) <= THRESHOLD) {
									userIdsToProcess.remove(es.SubscriberId);
								}
								subscriptonsToDelete.add(es);
							}
						}
					}
				}
			}
			Database.delete(subscriptonsToDelete, false);
		}

	}
	
	/**
	 * register another subscription for a given user and return TRUE if THRESHOLD is reached
	 */
	private static Integer incrementSubscriptionCount(final Map<Id, Integer> setByIdMap, final Id key, final Integer increment) {
		Integer count = setByIdMap.get(key);
		if (null == count) {
			count = 0;
		}
		count += increment;
		setByIdMap.put(key, count);
		return count;
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