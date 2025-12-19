<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="MediaCreator.Common.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
	request.setCharacterEncoding("UTF-8");

	DataRow patientRow = (DataRow)request.getAttribute("PATIENTROWT");

	String patientid = "";
	String patientkana = "";
	String patientname = "";
	String patientroma = "";
	String birthday = "";
	String sex = "";
	String blood = "";
	String tall = "";
	String weight = "";
	String nyugai = "";
	String byoutou = "";
	String room = "";
	String info = "";

	if(patientRow != null){

		patientid = patientRow.get("KANJA_ID").toString();
		patientkana = patientRow.get("KANASIMEI").toString();
		patientname = patientRow.get("KANJISIMEI").toString();
		patientroma = patientRow.get("ROMASIMEI").toString();

		String birthdaybuff = patientRow.get("BIRTHDAY").toString();
		birthday = String.format("%s(%s%s).%s.%s %s歳"
						,birthdaybuff.substring(0,4)
						,patientRow.get("NENGO_CHAR").toString()
						,patientRow.get("NENGO_YEAR").toString()
						,birthdaybuff.substring(4,6)
						,birthdaybuff.substring(6,8)
						,patientRow.get("AGE").toString()
						);

		sex = patientRow.get("SEX").toString();
		blood = patientRow.get("BLOOD").toString();

		tall = patientRow.get("TALL").toString();
		if(!tall.equals("")) {
			tall += "cm";
		}

		weight = patientRow.get("WEIGHT").toString();
		if(!weight.equals("")) {
			weight += "kg";
		}

		if(patientRow.get("KANJA_NYUGAIKBN").toString().equals("1")) {
			nyugai = "外来";
		}
		else if(patientRow.get("KANJA_NYUGAIKBN").toString().equals("2")) {
			nyugai = "入院";
		}

		byoutou = patientRow.get("BYOUTOU_NAME").toString();
		room = patientRow.get("BYOUSITU_NAME").toString();

		String buff = "";
		if(!patientRow.get("HANDICAPPED").toString().equals("")) {
			buff += "【障害情報】\r\n";
			buff += patientRow.get("HANDICAPPED").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("INFECTION").toString().equals("")) {
			buff += "【感染情報】\r\n";
			buff += patientRow.get("INFECTION").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("CONTRAINDICATION").toString().equals("")) {
			buff += "【禁忌情報】\r\n";
			buff += patientRow.get("CONTRAINDICATION").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("ALLERGY").toString().equals("")) {
			buff += "【アレルギー情報】\r\n";
			buff += patientRow.get("ALLERGY").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("PREGNANCY").toString().equals("")) {
			buff += "【妊娠情報】\r\n";
			buff += patientRow.get("PREGNANCY").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("NOTES").toString().equals("")) {
			buff += "【その他注意事項】\r\n";
			buff += patientRow.get("NOTES").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("EXAMDATA").toString().equals("")) {
			buff += "【検査情報】\r\n";
			buff += patientRow.get("EXAMDATA").toString() + "\r\n";
			buff += "\r\n";
		}
		if(!patientRow.get("EXTRAPROFILE").toString().equals("")) {
			buff += "【その他属性情報】\r\n";
			buff += patientRow.get("EXTRAPROFILE").toString() + "\r\n";
			buff += "\r\n";
		}
		info = buff;
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

<style>

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
				患者詳細
			</td>
		</tr>
	</table>

<!-- 本体部 -->
	<table class="noborder" style="width:100%; height:70%; border-spacing:0px; border-collapse:collapse;" >
		<tr height="450px" valign="top">
			<td class="frame1" width="50%" >
				<table border="0">
					<tr><td>ID：<%=patientid%></td></tr>
					<tr><td>患者カナ氏名：<%=patientkana%></td></tr>
					<tr><td>患者氏名：<%=patientname%></td></tr>
					<tr><td>患者ローマ氏名：<%=patientroma%></td></tr>
					<tr><td>生年月日：<%=birthday%></td></tr>
					<tr><td>性別：<%=sex%></td></tr>
					<tr><td>血液型：<%=blood%></td></tr>
					<tr><td>身長：<%=tall%></td></tr>
					<tr><td>体重：<%=weight%></td></tr>
					<tr><td>患者入外区分：<%=nyugai%></td></tr>
					<tr><td>患者病棟：<%=byoutou%></td></tr>
					<tr><td>病室：<%=room%></td></tr>
				</table>
			</td>
			<td class="frame1" width="50%" align="left">
				<div style="width:100%; height:450px; border-style:none; overflow:auto;" ><%=info.replace("\r\n","<br/>").replace("\r","<br/>").replace("\n","<br/>")%></div>
			</td>
		</tr>
		<tr height="10px">
			<td><%-- 隙間を開けるための空行 --%></td>
		</tr>
		<tr height="50px">
			<%-- ボタン --%>
			<td class="frame1" colspan="2">
				<table border="0" align="left">
					<tr>
						<td>
						</td>
					</tr>
				</table>
				<table border="0" align="right">
					<tr>
						<td>
							<input type="button" id="btnClose" name="btnClose" class="cmdbtn" value="閉じる" onClick="close_win();">
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>