package MediaCreator.Web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.*;

import MediaCreator.Common.DataRow;
import MediaCreator.Common.LogFactory;
import MediaCreator.Common.SessionControler;

/**
 * Servlet implementation class Help
 */
public class Help extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private Logger logger = LogFactory.getLogger();

       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Help() {
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
		
		//セッションタイムアウトでエラーにするため
		DataRow loginRow = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);
		String empid = loginRow.get("USERID").toString();

		RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/Help.jsp");
		dispatcher.forward(request, response);

	}

}
