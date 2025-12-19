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
			<!-- 2021.08.18 del start cosmo@Nishihara YOKOGAWAロゴ削除  -->
			<!-- <td background="images/frame_upper.jpg"><img src="images/yokogawa.png" /></td> -->
			<!-- 2021.08.18 del end cosmo@Nishihara YOKOGAWAロゴ削除  -->
			<td background="images/frame_upper.jpg">&nbsp;</td>
			<td background="images/frame_upper.jpg">&nbsp;</td>
		</tr>
	</table>

	<table class="frame1" width="100%" height="98%" align="center">
		<tr>
			<td>
				<table border="0" align="center">
					<tr>
						<td align="center">
							只今の時間はシステム停止中です。
						</td>
					</tr>
					<tr>
						<td align="center">
							本システムは営業時間内のみ稼動しています。
						</td>
					</tr>
					<tr>
						<td align="center">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td align="center">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td align="center">
							&nbsp;
						</td>
					</tr>
					<% 	if(!Common.toNullString(sysConfig.getInformationSection()).equals("")){ %>
					<tr>
						<td align="center">
							問合せ先
						</td>
					</tr>
					<tr>
						<td align="center">
							<%=sysConfig.getInformationSection() %>
						</td>
					</tr>
					<%	} %>
					<tr>
						<td align="center">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td align="center">
							<input id="btnClose" type="button" class="cmdbtn" value="キャンセル" onclick="close_win();" >
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>