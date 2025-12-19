<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    
<%@ page import="MediaCreator.Common.*" %> 
<%@ page import="java.sql.*" %> 
<%@ page import="java.net.*" %> 

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%
	request.setCharacterEncoding("UTF-8");

		String RIS_ID = (String)request.getAttribute("RIS_ID");					//ris_id
		String DOCTOR_NAME = (String)request.getAttribute("DOCTOR_NAME");		//依頼医
		String SECTION_NAME = (String)request.getAttribute("SECTION_NAME");		//依頼科
		Timestamp REQUESTDATE = (Timestamp)request.getAttribute("REQUESTDATE");	//依頼日
		String KANJA_ID = (String)request.getAttribute("KANJA_ID");				//患者ID
		String KANJISIMEI = (String)request.getAttribute("KANJISIMEI");			//患者氏名
		String ORDERNO = (String)request.getAttribute("ORDERNO");				//AccessionNo
		String NYUGAI = (String)request.getAttribute("NYUGAI");					//入外
		
		
		String   ACCESSIONNO_1			=	(String)request.getAttribute(     "ACCESSIONNO_1");
		String MODALITY_TYPE_1			=	(String)request.getAttribute(   "MODALITY_TYPE_1");
		Timestamp KENSA_DATE_1			=	(Timestamp)request.getAttribute(   "KENSA_DATE_1");
		String STUDYDESCRIPTION_1		=	(String)request.getAttribute("STUDYDESCRIPTION_1");

		String ACCESSIONNO_2			=	(String)request.getAttribute(     "ACCESSIONNO_2");
		String MODALITY_TYPE_2			=	(String)request.getAttribute(   "MODALITY_TYPE_2");
		Timestamp KENSA_DATE_2			=	(Timestamp)request.getAttribute(   "KENSA_DATE_2");
		String STUDYDESCRIPTION_2		=	(String)request.getAttribute("STUDYDESCRIPTION_2");

		String ACCESSIONNO_3			=	(String)request.getAttribute(     "ACCESSIONNO_3");
		String MODALITY_TYPE_3			=	(String)request.getAttribute(   "MODALITY_TYPE_3");
		Timestamp KENSA_DATE_3			=	(Timestamp)request.getAttribute(   "KENSA_DATE_3");
		String STUDYDESCRIPTION_3		=	(String)request.getAttribute("STUDYDESCRIPTION_3");

		String ACCESSIONNO_4			=	(String)request.getAttribute(     "ACCESSIONNO_4");
		String MODALITY_TYPE_4			=	(String)request.getAttribute(   "MODALITY_TYPE_4");
		Timestamp KENSA_DATE_4			=	(Timestamp)request.getAttribute(   "KENSA_DATE_4");
		String STUDYDESCRIPTION_4		=	(String)request.getAttribute("STUDYDESCRIPTION_4");

		String ACCESSIONNO_5			=	(String)request.getAttribute(     "ACCESSIONNO_5");
		String MODALITY_TYPE_5			=	(String)request.getAttribute(   "MODALITY_TYPE_5");
		Timestamp KENSA_DATE_5			=	(Timestamp)request.getAttribute(   "KENSA_DATE_5");
		String STUDYDESCRIPTION_5		=	(String)request.getAttribute("STUDYDESCRIPTION_5");

		String ACCESSIONNO_6			=	(String)request.getAttribute(     "ACCESSIONNO_6");
		String MODALITY_TYPE_6			=	(String)request.getAttribute(   "MODALITY_TYPE_6");
		Timestamp KENSA_DATE_6			=	(Timestamp)request.getAttribute(   "KENSA_DATE_6");
		String STUDYDESCRIPTION_6		=	(String)request.getAttribute("STUDYDESCRIPTION_6");

		String ACCESSIONNO_7			=	(String)request.getAttribute(     "ACCESSIONNO_7");
		String MODALITY_TYPE_7			=	(String)request.getAttribute(   "MODALITY_TYPE_7");
		Timestamp KENSA_DATE_7			=	(Timestamp)request.getAttribute(   "KENSA_DATE_7");
		String STUDYDESCRIPTION_7		=	(String)request.getAttribute("STUDYDESCRIPTION_7");

		String ACCESSIONNO_8			=	(String)request.getAttribute(     "ACCESSIONNO_8");
		String MODALITY_TYPE_8			=	(String)request.getAttribute(   "MODALITY_TYPE_8");
		Timestamp KENSA_DATE_8			=	(Timestamp)request.getAttribute(   "KENSA_DATE_8");
		String STUDYDESCRIPTION_8		=	(String)request.getAttribute("STUDYDESCRIPTION_8");

		String ACCESSIONNO_9			=	(String)request.getAttribute(     "ACCESSIONNO_9");
		String MODALITY_TYPE_9			=	(String)request.getAttribute(   "MODALITY_TYPE_9");
		Timestamp KENSA_DATE_9			=	(Timestamp)request.getAttribute(   "KENSA_DATE_9");
		String STUDYDESCRIPTION_9		=	(String)request.getAttribute("STUDYDESCRIPTION_9");

		String ACCESSIONNO_10			=	(String)request.getAttribute(     "ACCESSIONNO_10");
		String MODALITY_TYPE_10			=	(String)request.getAttribute(   "MODALITY_TYPE_10");
		Timestamp KENSA_DATE_10			=	(Timestamp)request.getAttribute(   "KENSA_DATE_10");
		String STUDYDESCRIPTION_10		=	(String)request.getAttribute("STUDYDESCRIPTION_10");

		String ACCESSIONNO_11			=	(String)request.getAttribute(     "ACCESSIONNO_11");
		String MODALITY_TYPE_11			=	(String)request.getAttribute(   "MODALITY_TYPE_11");
		Timestamp KENSA_DATE_11			=	(Timestamp)request.getAttribute(   "KENSA_DATE_11");
		String STUDYDESCRIPTION_11		=	(String)request.getAttribute("STUDYDESCRIPTION_11");

		String ACCESSIONNO_12			=	(String)request.getAttribute(     "ACCESSIONNO_12");
		String MODALITY_TYPE_12			=	(String)request.getAttribute(   "MODALITY_TYPE_12");
		Timestamp KENSA_DATE_12			=	(Timestamp)request.getAttribute(   "KENSA_DATE_12");
		String STUDYDESCRIPTION_12		=	(String)request.getAttribute("STUDYDESCRIPTION_12");

		String ACCESSIONNO_13			=	(String)request.getAttribute(     "ACCESSIONNO_13");
		String MODALITY_TYPE_13			=	(String)request.getAttribute(   "MODALITY_TYPE_13");
		Timestamp KENSA_DATE_13			=	(Timestamp)request.getAttribute(   "KENSA_DATE_13");
		String STUDYDESCRIPTION_13		=	(String)request.getAttribute("STUDYDESCRIPTION_13");

		String ACCESSIONNO_14			=	(String)request.getAttribute(     "ACCESSIONNO_14");
		String MODALITY_TYPE_14			=	(String)request.getAttribute(   "MODALITY_TYPE_14");
		Timestamp KENSA_DATE_14			=	(Timestamp)request.getAttribute(   "KENSA_DATE_14");
		String STUDYDESCRIPTION_14		=	(String)request.getAttribute("STUDYDESCRIPTION_14");

		String ACCESSIONNO_15			=	(String)request.getAttribute(     "ACCESSIONNO_15");
		String MODALITY_TYPE_15			=	(String)request.getAttribute(   "MODALITY_TYPE_15");
		Timestamp KENSA_DATE_15			=	(Timestamp)request.getAttribute(   "KENSA_DATE_15");
		String STUDYDESCRIPTION_15		=	(String)request.getAttribute("STUDYDESCRIPTION_15");

		String ACCESSIONNO_16			=	(String)request.getAttribute(     "ACCESSIONNO_16");
		String MODALITY_TYPE_16			=	(String)request.getAttribute(   "MODALITY_TYPE_16");
		Timestamp KENSA_DATE_16			=	(Timestamp)request.getAttribute(   "KENSA_DATE_16");
		String STUDYDESCRIPTION_16		=	(String)request.getAttribute("STUDYDESCRIPTION_16");

		String ACCESSIONNO_17			=	(String)request.getAttribute(     "ACCESSIONNO_17");
		String MODALITY_TYPE_17			=	(String)request.getAttribute(   "MODALITY_TYPE_17");
		Timestamp KENSA_DATE_17			=	(Timestamp)request.getAttribute(   "KENSA_DATE_17");
		String STUDYDESCRIPTION_17		=	(String)request.getAttribute("STUDYDESCRIPTION_17");

		String ACCESSIONNO_18			=	(String)request.getAttribute(     "ACCESSIONNO_18");
		String MODALITY_TYPE_18			=	(String)request.getAttribute(   "MODALITY_TYPE_18");
		Timestamp KENSA_DATE_18			=	(Timestamp)request.getAttribute(   "KENSA_DATE_18");
		String STUDYDESCRIPTION_18		=	(String)request.getAttribute("STUDYDESCRIPTION_18");

		String ACCESSIONNO_19			=	(String)request.getAttribute(     "ACCESSIONNO_19");
		String MODALITY_TYPE_19			=	(String)request.getAttribute(   "MODALITY_TYPE_19");
		Timestamp KENSA_DATE_19			=	(Timestamp)request.getAttribute(   "KENSA_DATE_19");
		String STUDYDESCRIPTION_19		=	(String)request.getAttribute("STUDYDESCRIPTION_19");

		String ACCESSIONNO_20			=	(String)request.getAttribute(     "ACCESSIONNO_20");
		String MODALITY_TYPE_20			=	(String)request.getAttribute(   "MODALITY_TYPE_20");
		Timestamp KENSA_DATE_20			=	(Timestamp)request.getAttribute(   "KENSA_DATE_20");
		String STUDYDESCRIPTION_20		=	(String)request.getAttribute("STUDYDESCRIPTION_20");

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">

<title>メディア受取票</title>

<script type="text/javascript" src="js/common.js"></script>

<%-- JQuery --%>
<script type="text/javascript" src="lib/jquery/js/jquery-1.8.3.js" ></script>
<script type="text/javascript" src="lib/jquery/js/jquery-ui-1.9.2.custom.js" ></script>
<script type="text/javascript" src="lib/jquery/js/i18n/jquery.ui.datepicker-ja.js" ></script>
<link rel="stylesheet" type="text/css" media="all"href="lib/jquery/css/mediacreator/jquery-ui-1.9.2.custom.css" />


<link rel="stylesheet" media="all" href="css/CommonStyle.css" type="text/css" />
<link rel="stylesheet" media="print" href="css/PrintStyle.css" type="text/css"/>


</head>
<%--
	レイアウト編集の説明。
	
	使える変数は下記です。
	HTMLに埋め込む際には <%= と %> で括って下さい。
	
	
	/* メディア作成依頼情報 */
	RIS_ID 			//ris_id
	DOCTOR_NAME		//依頼医
	SECTION_NAME	//依頼科
	REQUESTDATE		//依頼日(日付型)
	KANJA_ID 		//患者ID
	KANJISIMEI		//患者氏名
	ORDERNO			//オーダーNo(AccessionNo)
	NYUGAI			//入外

	/* メディア持ち出し画像情報 */
	/* 末尾の数字は1から20の最大20件まで使用できます。 */
	ACCESSIONNO_1		//AccessionNumber
	MODALITY_TYPE_1		//モダリティ
	KENSA_DATE_1		//検査日(日付型)
	STUDYDESCRIPTION_1	//STUDYDESCRIPTION


	■日付型の変数は、下記要領でフォーマットして使用して下さい。
	
		例：依頼日を 2013/11/18 の形式にする場合。
		Common.toFormatString(REQUESTDATE,"yyyy/MM/dd")


	■バーコードの表示
	バーコードはimgタグで表示します。
	下記の要領でsrcに表示する値とサイズを指定します。
	<img src="BarcodeImage?value=<%=KANJA_ID%>&width=100&height=30">

		value: バーコードの値
		width: バーコードの幅(px)
		height:バーコードの高さ(px)


 	ここから下(<body>から下)を編集して下さい。 
 	変数の埋め込み以外は通常のHTMLです。
 	
 --%>
<body>
	<h1>メディア受取票</h1>
	<input type="button" value="印刷" class="smallbtn" onclick="window.print();">
	<br/>

	RIS_ID                          = <%=RIS_ID%> <BR/>
	DOCTOR_NAME                     = <%=DOCTOR_NAME%> <BR/>
	SECTION_NAME                    = <%=SECTION_NAME%> <BR/>
	REQUESTDATE                     = <%=REQUESTDATE%> <BR/>
	KANJA_ID                        = <%=KANJA_ID%> <BR/>
	KANJISIMEI                      = <%=KANJISIMEI%> <BR/>
	ORDERNO                         = <%=ORDERNO%> <BR/>
	NYUGAI                         	= <%=NYUGAI%> <BR/>
	
	
	ACCESSIONNO_1                   = <%=ACCESSIONNO_1%> <BR/>
	MODALITY_TYPE_1                 = <%=MODALITY_TYPE_1%> <BR/>
	KENSA_DATE_1                    = <%=KENSA_DATE_1%> <BR/>
	STUDYDESCRIPTION_1              = <%=STUDYDESCRIPTION_1%> <BR/>
	
	ACCESSIONNO_2                   = <%=ACCESSIONNO_2%> <BR/>
	MODALITY_TYPE_2                 = <%=MODALITY_TYPE_2%> <BR/>
	KENSA_DATE_2                    = <%=KENSA_DATE_2%> <BR/>
	STUDYDESCRIPTION_2              = <%=STUDYDESCRIPTION_2%> <BR/>
	
	ACCESSIONNO_3                   = <%=ACCESSIONNO_3%> <BR/>
	MODALITY_TYPE_3                 = <%=MODALITY_TYPE_3%> <BR/>
	KENSA_DATE_3                    = <%=KENSA_DATE_3%> <BR/>
	STUDYDESCRIPTION_3              = <%=STUDYDESCRIPTION_3%> <BR/>
	
	ACCESSIONNO_4                   = <%=ACCESSIONNO_4%> <BR/>
	MODALITY_TYPE_4                 = <%=MODALITY_TYPE_4%> <BR/>
	KENSA_DATE_4                    = <%=KENSA_DATE_4%> <BR/>
	STUDYDESCRIPTION_4              = <%=STUDYDESCRIPTION_4%> <BR/>
	
	ACCESSIONNO_5                   = <%=ACCESSIONNO_5%> <BR/>
	MODALITY_TYPE_5                 = <%=MODALITY_TYPE_5%> <BR/>
	KENSA_DATE_5                    = <%=KENSA_DATE_5%> <BR/>
	STUDYDESCRIPTION_5              = <%=STUDYDESCRIPTION_5%> <BR/>
	
	ACCESSIONNO_6                   = <%=ACCESSIONNO_6%> <BR/>
	MODALITY_TYPE_6                 = <%=MODALITY_TYPE_6%> <BR/>
	KENSA_DATE_6                    = <%=KENSA_DATE_6%> <BR/>
	STUDYDESCRIPTION_6              = <%=STUDYDESCRIPTION_6%> <BR/>
	
	ACCESSIONNO_7                   = <%=ACCESSIONNO_7%> <BR/>
	MODALITY_TYPE_7                 = <%=MODALITY_TYPE_7%> <BR/>
	KENSA_DATE_7                    = <%=KENSA_DATE_7%> <BR/>
	STUDYDESCRIPTION_7              = <%=STUDYDESCRIPTION_7%> <BR/>
	
	ACCESSIONNO_8                   = <%=ACCESSIONNO_8%> <BR/>
	MODALITY_TYPE_8                 = <%=MODALITY_TYPE_8%> <BR/>
	KENSA_DATE_8                    = <%=KENSA_DATE_8%> <BR/>
	STUDYDESCRIPTION_8              = <%=STUDYDESCRIPTION_8%> <BR/>
	
	ACCESSIONNO_9                   = <%=ACCESSIONNO_9%> <BR/>
	MODALITY_TYPE_9                 = <%=MODALITY_TYPE_9%> <BR/>
	KENSA_DATE_9                    = <%=KENSA_DATE_9%> <BR/>
	STUDYDESCRIPTION_9              = <%=STUDYDESCRIPTION_9%> <BR/>
	
	ACCESSIONNO_10                  = <%=ACCESSIONNO_10%> <BR/>
	MODALITY_TYPE_10                = <%=MODALITY_TYPE_10%> <BR/>
	KENSA_DATE_10                   = <%=KENSA_DATE_10%> <BR/>
	STUDYDESCRIPTION_10             = <%=STUDYDESCRIPTION_10%> <BR/>
	
	ACCESSIONNO_11                  = <%=ACCESSIONNO_11%> <BR/>
	MODALITY_TYPE_11                = <%=MODALITY_TYPE_11%> <BR/>
	KENSA_DATE_11                   = <%=KENSA_DATE_11%> <BR/>
	STUDYDESCRIPTION_11             = <%=STUDYDESCRIPTION_11%> <BR/>
	
	ACCESSIONNO_12                  = <%=ACCESSIONNO_12%> <BR/>
	MODALITY_TYPE_12                = <%=MODALITY_TYPE_12%> <BR/>
	KENSA_DATE_12                   = <%=KENSA_DATE_12%> <BR/>
	STUDYDESCRIPTION_12             = <%=STUDYDESCRIPTION_12%> <BR/>
	
	ACCESSIONNO_13                  = <%=ACCESSIONNO_13%> <BR/>
	MODALITY_TYPE_13                = <%=MODALITY_TYPE_13%> <BR/>
	KENSA_DATE_13                   = <%=KENSA_DATE_13%> <BR/>
	STUDYDESCRIPTION_13             = <%=STUDYDESCRIPTION_13%> <BR/>
	
	ACCESSIONNO_14                  = <%=ACCESSIONNO_14%> <BR/>
	MODALITY_TYPE_14                = <%=MODALITY_TYPE_14%> <BR/>
	KENSA_DATE_14                   = <%=KENSA_DATE_14%> <BR/>
	STUDYDESCRIPTION_14             = <%=STUDYDESCRIPTION_14%> <BR/>
	
	ACCESSIONNO_15                  = <%=ACCESSIONNO_15%> <BR/>
	MODALITY_TYPE_15                = <%=MODALITY_TYPE_15%> <BR/>
	KENSA_DATE_15                   = <%=KENSA_DATE_15%> <BR/>
	STUDYDESCRIPTION_15             = <%=STUDYDESCRIPTION_15%> <BR/>
	
	ACCESSIONNO_16                  = <%=ACCESSIONNO_16%> <BR/>
	MODALITY_TYPE_16                = <%=MODALITY_TYPE_16%> <BR/>
	KENSA_DATE_16                   = <%=KENSA_DATE_16%> <BR/>
	STUDYDESCRIPTION_16             = <%=STUDYDESCRIPTION_16%> <BR/>
	
	ACCESSIONNO_17                  = <%=ACCESSIONNO_17%> <BR/>
	MODALITY_TYPE_17                = <%=MODALITY_TYPE_17%> <BR/>
	KENSA_DATE_17                   = <%=KENSA_DATE_17%> <BR/>
	STUDYDESCRIPTION_17             = <%=STUDYDESCRIPTION_17%> <BR/>
	
	ACCESSIONNO_18                  = <%=ACCESSIONNO_18%> <BR/>
	MODALITY_TYPE_18                = <%=MODALITY_TYPE_18%> <BR/>
	KENSA_DATE_18                   = <%=KENSA_DATE_18%> <BR/>
	STUDYDESCRIPTION_18             = <%=STUDYDESCRIPTION_18%> <BR/>
	
	ACCESSIONNO_19                  = <%=ACCESSIONNO_19%> <BR/>
	MODALITY_TYPE_19                = <%=MODALITY_TYPE_19%> <BR/>
	KENSA_DATE_19                   = <%=KENSA_DATE_19%> <BR/>
	STUDYDESCRIPTION_19             = <%=STUDYDESCRIPTION_19%> <BR/>
	
	ACCESSIONNO_20                  = <%=ACCESSIONNO_20%> <BR/>
	MODALITY_TYPE_20                = <%=MODALITY_TYPE_20%> <BR/>
	KENSA_DATE_20                   = <%=KENSA_DATE_20%> <BR/>
	STUDYDESCRIPTION_20             = <%=STUDYDESCRIPTION_20%> <BR/>
	
	バーコード<br/>
	患者ID<img src="BarcodeImage?value=<%=KANJA_ID%>&width=100&height=30"><BR/>
	AccessionNo<img src="BarcodeImage?value=<%=ORDERNO%>&width=100&height=30"><BR/>

</body>
</html>