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
 * Servlet implementation class LoginAjax
 */
public class LoginAjax extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private Logger logger = LogFactory.getLogger();

       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginAjax() {
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
		
		doLogin(request,response);
		
	}
	
	
	private void doLogin(HttpServletRequest request,HttpServletResponse response){
		
		try{
			
			boolean result = false;

			result = Common.doLogin(request, response, this.getServletContext(), false, true);

			//No22 診療科処理変更
			if(result){
				
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
					
						result = false;
					}
				}
				catch(Exception e){
					logger.error(e.toString(), e);
				}
				finally{
					DataBase.closeConnection(conn);
				}
			}
			
			
			String errmsg = "";
			if(!result){
				errmsg = Common.toNullString((String)request.getAttribute("ERRMSG"));
			}
			

			String json = "{\"result\":\"" + result + "\",\"errmsg\":\"" + errmsg + "\"}";
		    
		    logger.debug(json);
		    
		    response.getWriter().write(json);
		    
		}
		catch(Exception e){
			logger.error(e.toString(),e);
		}
		finally{

		}
		
	}

}
