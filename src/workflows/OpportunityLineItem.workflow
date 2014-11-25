<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CustomerRef</fullName>
        <field>CustomerRef__c</field>
        <formula>TEXT(Product2.CustomerRef__c)</formula>
        <name>CustomerRef</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fill_Revenue_Group</fullName>
        <field>Revenue_Group__c</field>
        <formula>TEXT(PricebookEntry.Product2.Revenue_Group__c)</formula>
        <name>Fill Revenue Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Product_Family</fullName>
        <field>Product_Family__c</field>
        <formula>TEXT(Product2.Family)</formula>
        <name>Set Product Family</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Product_Id</fullName>
        <field>ProductId__c</field>
        <formula>Product2.Id</formula>
        <name>Set Product Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Product_Name</fullName>
        <field>Product_Name__c</field>
        <formula>PricebookEntry.Product2.Name</formula>
        <name>Set Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCustRef</fullName>
        <field>CustomerRef__c</field>
        <formula>text(Product2.CustomerRef__c)</formula>
        <name>UpdateCustRef</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Product_Date_with_First_Inser</fullName>
        <field>ServiceDate</field>
        <formula>First_Insertion_Date__c</formula>
        <name>Update Opp Product Date with First Inser</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>OppLine Item Product Family and CustRef into OppLineItem</fullName>
        <actions>
            <name>CustomerRef</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Fill_Revenue_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When adding Pitch Ideas (Products) to Opportunities - copy Product Billing System and Grouping</description>
        <formula>!$Setup.No_Workflow__c.Flag__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Product Name</fullName>
        <actions>
            <name>Set_Product_Family</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Product_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Opp Product Date with First Insertion Date</fullName>
        <actions>
            <name>Update_Opp_Product_Date_with_First_Inser</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.First_Insertion_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
