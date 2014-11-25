/**
 * Gateway methods for the c2g__codaCompany__c object
 */
public without sharing class CompanyGateway
{
    /**
     * Get the Current Company
     *
     * Arguments:   n/a
     *
     * Returns:     c2g__codaCompany__c - Current Company
     */
    public static c2g__codaCompany__c getCurrentCompany()
    {
        // Query companies based on users group subscription
        c2g__codaCompany__c[] companies = [Select Id, Name, OwnerId
                                           From c2g__codaCompany__c
                                           Where OwnerId in (select GroupId from GroupMember where Group.Type = 'Queue' and UserOrGroupId = :UserInfo.getUserId())];

        // Ensure the user has a single current company
        if(companies.size() == 0)
            throw new CompanyException('Current company has not been set for this user');
        if(companies.size() > 1)
            throw new CompanyException('This operation is not valid in multiple company mode'); 
        
        return companies[0];
    }

    public class CompanyException extends Exception {}
}