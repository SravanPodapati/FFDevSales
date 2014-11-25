<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateFinanceAccountRecordType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ReadOnly</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateFinanceAccountRecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Name</fullName>
        <field>UniqueName__c</field>
        <formula>Name+ Company__r.Name</formula>
        <name>Update Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update UniqueName</fullName>
        <actions>
            <name>Update_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FinanceAccount__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateFinanceAccountToReadOnly</fullName>
        <actions>
            <name>UpdateFinanceAccountRecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FinanceAccount__c.SOP_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>FinanceAccount__c.SOP_Source__c</field>
            <operation>equals</operation>
            <value>CCI</value>
        </criteriaItems>
        <description>UpdateFinanceAccountToReadOnly</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
