package MediaCreator.Common;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.URL;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletContext;
import javax.xml.parsers.*;



import org.apache.log4j.*;
import org.w3c.dom.*;


public class Config implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static Logger logger = LogFactory.getLogger();

	
	private static final String FILE_NAME = "/WEB-INF/MediaCreator.config.xml";
	

	private String kensatypeid = null;
	private String sakuseiKbn = null;
	private String sakuseiSouti = null;
	private int patientLength = 8;
	private String viewCUrl = null;
	private boolean checkWorkTime = true;
	
	private String studyInstanceUid = null;
	
	private String informationSection = null;
	
	private String columnOrder = null;
	
	private String receiptSheetJspName = null;
	
	private String mediaType = null;
	
	private String kensasituID = null;
	
	private String jisisyaID = null;
	
	private String kaikeiDialog = null;
	
	//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
	private int connectRetryLimit = 0;
	
	//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
	private int connectRetryInterval = 0;

	private Config(){
	}

	
	public String getRecelptSheetJspName() {
		return receiptSheetJspName;
	}

	public void setRecelptSheetJspName(String receiptSheetJspName) {
		this.receiptSheetJspName = receiptSheetJspName;
	}

	public String getColumnOrder() {
		return columnOrder;
	}

	public void setColumnOrder(String columnOrder) {
		this.columnOrder = columnOrder;
	}

	public String getInformationSection() {
		return informationSection;
	}

	public void setInformationSection(String informationSection) {
		this.informationSection = informationSection;
	}

	
	
	public String getKensatypeid() {
		return kensatypeid;
	}

	public void setKensatypeid(String kensatypeid) {
		this.kensatypeid = kensatypeid;
	}

	public String getSakuseiKbn() {
		return sakuseiKbn;
	}

	public void setSakuseiKbn(String sakuseiKbn) {
		this.sakuseiKbn = sakuseiKbn;
	}

	public String getSakuseiSouti() {
		return sakuseiSouti;
	}

	public void setSakuseiSouti(String sakuseiSouti) {
		this.sakuseiSouti = sakuseiSouti;
	}

	public int getPatientLength() {
		return patientLength;
	}

	public void setPatientLength(int patientLength) {
		this.patientLength = patientLength;
	}

	public String getViewCUrl() {
		return viewCUrl;
	}

	public void setViewCUrl(String viewCUrl) {
		this.viewCUrl = viewCUrl;
	}

	public boolean isCheckWorkTime() {
		return checkWorkTime;
	}

	public void setCheckWorkTime(boolean checkWorkTime) {
		this.checkWorkTime = checkWorkTime;
	}
	
	public static Config getConfig(ServletContext ctx){

		Config config = loadConfig(ctx);
		
		return config;
	}
	
	public String getStudyInstanceUid() {
		return studyInstanceUid;
	}

	public void setStudyInstanceUid(String studyInstanceUid) {
		this.studyInstanceUid = studyInstanceUid;
	}

	
	private static Config loadConfig(ServletContext ctx){

		Config config = null;
		
		try {

			URL url = ctx.getResource(FILE_NAME);
			logger.debug(FILE_NAME + " = " + url);
			
			InputStream stream = ctx.getResourceAsStream(FILE_NAME);
			
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc = builder.parse(stream);
			Element root = doc.getDocumentElement();
			
			HashMap<String,String> map = new HashMap<String,String>();
			for(int i = 0; i < root.getChildNodes().getLength(); i++){
				logger.debug(root.getChildNodes().item(i).getNodeName() + ":" + root.getChildNodes().item(i).getTextContent());
				map.put(root.getChildNodes().item(i).getNodeName(), Common.toNullString(root.getChildNodes().item(i).getTextContent()));
			}
			
			config = new Config();
			
			config.setKensatypeid(map.get("KensaTypeId"));
			config.setSakuseiKbn(map.get("BuiId"));
			config.setSakuseiSouti(map.get("KensaKikiId"));
			config.setPatientLength(Integer.parseInt(map.get("PatientLength")));
			config.setViewCUrl(map.get("ViewCURL"));
			config.setStudyInstanceUid(map.get("StudyInstanceUID"));
			
			String flg = map.get("CheckWorkTime");
			if(flg.equals("Y")){
				config.setCheckWorkTime(true);
			}
			else{
				config.setCheckWorkTime(false);
			}
			
			config.setInformationSection(map.get("InformationSection"));
			config.setColumnOrder(map.get("ColumnOrder"));
			config.setRecelptSheetJspName(map.get("ReceiptSheetJSP"));
			
			config.setMediaType(map.get("MediaType"));
			
			config.setKensasituID(map.get("KensasituID"));

			config.setJisisyaID(map.get("JisisyaID"));
			
			//MIS受入テストNo43
			config.setKaikeiDialog(map.get("KaikeiDialog"));
			
			//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
			config.setConnectRetryLimit(Integer.parseInt(map.get("ConnectRetryLimit")));
			
			//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
			config.setConnectRetryInterval(Integer.parseInt(map.get("ConnectRetryInterval")));

		} 
		catch (Exception e) {
			logger.error(e.getMessage(),e);
			config = null;
		}
		
		return config;
	}


	public String getMediaType() {
		return mediaType;
	}


	public void setMediaType(String mediaType) {
		this.mediaType = mediaType;
	}


	public String getKensasituID() {
		return kensasituID;
	}


	public void setKensasituID(String kensasituID) {
		this.kensasituID = kensasituID;
	}


	public String getJisisyaID() {
		return jisisyaID;
	}


	public void setJisisyaID(String jisisyaID) {
		this.jisisyaID = jisisyaID;
	}


	public String getKaikeiDialog() {
		return kaikeiDialog;
	}

	
	public void setKaikeiDialog(String kaikeiDialog) {
		this.kaikeiDialog = kaikeiDialog;
	}

	
	//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
	public int getConnectRetryLimit() {
		return connectRetryLimit;
	}

	//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
	public void setConnectRetryLimit(int connectRetryLimit) {
		this.connectRetryLimit = connectRetryLimit;
	}


	//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
	public int getConnectRetryInterval() {
		return connectRetryInterval;
	}


	//DB接続処理見直し(2067025) 2017/03/06 S.Terakata(STI)
	public void setConnectRetryInterval(int connectRetryInterval) {
		this.connectRetryInterval = connectRetryInterval;
	}

}
