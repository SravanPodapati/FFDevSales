public with sharing class AccountFullSyncController {

	public Account currentRecord {get; set;}

	public AccountFullSyncController(ApexPages.StandardController controller) {
		this.currentRecord = [SELECT ID, DoCCIInt__c, BillingPostalCode from Account where id = : controller.getRecord().id];
	}

	public Pagereference cciFullSync() {
		User tempUser = [select Id, Profile.Name, Account_Full_Sync__c from User where id = : Userinfo.getUserId()];
		if (tempUser.Account_Full_Sync__c || tempUser.Profile.Name.toUpperCase() == 'SYSTEM ADMINISTRATOR') {
			try {
				if (this.currentRecord.DoCCIInt__c == true) {
					this.currentRecord.DoCCIInt__c = false;
					update this.currentRecord;
				}
				this.currentRecord.DoCCIInt__c = true;
				update this.currentRecord;
				return new pagereference('/' + this.currentRecord.id);
			} catch (Exception ex) {
				Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.FATAL, ex.getMessage());
				Apexpages.addMessage(errorMessage);
				return null;
			}
		} else {
			Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.FATAL, 'You Do not have access to this page. Please contact system administrator to get access to this page.');
			Apexpages.addMessage(errorMessage);
		}
		return null;
	}
}