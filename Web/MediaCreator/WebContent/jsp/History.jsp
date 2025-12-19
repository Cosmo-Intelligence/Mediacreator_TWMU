<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="MediaCreator.Common.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
	request.setCharacterEncoding("UTF-8");

	DataTable orderDat = (DataTable)request.getAttribute("ORDERLIST");

	DataRow emp = (DataRow)SessionControler.getValue(request, SessionControler.LOGINUSER);
	DataRow patientRow = (DataRow)request.getAttribute("PATIENTINFO");

	String patientid = "";
	String patientkana = "";
	String patientname = "";
	String patientsex = "";
	String patientbirth = "";
	String patientbyoutou = "";
	String patientsexicon = "images/sex_unknown.png";

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

<%-- JQuery --%>
<script type="text/javascript" src="lib/jquery/js/jquery-1.8.3.js" ></script>
<script type="text/javascript" src="lib/jquery/js/jquery-ui-1.9.2.custom.js" ></script>
<script type="text/javascript" src="lib/jquery/js/i18n/jquery.ui.datepicker-ja.js" ></script>
<link rel="stylesheet" type="text/css" media="all"href="lib/jquery/css/mediacreator/jquery-ui-1.9.2.custom.css" />


<link rel="stylesheet" media="all" href="css/CommonStyle.css" type="text/css" />

</head>

<script type="text/javascript">

	function showPatientInfo(){
		document.PatientHistory.action = "PatientInfo";
		document.PatientHistory.submit();
	}

	function printReceiptSheet(){

		if($('[name="rdoSelect"]:checked').length == 0){
			alertDialog("対象オーダーを選択して下さい。");
			return false;
		}


		$("#risid").val($('input[name="rdoSelect"]:checked').val());
		document.ReceiptPrint.submit();
	}

	function showReadme(orderno){
		var ret = false;

		$("#txtReadme").val("");

		var obj = null;
		var param = [
				{ name : 'orderno', value : orderno }
			];

		$.ajax({
			type: 'POST',
			url: 'GetReadme' + '?dummy=' + (new Date()).getTime(),
			data: param,
			dataType: 'json',
			async: false,
			cache: false,
			success: function(data, dataType){obj = data;},
			error: function(XMLHttpRequest, textStatus, errorThrown){alertDialog(textStatus + '\n接続が切れた可能性があります。再度ログインしてください。');}
		});


		//alert(ret);

		if(obj.result == 'true'){
			$("#txtReadme").val(obj.readme);
			ret = true;
		}
		else{
			ret = false;
		}

		return ret;

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

</script>

<style>

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

	/* Alertダイアログのボタンサイズ */
	#btnDialogAlertOK {
		width:113px; height:30px;
	}


</style>

</head>

<script type="text/javascript">
$(function(){
	$(":button").val("");
});
</script>

<body class="main-back">

	<!-- ヘッダ部 -->
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr align="right">
			<td background="images/frame_upper.jpg" align="left"><img src="images/frame_title.jpg"></td>
			<!-- 2021.08.19 del start cosmo@Nishihara YOKOGAWAロゴ削除  -->
			<!-- <td background="images/frame_upper.jpg"><img src="images/yokogawa.png" /></td> -->
			<!-- 2021.08.19 del end cosmo@Nishihara YOKOGAWAロゴ削除  -->
			<td background="images/frame_upper.jpg">&nbsp;</td>
			<td background="images/frame_upper.jpg">&nbsp;</td>
		</tr>
	</table>

	<!-- タイトル -->
	<table class="noborder" style="width:100%; height:30px;" >
		<tr>
			<td align="left" style="font-size:medium;">
				作成履歴
			</td>
			<td align="right">
				<input type="button" id="btnClose" name="btnClose" class="cmdbtn" value="閉じる" onClick="close_win();">
			</td>
		</tr>
	</table>

	<!-- 本体部 -->
	<form name="MainForm">
		<input type="text" style="display:none;" />
		<table class="noborder" style="width:100%; height:80%; border-spacing:0px; border-collapse:collapse;" >
			<tr height="30px">
				<%-- 患者情報 --%>
				<td class="frame1" colspan="2">
					<table border="0" width="100%" style="font-size:medium;">
						<%-- <tr><td colspan="7"><span class="errmsg"><%=errmsg %></span></td></tr> --%>
						<tr>
							<%-- 患者ID入力 --%>
							<td width="120px" nowrap>
								患者ID&nbsp;<input readonly value="<%=patientid%>" type="text" id="txtPatientid" name="txtPatientid" style="font-size: large; width: 100px; background-color:#C7ECF8;" />
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
							</td>							<%-- 患者詳細ボタン --%>
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

			<tr height="280px">
				<%-- 履歴一覧 --%>
				<td class="frame-white" align="center" >
					<div style="height:270px; width:98%; overflow-y:scroll; border-style:solid; border-width:1px; border-spacing:0px; border-collapse:collapse;">
						<table width="100%" style="border-width:1px; border-style:solid; border-spacing:0px; border-collapse:collapse;">
							<tr>
								<th>
									選択
								</th>
								<th>
									依頼日
								</th>
								<th>
									依頼科
								</th>
								<th>
									依頼者
								</th>
								<th>
									作成区分
								</th>
								<th>
									装置
								</th>
								<th>
									進捗
								</th>
							</tr>
							<%
								if(orderDat != null){
									for(int i = 0; i < orderDat.getRowCount(); i++){
										DataRow row = orderDat.getRows().get(i);
							%>
								<tr height="25px">
									<%
										//社内テストNo6 依頼ファイル作成失敗時のTransferStatus
										String disabled = "";
										if(row.get("SINTYOKU").toString().equals("失敗")){
											disabled = "disabled";
										}
									%>
									<td align="center" class="studytable">
										<input name="rdoSelect" type="radio" value="<%=row.get("RIS_ID").toString()%>" onclick="showReadme('<%=row.get("ORDERNO").toString()%>');" <%=disabled %>>
									</td>
									<td class="studytable"><%=Common.toFormatString((Timestamp)row.get("REQUESTDATE"),"yyyy/MM/dd")%></td>
									<td class="studytable"><%=row.get("SECTION_NAME").toString()%></td>
									<td class="studytable"><%=row.get("DOCTOR_NAME").toString()%></td>
									<td class="studytable"><%=row.get("BUI_NAME").toString()%></td>
									<td class="studytable"><%=row.get("KENSAKIKI_NAME").toString()%></td>
									<td class="studytable"><%=row.get("SINTYOKU").toString()%></td>
								</tr>
							<%
									}
								}
							%>
						</table>
					</div>
				</td>
			</tr>
			<tr height="130px">
				<%-- ReadMe --%>
				<td class="frame1" >
					<table border="0" width="100%">
						<tr>
							<td align="center">
								<textarea id="txtReadme" name="txtReadme" wrap="off" style="width:98%; height:120px; background-color:#C7ECF8;" readonly></textarea>
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
				<td class="frame1" >
					<table border="0" align="left">
						<tr>
							<td>
								<input type="button" id="btnPrint" name="btnPrint" class="cmdbtn" value="受取票印刷" onclick="printReceiptSheet();">
							</td>
						</tr>
					</table>
					<table border="0" align="right">
						<tr>
							<td>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</form>

	<%-- メディア受取票用Form --%>
	<form name="ReceiptPrint" target="_blank" method="POST" action="ReceiptSheet">
		<input type="hidden" id="risid" name="risid" />
	</form>

	<%-- 患者情報用Form --%>
	<form name="PatientHistory" target="_blank" method="POST" action="" >
		<input type="hidden" id="patientid" name="patientid" value="<%=patientid%>"/>
	</form>

	<%-- Alert --%>
	<div class="frame1" id="dialogAlert" title="メッセージ" style="display:none;">
	</div>

</body>
</html>