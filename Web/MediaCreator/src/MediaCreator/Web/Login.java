package MediaCreator.Web;

import java.io.IOException;
import java.net.URL;

import javax.naming.Context;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

import org.apache.log4j.*;

import MediaCreator.Common.Common;
import MediaCreator.Common.Config;
import MediaCreator.Common.DataBase;
import MediaCreator.Common.DataTable;
import MediaCreator.Common.LogFactory;
import MediaCreator.Common.SessionControler;

/**
 * Servlet implementation class Login
 */
public class Login extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private Logger logger = LogFactory.getLogger();
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Login() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		response.setDateHeader("Expires", -1);
		response.setHeader("pragma", "no-cache");
		response.setHeader("Cache-Control", "no-cache");
		response.addHeader("Cache-Control","no-store");
		response.setContentType("text/html; charset=UTF-8");

		request.setCharacterEncoding("UTF-8");

		//セッションクリア
		SessionControler.clearSession(request);
		
		
		//Config使うので読込む
		SessionControler.createSession(request);
		Config config = Config.getConfig(this.getServletContext());
		SessionControler.setValue(request, SessionControler.SYSTEMCONFIG, config);
		//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
		//接続リトライ回数保持
		DataBase.setRetryLimit(config.getConnectRetryLimit());	
		DataBase.setRetryInterval(config.getConnectRetryInterval());
		
		
		//業務時間チェック(Config情報を使うので Common.doLogin の後に呼ぶ事)
		if(!WorkTimeWarning.checkWorkTime(request, response)){
			logger.info("業務時間外");
			response.sendRedirect("WorkTimeWarning");
			return;
		}

		
		RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/Login.jsp");
		dispatcher.forward(request, response);


	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		response.setDateHeader("Expires", -1);
		response.setHeader("pragma", "no-cache");
		response.setHeader("Cache-Control", "no-cache");
		response.addHeader("Cache-Control","no-store");
		response.setContentType("text/html;UTF-8");

		request.setCharacterEncoding("UTF-8");

		
		
		boolean ret = Common.doLogin(request,response,this.getServletContext(),false,false);
		

		//業務時間チェック(Config情報を使うので Common.doLogin の後に呼ぶ事)
		if(!WorkTimeWarning.checkWorkTime(request, response)){
			logger.info("業務時間外");
			response.sendRedirect("WorkTimeWarning");
			return;
		}


		//No22 診療科処理変更
		if(ret){
			
			Connection conn = null;
			
			try{
				
				conn = DataBase.getRisConnection();
				
				String userid = request.getParameter("userid");
				
			
				//No22 診療科処理変更
				//依頼科チェック(ログインユーザーが何れかの診療科に所属しているか) 
				DataTable sectionDat = DataBase.getSectionMaster(userid,null,conn);
				if(sectionDat.getRowCount() == 0){
					//msg = "HISから指定されたパラメータに誤りがあります。";
					String msg = "診療科に所属されていない、または、システムに所属診療科が登録されていないためメディア作成依頼が制限されました。";
					request.setAttribute("ERRMSG", msg);
				
					ret = false;
				}
			}
			catch(Exception e){
				logger.error(e.toString(), e);
			}
			finally{
				DataBase.closeConnection(conn);
			}

		}
		
		if(ret){
			response.sendRedirect("MediaCreateMain?login=y");
			return;
		}
		
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/Login.jsp");
		dispatcher.forward(request, response);
		
	}
	


}
