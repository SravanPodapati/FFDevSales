<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_ServiceDate_With_FirstInsertionDt</fullName>
        <field>ServiceDate__c</field>
        <formula>First_Insertion_Date__c</formula>
        <name>Update ServiceDate With FirstInsertionDt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update ServiceDate Field with FirstInsertionDate Field</fullName>
        <actions>
            <name>Update_ServiceDate_With_FirstInsertionDt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Inactive_Pitch_Idea__c.First_Insertion_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
