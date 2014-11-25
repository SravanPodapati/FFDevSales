/***
Class created to send concept values back with package and media information to be used In Opportunity Line Item Creation
**/
public with sharing class ConceptValuesWithPackage{
   
   public String packageRuleName;
   public String titleCategoryCode;
   public Map<String,List<CCIConceptValuesGeneric>> conceptValues;
   public String mediaCode{public get; public set;}
   
   public ConceptValuesWithPackage(){}
   public ConceptValuesWithPackage(String packageRuleName,Map<String,List<CCIConceptValuesGeneric >> conceptValues,String titleCategoryCode){
       this.packageRuleName = packageRuleName;
       this.titleCategoryCode = titleCategoryCode;
       this.conceptValues = conceptValues;
       /*for(String key : this.conceptValues.keySet()){
           List<CCIConceptValuesGeneric> tempGenericList = this.conceptValues.get(key);
           if(tempGenericList != null && tempGenericList.size() > 1 ){
               tempGenericList.sort();
               this.conceptValues.put(key, tempGenericList);
           }
       }*/
   }
   
  
}