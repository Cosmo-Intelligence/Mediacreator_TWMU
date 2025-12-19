package MediaCreator.Common;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;



public class SessionControler {

	public static final String LOGINUSER = "LOGINUSER";
	public static final String SYSTEMCONFIG = "SYSTEMCONFIG";
	public static final String MASTERSTUDYLIST = "MASTERSTUDYLIST";
	public static final String UNITYTYPE = "UNITYTYPE";
	
	
	public static boolean isLogin(HttpServletRequest request){
		
		if(getSession(request) == null){
			return false;
		}
		
		if(getValue(request,LOGINUSER) == null){
			return false;
		}
		
		return true;
	}
	
	public static HttpSession createSession(HttpServletRequest request){
		return request.getSession(true);
	}

	public static HttpSession getSession(HttpServletRequest request){
		return request.getSession(false);
	}
	
	public static Object getValue(HttpServletRequest request,String name){
		HttpSession session = request.getSession(false);
		
		return session.getAttribute(name);
	}

	public static void setValue(HttpServletRequest request,String name, Object value){
		HttpSession session = request.getSession(false);
		
		session.setAttribute(name,value);
	}

	public static void removeValue(HttpServletRequest request,String name){
		HttpSession session = request.getSession(false);
		
		session.removeAttribute(name);
	}

	public static void clearSession(HttpServletRequest request){
		
		HttpSession session = request.getSession(false);
		
		if(session == null){
			return;
		}
		
		session.invalidate();
		
		return;
	}
	
}


