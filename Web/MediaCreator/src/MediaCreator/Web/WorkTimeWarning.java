package MediaCreator.Web;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.*;

import MediaCreator.Common.Config;
import MediaCreator.Common.DataBase;
import MediaCreator.Common.DataRow;
import MediaCreator.Common.DataTable;
import MediaCreator.Common.LogFactory;
import MediaCreator.Common.SessionControler;

/**
 * Servlet implementation class WorkTimeWarnig
 */
public class WorkTimeWarning extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private static Logger logger = LogFactory.getLogger();

       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public WorkTimeWarning() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		response.setDateHeader("Expires", -1);
		response.setHeader("pragma", "no-cache");
		response.setHeader("Cache-Control", "no-cache");
		response.addHeader("Cache-Control","no-store");
		response.setContentType("text/html; charset=UTF-8");
	
		doPost(request,response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		response.setDateHeader("Expires", -1);
		response.setHeader("pragma", "no-cache");
		response.setHeader("Cache-Control", "no-cache");
		response.addHeader("Cache-Control","no-store");
		response.setContentType("text/html; charset=UTF-8");
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/WorkTimeWarning.jsp");
		dispatcher.forward(request, response);

	}
	
	
	/*
	 * @return  true:業務時間内 / false:時間外
	 */
	public static boolean checkWorkTime(HttpServletRequest request, HttpServletResponse response){
		
		
		Config config = (Config)SessionControler.getValue(request, SessionControler.SYSTEMCONFIG);

		logger.debug("isCheckWorkTime = " + config.isCheckWorkTime());

		if(!config.isCheckWorkTime()){
			return true;
		}
		
		Connection conn = null;
		
		try{
			
			conn = DataBase.getRisConnection();

			
			DataTable Dat = DataBase.getZoneCode(conn);
			
			String zonecode = Dat.getRows().get(0).get("ZONE_CODE").toString();
			logger.debug("Zone_Code = " + zonecode);
			
		    if(zonecode.equals("1")){
		    	//日勤時間内
		    	return true;
		    }
		    else{
		    	return false;
		    }
		}
		catch(Exception e){
			logger.error(e.toString(),e);
			return true;
		}
		finally{
			DataBase.closeConnection(conn);
		}
		
	}

}
