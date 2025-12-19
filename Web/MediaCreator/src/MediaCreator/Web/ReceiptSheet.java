package MediaCreator.Web;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import MediaCreator.Common.Config;
import MediaCreator.Common.DataBase;
import MediaCreator.Common.DataRow;
import MediaCreator.Common.DataTable;
import MediaCreator.Common.LogFactory;
import MediaCreator.Common.SessionControler;

import org.apache.log4j.*;

/**
 * Servlet implementation class ReceiptSheet
 */
public class ReceiptSheet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private Logger logger = LogFactory.getLogger();
	 
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ReceiptSheet() {
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
		
		
		String risid = request.getParameter("risid");
		
		Connection conn = null;
		
		try{
			conn = DataBase.getRisConnection();
		
			DataTable orderDat = DataBase.getCodonicsMediaOrderTable(risid, null, conn);

			DataTable studyDat = DataBase.getCodonicsMediaOrderStudyTable(risid, null, conn);
			
			String patientid = orderDat.getRows().get(0).get("KANJA_ID").toString();
			
			DataTable patientDat = DataBase.getPatientInfo(patientid, conn);

			if(orderDat.getRowCount() > 0){

				request.setAttribute("RIS_ID", orderDat.getRows().get(0).get("RIS_ID").toString());				//ris_id
				request.setAttribute("DOCTOR_NAME", orderDat.getRows().get(0).get("DOCTOR_NAME").toString());	//依頼医
				request.setAttribute("SECTION_NAME", orderDat.getRows().get(0).get("SECTION_NAME").toString());	//依頼科
				request.setAttribute("REQUESTDATE", orderDat.getRows().get(0).get("REQUESTDATE"));				//依頼日
				request.setAttribute("KANJA_ID", orderDat.getRows().get(0).get("KANJA_ID").toString());			//患者ID
				request.setAttribute("KANJISIMEI", orderDat.getRows().get(0).get("KANJISIMEI").toString());		//患者氏名
				request.setAttribute("ORDERNO", orderDat.getRows().get(0).get("ORDERNO").toString());			//AccessionNo
				
				String nyugai = "";
				if(patientDat.getRows().get(0).get("KANJA_NYUGAIKBN").toString().equals("1")){
					nyugai = "外来";
				}
				else if(patientDat.getRows().get(0).get("KANJA_NYUGAIKBN").toString().equals("2")){
					nyugai = "入院";
				}
				request.setAttribute("NYUGAI", nyugai);			//入外
				request.setAttribute("KANASIMEI", patientDat.getRows().get(0).get("KANASIMEI").toString());		//カナ氏名

				
				for(int i = 0; i < 20; i++){
					if(i < studyDat.getRowCount()){
						request.setAttribute("ACCESSIONNO" + "_" + (i+1), studyDat.getRows().get(i).get("ACCESSIONNO").toString());
						request.setAttribute("MODALITY_TYPE" + "_" + (i+1), studyDat.getRows().get(i).get("MODALITY_TYPE").toString());
						request.setAttribute("KENSA_DATE" + "_" + (i+1), studyDat.getRows().get(i).get("KENSA_DATE"));
						request.setAttribute("STUDYDESCRIPTION" + "_" + (i+1), studyDat.getRows().get(i).get("STUDYDESCRIPTION").toString());
					}
					else{
						request.setAttribute("ACCESSIONNO" + "_" + (i+1), "");
						request.setAttribute("MODALITY_TYPE" + "_" + (i+1), "");
						request.setAttribute("KENSA_DATE" + "_" + (i+1),null);
						request.setAttribute("STUDYDESCRIPTION" + "_" + (i+1), "");
					}
				}
			}
			
		    
			Config config = (Config)SessionControler.getValue(request, SessionControler.SYSTEMCONFIG);
			RequestDispatcher dispatcher = request.getRequestDispatcher(config.getRecelptSheetJspName());
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
