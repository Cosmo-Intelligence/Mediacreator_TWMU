package MediaCreator.Web;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.sql.*;

import org.apache.log4j.*;

import MediaCreator.Common.*;


/**
 * Servlet implementation class CheckResultAjax
 */
public class CheckResultAjax extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private Logger logger = LogFactory.getLogger();

       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CheckResultAjax() {
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
		
		doCheck(request,response);
	
	}


	private void doCheck(HttpServletRequest request,HttpServletResponse response){
		
		String requestid = request.getParameter("requestid");
		
		String message = "";
		
		Connection conn = null;
		
		try{
			conn = DataBase.getRisConnection();
		
			DataTable dat = DataBase.getToCodonicsInfo(requestid, conn);
		
			boolean isFinished = false;

			if(dat.getRowCount() > 0){
				String transferstatus = dat.getRows().get(0).get("TRANSFERSTATUS").toString();
				
				if(transferstatus.equals("01")){
					isFinished = true;
				}

				//社内テストNo6 依頼ファイル作成失敗時のTransferStatus
				//失敗時はTransferStatuが"02"になる。
				if(transferstatus.equals("02")){
					isFinished = true;
					message = "メディア作成依頼に失敗しました。";
				}
			}
			
			String json = "{\"result\":\"" + isFinished + "\"" + "," + "\"message\":\"" + message + "\"}";
		    
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
