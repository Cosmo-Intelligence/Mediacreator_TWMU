package MediaCreator.Common;

import java.io.Serializable;
import java.util.*;

public class DataRow implements Serializable{
	
	private static final long serialVersionUID = 1L;

	private HashMap<String,Object> row = new HashMap<String,Object>(); 

	public void put(String columnName , Object value){
		if(value instanceof String){
			row.put(columnName, Common.toNullString((String)value));
		}
		else{
			row.put(columnName, value);
		}
	}

	public Object get(String columnName){
		return row.get(columnName);
	}

	public String[] getColumnNames(){
		String[] ret = new String[row.keySet().size()];
		row.keySet().toArray(ret);
		return ret;
	}
}
