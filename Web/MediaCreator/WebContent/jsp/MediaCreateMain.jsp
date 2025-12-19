<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="MediaCreator.Common.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
	request.setCharacterEncoding("UTF-8");

	String errmsg = Common.toNullString((String)request.getAttribute("ERRMSG"));

	DataRow emp = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);
	DataRow patientRow = (DataRow)request.getAttribute("PATIENTINFO");

	Timestamp sysdate = (Timestamp)request.getAttribute("SYSDATE");

	//
	Config sysConfig = (Config)SessionControler.getValue(request, SessionControler.SYSTEMCONFIG);

	//ViewC用
	String useridForVins = (String)request.getAttribute("useridForVins");
	String passwdForVins = (String)request.getAttribute("passwdForVins");

	//依頼科
	DataTable iraiDat = (DataTable)request.getAttribute("SECTIONLIST");

	//依頼医
	DataTable doctorDat = (DataTable)request.getAttribute("DOCTORLIST");

	//作成区分
	DataTable kbnDat = (DataTable)request.getAttribute("KUBUNLIST");

	//作成装置
	DataTable soutiDat = (DataTable)request.getAttribute("SOUTILIST");

	//モダリティ
	DataTable modalityDat = (DataTable)request.getAttribute("MODALITYLIST");

	//MasterStudy
	DataTable studyDat = (DataTable)request.getAttribute("MASTERSTUDYLIST");


	//MODE メディア作成から完了までの判定用
	String mode = Common.toNullString((String)request.getAttribute("MODE"));

	//電子カルテ連携フラグ
	String fromKarte = Common.toNullString(request.getParameter("fromKarte"));

	String risid = Common.toNullString((String)request.getAttribute("create_risid"));
	String orderno = Common.toNullString((String)request.getAttribute("create_orderno"));
	String requestid = Common.toNullString((String)request.getAttribute("create_requestid"));


	String patientid = "";
	String patientkana = "";
	String patientname = "";
	String patientsex = "";
	String patientbirth = "";
	String patientbyoutou = "";
	//String patientsexicon = "images/sex_unknown.png";
	String patientsexicon = "";

	if(patientRow != null){
		patientid = patientRow.get("KANJA_ID").toString();
		patientkana = patientRow.get("KANASIMEI").toString();
		patientname = patientRow.get("KANJISIMEI").toString();
		patientsex = patientRow.get("SEX").toString();

		if(patientsex.equals("M")){
			patientsexicon = "images/sex_male.png";
		}
		else if(patientsex.equals("F")){
			patientsexicon = "images/sex_female.png";
		}
		else{
			patientsexicon = "images/sex_unknown.png";
		}

		String birthday = patientRow.get("BIRTHDAY").toString();
		patientbirth = String.format("%s(%s%s).%s.%s %s歳"
				,birthday.substring(0,4)
				,patientRow.get("NENGO_CHAR").toString()
				,patientRow.get("NENGO_YEAR").toString()
				,birthday.substring(4,6)
				,birthday.substring(6,8)
				,patientRow.get("AGE").toString()
			);

		//patientbyoutou = patientRow.get("").toString();
		String nyugai = patientRow.get("KANJA_NYUGAIKBN").toString();
		String nyuaginame = "";

		if(nyugai.equals("1")){
			nyuaginame = "外来";
		}
		else if(nyugai.equals("2")){
			nyuaginame = "入院";
		}

		patientbyoutou = String.format("%s %s %s %scm/%skg",
				nyuaginame,
				patientRow.get("BYOUTOU_NAME").toString(),
				patientRow.get("BYOUSITU_NAME").toString(),
				patientRow.get("TALL").toString(),
				patientRow.get("WEIGHT").toString()
			);

	}

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">

<title>医療画像情報持出</title>

<script type="text/javascript" src="js/common.js"></script>
<link rel="stylesheet" href="css/CommonStyle.css" type="text/css" />
<!--
<link rel="stylesheet" href="css/mgui.css" type="text/css" />
<link rel="stylesheet" href="css/mscan.login.dlg.css" type="text/css" />
 -->

<%-- JQuery --%>
<script type="text/javascript" src="lib/jquery/js/jquery-1.8.3.js" ></script>
<script type="text/javascript" src="lib/jquery/js/jquery-ui-1.9.2.custom.js" ></script>
<script type="text/javascript" src="lib/jquery/js/i18n/jquery.ui.datepicker-ja.js" ></script>
<link rel="stylesheet" type="text/css" href="lib/jquery/css/mediacreator/jquery-ui-1.9.2.custom.css" />
<!--
<link rel="stylesheet" type="text/css" href="css/mono-theme/jquery-ui-1.8.21.custom.css" />
  -->

<style>

	/* 画面クリア */
	#btnClear {
		background: url("images/display_clear.png") !important; border:none;
	}
	#btnClear:active {
		background: url("images/display_clear_d.png") !important; border:none;
	}

	/* 作成履歴 */
	#btnHistory {
		background: url("images/create_history.png") !important; border:none;
	}
	#btnHistory:active {
		background: url("images/create_history_d.png") !important; border:none;
	}
	#btnHistory:disabled {
		background: url("images/create_history_s.png") !important; border:none;
	}
	#btnHistory.disabled {
		background: url("images/create_history_s.png") !important; border:none;
	}

	/* メディア作成 */
	#btnCreate {
		background: url("images/create_media.png") !important; border:none;
	}
	#btnCreate:active {
		background: url("images/create_media_d.png") !important; border:none;
	}
	#btnCreate:disabled {
		background: url("images/create_media_s.png") !important; border:none;
	}
	#btnCreate.disabled {
		background: url("images/create_media_s.png") !important; border:none;
	}

	/* 受取票印刷 */
	#btnPrint {
		background: url("images/ticket_print.png") !important; border:none;
	}
	#btnPrint:active {
		background: url("images/ticket_print_d.png") !important; border:none;
	}
	#btnPrint:disabled {
		background: url("images/ticket_print_s.png") !important; border:none;
	}
	#btnPrint.disabled {
		background: url("images/ticket_print_s.png") !important; border:none;
	}

	/*患者詳細*/
	#btnPatientinfo {
		background: url("images/patient_detail.png") !important; border:none;
	}
	#btnPatientinfo:active {
		background: url("images/patient_detail_d.png") !important; border:none;
	}
	#btnPatientinfo:disabled {
		background: url("images/patient_detail_s.png") !important; border:none;
	}
	#btnPatientinfo.disabled {
		background: url("images/patient_detail_s.png") !important; border:none;
	}

	/*検索*/
	#btnSearch {
		background: url("images/kensaku.png") !important; border:none;
	}
	#btnSearch:active {
		background: url("images/kensaku_D.png") !important; border:none;
	}
	#btnSearch:disabled {
		background: url("images/kensaku_S.png") !important; border:none;
	}
	#btnSearch.disabled {
		background: url("images/kensaku_S.png") !important; border:none;
	}

	/*クリア*/
	#btnSearchClear {
		background: url("images/kuria.png") !important; border:none;
	}
	#btnSearchClear:active {
		background: url("images/kuria_D.png") !important; border:none;
	}
	#btnSearchClear:disabled {
		background: url("images/kuria_S.png") !important; border:none;
	}
	#btnSearchClear.disabled {
		background: url("images/kuria_S.png") !important; border:none;
	}

	/*閉じる*/
	#btnClose {
		background: url("images/tojiru.png") !important; border:none;
	}
	#btnClose:active {
		background: url("images/tojiru_D.png") !important; border:none;
	}
	#btnClose:disabled {
		background: url("images/tojiru_S.png") !important; border:none;
	}
	#btnClose.disabled {
		background: url("images/tojiru_S.png") !important; border:none;
	}

	/*ユーザ切替*/
	#btnLogoff {
		background: url("images/change_user.png") !important; border:none;
	}
	#btnLogoff:active {
		background: url("images/change_user_u.png") !important; border:none;
	}
	#btnLogoff:disabled {
		background: url("images/change_user_d.png") !important; border:none;
	}
	#btnLogoff.disabled {
		background: url("images/change_user_d.png") !important; border:none;
	}

	/*ヘルプ*/
	#btnHelp {
		background-image: url("images/help.png") !important;
		width:20px; height:20px;
		background-size:20px 20px;
		display: block;border:none;text-decoration:none;outline:none;
	}
	#btnHelp:hover {
		background-image: url("images/help.png") !important; border:none; width:20px; height:20px; background-size:20px 20px; display: block;
		border:none;text-decoration:none;outline:none;
	}
	#btnHelp:active {
		background-image: url("images/help_d.png") !important; border:none; width:20px; height:20px; background-size:20px 20px; display: block;
		border:none;text-decoration:none;outline:none;
	}

	/* ViewC画像 */
	a.viewcgazou {
		background-image: url("images/gazou.png") !important; border:none; width:20px; height:20px; background-size:20px 20px; display: block;
		border:none;text-decoration:none;outline:none;
	}
	a:hover.viewcgazou {
		background-image: url("images/gazou.png") !important; border:none; width:20px; height:20px; background-size:20px 20px; display: block;
		border:none;text-decoration:none;outline:none;
	}
	a:active.viewcgazou {
		background-image: url("images/gazou_down.png") !important; border:none; width:20px; height:20px; background-size:20px 20px; display: block;
		border:none;text-decoration:none;outline:none;
	}

	/* ユーザ切替ダイアログのボタン配置エリア */
	/*
	.ui-dialog-buttonset{
		width:100%;
		height:100%;
		position:absolute;
		top:0px;left:0px;
	}
	*/

	/*ユーザ切替のログイン*/
	#btnDialogLogin {
		background: url("images/login.png") !important; border:none;
		width:113px; height:30px;
		position:relative; top:0px;
		left:-27px;
	}
	#btnDialogLogin:active {
		background: url("images/login_D.png") !important; border:none;
	}
	#btnDialogLogin:disabled {
		background: url("images/login_S.png") !important; border:none;
	}
	#btnDialogLogin.disabled {
		background: url("images/login_S.png") !important; border:none;
	}

	/*ユーザ切替のキャンセル*/
	#btnDialogCancel {
		background: url("images/cancel.png") !important; border:none;
		width:113px; height:30px;
	}
	#btnDialogCancel:active {
		background: url("images/cancel_D.png") !important; border:none;
	}
	#btnDialogCancel:disabled {
		background: url("images/cancel_S.png") !important; border:none;
	}
	#btnDialogCancel.disabled {
		background: url("images/cancel_S.png") !important; border:none;
	}


	/*会計連携ダイアログ*/
	#btnDialogKaikeiOK {
		width:113px; height:30px;
	}
	<%--
	#btnDialogKaikeiOK:active {
		background: url("images/tojiru_D.png") !important; border:none;
	}
	#btnDialogKaikeiOK:disabled {
		background: url("images/tojiru_S.png") !important; border:none;
	}
	#btnDialogKaikeiOK.disabled {
		background: url("images/tojiru_S.png") !important; border:none;
	}
	--%>


	/* Alertダイアログのボタンサイズ */
	#btnDialogAlertOK {
		width:113px; height:30px;
	}


	/* 確認ダイアログのボタンサイズを揃える。 */
	#btnDialogConfirmOK {
		width:113px; height:30px;
		position:relative; top:0px;
		left:-27px;
	}
	#btnDialogConfirmCancel {
		width:113px; height:30px;
	}

</style>
</head>

<script type="text/javascript">
	function submitMainForm(method){
		document.MainForm.method = method;
		document.MainForm.submit();
	}

	function serchStudy(){

		if($('[name="chkSelect"]:checked').length > 0){
			//if(!confirm("選択された画像は解除されます。\n検索を実行してよろしいですか?")){
			//	return false;
			//}
			confirmDialog("選択された画像は解除されます。<br/>検索を実行してよろしいですか?<br/><br/>",
							function(){
								$("#requesttype").val("search");
								submitMainForm("POST");
							}
			);
		}
		else{
			<%--  --%>
			$("#requesttype").val("search");
			submitMainForm("POST");
		}

		//$("#requesttype").val("search");
		//submitMainForm("POST");
	}

	function createMedia(){

		if(!checkInput()){
			return;
		}

		//if(!confirm("持ち出しメディアを作成します。\nよろしいですか?")){
		//	return false;
		//}
		confirmDialog("持ち出しメディアを作成します。<br/>よろしいですか?<br/><br/>",
				function(){
					$("#btnCreate").prop("disabled",true);
					$("#btnCreate").addClass("disabled");

					$("#requesttype").val("create");
					submitMainForm("POST");
				}
		);

		/*
		$("#btnCreate").prop("disabled",true);
		$("#btnCreate").addClass("disabled");

		$("#requesttype").val("create");
		submitMainForm("POST");
		*/
	}

	function clearInfo(){

		<%
			//電子カルテ連携時は患者ID変更しない。
			if(!fromKarte.equals("y")){
		%>
		$("#txtPatientid").val("");
		$("#pid").val("");
		$("#selSectionid").val("");
		<%
			}
		%>
		$("#selDoctorid").val("");
		//$("#selSakuseikbn").val("");
		//$("#selSakuseisouti").val("");

		//$("#selMediatype").val("");
		$("#selMediatype") .prop('selectedIndex', 0);

		$("#txtComments").val("");
		$("#dateFrom").val("");
		$("#dateTo").val("");
		$("#selModality").val("");

		$("#chkKensadate").prop("checked",false);	<%-- 値を""で括らないこと --%>
		$("#chkModality").prop("checked",false);	<%-- 値を""で括らないこと --%>


		$("#requesttype").val("clear");
		submitMainForm("POST");
	}

	function inputPatient(keycode){

		<%
			//電子カルテ連携時は患者変更しない
			if(fromKarte.equals("y")){
		%>
			return;
		<%
			}
		%>


		if(keycode != 13){
			return;
		}

		var patientid = $("#txtPatientid").val();
		if(patientid == ""){
			return;
		}

		<%
			String zero = "";
			for(int i = 0; i < sysConfig.getPatientLength(); i++){
				zero += "0";
			}
		%>

		var result = ('<%=zero%>' + patientid).slice(-<%=String.valueOf(sysConfig.getPatientLength())%>);
		$("#txtPatientid").val(result);
		$("#pid").val(result);

		$("#requesttype").val("patient");
		submitMainForm("POST");
	}

	function changeSection(){
		$("#requesttype").val("changesection");
		submitMainForm("POST");
	}

	function setDefaultValue(){

	<%

		String requettype = Common.toNullString(request.getParameter("requesttype"));

		String section = Common.toNullString(request.getParameter("selSectionid"));
		String doctor = Common.toNullString(request.getParameter("selDoctorid"));
		String kubun = Common.toNullString(request.getParameter("selSakuseikbn"));
		String souti = Common.toNullString(request.getParameter("selSakuseisouti"));
		String syurui = Common.toNullString(request.getParameter("selMediatype"));
		String comment = Common.toNullString(request.getParameter("txtComments")).replace("\r\n","\\n");
		String datefrom = Common.toNullString(request.getParameter("dateFrom"));
		String dateto = Common.toNullString(request.getParameter("dateTo"));
		String modality = Common.toNullString(request.getParameter("selModality"));

		String[] chkAcnoList = request.getParameterValues("chkSelect");
		if(chkAcnoList == null){
			chkAcnoList = new String[0];
		}

		String chkAllImage = Common.toNullString(request.getParameter("chkAllImage"));


		String chkKensadate = Common.toNullString(request.getParameter("chkKensadate"));
		%>
		//'<%=chkKensadate%>'
		<%
		if(!chkKensadate.equals("")){
			chkKensadate = "true";
		}
		else{
			chkKensadate = "false";
		}

		String chkModakity = Common.toNullString(request.getParameter("chkModality"));
		if(!chkModakity.equals("")){
			chkModakity = "true";
		}
		else{
			chkModakity = "false";
		}

		String requesttype = Common.toNullString(request.getParameter("requesttype"));
	%>

		$("SELECT" + "#selSectionid").val("<%=section%>");
		$("SELECT" + "#selDoctorid").val("<%=doctor%>");
		$("SELECT" + "#selSakuseikbn").val("<%=kubun%>");
		$("SELECT" + "#selSakuseisouti").val("<%=souti%>");
		$("SELECT" + "#selMediatype").val("<%=syurui%>");

		$("#txtComments").val("<%=comment%>");
		$("#dateFrom").val("<%=datefrom%>");
		$("#dateTo").val("<%=dateto%>");
		$("#selModality").val("<%=modality%>");

		$("#chkKensadate").prop("checked",<%=chkKensadate%>);	<%-- 値を""で括らないこと --%>
		$("#chkModality").prop("checked",<%=chkModakity%>);		<%-- 値を""で括らないこと --%>


		<%
			//チェックの復元
			if(!requesttype.equals("search")){
				if(!chkAllImage.equals("")){
		%>
		$("#chkAllImage").prop("checked",true);
		<%
				}
				for(int i = 0; i < chkAcnoList.length; i++){
		%>
		$("[name='chkSelect'][value='<%=chkAcnoList[i]%>']").prop("checked",true);
		<%
				}
			}
		%>

		<%-- ボタン制御 --%>
		$("#btnPatientinfo").prop("disabled",true);
		$("#btnPatientinfo").addClass("disabled");

		$("#btnSearch").prop("disabled",true);
		$("#btnSearch").addClass("disabled");

		$("#btnHistory").prop("disabled",true);
		$("#btnHistory").addClass("disabled");

		//$("#btnClear").prop("disabled",true);

		$("#btnCreate").prop("disabled",true);
		$("#btnCreate").addClass("disabled");

		$("#btnPrint").prop("disabled",true);
		$("#btnPrint").addClass("disabled");

		//$("#btnClose").prop("disabled",true);

	<%
		if(patientRow != null){
	%>
		$("#btnPatientinfo").prop("disabled",false);
		$("#btnPatientinfo").removeClass("disabled");

		$("#btnSearch").prop("disabled",false);
		$("#btnSearch").removeClass("disabled");

		$("#btnHistory").prop("disabled",false);
		$("#btnHistory").removeClass("disabled");

		$("#btnCreate").prop("disabled",false);
		$("#btnCreate").removeClass("disabled");
	<%
		}
	%>

	<%
		if(mode.equals("creating")){
	%>
		$("#btnPrint").prop("disabled",true);
		$("#btnPrint").addClass("disabled");

		$("#btnCreate").prop("disabled",true);
		$("#btnCreate").addClass("disabled");
	<%
		}
	%>

	<%
		//電子カルテ連携時は患者変更しない
		if(fromKarte.equals("y")){
	%>
		$("#txtPatientid").prop("readonly",true);
	<%
		}
	%>


	}

	function checkInput(){


		if($("#pid").val() == ""){
			alertDialog("患者IDを入力して下さい。");
			return false;
		};

		if($("#selSectionid").val() == ""){
			alertDialog("依頼科を選択して下さい。");
			return false;
		};

		if($("#selDoctorid").val() == ""){
			alertDialog("依頼者を選択して下さい。");
			return false;
		};

		if($("#selSakuseikbn").val() == ""){
			alertDialog("作成区分を選択して下さい。");
			return false;
		};

		if($("#selSakuseisouti").val() == ""){
			alertDialog("作成装置を選択して下さい。");
			return false;
		};

		if($("#selMediatype").val() == ""){
			alertDialog("メディア種別を選択して下さい。");
			return false;
		};

		//if($("#txtComments").val() == ""){
		//	alertDialog("コメントを入力して下さい。");
		//	return false;
		//};

		<%--
		if($("#txtComments").val().length > 2000){
			alertDialog("コメントは最大で2000文字までしか入力できません。");
			return false;
		};
		--%>
		//No29 コメントの保存先  2014/05/20 S.Terakata(STI)
		if($("#txtComments").val().length > 512){
			<%-- OrderIndicateTableのOrderComment_idに合わせる。 --%>
			alertDialog("コメントは最大で512文字までしか入力できません。");
			return false;
		};


		if($('[name="chkSelect"]:checked').length == 0){
			alertDialog("対象画像を選択して下さい。");
			return false;
		}

		return true;

	}


	function checkFinish(){
		var ret = 'false';

		var obj = null;
		var param = [
				{ name : 'requestid', value : '<%=requestid%>' }
			];

		$.ajax({
			type: 'POST',
			url: 'CheckResultAjax' + '?dummy=' + (new Date()).getTime(),
			data: param,
			dataType: 'json',
			async: false,
			cache: false,
			success: function(data, dataType){obj = data;},
			error: function(XMLHttpRequest, textStatus, errorThrown){alertDialog(textStatus + '\n接続が切れた可能性があります。再度ログインしてください。');}
		});


		//alertDialog(ret);

		<%--
		//社内テストNo6 依頼ファイル作成失敗時のTransferStatus
		--%>
		if(obj.result == 'true'){
			if(obj.message==""){
				$("#btnPrint").prop("disabled",false);
				$("#btnPrint").removeClass("disabled");

				<%-- MIS受入テスト No43 --%>
				try{
					$("#waitMedia").dialog("close");
				}
				catch(ex){
				}
				<% if(sysConfig.getKaikeiDialog().equals("Y")){ %>
				<%--
				alertDialog("発行依頼時に会計情報が連携します。");
				printReceiptSheet();
				--%>

				$("#dialogKaikei").dialog(
					{ buttons: {
					// ボタンを設定
					// 「はい」ボタンのテキストとイベントハンドラ
					"OK": {click: function(event) {
											// event.target でボタンの要素を参照
											$(this).dialog("close");
											printReceiptSheet();
										},
								id: "btnDialogKaikeiOK",
								text: "OK"
							}
					},
		    		modal: true,
		    		resizable: false
				});

				<% 	}
					else{
				%>
				<%-- 受入テスト No16 メディア持出票の表示タイミング --%>
				printReceiptSheet();
				<%	} %>
			}
			else{
				alertDialog(obj.message);
				<%-- $("#btnCreate").prop("disabled",false); 作成ボタン有効にしない --%>
				try{
					$("#waitMedia").dialog("close");
				}
				catch(ex){
				}
			}


		}
		else{
			$( "#waitMedia" ).dialog({resizable: false});
			setTimeout("checkFinish()",3000);	//依頼ファイル作成を3秒待つ。
		}

		return ret;

	}

	function logOff(){
		$( "#dialogLogin" ).dialog(
			{ buttons: {
				// ボタンを設定
				// 「はい」ボタンのテキストとイベントハンドラ
				"ログイン": {click: function(event) {
										// event.target でボタンの要素を参照
										if(ajaxLogin()){
											$(this).dialog("close");
											clearInfo();
										}
									},
							id: "btnDialogLogin",
							text: ""
						},
				// 「いいえ」ボタンのテキストとイベントハンドラ
				"キャンセル": {click: function() {
										$(this).dialog("close");
										//changeSection();	//再表示
									},
								id: "btnDialogCancel",
								text: ""
							}
	    		},
	    		modal: true,
	    		resizable: false
			});
	}

	function ajaxLogin(){

		var ret = 'false';
		var errmsg = '';


		//var obj = null;
		var param = [
				{ name : 'userid', value : $("#userid").val() },
				{ name : 'password', value : $("#password").val() }
			];

		$.ajax({
			type: 'POST',
			url: 'LoginAjax' + '?dummy=' + (new Date()).getTime(),
			data: param,
			dataType: 'json',
			async: false,
			cache: false,
			success: function(data, dataType){
				ret = data.result;
				errmsg = data.errmsg;
			},
			error: function(XMLHttpRequest, textStatus, errorThrown){alertDialog(textStatus + '\n接続が切れた可能性があります。再度ログインしてください。');}
		});


		//alertDialog(ret);

		if(ret == 'true'){
			return true;
		}
		else{
			//$("#loginError").val(errmsg);
			alertDialog(errmsg);
			return false;
		}


		return true;
	}

	function printReceiptSheet(){
		document.ReceiptPrint.submit();
	}

	function showPatientInfo(){
		document.PatientHistory.action = "PatientInfo";
		document.PatientHistory.submit();
	}

	function showHistory(){
		document.PatientHistory.action = "History";
		document.PatientHistory.submit();
	}

	function showViewC(accessionno){
		$("#accessionno").val(accessionno);
		document.ViewC.submit();
	}

	function showHelp(){
		document.Help.submit();
	}

	function clearSearchParam(){
		$("#dateFrom").val("");
		$("#dateTo").val("");
		$("#selModality").val("");
	}

	function selectAllImage(checkobj){
		$("[name='chkSelect']:enabled").prop("checked",$(checkobj).prop("checked"));
	}


	function alertDialog(msg){

		$("#dialogAlert").html(msg);
		$("#dialogAlert").dialog(
			{ buttons: {
			// ボタンを設定
			// 「はい」ボタンのテキストとイベントハンドラ
			"OK": {click: function(event) {
							// event.target でボタンの要素を参照
							$(this).dialog("close");
						},
					id: "btnDialogAlertOK",
					text: "OK"
				}
			},
    		modal: true,
    		resizable: false
		});
	}

	function confirmDialog(msg,okFunc){

		$("#dialogConfirm").html(msg);
		$("#dialogConfirm").dialog(
			{ buttons: {
			// ボタンを設定
			// 「はい」ボタンのテキストとイベントハンドラ
			"OK": {click: function(event) {
							// event.target でボタンの要素を参照
							okFunc();
							$(this).dialog("close");
						},
					id: "btnDialogConfirmOK",
					text: "OK"
				},
			"キャンセル": {click: function(event) {
						// event.target でボタンの要素を参照
						$(this).dialog("close");
					},
					id: "btnDialogConfirmCancel",
					text: "キャンセル"

				}
			},
    		modal: true,
    		resizable: false
		});
	}

	</script>

<script type="text/javascript">
$(function(){

	$(":button").val("");

	$("#dateFrom").datepicker();
	$("#dateTo").datepicker();

	$("#txtPatientid").val("<%=patientid%>");
	$("#pid").val("<%=patientid%>");

	setDefaultValue();

	$("#txtPatientid").focus();

	<%
	if(mode.equals("creating")){
	%>
	checkFinish();
	<%
		}
	%>

});
</script>

<body class="main-back">

	<!-- ヘッダ部 -->
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr align="right">
			<td background="images/frame_upper.jpg" align="left"><img src="images/frame_title.jpg" /></td>
			<!--
			<td align="right" nowrap background="images/frame_upper.jpg">
				<span style="color:#FFFFFF;">ログイン：&nbsp;&nbsp;</span>
			</td>
			-->
			<td align="left" width="250px" nowrap background="images/frame_upper.jpg">
				<div style="position:relative; height:30px">
					<img src="images/logineria.png" style="position:absolute; left:0px; top:2px;">
					<span style="position:absolute; left:60px; top:7px"><%=emp.get("USERNAME").toString()%></span>
				</div>
			</td>
			<td background="images/frame_upper.jpg">
				&nbsp;&nbsp;
			</td>
			<td align="left"background="images/frame_upper.jpg">
				<input type="button" id="btnLogoff" class="smallbtn" value="ログオフ" onclick="logOff();" />
			</td>
			<td background="images/frame_upper.jpg">
				&nbsp;&nbsp;
				&nbsp;&nbsp;
				&nbsp;&nbsp;
				&nbsp;&nbsp;
				&nbsp;&nbsp;
			</td>
			<td background="images/frame_upper.jpg">
				<a id="btnHelp" href="javascript:showHelp();" style="width:20px; height:20px; margin-right:15px;" >&nbsp;</a>
			</td>
			<!-- 2021.08.19 del start cosmo@Nishihara YOKOGAWAロゴ削除  -->
			<!-- <td background="images/frame_upper.jpg"> -->
			<!-- &nbsp; -->
			<!-- <img src="images/yokogawa.png" /> -->
			<!-- &nbsp; -->
			<!-- &nbsp; -->
			<!-- </td> -->
			<!-- 2021.08.19 del end cosmo@Nishihara YOKOGAWAロゴ削除  -->
		</tr>
	</table>

	<!-- タイトル -->
	<table class="noborder" style="width:100%; height:30px;" >
		<tr>
			<td align="left" style="font-size:medium;">
				医療画像情報メディア作成
			</td>
			<td align="right">
				<input type="button" id="btnClose" name="btnClose" class="cmdbtn" value="閉じる" onClick="close_win();">
			</td>
		</tr>
	</table>

	<!-- 本体部 -->
	<form name="MainForm" action="MediaCreateMain">
		<table class="noborder" style="width:100%; height:90%; border-spacing:0px; border-collapse:collapse; " >
			<tr height="30px">
				<%-- 患者情報 --%>
				<td class="frame1" colspan="2">
					<table border="0" width="100%" style="font-size:medium;">
						<tr><td colspan="7"><span class="errmsg"><%=errmsg %></span></td></tr>
						<tr>
							<%-- 患者ID入力 --%>
							<td width="120px" nowrap>
								患者ID&nbsp;<input type="text" id="txtPatientid" name="txtPatientid" style="font-size: large;width: 100px; background-color:#C7ECF8;" onkeypress="inputPatient(event.keyCode);" />
								<input type="hidden" id="pid" name="pid">
							</td>
							<%-- 患者氏名 --%>
							<td width="120px" nowrap>
								<div style="width:120px; overflow:hidden;">
								<%=patientname%>
								</div>
							</td>
							<%-- 患者カナ --%>
							<td width="180px" nowrap>
								<div style="width:180px; overflow:hidden;">
								<%=patientkana%>
								</div>
							</td>
							<%-- 性別アイコン --%>
							<td width="60px" nowrap>
								<% if(!patientsexicon.equals("")){ %>
								<img src="<%=patientsexicon%>" width="25px" height="25px" />
								<% } else { %>
								&nbsp;
								<% } %>
							</td>
							<%-- 生年月日 --%>
							<td width="200px" nowrap>
								<div style="width:200px; overflow:hidden;">
								<%=patientbirth%>
								</div>
							</td>
							<%-- 入院 身長 体重 --%>
							<td width="400px" nowrap>
								<div style="width:400px; overflow:hidden;">
								<%=patientbyoutou%>
								</div>
							</td>
							<%-- 患者詳細ボタン --%>
							<td align="right" nowrap>
								<input type="button" id="btnPatientinfo" class="smallbtn" value="患者詳細" onclick="showPatientInfo();">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr height="10px">
				<td><%-- 隙間を開けるための空行 --%></td>
			</tr>
			<tr height="30px">
				<%-- タイトル --%>
				<td class="frame3" colspan="2">
					<table border="0" width="100%">
						<tr>
							<td style="color:white;">メディア作成情報</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr class="frame1">
				<%-- オーダー情報入力 --%>
				<td class="frame1" width="380px">
					<table border="0">
						<tr height="25px">
							<td nowrap align="right">
								依頼科&nbsp;
							</td>
							<td nowrap align="left">
								<%
									if(iraiDat != null){
										if(iraiDat.getRowCount() == 1){
								%>
								<input type="text" style="border-style:none; background-color:transparent;width:100%;" value="<%=iraiDat.getRows().get(0).get("SECTION_NAME").toString()%>"  readonly>
								<input type="hidden" id="selSectionid" name="selSectionid"  value="<%=iraiDat.getRows().get(0).get("SECTION_ID").toString()%>">
								<%
										}
										else{
								%>
								<select id="selSectionid" name="selSectionid" class="orderInfoItem" >
									<option value=""></option>
								<%
											for(int i = 0; i < iraiDat.getRowCount(); i++){
								%>
									<option value="<%=iraiDat.getRows().get(i).get("SECTION_ID").toString()%>"><%=iraiDat.getRows().get(i).get("SECTION_NAME").toString()%></option>
								<%
											}
								%>
								</select>
								<%
										}
									}
								%>
							</td>
						</tr>
						<tr height="25px">
							<td nowrap align="right">
								依頼者&nbsp;
							</td>
							<td nowrap align="left">
								<%
									if(doctorDat != null){
										if(doctorDat.getRowCount() == 1){
								%>
								<input type="text" style="border-style:none; background-color:transparent;width:100%;" value="<%=doctorDat.getRows().get(0).get("DOCTOR_NAME").toString()%>"  readonly>
								<input type="hidden" id="selDoctorid" name="selDoctorid"  value="<%=doctorDat.getRows().get(0).get("DOCTOR_ID").toString()%>">
								<%
										}
										else{
								%>
								<select id="selDoctorid" name="selDoctorid" class="orderInfoItem" >
									<option value=""></option>
								<%
											for(int i = 0; i < doctorDat.getRowCount(); i++){
								%>
									<option value="<%=doctorDat.getRows().get(i).get("DOCTOR_ID").toString()%>"><%=doctorDat.getRows().get(i).get("DOCTOR_NAME").toString()%></option>
								<%
											}
								%>
								</select>
								<%
										}
									}
								%>
							</td>
						</tr>
						<tr height="25px">
							<td nowrap align="right">
								メディア作成日&nbsp;
							</td>
							<td nowrap align="left">
								<input type="text" style="background-color:transparent; border-style:none;width:100%;" value="<%=new SimpleDateFormat("yyyy/MM/dd").format(sysdate) %>" readonly/>
								<input type="hidden" id="createdate" name="createdate">
							</td>
						</tr>
						<tr height="25px">
							<td nowrap align="right">
								メディア作成区分&nbsp;
							</td>
							<td nowrap align="left">
								<%
									if(kbnDat != null){
										if(kbnDat.getRowCount() == 1){
								%>
								<input type="text" style="border-style:none; background-color:transparent;width:100%;" value="<%=kbnDat.getRows().get(0).get("BUI_NAME").toString()%>"  readonly>
								<input type="hidden" id="selSakuseikbn" name="selSakuseikbn"  value="<%=kbnDat.getRows().get(0).get("BUI_ID").toString()%>">
								<%
										}
										else{
								%>
								<select id="selSakuseikbn" name="selSakuseikbn" class="orderInfoItem" >
									<option value=""></option>
								<%
											for(int i = 0; i < kbnDat.getRowCount(); i++){
								%>
									<option value="<%=kbnDat.getRows().get(i).get("BUI_ID").toString()%>"><%=kbnDat.getRows().get(i).get("BUI_NAME").toString()%></option>
								<%
											}
								%>
								</select>
								<%
										}
									}
								%>
							</td>
						</tr>
						<tr height="25px">
							<td nowrap align="right">
								作成装置&nbsp;
							</td>
							<td nowrap align="left">
								<%
									if(soutiDat != null){
										if(soutiDat.getRowCount() == 1){
								%>
								<input type="text" style="border-style:none; background-color:transparent;width:100%;" value="<%=soutiDat.getRows().get(0).get("KENSAKIKI_NAME").toString()%>"  readonly>
								<input type="hidden" id="selSakuseisouti" name="selSakuseisouti"  value="<%=soutiDat.getRows().get(0).get("KENSAKIKI_ID").toString()%>">
								<%
										}
										else{
								%>
								<select id="selSakuseisouti" name="selSakuseisouti" class="orderInfoItem" >
									<option value=""></option>
								<%
											for(int i = 0; i < soutiDat.getRowCount(); i++){
								%>
									<option value="<%=soutiDat.getRows().get(i).get("KENSAKIKI_ID").toString()%>"><%=soutiDat.getRows().get(i).get("KENSAKIKI_NAME").toString()%></option>
								<%
											}
								%>
								</select>
								<%
										}
									}
								%>
							</td>
						</tr>
						<tr height="25px">
							<td nowrap align="right">
								メディア種別&nbsp;
							</td>
							<td nowrap align="left">
								<%
									String type = sysConfig.getMediaType();
									String[] typelist = type.split(",");

									String typeid = " : ";
									String typename = " : ";

									if(typelist.length > 1){
								%>
								<select id="selMediatype" name="selMediatype" class="orderInfoItem">
									<%--<option value=""></option> --%>
									<%
										for(int i = 0; i < typelist.length; i++){
											if(typelist[i].indexOf(":") < 0){
												continue;
											}
											typeid = typelist[i].split(":")[0];
											typename = typelist[i].split(":")[1];

											String selected = "";
											if(i == 0){
												selected = "selected";
											}

									%>
									<option value="<%=typeid%>"><%=typename%></option>
									<%
										}
									%>
								</select>
								<%
									}
									else{
										typeid = typelist[0].split(":")[0];
										typename = typelist[0].split(":")[1];
								%>
								<input type="text" style="border-style:none; background-color:transparent;width:100%;" value="<%=typename %>"  readonly>
								<input type="hidden" id="selMediatype" name="selMediatype" value="<%=typeid %>">
								<%
									}
								%>
							</td>
						</tr>
						<tr height="25px">
							<td nowrap valign="top" align="right">
								コメント&nbsp;
							</td>
							<td >
								<textarea id="txtComments" name="txtComments" wrap="off" class="orderInfoItem" style="height: 220px;"></textarea>
							</td>
						</tr>
					</table>
				</td>
				<%-- 画像選択 --%>
				<td class="frame-white" width="900px">
					<table border="0" width="100%">
						<tr>
							<td>
								<table border="0" width="100%">
									<tr>
										<td nowrap align="right">
											<input type="checkbox" id="chkKensadate" name="chkKensadate" value="Y" style="display:none;"/>検査日&nbsp;
										</td>
										<td nowrap colspan="2">
											<input type="text" id="dateFrom" name="dateFrom" style="width:80px;"> ～ <input type="text" id="dateTo" name="dateTo" style="width:80px;">
										</td>
										<td nowrap align="right">
											&nbsp;&nbsp;<input type="checkbox" id="chkModality" name="chkModality" value="Y" style="display:none;"/>モダリティ&nbsp;
										</td>
										<td nowrap >
											<select id="selModality" name="selModality" style="width: 120px;">
											<%
												if(modalityDat != null){
													//if(modalityDat.getRowCount() > 1){
											%>
											<option value=""></option>
											<%
													//}

													for(int i = 0; i < modalityDat.getRowCount(); i++){
											%>
											<option value="<%=modalityDat.getRows().get(i).get("MODALITY").toString()%>"><%=modalityDat.getRows().get(i).get("MODALITY").toString()%></option>
											<%
													}
												}
												else{
											%>
											<option value=""></option>
											<%
												}
											%>
											</select>
										</td>
										<td nowrap align="right">
											<input type="button" id="btnSearch" name="btnSearch" value="検索" class="smallbtn" onClick="serchStudy();">
											<input type="button" id="btnSearchClear" name="btnSearchClear" value="クリア" class="smallbtn" onClick="clearSearchParam();">
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td>
								<%-- 画像選択グリッド --%>
								<div style="height:340px; width:100%; overflow:auto; border-style:solid; border-width:1px; border-spacing:0px; border-collapse:collapse;" >
									<table id="tblStudy" width="100%" style="border-width:1px; border-style:solid; border-spacing:0px; border-collapse:collapse;">
										<thead>
										<tr>
											<%
												String column = sysConfig.getColumnOrder();
												String[] columnlist=column.split(",");

												for(int idx = 0; idx < columnlist.length; idx++){
											%>
											<th style="border-width:1px; border-style:solid; border-spacing:0px; border-collapse:collapse;">
												<div style="position:relative;">
												<%
													if(columnlist[idx].equals("選択")){
												%>
												<input type="checkbox" id="chkAllImage" name="chkAllImage" value="allselect" style="position:relative; top:2px;" onclick="selectAllImage(this);"/>
												<%
													}
												%>
												<%=columnlist[idx]%>
												</div>
											</th>
											<%
												}
											%>
										</tr>
										</thead>
										<%
											if(studyDat != null){
												for(int i = 0; i < studyDat.getRowCount(); i++){
													DataRow row = studyDat.getRows().get(i);

													String enablecheck = "";
													if(!row.get("MEDIA_BIKOU").toString().equals("")){
														enablecheck = "disabled";
													}

										%>
										<tbody>
											<tr height="25px">
											<%
													for(int idx = 0; idx < columnlist.length; idx++){
											%>
												<% 	if(columnlist[idx].equals("選択")){ %>
												<td nowrap align="center" class="studytable">
													<%--<input name="chkSelect" type="checkbox" value="<%=row.get("ACCESSIONNUMBER").toString()%>" <%=enablecheck%>/> --%>
													<input name="chkSelect" type="checkbox" value="<%=row.get("STUDYINSTANCEUID").toString()%>" <%=enablecheck%>/>
												</td>
												<% } %>
												<% 	if(columnlist[idx].equals("検査日")){ %>
													<%-- No30 特定の患者でメディア作成できない  2014/05/26 S.Terakata(STI) --%>
													<%
														String kensadate = "";
														if(row.get("STUDYDATE") != null){
															kensadate = new SimpleDateFormat("yyyy/MM/dd").format((Timestamp)row.get("STUDYDATE"));
														}
													%>
												<%-- <td nowrap align="center" class="studytable"><%=new SimpleDateFormat("yyyy/MM/dd").format((Timestamp)row.get("STUDYDATE"))%></td> --%>
												<td nowrap align="center" class="studytable"><%=kensadate%></td>
												<% } %>
												<% 	if(columnlist[idx].equals("モダリティ")){ %>
												<td nowrap align="center" class="studytable"><%=row.get("MODALITY").toString()%></td>
												<% } %>
												<% 	if(columnlist[idx].equals("AccessionNo")){ %>
												<td nowrap class="studytable"><%=row.get("ACCESSIONNUMBER").toString()%></td>
												<% } %>
												<% 	if(columnlist[idx].equals("検査種別")){ %>
												<td class="studytable"><%=row.get("STUDYDESCRIPTION").toString()%></td>
												<% } %>
												<% 	if(columnlist[idx].equals("画像")){ %>
												<td nowrap align="center" class="studytable">
													<%-- <a class="viewcgazou" href="javascript:showViewC('<%=row.get("ACCESSIONNUMBER").toString()%>');">&nbsp;</a> --%>
													<%-- <a target="_blank" class="viewcgazou" href="<%=String.format(sysConfig.getViewCUrl(), useridForVins, passwdForVins, row.get("ACCESSIONNUMBER").toString()) %>">&nbsp;</a> --%>
													<a target="_blank" class="viewcgazou" href="<%=String.format(sysConfig.getViewCUrl(), useridForVins, passwdForVins, row.get("ACCESSIONNUMBER").toString(), row.get("STUDYINSTANCEUID").toString()) %>">&nbsp;</a>
												</td>
												<% } %>
												<% 	if(columnlist[idx].equals("備考")){ %>
												<td class="studytable"><%=row.get("MEDIA_BIKOU").toString()%></td>
												<% } %>
											<%
												}
											%>
											</tr>
										<%
												}
											}
										%>
										</tbody>
									</table>
								</div>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr height="10px">
				<td><%-- 隙間を開けるための空行 --%></td>
			</tr>

			<tr height="50px">
				<%-- ボタン --%>
				<td class="frame1" colspan="2">
					<table border="0" align="right"> <%-- なぜか一番下に置くと改行されるのでここに置く。 --%>
						<tr>
							<td>
								<input type="button" id="btnClear" name="btnClear" class="cmdbtn" value="画面クリア" onclick="clearInfo();">
							</td>
						</tr>
					</table>
					<table border="0" align="left">
						<tr>
							<td>
								<input type="button" id="btnHistory" name="btnHistory" class="cmdbtn" value="履歴" onclick="showHistory();">
							</td>
						</tr>
					</table>
					<table border="0" align="center">
						<tr>
							<td>
								<input type="button" id="btnCreate" name="btnCreate" class="cmdbtn" value="メディア作成" onclick="createMedia();">
							</td>
							<td>
								<input type="button" id="btnPrint" name="btnPrint" class="cmdbtn" value="受取票印刷" onclick="printReceiptSheet();">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<input type="hidden" id="requesttype" name="requesttype"/>
		<input type="hidden" id="requestid" name="requestid" value="<%=requestid%>"/>
		<input type="hidden" id="fromKarte" name="fromKarte" value="<%=fromKarte%>"/>

	</form>
	<%-- ログインダイアログ --%>
	<div id="dialogLogin" title="ユーザ切替" style="display:none;">
		<table  align="center" width="100%">
			<tr align="center">
				<td>
					<table>
						<tr>
							<td align="right">
								ユーザID：
							</td>
							<td>
								<input type="text" name="userid" id="userid" style="height: 20px; width: 120px; font-size: large;">
							</td>
						</tr>
						<tr>
							<td align="right">
								パスワード：
							</td>
							<td>
								<input type="password" name="password" id="password" style="height: 20px; width: 120px; font-size: large;">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<span id="loginError" class="errmsg"></span>
				</td>
			</tr>
		</table>
	</div>

	<%-- メディア受取票用Form --%>
	<form name="ReceiptPrint" target="_blank" method="POST" action="ReceiptSheet">
		<input type="hidden" id="risid" name="risid" value="<%=risid%>"/>
	</form>
	<div class="frame1" id="waitMedia" title="メディアの作成" style="display:none;">
		メディアを作成しています。<br/>しばらくお待ちください。
	</div>

	<div class="frame1" id="dialogKaikei" title="会計情報連携" style="display:none;">
		発行依頼時に会計情報が連携します。
	</div>

	<%-- 履歴と患者情報用Form --%>
	<form name="PatientHistory" target="_blank" method="POST" action="" >
		<input type="hidden" id="patientid" name="patientid" value="<%=patientid%>"/>
	</form>

	<%-- ViewC用Form --%>
	<form name="ViewC" target="_blank" method="POST" action="ShowViewC" >
		<input type="hidden" id="accessionno" name="accessionno" />
	</form>

	<%-- Help用Form --%>
	<form name="Help" target="_blank" method="GET" action="Help" >
	</form>

	<%-- Alert --%>
	<div class="frame1" id="dialogAlert" title="メッセージ" style="display:none;">
	</div>

	<%-- Confirm --%>
	<div class="frame1" id="dialogConfirm" title="確認" style="display:none;">
	</div>

</body>
</html>