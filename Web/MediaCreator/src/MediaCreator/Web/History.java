package MediaCreator.Web;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import MediaCreator.Common.DataBase;
import MediaCreator.Common.DataRow;
import MediaCreator.Common.DataTable;
import MediaCreator.Common.LogFactory;
import MediaCreator.Common.SessionControler;

import org.apache.log4j.*;

/**
 * Servlet implementation class Hisotry
 */
public class History extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	private Logger logger = LogFactory.getLogger();
	 
    /**
     * @see HttpServlet#HttpServlet()
     */
    public History() {
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
		
		doPrint(request,response);
		
	}

	private void doPrint(HttpServletRequest request,HttpServletResponse response){

		//セッションタイムアウトでエラーにするため
		DataRow loginRow = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);
		String empid = loginRow.get("USERID").toString();

		
		String patientid = request.getParameter("patientid");
		
		Connection conn = null;
		
		try{
			conn = DataBase.getRisConnection();
		
			DataTable Dat = DataBase.getCodonicsMediaOrderTable(null, patientid, conn);
			request.setAttribute("ORDERLIST", Dat);
		    
			
			DataTable patientDat = DataBase.getPatientInfo(patientid, conn);
			request.setAttribute("PATIENTINFO", patientDat.getRows().get(0));

			
			RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/History.jsp");
			dispatcher.forward(request, response);

		}
		catch(Exception e){
			logger.error(e.toString(),e);
		}
		finally{
			DataBase.closeConnection(conn);
		}
		
	}
	
}
