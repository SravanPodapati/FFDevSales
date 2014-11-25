<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>QueryChaseEmail</fullName>
        <description>Query Chase Email</description>
        <protected>false</protected>
        <recipients>
            <field>SalesManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SalesPersonEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SalesSectionEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>QueryManagementTemplates/QueryChaseEmail</template>
    </alerts>
    <alerts>
        <fullName>QueryOpenEmail</fullName>
        <description>Query Open Email</description>
        <protected>false</protected>
        <recipients>
            <field>SalesManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SalesPersonEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SalesSectionEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>QueryManagementTemplates/QueryOpenEmail</template>
    </alerts>
    <fieldUpdates>
        <fullName>QueryClosedDate</fullName>
        <description>Updates the Query Closed Date whenever the Query Status is Denied or Passed</description>
        <field>QueryCloseDate__c</field>
        <formula>Today()</formula>
        <name>Query Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateApprovingCreditController</fullName>
        <description>Updates the Approving Credit Controller when the Credit Controller Approved checkbox is ticked</description>
        <field>ApprovingCreditController__c</field>
        <formula>$User.FirstName + &apos; &apos; +  $User.LastName</formula>
        <name>Update Approving Credit Controller</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCreditApprovalLevel</fullName>
        <description>Updates the Credit Approval Level</description>
        <field>CreditApprovalLevel__c</field>
        <formula>SalesApprover__r.CreditApprovalLevel__c</formula>
        <name>Update Credit Approval Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCreditControllerApprovedDate</fullName>
        <description>Updates the Credit Controller Approved Date when the Credit Controller Approved checkbox is ticked</description>
        <field>CreditControllerApprovedDate__c</field>
        <formula>Today()</formula>
        <name>Update Credit Controller Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateDateOpened</fullName>
        <description>Update the Date Time the Query was Opened.</description>
        <field>DateOpened__c</field>
        <formula>NOW()</formula>
        <name>Update Date Opened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSalesManagerEmail</fullName>
        <description>Updates the Sales Manager Email</description>
        <field>SalesManagerEmail__c</field>
        <formula>SalesManager__r.Email__c</formula>
        <name>Update Sales Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToQueryPassed</fullName>
        <description>Updates the Status to “Query Passed” when the Credit Controller Approved checkbox is ticked</description>
        <field>Status__c</field>
        <literalValue>Query Passed</literalValue>
        <name>Update Status to Query Passed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Credit Controller Approved</fullName>
        <actions>
            <name>UpdateApprovingCreditController</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateCreditControllerApprovedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateStatusToQueryPassed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Query__c.CreditControllerApproved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Enters the Credit Controller name and approval date when the Credit Controller Approved checkbox is ticked. Also updates the Status to “Query Passed”</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Query Chase Actions</fullName>
        <actions>
            <name>QueryChaseEmail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Query__c.Send48HrEmail__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email to the Sales Person, Sales Manager and Sales Team email address when the Send48HrEmail flag is set.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Query Closed</fullName>
        <actions>
            <name>QueryClosedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Query__c.Status__c</field>
            <operation>equals</operation>
            <value>Query Denied,Query Passed</value>
        </criteriaItems>
        <description>Enters the Query Closed Date when the Status is Queried Denied or Query Passed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Query Open Actions</fullName>
        <actions>
            <name>QueryOpenEmail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateDateOpened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Query__c.Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>Sends and email to the Sales Person, Sales Manager and Sales Team email address when the Query Status is changed to Open</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sales Approver Entered</fullName>
        <actions>
            <name>UpdateCreditApprovalLevel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Credit Approval Level whenever a Sales Approver is entered or changed</description>
        <formula>ISNEW() || ISCHANGED ( SalesApprover__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sales Manager Entered</fullName>
        <actions>
            <name>UpdateSalesManagerEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Sales Manager Email whenever a Sales Manager is entered or changed</description>
        <formula>ISNEW() || ISCHANGED ( SalesManager__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
