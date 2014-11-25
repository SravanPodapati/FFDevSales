<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_owner_to_Virtual_Data_Team_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Virtual_Data_Team</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to Virtual Data Team  Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Integration Failure actions</fullName>
        <actions>
            <name>Change_owner_to_Virtual_Data_Team_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Integration_Logs__c.Status__c</field>
            <operation>equals</operation>
            <value>Failure</value>
        </criteriaItems>
        <description>Disable before Mass Updates.
Enable again after Mass Updates to CCI is complete.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
