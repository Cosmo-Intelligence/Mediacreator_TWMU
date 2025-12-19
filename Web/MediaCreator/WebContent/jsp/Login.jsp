<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="MediaCreator.Common.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
	request.setCharacterEncoding("UTF-8");

	String errmsg = Common.toNullString((String)request.getAttribute("ERRMSG"));
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

	/*ログイン*/
	#btnLogin {
		background: url("images/login.png") !important; border:none;
	}
	#btnLogin:active {
		background: url("images/login_D.png") !important; border:none;
	}
	#btnLogin:disabled {
		background: url("images/login_S.png") !important; border:none;
	}

	/*キャンセル*/
	#btnCancel {
		background: url("images/cancel.png") !important; border:none;
	}
	#btnCancel:active {
		background: url("images/cancel_D.png") !important; border:none;
	}
	#btnCancel:disabled {
		background: url("images/cancel_S.png") !important; border:none;
	}

</style>

</head>

<script type="text/javascript">
$(function(){
	$(":button").val("");
	$(":submit").val("");
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
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<br/>
	<form name="LoginForm" action="Login" method="POST">
		<table align="center" width="100%">
			<tr align="center">
				<td>
					<table cellspacing="0" style="border-width:1px; border-style:none; border-spacing:0px; border-collapse:collapse;">
						<tr align="center" style="border-spacing:0px; border-collapse:collapse;">
							<td class="frame1" style="padding:5px 10px; border-spacing:0px; border-collapse:collapse;">
								<table>
									<tr>
										<td align="right">
											ユーザID：
										</td>
										<td>
											<input type="text" name="userid" style="height: 25px; width: 200px; font-size: large">
										</td>
									</tr>
									<tr>
										<td align="right">
											パスワード：
										</td>
										<td>
											<input type="password" name="password" style="height: 25px; width: 200px; font-size: large">
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr style="border-spacing:0px; border-collapse:collapse;">
							<td align="center" colspan="2" class="frame2" style="padding:5px 10px; border-spacing:0px; border-collapse:collapse;">
								<input id="btnLogin" type="submit" value="ログイン" onClick="document.LoginForm.submit();" class="cmdbtn">
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<input id="btnCancel" type="button" value="キャンセル" onClick="close_win();" class="cmdbtn">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<span class="errmsg"><%=errmsg %></span>
				</td>
			</tr>
		</table>
	</form>
</body>
</html>