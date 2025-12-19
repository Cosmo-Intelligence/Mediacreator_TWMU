package MediaCreator.Web;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import org.apache.log4j.*;

import MediaCreator.Common.*;


/**
 * Servlet implementation class GetReadme
 */
public class GetReadme extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	private Logger logger = LogFactory.getLogger();

	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GetReadme() {
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
		
		returnReadme(request,response);
	}

	private void returnReadme(HttpServletRequest request,HttpServletResponse response){
		
		String orderno = Common.toNullString(request.getParameter("orderno"));
		
		Connection conn = null;
		
		boolean result = false;
		
		try{
			
			conn = DataBase.getRisConnection();

			
			DataTable Dat = DataBase.getCodonicsMediaCompleteTable(orderno, conn);
			
			String readme = "";
			
			if(Dat.getRowCount() > 0){
				readme = Dat.getRows().get(0).get("README").toString();
				result = true;
			}
			
			//改行を変換
			readme = readme.replaceAll("\n", "\\\\n");
			readme = readme.replaceAll("\r", "\\\\r");

			String json = "{\"result\":\"" + result + "\",\"readme\":\"" + readme + "\"}";
		    
		    logger.debug(json);
		    
		    response.getWriter().write(json);
		    
		}
		catch(Exception e){
			logger.error(e.toString(),e);
		}
		finally{
			DataBase.closeConnection(conn);
		}
		
	}

}
