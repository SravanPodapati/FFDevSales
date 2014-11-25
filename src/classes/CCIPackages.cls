public with sharing class CCIPackages  implements Comparable{
   
    public String description;
    public String name;
    public String code;
   
    
    public CCIPackages(){}
    public CCIPackages(String description,String name,String code){
        this.description = description;
        this.name = name;
        this.code = code;
    }
    
    public Integer compareTo(Object compareTo) {
            CCIPackages compareObj = (CCIPackages)compareTo;
            if(this.name > compareObj.name){
                return 1;
            }else if(this.name < compareObj.name){
                return 0;
            }
            return -1;
        }
    
}