<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EventEmailSentFieldUpdate</fullName>
        <field>EmailSent__c</field>
        <literalValue>1</literalValue>
        <name>EventEmailSentFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EventEmailSentFieldUpdate</fullName>
        <actions>
            <name>EventEmailSentFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.Do_you_require_marketing_info__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Structured Sales Meeting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.EmailSent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This is used to ensure just one email is sent on first save of a Structured Sales Meeting event where Marketing Material is needed.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
