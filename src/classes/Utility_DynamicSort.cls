global class Utility_DynamicSort {

	public class Utility_DynamicSortException extends Exception {}

	global Utility_DynamicSort() {

	}

	public list < sObject > sObjectListSort(list < sObject > items, String sortField, String direction) {

		//verify the values
		if (items == null) {
			throw new Utility_DynamicSortException('You must pass a valid list of sobjects');
		}

		//default sorting field if not specified 
		if (sortField == null || sortField == '') {
			sortField = 'id';
		}
		//default sorting direction if not specified
		if (direction == null || direction == '') {
			direction = 'ASC';
		}

		//verify wether the sorting field is valid or not 
		Schema.Sobjecttype objType = items != null && items.size() > 0 ? items[0].getSObjectType() : null;
		if (objType != null) {
			Map < String, Schema.SObjectField > objFieldsMap = objType.getDescribe().fields.getMap();
			if (!objFieldsMap.containsKey(sortField)) {
				throw new Utility_DynamicSortException('Sorting Field is invalid for Object Type ' + objType);
			}
		}

		list < sObject > resultList = new list < sObject > ();

		//Create a mp that can be used for sorting
		map < object, list < sObject >> objectMap = new map < object, list < sObject >> ();

		//Group the items based on the sorting field value
		for (sObject obj: items) {
			string temp = (String) obj.get(sortField);
			temp = temp != null ? temp.toUpperCase() : '';
			if (!objectMap.containsKey(temp)) {
				objectMap.put(temp, new list < sObject > ());
			}
			objectMap.get(temp).add(obj);
		}

		//Sort the map keys
		list < object > keys = new list < object > (objectMap.keySet());
		keys.sort();

		//Apply the sorting order
		if (direction.equalsIgnoreCase('ASC')) {
			for (object obj: keys) {
				resultList.addAll(objectMap.get(obj));
			}
		} else if (direction.equalsIgnoreCase('DESC')) {
			for (integer i = keys.size() - 1; i >= 0; i--) {
				resultList.addAll(objectMap.get(keys[i]));
			}
		}
		return resultList;
	}
}