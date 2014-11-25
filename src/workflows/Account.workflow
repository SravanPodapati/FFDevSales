<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Agency_Account_created</fullName>
        <ccEmails>SSFOperative@anmedia.co.uk</ccEmails>
        <description>New Agency Account created</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Metro/New_Agency_Account_created</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateAccountNameCustomField</fullName>
        <field>Account_Name__c</field>
        <formula>IF(ISPICKVAL(Type, &apos;Private advertiser&apos;), TEXT(Salutation__c) + FirstName__c + Name +  BillingStreet +  SUBSTITUTE(BillingPostalCode, &apos; &apos;, &apos;&apos;) , Name + TEXT(Type) + if(IsActive__c,&apos;TRUE&apos;,&apos;FALSE&apos;)
+  if( IsMerchant__c ,&apos;TRUE&apos;,&apos;FALSE&apos;)
+  SUBSTITUTE(BillingPostalCode, &apos; &apos;, &apos;&apos;)   )</formula>
        <name>UpdateAccountNameCustomField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAccountType</fullName>
        <field>Type</field>
        <literalValue>Direct Advertiser</literalValue>
        <name>UpdateAccountType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCountryIfNullToUK</fullName>
        <description>If the Billing Street is null and the Bulling Country is null then update the Billing Country to UK</description>
        <field>BillingCountry</field>
        <formula>&quot;United Kingdom&quot;</formula>
        <name>UpdateCountryIfNullToUK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateMerchant</fullName>
        <field>IsMerchant__c</field>
        <literalValue>1</literalValue>
        <name>UpdateMerchant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToLocked</fullName>
        <description>If either CCI Mail ID or CCI Metro ID is populated set the account to Locked</description>
        <field>Status__c</field>
        <literalValue>Locked</literalValue>
        <name>UpdateStatusToLocked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Record_Type_Client</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Advertiser</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Account Record Type Client</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AccountAccountType</fullName>
        <actions>
            <name>UpdateAccountType</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateMerchant</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Lead_Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Wowcher</value>
        </criteriaItems>
        <description>Update Account Type if the record originates from Lead</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Account Record Type</fullName>
        <actions>
            <name>Update_Account_Record_Type_Client</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Direct Advertiser,Client</value>
        </criteriaItems>
        <description>Update the Account Record Type if it originates from a Lead</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateAccountNameCustomField</fullName>
        <actions>
            <name>UpdateAccountNameCustomField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>It updates AccountName Custom field with name of an Account</description>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCountryIfNull</fullName>
        <actions>
            <name>UpdateCountryIfNullToUK</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.BillingStreet</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.BillingCountry</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If the Billing Street has been entered and if the country is empty then assume United Kingdom</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateStatusToLocked</fullName>
        <actions>
            <name>UpdateStatusToLocked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Account.CCIMailCustID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CCIMetroCustID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If either CCI Mail ID or CCI Metro ID is populated set the account to Locked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>New_Agency_Account_created</fullName>
        <assignedTo>MetroDisplayFinanceHead</assignedTo>
        <assignedToType>role</assignedToType>
        <description>New Agency Account is created and needs to be approved.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>New Agency Account created.</subject>
    </tasks>
</Workflow>
