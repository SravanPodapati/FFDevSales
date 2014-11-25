public with sharing class BookingConformationPdfController {

	public static Order currentOrder {
		get;
		set;
	}
	public static list < OrderItem > relatedItems {
		get;
		set;
	}

	public BookingConformationPdfController(ApexPages.StandardController controller) {
		currentOrder = [Select Opportunity__r.Owner.Name, CCIBookingAgencyId__c, TotalAmount, Finance_Account__r.Name, CCI_Order_ID__c, Booking_Source__c, Agency__r.Name, ActivatedDate, ActivatedById, Account.Name, Created_In_CCI_By__c From Order where id = : ApexPages.currentPage().getParameters().get('Id')];
		relatedItems = new list < OrderItem > ([Select Zone_Name__c, Publication_Name__c, Section_Name__c, UnitPrice, ListPrice, Last_Delivery_Date__c, Is_Cancelled__c, Description, Position__c, Size__c, Colour__c, CopySplit__c, SCC_Rate__c, CCI_Order_Item_ID__c From OrderItem where OrderID = : currentOrder.Id]);
	}

	public static string getBrand() {
		set < String > brands = new set < String > ();
		string brandString;
		for (OrderItem oI: relatedItems) {
			if (oI.Publication_Name__c != null && oI.Publication_Name__c != '') brands.add(oI.Publication_Name__c.toUpperCase());
		}
		if (relatedItems.size() > 0) {
			if (brands.size() > 1) {
				return '[multiple]';
			} else {
				return relatedItems[0].Publication_Name__c;
			}
		} else {
			return '';
		}
	}

	public static string getAgency() {
		if (currentOrder.CCIBookingAgencyId__c != null && currentOrder.CCIBookingAgencyId__c != '') {
			Account agencyAccount = [select id, name from Account where CCIMailCustID__c = : currentOrder.CCIBookingAgencyId__c limit 1];
			return agencyAccount.name;
		} else {
			return '';
		}
	}

}