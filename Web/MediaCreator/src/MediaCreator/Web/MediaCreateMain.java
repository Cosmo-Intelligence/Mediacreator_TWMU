package MediaCreator.Web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Timestamp;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import MediaCreator.Common.Common;
import MediaCreator.Common.Config;
import MediaCreator.Common.DataBase;
import MediaCreator.Common.DataRow;
import MediaCreator.Common.DataTable;
import MediaCreator.Common.LogFactory;
import MediaCreator.Common.SessionControler;

/**
 * Servlet implementation class MediaCreateMain
 */
public class MediaCreateMain extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private Logger logger = LogFactory.getLogger();


	private static final String REQUESTTYPE_CREATE = "create";
	private static final String REQUESTTYPE_SEARCH = "search";
	private static final String REQUESTTYPE_CLEAR = "clear";
	private static final String REQUESTTYPE_PATIENT = "patient";
	private static final String REQUESTTYPE_SECTION = "changesection";

    /**
     * @see HttpServlet#HttpServlet()
     */
    public MediaCreateMain() {
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

		//GETパラメータは日本語が文字化けするので注意!!
		//使うときはこんな感じで自力でデコードすること!!
		//String buff = new String (Common.toNullString(request.getParameter("txtComments")).getBytes("ISO-8859-1"));
		//comment = URLDecoder.decode(buff,"UTF-8");

		//ログイン画面から
		String login = request.getParameter("login");

		//電子カルテ連携
		String userid = request.getParameter("userid");
		String sectionid = request.getParameter("sectionid");
		String pid = request.getParameter("pid");


		if(login == null){

			String msg = "";
			String logmsg = "";

			if(userid == null || sectionid == null || pid == null ){
				msg = "HISから必要な情報が渡ってきませんでした。";
				logmsg = "パラメータ未指定";

				//この後ログイン処理があるのでこの時点でReturnする。
				//連携エラー画面
				showKarteError(request,response,msg,logmsg);
				return;
			}

			boolean ret = Common.doLogin(request, response, this.getServletContext(),true, false);

			//業務時間チェック(Config情報を使うので Common.doLogin の後に呼ぶ事)
			if(!WorkTimeWarning.checkWorkTime(request, response)){
				logger.info("業務時間外");
				response.sendRedirect("WorkTimeWarning");
				return;
			}


			if(!ret){
				msg = "HISから指定されたパラメータに誤りがあります。";
				logmsg = "パラメータ誤り";
				//response.sendRedirect("Login");
				//return;
			}


			//空白が付いてくる事があるのでtrimする。
			userid = Common.toNullString(userid).trim();
			sectionid = Common.toNullString(sectionid).trim();
			pid = Common.toNullString(pid).trim();

			if(userid.equals("") || sectionid.equals("") || pid.equals("") ){
				msg = "HISから必要な情報が渡ってきませんでした。";
				logmsg = "パラメータ空";
			}


			//誤りチェック
			if(msg.equals("")){

				Connection conn = DataBase.getRisConnection();
				try{

					//ユーザーはログイン処理でチェックしてるのでしない。

					//患者チェック
					DataTable patientDat = DataBase.getPatientInfo(pid, conn);
					if(patientDat.getRowCount() == 0){
						msg = "HISから指定されたパラメータに誤りがあります。";
						logmsg = "パラメータ誤り";
					}

					//No22 診療科処理変更 診療科チェックしない
					//依頼科チェック
					//DataTable sectionDat = DataBase.getSectionMaster(userid, sectionid, conn);
					//if(sectionDat.getRowCount() == 0){
					//	//msg = "HISから指定されたパラメータに誤りがあります。";
					//	msg = "診療科に所属されていない、または、システムに所属診療科が登録されていないためメディア作成依頼が制限されました。";
					//	logmsg = "パラメータ誤り";
					//}

					//No22 診療科処理変更
					//依頼科チェック(ログインユーザーが何れかの診療科に所属しているか)
					DataTable sectionDat = DataBase.getSectionMaster(userid,null,conn);
					if(sectionDat.getRowCount() == 0){
						//msg = "HISから指定されたパラメータに誤りがあります。";
						msg = "診療科に所属されていない、または、システムに所属診療科が登録されていないためメディア作成依頼が制限されました。";
						logmsg = "パラメータ誤り";
					}

					//No22 診療科処理変更
					//依頼科チェック(診療科が存在するか)
					sectionDat = DataBase.getSectionMaster(null,sectionid,conn);
					if(sectionDat.getRowCount() == 0){
						//msg = "HISから指定されたパラメータに誤りがあります。";
						msg = "診療科に所属されていない、または、システムに所属診療科が登録されていないためメディア作成依頼が制限されました。";
						logmsg = "パラメータ誤り";
					}

				}
				catch(Exception e){
					logger.error(e.toString(), e);
				}
				finally{
					DataBase.closeConnection(conn);
				}
			}


			if(msg.equals("")){
				String url = "MediaCreateMain?pid=" + pid + "&selSectionid=" + sectionid + "&fromKarte=y&login=y";
				response.sendRedirect(url);
				return;
			}
			else{
				//連携エラー画面
				showKarteError(request,response,msg,logmsg);
				return;
			}
		}

		doPost(request,response);


	}


	private void showKarteError(HttpServletRequest request, HttpServletResponse response, String msg, String logmsg) throws ServletException, IOException{

		StringBuffer requesturl = request.getRequestURL();

		String query = request.getQueryString();

		if(query != null){
			requesturl.append("?").append(query);
		}

		logger.error("HIS-URL連携:" + logmsg + "=[" + requesturl.toString() + "]");

		request.setAttribute("errmsg",msg);
		RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/KarteError.jsp");
		dispatcher.forward(request, response);
		return;
	}


	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		response.setDateHeader("Expires", -1);
		response.setHeader("pragma", "no-cache");
		response.setHeader("Cache-Control", "no-cache");
		response.addHeader("Cache-Control","no-store");
		response.setContentType("text/html; charset=UTF-8");

		request.setCharacterEncoding("UTF-8");


		//業務時間チェック(Config情報を使うので Common.doLogin の後に呼ぶ事)
		if(!WorkTimeWarning.checkWorkTime(request, response)){
			logger.info("業務時間外");
			response.sendRedirect("WorkTimeWarning");
			return;
		}


		String requesttype = Common.toNullString(request.getParameter("requesttype"));

		String fromKarte = Common.toNullString(request.getParameter("fromKarte"));

		if(!SessionControler.isLogin(request)){
			logger.debug("Not Logged In!!");
			response.sendRedirect("Login");
			return;
		}


		DataRow patientRow = null;
		String patientid = request.getParameter("pid");
		if(!Common.toNullString(patientid).equals("")){
			patientRow = setPatientInfo(patientid,request);
		}

		setSelectList(request);

		if(requesttype.equals(REQUESTTYPE_PATIENT)){
			SessionControler.removeValue(request,SessionControler.MASTERSTUDYLIST);

			//監査証跡
			Connection risConn = null;
			Connection unityConn = null;
			try{

				risConn = DataBase.getRisConnection();
				unityConn = DataBase.getUnityConnection();

				Timestamp sysdate = DataBase.getSysdate(unityConn);

				DataTable serverDat = DataBase.getCurrentServerType(risConn);

				String servertype = serverDat.getRows().get(0).get("CURRENTTYPE").toString();

				String ipaddr = request.getRemoteAddr();

				DataRow loginRow = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);

				DataBase.insertAuditTrail(servertype, sysdate, "DISPLAY", patientRow, loginRow, ipaddr, unityConn);
				unityConn.commit();
			}
			catch(Exception ee){
				try{
					unityConn.rollback();
				}
				catch(Exception eee){
					//NULL;
				}
				logger.error(ee.toString(),ee);
			}
			finally{
				DataBase.closeConnection(risConn);
				DataBase.closeConnection(unityConn);

			}
		}

		if(requesttype.equals(REQUESTTYPE_CLEAR)){
			SessionControler.removeValue(request,SessionControler.MASTERSTUDYLIST);
		}

		//受入No12 患者決定時の画像検索
		//if(requesttype.equals(REQUESTTYPE_SEARCH)){
		if(requesttype.equals(REQUESTTYPE_SEARCH) || requesttype.equals(REQUESTTYPE_PATIENT) || !fromKarte.equals("")){
			searchMasterStudy(request);
		}

		if(requesttype.equals(REQUESTTYPE_CREATE)){
			if(createRisOrder(request)){;
				request.setAttribute("MODE", "creating");
				DataTable dat = (DataTable)SessionControler.getValue(request,SessionControler.MASTERSTUDYLIST);
				SessionControler.removeValue(request,SessionControler.MASTERSTUDYLIST);
				request.setAttribute("MASTERSTUDYLIST", dat);
			}
		}

		if(requesttype.equals(REQUESTTYPE_SECTION)){
			DataTable dat = (DataTable)SessionControler.getValue(request,SessionControler.MASTERSTUDYLIST);
			request.setAttribute("MASTERSTUDYLIST", dat);
		}

		// 2021.08.19 del start cosmo@Nishihara 未使用の為削除
		//ViewC用
		// setViewCInfo(request);
		// 2021.08.19 del end cosmo@Nishihara 未使用の為削除

		RequestDispatcher dispatcher = request.getRequestDispatcher("jsp/MediaCreateMain.jsp");
		dispatcher.forward(request, response);

	}


	private DataRow setPatientInfo(String patientid, HttpServletRequest request){

		DataRow ret = null;

		Connection conn = null;

		try{
			conn = DataBase.getRisConnection();

			DataTable dat = DataBase.getPatientInfo(patientid, conn);

			if(dat.getRowCount() == 0){
				addErrorMessage("該当する患者が見つかりません。",request);
				return ret;
			}

			request.setAttribute("PATIENTINFO", dat.getRows().get(0));

			ret = dat.getRows().get(0);

		}
		catch(Exception e){
			logger.error(e.toString(),e);
			//
			//受入No13 DBエラー時のメッセージ
			//addErrorMessage(e.toString(),request);
			addErrorMessage("患者検索に失敗しました。",request);
		}
		finally{
			DataBase.closeConnection(conn);
		}

		return ret;

	}

	private void setSelectList(HttpServletRequest request){

		Connection conn = null;
		Connection arqsConn = null;
		try{

			Config config = (Config)SessionControler.getValue(request,SessionControler.SYSTEMCONFIG);

			DataRow loginRow = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);
			String loginId = loginRow.get("USERID").toString();

			conn = DataBase.getRisConnection();
			arqsConn = DataBase.getArqsConnection();

			Timestamp sysdate = DataBase.getSysdate(conn);
			request.setAttribute("SYSDATE", sysdate);


			//依頼科
			String fromKarte = Common.toNullString(request.getParameter("fromKarte"));
			String sectionid = null;
			if(!fromKarte.equals("")){
				sectionid = Common.toNullString(request.getParameter("selSectionid"));
				if(sectionid.equals("")){
					sectionid = null;
				}
			}
			//No22 依頼科処理変更
			//DataTable iraiDat = DataBase.getSectionMaster(loginId, sectionid, conn);
			DataTable iraiDat = DataBase.getSectionMaster(null, sectionid, conn);
			request.setAttribute("SECTIONLIST", iraiDat);


			//依頼医
			DataTable doctorDat = DataBase.getSectionDoctorMaster(null, loginId, conn);
			request.setAttribute("DOCTORLIST", doctorDat);

			//作成区分
			DataTable kbnDat = DataBase.getBuiMaster(config.getSakuseiKbn(), conn);
			request.setAttribute("KUBUNLIST", kbnDat);

			//作成装置
			DataTable soutiDat = DataBase.getKensakikiMaster(config.getSakuseiSouti(), conn);
			request.setAttribute("SOUTILIST", soutiDat);

			//モダリティ
			//DataTable modalityDat = DataBase.getModalityList(conn);
			//MIS受入テスト No47
			String patientid = Common.toNullString(request.getParameter("pid"));
			if(patientid.equals("")){
				patientid = null;
			}
			DataTable modalityDat = DataBase.getModalityListFromArqs(patientid, arqsConn);
			request.setAttribute("MODALITYLIST", modalityDat);

		}
		catch(Exception e){
			logger.error(e.toString(),e);
			//受入No13 DBエラー時のメッセージ
			//addErrorMessage(e.toString(),request);
			addErrorMessage("画面情報の取得に失敗しました。",request);
		}
		finally{
			DataBase.closeConnection(conn);
			DataBase.closeConnection(arqsConn);
		}

	}


	private void searchMasterStudy(HttpServletRequest request){

		Connection conn = null;

		try{

			String patientid = Common.toNullString(request.getParameter("pid"));
			String chkModality = Common.toNullString(request.getParameter("chkModality"));
			String modality = Common.toNullString(request.getParameter("selModality"));
			String chkDate = Common.toNullString(request.getParameter("chkKensadate"));
			String dateFromString = Common.toNullString(request.getParameter("dateFrom"));
			String dateToString = Common.toNullString(request.getParameter("dateTo"));

			Timestamp dateFrom = null;
			Timestamp dateTo = null;

			//患者ID未指定時は検索しない。
			if(patientid.equals("")){
				return;
			}

			if(modality.equals("")){
				modality = null;
			}


			//チェックボックス無くなった
			//if(chkModality.equals("")){
			//	modality = null;
			//}

			//チェックボックス無くなった
			//if(chkDate.equals("")){
			//	dateFrom = null;
			//	dateTo = null;
			//}
			//else{
				if(dateFromString.equals("")){
					dateFrom = null;
				}
				else{
					dateFrom = Common.toTimestamp(dateFromString);
				}

				if(dateToString.equals("")){
					dateTo = null;
				}
				else{
					dateTo = Common.toTimestamp(dateToString);
				}
			//}

			conn = DataBase.getArqsConnection();	//ARQS
			//DataTable studyDat = DataBase.getMasterStudy(null, patientid, modality, dateFrom, dateTo, conn);
			DataTable studyDat = DataBase.getMasterStudy(null, patientid, modality, null, dateFrom, dateTo, conn);
			request.setAttribute("MASTERSTUDYLIST", studyDat);

			//再表示用に保持
			SessionControler.setValue(request, SessionControler.MASTERSTUDYLIST, studyDat);

		}
		catch(Exception e){
			logger.error(e.toString(),e);
			//受入No13 DBエラー時のメッセージ
			//addErrorMessage(e.toString(),request);
			addErrorMessage("画像検索に失敗しました。",request);
		}
		finally{
			DataBase.closeConnection(conn);
		}
	}


	private boolean createRisOrder(HttpServletRequest request){

		Connection conn  = null;
		Connection connArqs = null;
		Connection connUnity = null;

		try{
			conn = DataBase.getRisConnection();
			connArqs = DataBase.getArqsConnection();
			connUnity = DataBase.getUnityConnection();

			Config config = (Config)SessionControler.getValue(request, SessionControler.SYSTEMCONFIG);
			DataRow loginRow = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);


			String kensatypeid = config.getKensatypeid();


			DataTable kensatypeDat = DataBase.getKensaTypeMaster(config.getKensatypeid(), conn);
			DataRow kensatypeRow = kensatypeDat.getRows().get(0);

			Timestamp sysdate = DataBase.getSysdate(conn);

			String kensadate = Common.toFormatString(sysdate,"yyyyMMdd");

			//社内No15 OrderMainTableのKensa_Starttime
			//String kensatime = Common.toFormatString(sysdate,"hhmmss");
			String kensatime = Common.toFormatString(sysdate,"HHmmss");

			//ToHisInfoのRequestTerminalに合わせて10Byte以内にする。
			String terminalname = "MediaCreat";

			//実施者
			String jisisyaId = Common.toNullString(config.getJisisyaID());
			String jisisyaName = "";

			DataTable jisiDat =DataBase.getJisisya(jisisyaId, connUnity);
			if(jisiDat.getRowCount() > 0){
				jisisyaName = jisiDat.getRows().get(0).get("USERNAME").toString();
			}

			//configに設定してない時はログインユーザー
			if(jisisyaId.equals("")){
				jisisyaId = loginRow.get("USERID").toString();
				jisisyaName = loginRow.get("USERNAME").toString();
			}

			//画面入力
			String patientid = request.getParameter("pid");
			String sectionid = request.getParameter("selSectionid");
			String doctorid = request.getParameter("selDoctorid");
			String sakuseikbn = request.getParameter("selSakuseikbn");
			String sakusesouti = request.getParameter("selSakuseisouti");
			String mediatype = request.getParameter("selMediatype");
			String comments = request.getParameter("txtComments");

			//String[] acnolist = request.getParameterValues("chkSelect");
			String[] uidlist = request.getParameterValues("chkSelect");

			//TODO: 対象Study


			DataTable patientDat = DataBase.getPatientInfo(patientid, conn);
			DataRow patientRow = patientDat.getRows().get(0);

			DataTable buiMstDat = DataBase.getBuiMaster(sakuseikbn,conn);
			DataRow buiMstRow = buiMstDat.getRows().get(0);

			//社内テストNo7 CodonicsMediaOrderTableのKensaKikiの値
			DataTable kikiDat = DataBase.getKensakikiMaster(sakusesouti, conn);
			DataRow kikiRow = kikiDat.getRows().get(0);

			String aetitle = kikiRow.get("AE_TITLE_MWM").toString();
			if(aetitle.equals("")){
				aetitle = kikiRow.get("KENSAKIKI_ID").toString();
			}


			//Ris_id(RisIdSequence.nextval)
			String risid = DataBase.createRisId(conn);

			//OrderNo(RisOrderSequence.nextval)
			String orderno = DataBase.createOrderNo(conn);

			//StudyInstanceUid(1.2.392.200045.6960.4.7.nnnnnn.ris_id)(systemdefine.licenceno)
			String studyinstanceuid = DataBase.createSutudyInstanceUid(risid,config.getStudyInstanceUid(), conn);

			//ToCodonicsInfo RequestID
			String requestid = DataBase.createToCodonicsRequestId(conn);

			//業務区分
			DataTable Dat = DataBase.getZoneCode(conn);
			String gyoumukbn = "";
			if(Dat.getRowCount() > 0){
				gyoumukbn = Dat.getRows().get(0).get("ZONE_CODE").toString();
			}


			//画面に渡す用
			request.setAttribute("create_risid", risid);
			request.setAttribute("create_orderno", orderno);
			request.setAttribute("create_requestid", requestid);


			//OederMainTable
			DataRow orderRow = new DataRow();
			orderRow.put("RIS_ID", risid);
			orderRow.put("SYSTEMKBN", "1");
			orderRow.put("STUDYINSTANCEUID", studyinstanceuid);
			orderRow.put("ORDERNO", orderno);
			orderRow.put("ACCESSIONNO", orderno);
			orderRow.put("KENSA_DATE", kensadate);
			orderRow.put("KENSA_STARTTIME", kensatime);
			orderRow.put("KENSATYPE_ID", kensatypeid);

			//orderRow.put("KENSASITU_ID", buiMstRow.get("EXAMROOM_ID").toString());
			orderRow.put("KENSASITU_ID", config.getKensasituID());	//固定文字

			orderRow.put("KENSAKIKI_ID", sakusesouti);
			orderRow.put("SYOTISITU_FLG", buiMstRow.get("SYOTISITU_FLG").toString());
			orderRow.put("KANJA_ID", patientid);
			orderRow.put("KENSA_DATE_AGE", patientRow.get("AGE").toString());
			orderRow.put("DENPYO_NYUGAIKBN", patientRow.get("KANJA_NYUGAIKBN").toString());
			orderRow.put("IRAI_SECTION_ID", sectionid);
			orderRow.put("IRAI_DOCTOR_NO", doctorid);
			orderRow.put("DOKUEI_FLG", buiMstRow.get("DOKUEI_FLG").toString());

			DataBase.updateTable("OrderMainTable", "RIS_ID", orderRow, conn);


			//ExtendOrderInfo
			DataRow extendRow = new DataRow();
			extendRow.put("RIS_ID", risid);
			extendRow.put("ORDER_DATE", sysdate);
			extendRow.put("RIS_HAKKO_TERMINAL", terminalname);
			extendRow.put("RIS_HAKKO_USER", loginRow.get("USERID").toString());
			extendRow.put("HIS_HAKKO_DATE", sysdate);
			extendRow.put("HIS_UPDATE_DATE", sysdate);
			extendRow.put("RI_ORDER_FLG", buiMstRow.get("RI_ORDER_FLG").toString());
			extendRow.put("HIS_UPDATE_DATE", sysdate);
			extendRow.put("YOTEIKAIKEI_FLG", kensatypeRow.get("DEF_KAIKEI_FLG").toString());
			extendRow.put("ISITATIAI_FLG", buiMstRow.get("ISITATIAI_FLG").toString());
			extendRow.put("PORTABLE_FLG", buiMstRow.get("PORTABLEFLAG").toString());
			extendRow.put("KENSA_SYOKAI_FLG", "0");
			// 2021.08.30 mod start cosmo@Nishihara
			// extendRow.put("SHIKYU_FLG", "0");
			extendRow.put("SIKYU_FLG", "0");
			// 2021.08.30 mod end cosmo@Nishihara
			extendRow.put("SEISAN_FLG", "0");

			DataBase.updateTable("ExtendOrderInfo", "RIS_ID", extendRow, conn);


			//OrderIndicateTable
			DataRow indicateRow = new DataRow();
			indicateRow.put("RIS_ID", risid);
			//indicateRow.put("ORDERCOMMENT_ID", comments); 	//社内テストNo3 コメント登録でエラー

			//No29 コメントの保存先  2014/05/20 S.Terakata(STI)
			indicateRow.put("ORDERCOMMENT_ID", comments);

			DataBase.updateTable("OrderIndicateTable", "RIS_ID", indicateRow, conn);


			//OrderBuiTable
			DataRow orderBuiRow = new DataRow();
			orderBuiRow.put("RIS_ID", risid);
			orderBuiRow.put("NO", "1");
			orderBuiRow.put("BUI_ID", buiMstRow.get("BUI_ID").toString());
			orderBuiRow.put("KENSASITU_ID", orderRow.get("KENSASITU_ID").toString());
			orderBuiRow.put("KENSAKIKI_ID", orderRow.get("KENSAKIKI_ID").toString());

			DataBase.updateTable("OrderBuiTable", new String[]{"RIS_ID","NO"}, orderBuiRow, conn);


			//ExMainTable
			DataRow exMainRow = new DataRow();
			exMainRow.put("RIS_ID", risid);
			exMainRow.put("KENSATYPE_ID",orderRow.get("KENSATYPE_ID").toString());
			exMainRow.put("KENSA_DATE",orderRow.get("KENSA_DATE").toString());
			exMainRow.put("KENSASITU_ID",orderRow.get("KENSASITU_ID").toString());
			exMainRow.put("KENSAKIKI_ID",orderRow.get("KENSAKIKI_ID").toString());
			exMainRow.put("KANJA_ID",orderRow.get("KANJA_ID").toString());
			exMainRow.put("KENSA_DATE_AGE",orderRow.get("KENSA_DATE_AGE").toString());
			exMainRow.put("DENPYO_NYUGAIKBN",orderRow.get("DENPYO_NYUGAIKBN").toString());
			exMainRow.put("UKETUKE_TANTOU_ID",loginRow.get("USERID").toString());
			exMainRow.put("UKETUKE_TANTOU_NAME",loginRow.get("USERNAME").toString());
			exMainRow.put("RECEIPTDATE",sysdate);
			//exMainRow.put("RECEIPTTERMINALID",terminalname);
			exMainRow.put("EXAMSTARTDATE",sysdate);
			exMainRow.put("EXAMENDDATE",sysdate);
			//exMainRow.put("EXAMTERMINALID",terminalname);
			exMainRow.put("GYOUMU_KBN",gyoumukbn);
			exMainRow.put("STATUS","20");		//検査中
			exMainRow.put("RECEIPTFLAG","ON");
			exMainRow.put("EXAMSAVEFLAG","1");

			exMainRow.put("JISISYA_ID",jisisyaId);
			exMainRow.put("JISISYA_NAME",jisisyaName);

			DataBase.updateTable("ExMainTable", "RIS_ID", exMainRow, conn);


			//ExtendExamInfo
			DataRow extendExamRow = new DataRow();
			extendExamRow.put("RIS_ID", risid);
			extendExamRow.put("DOKUEI_FLG", buiMstRow.get("DOKUEI_FLG").toString());
			extendExamRow.put("JISSEKIKAIKEI_FLG", kensatypeRow.get("DEF_KAIKEI_FLG").toString());

			DataBase.updateTable("ExtendExamInfo", "RIS_ID", extendExamRow, conn);


			//ExBuitable
			DataRow exBuiRow = new DataRow();
			exBuiRow.put("RIS_ID", risid);
			exBuiRow.put("NO", "1");
			exBuiRow.put("BUI_ID", orderBuiRow.get("BUI_ID").toString());
			exBuiRow.put("KENSASITU_ID",orderRow.get("KENSASITU_ID").toString());
			exBuiRow.put("KENSAKIKI_ID",orderRow.get("KENSAKIKI_ID").toString());
			exBuiRow.put("SATUEISTATUS", "1");

			DataBase.updateTable("ExBuitable", new String[]{"RIS_ID","NO"}, exBuiRow, conn);


			//PatientResultsInfo
			DataRow patResultsRow = new DataRow();
			patResultsRow.put("RIS_ID", risid);
			patResultsRow.put("KANJA_ID",patientRow.get("KANJA_ID").toString());
			patResultsRow.put("KANJISIMEI",patientRow.get("KANJISIMEI").toString());
			patResultsRow.put("ROMASIMEI",patientRow.get("ROMASIMEI").toString());
			patResultsRow.put("KANASIMEI",patientRow.get("KANASIMEI").toString());
			patResultsRow.put("BIRTHDAY",patientRow.get("BIRTHDAY").toString());
			patResultsRow.put("SEX",patientRow.get("SEX").toString());
			patResultsRow.put("KANJA_NYUGAIKBN",patientRow.get("KANJA_NYUGAIKBN").toString());
			patResultsRow.put("SECTION_ID",patientRow.get("SECTION_ID").toString());
			patResultsRow.put("BYOUTOU_ID",patientRow.get("BYOUTOU_ID").toString());
			patResultsRow.put("BYOUSITU_ID",patientRow.get("BYOUSITU_ID").toString());
			patResultsRow.put("TALL",patientRow.get("TALL").toString());
			patResultsRow.put("WEIGHT",patientRow.get("WEIGHT").toString());
			patResultsRow.put("BLOOD",patientRow.get("BLOOD").toString());
			patResultsRow.put("TRANSPORTTYPE",patientRow.get("TRANSPORTTYPE").toString());
			patResultsRow.put("HANDICAPPEDMARK",patientRow.get("HANDICAPPEDMARK").toString());
			patResultsRow.put("HANDICAPPED",patientRow.get("HANDICAPPED").toString());
			patResultsRow.put("INFECTIONMARK",patientRow.get("INFECTIONMARK").toString());
			patResultsRow.put("INFECTION",patientRow.get("INFECTION").toString());
			patResultsRow.put("CONTRAINDICATIONMARK",patientRow.get("CONTRAINDICATIONMARK").toString());
			patResultsRow.put("CONTRAINDICATION",patientRow.get("CONTRAINDICATION").toString());
			patResultsRow.put("ALLERGYMARK",patientRow.get("ALLERGYMARK").toString());
			patResultsRow.put("ALLERGY",patientRow.get("ALLERGY").toString());
			patResultsRow.put("PREGNANCYMARK",patientRow.get("PREGNANCYMARK").toString());
			patResultsRow.put("PREGNANCY",patientRow.get("PREGNANCY").toString());
			patResultsRow.put("NOTESMARK",patientRow.get("NOTESMARK").toString());
			patResultsRow.put("NOTES",patientRow.get("NOTES").toString());
			patResultsRow.put("EXAMDATA",patientRow.get("EXAMDATA").toString());
			patResultsRow.put("EXTRAPROFILE",patientRow.get("EXTRAPROFILE").toString());
			patResultsRow.put("CREATININERESULT",patientRow.get("CREATININERESULT").toString());
			patResultsRow.put("CREATININEUPDATEDATE",patientRow.get("CREATININEUPDATEDATE"));
			patResultsRow.put("EGFRRESULT",patientRow.get("EGFRRESULT").toString());
			patResultsRow.put("EGFRUPDATEDATE",patientRow.get("EGFRUPDATEDATE"));


			DataBase.updateTable("PatientResultsInfo", "RIS_ID", patResultsRow, conn);


			//ToCodonicsInfo
			//String filename = "order_" + orderno + "_" + Common.toFormatString(sysdate, "yyyyMMddhhmmss") + ".idx";
			String filename = "order_" + orderno + "_" + Common.toFormatString(sysdate, "yyyyMMddHHmmss") + ".idx";	//社内テストNo5 ToCodonicsInfoのIndexFileName

			DataRow toCodonicsRow = new DataRow();
			toCodonicsRow.put("REQUESTID", requestid);
			toCodonicsRow.put("REQUESTDATE", sysdate);
			toCodonicsRow.put("RIS_ID", risid);
			toCodonicsRow.put("REQUESTUSER", loginRow.get("USERID").toString());
			toCodonicsRow.put("REQUESTTYPE", "00");
			toCodonicsRow.put("INDEXFILENAME", filename);
			toCodonicsRow.put("TRANSFERSTATUS", "00");
			toCodonicsRow.put("TRANSFERDATE", sysdate);

			DataBase.updateTable("ToCodonicsInfo", "REQUESTID", toCodonicsRow, conn);


			//CodonicsMediaOrderTable
			DataRow mediaOrderRow = new DataRow();
			mediaOrderRow.put("RIS_ID", risid);
			mediaOrderRow.put("KANJA_ID", orderRow.get("KANJA_ID").toString());
			mediaOrderRow.put("IRAI_SECTION_ID", orderRow.get("IRAI_SECTION_ID").toString());
			mediaOrderRow.put("IRAI_DOCTOR_ID", orderRow.get("IRAI_DOCTOR_NO").toString());
			mediaOrderRow.put("REQUESTDATE", sysdate);
			mediaOrderRow.put("ORDER_BUI_ID", orderBuiRow.get("BUI_ID").toString());

			//mediaOrderRow.put("KENSAKIKI", orderRow.get("KENSAKIKI_ID").toString());
			mediaOrderRow.put("KENSAKIKI", aetitle);		//社内テストNo7 CodonicsMediaOrderTableのKensaKikiの値

			mediaOrderRow.put("MEDIA_FLG", mediatype);
			mediaOrderRow.put("ORDER_COMMENT", comments);
			mediaOrderRow.put("ORDERNO", orderRow.get("ORDERNO").toString());


			DataBase.updateTable("CodonicsMediaOrderTable", "RIS_ID", mediaOrderRow, conn);


			//CodonicsMediaOrderStudyTable
			DataRow orderStudyRow = new DataRow();
			orderStudyRow.put("RIS_ID", risid);
			//for(int i = 0; i < acnolist.length; i++){
			for(int i = 0; i < uidlist.length; i++){

				//DataTable studyDat = DataBase.getMasterStudy(acnolist[i], null, null, null, null, connArqs);
				DataTable studyDat = DataBase.getMasterStudy(null, null, null,uidlist[i], null, null, connArqs);
				DataRow studyRow = studyDat.getRows().get(0);

				orderStudyRow.put("NO",String.valueOf(i + 1));
				orderStudyRow.put("ACCESSIONNO", studyRow.get("ACCESSIONNUMBER").toString());
				orderStudyRow.put("MODALITY_TYPE", studyRow.get("MODALITY").toString());
				orderStudyRow.put("KENSA_DATE", studyRow.get("STUDYDATE"));
				orderStudyRow.put("STUDYDESCRIPTION", studyRow.get("STUDYDESCRIPTION").toString());
				orderStudyRow.put("STUDYINSTANCEUID", studyRow.get("STUDYINSTANCEUID").toString());

				DataBase.updateTable("CodonicsMediaOrderStudyTable", new String[]{"RIS_ID","NO"}, orderStudyRow, conn);
			}

			conn.commit();
			logger.debug("Commit");

		}
		catch(Exception e){
			logger.error(e.toString(),e);
			//受入No13 DBエラー時のメッセージ
			//addErrorMessage(e.toString(),request);
			addErrorMessage("登録に失敗しました",request);

			try{
				logger.debug("RollBack");
				conn.rollback();
			}
			catch(Exception ee){

			}
			return false;
		}
		finally{
			DataBase.closeConnection(conn);
			DataBase.closeConnection(connArqs);
			DataBase.closeConnection(connUnity);	//No27 接続Close漏れ
		}

		return true;
	}

	private void addErrorMessage(String message, HttpServletRequest request){

		String msg = Common.toNullString((String)request.getAttribute("ERRMSG"));

		if(!msg.equals("")){
			msg += "<br/>";
		}

		msg += message;

		request.setAttribute("ERRMSG", msg);

	}

	// 2021.08.19 del start cosmo@Nishihara 未使用の為削除
//	private void setViewCInfo(HttpServletRequest request){
//
//		Connection conn = null;
//
//		try{
//
//			conn = DataBase.getArqsConnection();
//
//			DataRow loginRow = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);
//
//			String userid = loginRow.get("USERID").toString();
//			String password = "";
//
//			DataTable Dat = DataBase.getUserManageVins(userid, conn);
//			if(Dat.getRowCount() > 0){
//				password = Dat.getRows().get(0).get("PASSWORD").toString();
//			}
//
//			request.setAttribute("useridForVins", userid);
//			request.setAttribute("passwdForVins", password);
//
//		}
//		catch(Exception e){
//			logger.error(e.toString(),e);
//		}
//		finally{
//			DataBase.closeConnection(conn);
//		}
//
//	}
	// 2021.08.19 del end cosmo@Nishihara 未使用の為削除

}
