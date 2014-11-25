public without sharing class AccountMergeUtility {


	public static void MergeAccountsBusinessTeamActivities(Id[] mergedAccountIds) {
		system.debug('>>>>>>>>>> Merging accounts (count: ' + (mergedAccountIds != null ? mergedAccountIds.size() : 0) + ')...');

		if (mergedAccountIds == null || mergedAccountIds.size() == 0) {
			return;
		}

		List < Attachment > attachsToInsert = new List < Attachment > ();
		List < Note > notesToInsert = new List < Note > ();
		List < Note > notesToDelete = new List < Note > ();
		List < Attachment > attachsToDelete = new List < Attachment > ();
		List < Task > tasksToUpdate = new List < Task > ();
		List < Event > eventsToUpdate = new List < Event > ();
		List < Business_Team_Activity__c > btasToDelete = new List < Business_Team_Activity__c > ();


		// Activities of all merged accounts
		List < Business_Team_Activity__c > allActivities = [select id, name, account__c, Owner_s_Department__c, (select id, WhatId from events), (select id, body, isPrivate, Title, OwnerId from notes), (select id, WhatId from tasks)
		from Business_Team_Activity__c where account__c in : mergedAccountIds];

		// Get Attachments seperately
		List < Attachment > allAttachments = [select id, body, ContentType, description, isPrivate, Name, ownerId, ParentId
		from Attachment
		where ParentId in : allActivities];

		List < Note > allNotes = [select id, body, isPrivate, Title, ownerId, ParentId
		from Note
		where ParentId in : allActivities];

		Account acc = [select name from Account where id = : mergedAccountIds];
		//Account acc1 = [select name from Account where id =:deletedAccountIds];
		Map < String, ID > Map1 = new Map < String, ID > ();
		Map < String, ID > Map1a = new Map < String, ID > ();
		Map < String, ID > Map2 = new Map < String, ID > ();
		Map < ID, ID > Map3 = new Map < ID, ID > ();
		//Map<ID,ID> Map4=new Map<ID,ID>();

		if (allActivities.size() > 0) {
			for (Business_Team_Activity__c bta: allActivities) {
				system.debug('acc.name:' + acc.name);
				system.debug('bta.Owner_s_Department__c:' + bta.Owner_s_Department__c);
				system.debug('bta.name:' + bta.name);
				system.debug('bta.account__c:' + bta.Account__c);
				if (bta.name != acc.name + ' (' + bta.Owner_s_Department__c + ')') {
					Map2.Put(bta.Owner_s_Department__c, bta.id);
					btasToDelete.add(bta);

				} else if (bta.name == acc.name + ' (' + bta.Owner_s_Department__c + ')') {
					if (Map1.ContainsKey(bta.Owner_s_Department__c)) {
						Map1a.Put(bta.Owner_s_Department__c, bta.id);
						btasToDelete.add(bta);

					} else {
						Map1.Put(bta.Owner_s_Department__c, bta.id);
					}

				}

			}
		}

		system.debug('Map1a:' + Map1a);
		for (String currkey: Map2.keySet()) {
			Map3.put(Map2.get(currkey), Map1.get(currkey));
			system.debug('1-Map3:' + Map3);

		}
		for (String currkey: Map1a.keySet()) {
			Map3.put(Map1a.get(currkey), Map1.get(currkey));
			system.debug('2-Map3:' + Map3);

		}
		List < Task > allTasks = [select id, WhatId from task where WhatId in : btasToDelete];
		List < Event > allEvents = [select id, WhatId from event where WhatId in : btasToDelete];

		system.debug('allActivities:' + allActivities);
		system.debug('btasToDelete:' + btasToDelete);
		system.debug('Map1:' + Map1);
		system.debug('Map2:' + Map2);
		system.debug('Map3:' + Map3);
		system.debug('allTasks:' + allTasks);

		For(Task t1: allTasks) {
			if (Map3.ContainsKey(t1.WhatID)) {
				system.debug('t1.WhatID:' + t1.WhatID);
				t1.WhatId = Map3.get(t1.WhatID);
				tasksToUpdate.add(t1);
			}
		}

		For(Event e1: allEvents) {
			if (Map3.ContainsKey(e1.WhatID)) {
				system.debug('e1.WhatID:' + e1.WhatID);
				e1.WhatId = Map3.get(e1.WhatID);
				eventsToUpdate.add(e1);
			}
		}

		system.debug('tasksToUpdate:' + tasksToUpdate);
		system.debug('eventsToUpdate:' + eventsToUpdate);

		For(Attachment a1: allAttachments) {
			system.debug('a1.ParentID:' + a1.ParentID);
			if (Map3.ContainsKey(a1.ParentID)) {
				Attachment newA = new Attachment(
					ParentId = Map3.get(a1.ParentID),
					Body = a1.Body,
					ContentType = a1.ContentType,
					Description = a1.Description,
					IsPrivate = a1.IsPrivate,
					Name = a1.Name,
					OwnerId = a1.OwnerId);
				attachsToInsert.add(newA);
				attachsToDelete.add(a1);
			}
		}


		For(Note n1: allNotes) {
			system.debug('n1.ParentID:' + n1.ParentID);
			if (Map3.ContainsKey(n1.ParentID)) {
				Note newN = new Note(
					ParentId = Map3.get(n1.ParentID),
					Body = n1.Body,
					IsPrivate = n1.IsPrivate,
					Title = n1.Title,
					OwnerId = n1.OwnerId);
				notesToInsert.add(newN);
				notesToDelete.add(n1);
			}
		}

		system.debug('attachsToInsert:' + attachsToInsert);
		system.debug('notesToInsert:' + notesToInsert);

		//insert;
		insert attachsToInsert;
		insert notesToInsert;

		if (tasksToUpdate.size() > 0) {
			update tasksToUpdate;
		}

		if (eventsToUpdate.size() > 0) {
			update eventsToUpdate;
		}

		if (btasToDelete.size() > 0) {
			Database.executeBatch(new Batchdelete(btasToDelete, 'Business_Team_Activity__c'));
		}

	}

	// Gar 130 - merging chatter feeds between records 
	// This method considered that the communities are not enabled.
	public static void mergeChatterFeeds(map<Id, Id> oldRecordIdToNewRecordIdMap){
		
		system.debug('*** In Merge Chatter Feeds method ***');
		system.debug('*** oldRecordIdToNewRecordIdMap'+oldRecordIdToNewRecordIdMap+' ***');
		
		//Old records feeds
		list<FeedItem> oldRecordFeedItems = new list<FeedItem> ([SELECT Type, Title, SystemModstamp, RelatedRecordId, LinkUrl, LikeCount, LastModifiedDate, IsDeleted, ParentId, 
																			InsertedById, Id, CreatedDate, CreatedBy.Name, ContentType, ContentSize, ContentFileName, ContentDescription, 
																			ContentData, CommentCount, Body, 
																			(SELECT Id, TopicId, EntityId, CreatedDate, CreatedById, IsDeleted, SystemModstamp FROM TopicAssignments), 
																			(SELECT Id, FeedItemId, ParentId, RelatedRecordId, CommentType, CreatedBy.Name, CreatedDate, CommentBody, IsDeleted, InsertedById FROM FeedComments) 
																		FROM FeedItem
																		WHERE Type != 'TrackedChange'
																		AND ParentId IN: oldRecordIdToNewRecordIdMap.keySet()
																		order By CreatedDate
																		ALL ROWS]);
		
		/*Items to Insert derived from old feed items limited by ParentId  
		* FeedItems 
		* TopicAssignments -- Topics are not enabled hence commenting the code
		* FeedComments
		* FeedTrackedChanges -- Can not merge this object records as it is not editable or updatable
		* FeedLikes -- Can not merge this records as InsertedById field is not creatable. 
		*/
		//FeedItems to insert
		map<Id, FeedItem> oldFeedIdToNewFeedItemsMap = new map<Id, FeedItem>();
		//TopicAssignments -- Topics are not enabled hence commenting the code
		//map<Id, TopicAssignment> oldFeedIDToTopicAssignmentsMap = new map<Id, TopicAssignment>();
		//FeedComments
		map<Id, FeedComment> oldFeedIDToFeedCommentsMap = new map<Id, FeedComment>();
		
		//Feed Items are not editable. So Insering new records
		for(FeedItem fI : oldRecordFeedItems){
			id masterRecordID = oldRecordIdToNewRecordIdMap.get(fI.ParentID);
			
			//as we can not clone the feed items we need to add the values one by one
			FeedItem newFI = new FeedItem(Body = fI.Body+' '+'Created By '+fI.CreatedBy.Name +' on '+fI.CreatedDate, ContentData= fI.RelatedRecordID == null ? fI.ContentData:null, ContentDescription = fI.ContentDescription, 
											ContentFileName = fI.RelatedRecordID == null ? fI.ContentFileName:'', LinkUrl = fI.LinkUrl, ParentId = masterRecordID, RelatedRecordId=fI.RelatedRecordId, Title = fI.Title, 
											Type = fI.Type);
			oldFeedIdToNewFeedItemsMap.put(fI.Id, newFI);
			system.debug('***oldFeedIdToNewFeedItemsMap : '+ oldFeedIdToNewFeedItemsMap);
		}

		if(oldFeedIdToNewFeedItemsMap.values() != null && oldFeedIdToNewFeedItemsMap.values().size() > 0){
			insert oldFeedIdToNewFeedItemsMap.values();
		}
		
		// Topic Assignements && Feed Comments 
		for(FeedItem fI : oldRecordFeedItems){
			id masterRecordID = oldRecordIdToNewRecordIdMap.get(fI.ParentID);
			id newFeedId = oldFeedIdToNewFeedItemsMap.get(fI.Id).Id;
			//Topic Assignement --Topics are not enabled hence commenting the code
			//for(TopicAssignment tA : fI.TopicAssignments){
			//	TopicAssignment newTA = new TopicAssignment(EntityID = newFeedID, TopicId = tA.TopicID); 
			//	oldFeedIDToTopicAssignmentsMap.put(fI.ID, newTA);
			//	}
			//Feed Comments
			for(FeedComment fC : fI.FeedComments){
				FeedComment newFC = new FeedComment(CommentBody = fC.CommentBody+' '+'Created By '+fC.CreatedBy.Name +' on '+fC.CreatedDate, CommentType = fC.CommentType, FeedItemId = newFeedID, RelatedRecordId = fC.RelatedRecordID);
				oldFeedIDToFeedCommentsMap.put(fI.ID, newFC);
			}
		}
		//Topic Assignement --Topics are not enabled hence commenting the code
		//if(oldFeedIDToTopicAssignmentsMap.values() != null && oldFeedIDToTopicAssignmentsMap.values().size() > 0){
		//	insert oldFeedIDToTopicAssignmentsMap.values();
		//}
		
		if(oldFeedIDToFeedCommentsMap.values() != null && oldFeedIDToFeedCommentsMap.Values().size() > 0){
			insert oldFeedIDToFeedCommentsMap.values();
		}
		
		/*Followers of a related record will be derived from EntitySubscription and limited by ParentID
		* limitations on this query for API 31.0 version is 
		* A query must include a LIMIT clause and the limit can’t exceed 1000.
		* According to vurrent number of chatter liceneces used this should not be reached. 
		* However this may be breached in future.
		*/
		list<EntitySubscription> entitySubscriptionToInsert = new list<EntitySubscription>(); 
		map<ID, list<EntitySubscription>> oldRecordIDToListOfFollowersMap = new map<ID, list<EntitySubscription>>();
		
		//We have to avoid duplicate followers on master record
		map<ID, set<ID>> masterRecordIdToFollowersSet = new map<Id, Set<Id>>();
		
		for(EntitySubscription eS : [Select SubscriberId, ParentId, Id
										From EntitySubscription 
										WHERE ParentID IN: oldRecordIdToNewRecordIdMap.values()
										order by CreatedDate
										limit 1000 ALL ROWS
										]){
			if(!masterRecordIdToFollowersSet.containsKey(eS.ParentID)){
				masterRecordIdToFollowersSet.put(eS.ParentID, new SET<ID>());
			}
			masterRecordIdToFollowersSet.get(eS.ParentID).add(eS.SubscriberID);
		}
		
		//list of followers on old (loosing/deleting) records
		list<EntitySubscription> oldRecordFollowersList = new list<EntitySubscription>([Select SubscriberId, ParentId, Id
																						From EntitySubscription 
																						WHERE ParentID IN: oldRecordIdToNewRecordIdMap.keySet()
																						ORDER By CreatedDate limit 1000 ALL ROWS]);
		//construct a map between old record id to its list of followers
		for(EntitySubscription eS: oldRecordFollowersList){
			if(!oldRecordIDToListOfFollowersMap.containsKey(eS.ParentID)){
				oldRecordIDToListOfFollowersMap.Put(es.ParentID, new list<EntitySubscription>());
			}
			oldRecordIDToListOfFollowersMap.get(es.ParentID).add(eS);
		}
		 
		//Followers are not editable, So inserting new records. 
		if(oldRecordIDToListOfFollowersMap.size() > 0 ){
			for(ID oldRecordID : oldRecordIdToNewRecordIdMap.keySet()){
				ID newRecordID = oldRecordIdToNewRecordIdMap.get(oldRecordID);
				if(oldRecordIDToListOfFollowersMap.containsKey(oldRecordID)){
					for(EntitySubscription oldES: oldRecordIDToListOfFollowersMap.get(oldRecordID)){
						if(masterRecordIdToFollowersSet.containsKey(newRecordID) && !masterRecordIdToFollowersSet.get(newRecordID).contains(oldES.SubscriberId) ){
							entitySubscriptionToInsert.add(new EntitySubscription(SubscriberId=oldES.SubscriberId, ParentId = newRecordID));
							masterRecordIdToFollowersSet.get(newRecordID).add(oldES.SubscriberId);
						}
					}
				}
			}
			
			if(entitySubscriptionToInsert.size() > 0){
				insert entitySubscriptionToInsert;
			}
		}
	}
}