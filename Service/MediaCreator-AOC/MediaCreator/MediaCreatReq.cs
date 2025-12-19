using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using MediaCreator.Common;
using System.IO;

using Oracle.DataAccess.Client;

//*******************************************************************************
// システム名称　　：MediaCreator
// プロセス名称　　：メディア作成依頼ファイル処理　メイン
// 作成者          ：Y.Kitaoka
// 作成日付　　　　：2013/11/13
// 更新日付　　　　：2013/11/22
//                 ：
// 補　足　説　明　：
//                 ：
//*******************************************************************************
namespace MediaCreator
{
    public class MediaCreatReq
    {


        private static readonly log4net.ILog logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);


        // Propertiesより情報取得
        String OrderDataOutput = Properties.Settings.Default.OrderDataFolder;
        String OrderLogOutput = Properties.Settings.Default.OrderLogFolder;

        //*****************************************************************************
        //関数名称：associationTableSet
        //機能概略：関係テーブル設定処理(TOHISINFO)
        //引数　　：I:string orderno
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/15
        //*****************************************************************************
        private void associationTableSet(DataRow requestRow, OracleConnection conn){

            String orderno = requestRow["ORDERNO"].ToString();
            String risid = requestRow["RIS_ID"].ToString();

            try{

                // HIS送信リクエストテーブル(CODONICSMEDIAORDERTABLE)に情報を選択 取得
                DataTable toHisDat = DataBase.getEmptyTable("TOHISINFO",conn);
                DataRow toHisRow = toHisDat.NewRow();

                /*
                mdSet.kanja_id = dt.Rows[0][0].ToString();
                mdSet.requestdate = dt.Rows[0][1].ToString();
                mdSet.ris_id = dt.Rows[0][2].ToString();

                mdSet.orderno = orderno;
                mdSet.requesttype = "OP01";
                mdSet.transferstatus = "00";
                */

                toHisRow["MESSAGEID2"] = requestRow["KANJA_ID"];
                toHisRow["REQUESTDATE"] = requestRow["REQUESTDATE"];
                toHisRow["RIS_ID"] = requestRow["RIS_ID"];
                toHisRow["MESSAGEID1"] = requestRow["ORDERNO"];

                toHisRow["REQUESTTYPE"] = "OP01";
                toHisRow["TRANSFERSTATUS"] = "00";
                

                //RIS_IDより EXTENDORDERINFO.RIS_HAKKO_USER,RIS_HAKKO_TERMINAL を取得
                DataTable extendDat = DataBase.getExtendOrderInfo(risid, conn);
                DataRow extendRow = extendDat.Rows[0];

                /*
                mdSet.requestuser = dt.Rows[0][0].ToString();
                mdSet.requestterminallid = dt.Rows[0][1].ToString();
                */

                toHisRow["REQUESTUSER"] = extendRow["RIS_HAKKO_USER"];
                toHisRow["REQUESTTERMINALID"] = extendRow["RIS_HAKKO_TERMINAL"];


                // RIS_IDより EXMAINTABLE のステータスが既に90の場合は
                // ToHisInfoテーブルに情報追加はしない
                DataTable exMainDat = DataBase.getExMainTable(risid,conn);
                DataRow exMainRow = exMainDat.Rows[0];

                //MCHT-04J-T33対応(未受けモード対応) 2014/09/22 S.Terakata(STI)
                String orderstatus = exMainRow["STATUS"].ToString();
                //if (dt.Rows[ROW0][COL0].ToString() != "90")
                if (orderstatus != "90")
                {
                    //FROMRISSEQUENCE.NEXTVALにて、設定するREQUESTIDの採番
                    String requestid = DataBase.getToHisInfoKey(conn);
                    /*
                    mdSet.requestid = dt.Rows[0][0].ToString();
                    */

                    toHisRow["REQUESTID"] = requestid;

                    //MCHT-04J-T33対応(未受けモード対応) 2014/09/22 S.Terakata(STI)
                    if (orderstatus != "0") {
                        // ToHisInfoテーブルに情報追加
                        DataBase.updateTable("TOHISINFO", new String[] { "REQUESTID" }, toHisRow, conn);

                        // EXMAINTABLE のステータス更新(exmaintable.statusに"90"を設定)
                        DataRow updateExMainRow = DataBase.getEmptyTableRow("EXMAINTABLE", new String[] { "RIS_ID", "STATUS" }, conn);
                        updateExMainRow["RIS_ID"] = exMainRow["RIS_ID"];
                        updateExMainRow["STATUS"] = "90";
                        DataBase.updateTable("EXMAINTABLE", new String[] { "RIS_ID" }, updateExMainRow, conn);

                    }
                }
            }
            catch (Exception ex)
            {
                logger.Fatal("associationTableSet Error " +
                                         " orderno=" + orderno, ex);
            }
        }

         //*****************************************************************************
        //関数名称：mediaCreatReqDatWrite
        //機能概略：メディア作成依頼ファイルを指定フォルダに作成
        //引数　　：I:string ris_id
        //引数　　：I:string file
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        private Boolean mediaCreatReqDatWrite(DataRow requestRow, DataTable studyDat, DataRow orderRow, DateTime sysdate, String filename){

            try{

                FileControler file = new FileControler(FileControler.FileClass.Request);

                String category = "";


                category = "SERVER0";
                file.setValue(category, "strHostName", Properties.Settings.Default.strHostName);
                file.setValue(category, "strAEtitle", Properties.Settings.Default.strAEtitle);
                file.setValue(category, "iPortNum", Properties.Settings.Default.iPortNum);


                category = "RETRIEVE";
                file.setValue(category, "Priority", "0");
                file.setValue(category, "iCount", String.Format("{0}",studyDat.Rows.Count - 1));

                for (int i = 0; i < studyDat.Rows.Count; i++) {
                    DataRow row = studyDat.Rows[i];
                
                    file.setValue(category, String.Format("strStudyInstanceUID_{0}",i), row["STUDYINSTANCEUID"].ToString());
                    file.setValue(category, String.Format("Server_{0}",i), "SERVER0");
                    file.setValue(category, String.Format("Source_{0}", i), "0");
                }

                category = "CLIENT";
                file.setValue(category, "strQueryAEtitle", Properties.Settings.Default.strQueryAEtitle);
                file.setValue(category, "strMoveAEtitle", Properties.Settings.Default.strMoveAEtitle);
                file.setValue(category, "iMovePortNum", Properties.Settings.Default.iMovePortNum);


                category = "Operation";
                file.setValue(category, "MakeMedia", "1");

                category = "Protocol";
                file.setValue(category, "ProtocolName", requestRow["ORDER_BUI_ID"].ToString());

                category = "MediaOrder";
                file.setValue(category, "LinkMode", "0");
                file.setValue(category, "OrderNo", requestRow["ORDERNO"].ToString());

                //TODO:
                file.setValue(category, "UserLoginName", orderRow["IRAI_DOCTOR_NO"].ToString());
                file.setValue(category, "UserFullName", orderRow["IRAI_DOCTOR_NAME"].ToString());
                file.setValue(category, "PatientID", orderRow["KANJA_ID"].ToString());
                file.setValue(category, "PatientName", orderRow["KANASIMEI"].ToString());
                file.setValue(category, "StudyDate", ((DateTime)requestRow["REQUESTDATE"]).ToString("yyyy/MM/dd"));   //YYYY/MM/DD

                file.setValue(category, "FreeText1", orderRow["KANASIMEI"].ToString());
                file.setValue(category, "FreeText2", orderRow["BIRTHDAY"].ToString());
                file.setValue(category, "FreeText3", orderRow["SEX_NAME"].ToString());
                file.setValue(category, "FreeText4", orderRow["KENSA_DATE_AGE"].ToString());
                file.setValue(category, "FreeText5", orderRow["SECTION_NAME"].ToString());
                file.setValue(category, "FreeText6", orderRow["IRAI_DOCTOR_NAME"].ToString());
                file.setValue(category, "FreeText7", orderRow["KANJA_ID"].ToString());
                file.setValue(category, "FreeText8", "");
                file.setValue(category, "FreeText9", "");
                file.setValue(category, "FreeText10", "");
                
                file.setValue(category, "Copies", "1");
                

                category = "Other";
                file.setValue(category, "iCount", "-1");

                
                file.saveToFile(filename);

                logger.Debug("request file = " + filename);

                
                // Logファイル 作成
                Common.Common.streamWriter(OrderLogOutput + "\\" + "order_" +
                                           Common.Common.getTimeString().Replace("/", "").Substring(0, 8) + ".log",
                                           Common.Common.getTimeString() + " >> " + filename + " normal end" + "\r\n", 0);

            }
            catch (Exception ex)
            {
                logger.Fatal("mediaCreatReqDatWrite Error " +
                                         " file=" + filename, ex);

                return false;
            }

            return true;
        }

        //*****************************************************************************
        //関数名称：mediaCreatReqMain
        //機能概略：メディア作成依頼ファイル処理 メイン
        //引数　　：-
        //返り値　：-
        //作成者　：Y.Kitaoka
        //作成日時：2013/11/13
        //*****************************************************************************
        public void mediaCreatReqMain()
        {

            try
            {

                //出力先チェック
                DirectoryInfo dir = new DirectoryInfo(Properties.Settings.Default.OrderDataFolder);
                if (!dir.Exists) {
                    Common.Common.connectNetworkDirectory(dir, Properties.Settings.Default.NetworkUser, Properties.Settings.Default.NetworkPass);
                }

                using (OracleConnection conn = DataBase.getConnection()) {

                    DateTime sysdate = DataBase.getSysdate(conn);

                    //REQUESTID,REQUESTDATE,RIS_ID 情報取得
                    DataTable requestDat = DataBase.getToCodonicsInfoList(conn);

                    //ToCodonicsInfo.TransferStatus 未送信'00' が無い場合は処理しない
                    if (requestDat.Rows.Count > 0) {

                        DataRow requestRow = requestDat.Rows[0];

                        String risid = requestRow["RIS_ID"].ToString();

                        logger.Debug("Request OrdeNo = " + requestRow["ORDERNO"].ToString());


                        //CODONICSMEDIAORDERSTUDYTABLE.ACCESSIONNO,KENSA_DATE,MODALITY_TYPE 情報をDataSetより取得
                        DataTable studyDat = DataBase.getCodonicsMediaOrderStudyTable(risid, conn);

                        //RISオーダー関連データ
                        DataTable orderDat = DataBase.getOrderMainTable(risid,conn);
                        DataRow orderRow = orderDat.Rows[0];

                        //メディア作成依頼ファイルを作成・配置
                        String filename = OrderDataOutput + "\\" + requestRow["ORDERNO"].ToString() + ".request";
                        Boolean ret = mediaCreatReqDatWrite(requestRow,studyDat,orderRow,sysdate,filename);

                        DataRow updateRequestRow = DataBase.getEmptyTableRow("TOCODONICSINFO", new String[] { "REQUESTID", "TRANSFERSTATUS", "TRANSFERDATE" }, conn);
                        updateRequestRow["REQUESTID"] = requestRow["REQUESTID"];
                        updateRequestRow["TRANSFERDATE"] = sysdate;
                        if (ret) {
                            //成功
                            updateRequestRow["TRANSFERSTATUS"] = "01";
                        }
                        else {
                            //失敗
                            updateRequestRow["TRANSFERSTATUS"] = "02";
                        }

                        DataBase.updateTable("TOCODONICSINFO", new String[] { "REQUESTID" }, updateRequestRow, conn);


                        /* 2013/12/06 仕様変更 */
                        // orderno抜き出す
                        String orderno = requestRow["ORDERNO"].ToString();


                        // 関係テーブル設定処理(TOHISINFO)
                        associationTableSet(requestRow,conn);
                        /* 2013/12/06 仕様変更 */

                    }
                }
            }
            catch (Exception ex)
            {
                logger.Fatal("mediaCreatReqMain Error ", ex);
            }
        }
    }
}
