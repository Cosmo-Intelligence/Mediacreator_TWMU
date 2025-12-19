package MediaCreator.Common;


import org.apache.log4j.*;

public class LogFactory {
	
	private static Logger logger = null;

	public static Logger getLogger(){
		
		if(logger == null){
			logger = Logger.getLogger("MediaCreator");
		}
		
		return logger;
		
	}
	
}
