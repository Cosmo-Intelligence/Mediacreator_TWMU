<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="MediaCreator.Common.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
	request.setCharacterEncoding("UTF-8");

	Config sysConfig = (Config)SessionControler.getValue(request, SessionControler.SYSTEMCONFIG);

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">

<title>医療画像情報持出</title>

<script type="text/javascript" src="js/common.js"></script>
<link rel="stylesheet" href="css/CommonStyle.css" type="text/css" />

<%-- JQuery --%>
<script type="text/javascript" src="lib/jquery/js/jquery-1.8.3.js" ></script>
<script type="text/javascript" src="lib/jquery/js/jquery-ui-1.9.2.custom.js" ></script>
<script type="text/javascript" src="lib/jquery/js/i18n/jquery.ui.datepicker-ja.js" ></script>
<link rel="stylesheet" type="text/css" href="lib/jquery/css/mediacreator/jquery-ui-1.9.2.custom.css" />


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

	<!-- 本体部 -->
	<table class="noborder" style="width:100%; height:80%; border-spacing:0px; border-collapse:collapse;" >
		<tr>
			<td align="center">
				<% 	if(!Common.toNullString(sysConfig.getInformationSection()).equals("")){ %>
				問合せ先:<%=sysConfig.getInformationSection()%>
				<%
					}
					else{
				%>
				&nbsp;
				<% 	} %>
			</td>
		</tr>
		<tr>
			<%-- PDF --%>
			<td class="frame-white" align="center" >
				<iframe src="help/help.pdf" width="100%" height="480px" ></iframe>
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
						</td>
					</tr>
				</table>
				<table border="0" align="right">
					<tr>
						<td>
							<input type="button" id="btnClose" name="btnClose" class="cmdbtn" value="閉じる" onClick="close_win();" >
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

</body>
</html>