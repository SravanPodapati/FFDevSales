<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CD_Stamp_Latest_Rate_Date</fullName>
        <field>Last_Rate_Update_Date__c</field>
        <formula>Effective_Date__c</formula>
        <name>CD Stamp Latest Rate Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Currency_Director_Currencies__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CD_Stamp_Latest_Rate_Rate</fullName>
        <field>Last_Rate_Update_Rate__c</field>
        <formula>Rate__c</formula>
        <name>CD Stamp Latest Rate Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Currency_Director_Currencies__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>CD Stamp Currency with Latest Rate</fullName>
        <actions>
            <name>CD_Stamp_Latest_Rate_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CD_Stamp_Latest_Rate_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps the [Currency Director Currency] master with the latest exchange rate (vs. the [Currency Director] Base Currency)</description>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
