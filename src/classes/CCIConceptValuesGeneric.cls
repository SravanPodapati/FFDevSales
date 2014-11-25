public class CCIConceptValuesGeneric implements Comparable{
    public String description;
    public string name;
    public string code;
    public Integer compareTo(Object compareTo) {
        CCIConceptValuesGeneric compareObj = (CCIConceptValuesGeneric )compareTo;
        if(this.name > compareObj.name){
            return 1;
        }else if(this.name < compareObj.name){
            return 0;
        }
        return -1;
    }
}