package MediaCreator.Web;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.*;
import java.util.Hashtable;

import com.google.zxing.*;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;


import java.sql.*;

import org.apache.log4j.*;

import MediaCreator.Common.*;

/**
 * Servlet implementation class BarcodeTest
 */
public class BarcodeImage extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	private Logger logger = LogFactory.getLogger();

	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public BarcodeImage() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

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
		response.setContentType("image/png");	
	
		outputBarcode(request,response);
		
	}
	
	private void outputBarcode(HttpServletRequest request, HttpServletResponse response){
		
		try{
			
			String value = request.getParameter("value");
			String width =  Common.toNullString(request.getParameter("width"));
			String height = Common.toNullString(request.getParameter("height"));
			
			int x = 200;
			int	y = 50;
			
			if(!width.equals("")){
				x = Integer.parseInt(width);
			}

			if(!height.equals("")){
				y = Integer.parseInt(height);
			}
			
			
			//com.google.zxing.oned.Code128Writer writer = new com.google.zxing.oned.Code128Writer();
			//BitMatrix bitData = writer.encode(value,BarcodeFormat.CODE_128, x, y);

			com.google.zxing.oned.Code39Writer writer = new com.google.zxing.oned.Code39Writer();
			BitMatrix bitData = writer.encode(value,BarcodeFormat.CODE_39, x, y);
			
			//FileOutputStream output = new FileOutputStream("D:\\mycode.png");
            MatrixToImageWriter.writeToStream(bitData, "png", response.getOutputStream());
		}
		catch(Exception ex){
			ex.printStackTrace();
		}
		finally{
		}
	}

}
