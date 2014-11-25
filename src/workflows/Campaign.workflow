<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CampaignCompleteMarkInactive</fullName>
        <description>If a campaign is marked as complete update Active to Inactive</description>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>CampaignCompleteMarkInactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CampaignCompleteMarkInactive</fullName>
        <actions>
            <name>CampaignCompleteMarkInactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>If a campaign is marked as complete update Active to Inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
