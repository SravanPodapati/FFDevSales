//Test class with see all data to true to avoid exception "You have uncommitted work pending. Please commit or rollback before calling out"
@isTest (seeAllData = true)
public class Common_Test2 {
	static testMethod void profiles1() {
		//CCI Order Params
        //insert TestData.createOrderParamSettings();
        //insert TestData.createBookingSystemSettings();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //CCI Profiles 
        set <string> testCCIProfiles = common.CCIProfiles();
        testCCIProfiles = common.CCIProfiles();
        system.assertNotEquals(null, testCCIProfiles);
        
        //USerProfiles return part when it is not balnk
        String testUserProfile = Common.userProfile();
        system.assertNotEquals(null, testUserProfile);
        
    }
    
    static testmethod void profiles2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //USerProfiles
        String testUserProfile = Common.userProfile();
        system.assertNotEquals(null, testUserProfile);
    }
    
    static testmethod void group1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //CCI Groups
        set <string> testCCIGroups = common.CCIGroups();
        testCCIGroups = common.CCIGroups();
        system.assertNotEquals(null, testCCIGroups);
        
        //userGroup return part when it is not balnk
        String testuserGroup = Common.userGroup();
        system.assertNotEquals(null, testuserGroup);
    }
    
    static testmethod void group2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
	   
        //userGroup return part when it is not balnk
        String testuserGroup = Common.userGroup();
        system.assertNotEquals(null, testuserGroup);

    }
}