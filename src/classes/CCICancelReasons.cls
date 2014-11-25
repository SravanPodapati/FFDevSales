public class CCICancelReasons implements Comparable {
    
	public String description;
	public String name;
	public String code;
	
	public CCICancelReasons(){
		
	}
	
	public Integer compareTo(Object compareTo) {
        CCICancelReasons compareToObj = (CCICancelReasons)compareTo;
        if(this.name > compareToObj.name){
        	return 1;
        }
        if(this.name < compareToObj.name){
        	return -1;
        }
        return 0;
	}
}