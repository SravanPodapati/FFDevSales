<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Update_Request_Pending</fullName>
        <description>Update Request Pending</description>
        <protected>false</protected>
        <recipients>
            <recipient>Virtual_Data_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Update_Request_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateOwner</fullName>
        <description>Update the owner field to the VirtualDataTeam Queue</description>
        <field>OwnerId</field>
        <lookupValue>Virtual_Data_Team</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>UpdateOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateOwner</fullName>
        <actions>
            <name>Update_Request_Pending</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Update_Request__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Owner field to be Virtual Data Team Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
