using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using MediaCreator.Common;
using System.Threading;

using Oracle.DataAccess.Client;

//*******************************************************************************
// システム名称　　：MediaCreator
// プロセス名称　　：メディア作成完了通知処理　メイン
// 作成者          ：Y.Kitaoka
// 作成日付　　　　：2013/11/15
// 更新日付　　　　：
//                 ：
// 補　足　説　明　：
//                 ：
//*******************************************************************************
namespace MediaCreator
{
    public class MediaCreatDoneNoticeSet
    {

        private static readonly log4net.ILog logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        // Propertiesより情報取得
        string ResultDataInput = Properties.Settings.Default.ResultDataFolder;
        //string ResultIndexInput = Properties.Settings.Default.ResultIndexFolder;
        string ResultLogOutput = Properties.Settings.Default.ResultLogFolder;
        string OrderDataInput = Properties.Settings.Default.OrderDataFolder;

        public const String EXTENSION_STATUS = "status";
        public const String EXTENSION_ERROR = "error";


 
        //*****************************************************************************
        //関数名称：mediaCreatDoneNoticeSetMain
        //機能概略：メディア作成完了通知ファイル　メイン処理
        //引数　　：-
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        public void mediaCreatDoneNoticeSetMain(String extension)
        {

            //出力先チェック
            DirectoryInfo dir = new DirectoryInfo(Properties.Settings.Default.ResultDataFolder);
            if (!dir.Exists) {
                Common.Common.connectNetworkDirectory(dir, Properties.Settings.Default.NetworkUser, Properties.Settings.Default.NetworkPass);
            }



            // 拡張子が*.datのファイル名を取得する
            //MCHT-04J-T33対応(AOC対応) 2014/09/22 S.Terakata(STI)
            //string[] strFiles = Directory.GetFiles(ResultDataInput, "*.dat");
            String[] strFiles = new String[0];

            if (extension == EXTENSION_STATUS) {
                //statusファイル監視
                strFiles = Directory.GetFiles(ResultDataInput, "*." + extension);
            }
            else {
                //errorファイル監視
                strFiles = Directory.GetFiles(OrderDataInput, "*." + extension);
            }

            FileControler file = null;

            // メディア作成完了通知ファイルが存在していない場合は処理しない
            if (strFiles.Length != 0)
            {
                try{
                    
                    //結果ファイル取得
                    file = FileControler.loadFromFile(strFiles[0], FileControler.FileClass.Responce);

                    if (extension == EXTENSION_STATUS) {
                        logger.Debug(extension + " file = " + strFiles[0] 
                                + ", IsFinished = " + file.getValue("CDJobInfo", "IsFinished")
                                + ", StateFlag = " + file.getValue("CDJobInfo", "StateFlag")
                                );
                    }
                    else {
                        logger.Debug(extension + " file = " + strFiles[0]);
                    }
                    
                    //BackUp先の指定があるときはコピー
                    String bkup = Properties.Settings.Default.ResultDataBackupFolder;
                    if (bkup != null && bkup != "") {
                        if (Directory.Exists(bkup)) {
                            String bkupfilename = Path.GetFullPath(bkup) + "\\" + Path.GetFileName(file.getFilename());
                            File.Copy(file.getReadingFilename(), bkupfilename, true);
                        }
                    }


                    Boolean isSuccess = false;

                    String stateflg = "";
                    if (extension == EXTENSION_STATUS) {
                        if (file.getValue("CDJobInfo", "IsFinished") != "1") {
                            //未完了
                            return;
                        }

                        stateflg = file.getValue("CDJobInfo", "StateFlag");
                        if (stateflg == "4") {
                            //成功
                            isSuccess = true;
                        }
                    }

                    using (OracleConnection conn = DataBase.getConnection()) {

                        String orderno = Path.GetFileNameWithoutExtension(strFiles[0]);

                        if (extension == EXTENSION_ERROR) {
                            //エラーファイルは.request.errorなのでもう一度拡張子を除く。
                            orderno = Path.GetFileNameWithoutExtension(orderno);
                        }

                        String diskid = "1";
                        String readfile = file.AllString;

                        //結果書き込み
                        DataTable requestDat = DataBase.getToCodonicsInfoByOrderNo(orderno, conn);

                        if (requestDat.Rows.Count > 0) {

                            DataRow requestRow = requestDat.Rows[0];

                            if (!isSuccess) {
                                requestRow["TRANSFERSTATUS"] = "02";

                                DataBase.updateTable("TOCODONICSINFO", new String[] { "REQUESTID" }, requestRow, conn);
                            }



                            //情報をDB(CODONICSMEDIACOMPLETETABLE)にインサート
                            DataRow completeRow = DataBase.getEmptyTableRow("CODONICSMEDIACOMPLETETABLE", conn);
                            completeRow["ORDERNO"] = orderno;
                            completeRow["DISKID"] = diskid;
                            completeRow["README"] = readfile;

                            DataBase.updateTable("CODONICSMEDIACOMPLETETABLE", new String[] { "ORDERNO" }, completeRow, conn);

                            //サーバーの日付を取得し、Logファイル 作成

                            String filehead = "result_";
                            if (extension == EXTENSION_ERROR) {
                                filehead = "error_";
                            }

                            if (!isSuccess) {
                                filehead = "error_";
                            }

                            if (isSuccess) {
                                Common.Common.streamWriter(ResultLogOutput + "\\" + filehead +
                                   Common.Common.getTimeString().Replace("/", "").Substring(0, 8) + ".log",
                                   Common.Common.getTimeString() + " >> " +
                                   Path.GetFileName(strFiles[0]) + " normal end" + "\r\n", 1);
                            }
                            else {
                                if (extension == EXTENSION_STATUS) {
                                    Common.Common.streamWriter(ResultLogOutput + "\\" + "result_" +
                                       Common.Common.getTimeString().Replace("/", "").Substring(0, 8) + ".log",
                                       Common.Common.getTimeString() + " >> " +
                                       Path.GetFileName(strFiles[0]) + " Status Error (StateFlag = " + stateflg + ")" + "\r\n", 1);

                                    Common.Common.streamWriter(ResultLogOutput + "\\" + filehead +
                                       Common.Common.getTimeString().Replace("/", "").Substring(0, 8) + ".log",
                                       Common.Common.getTimeString() + " >> " +
                                       Path.GetFileName(strFiles[0]) + " Status Error (StateFlag = " + stateflg + ")" + "\r\n", 1);
                                
                                }
                                else {
                                    Common.Common.streamWriter(ResultLogOutput + "\\" + filehead +
                                       Common.Common.getTimeString().Replace("/", "").Substring(0, 8) + ".log",
                                       Common.Common.getTimeString() + " >> " +
                                       Path.GetFileName(strFiles[0]) + " Request Error" + "\r\n", 1);
                                }
                            }
                        }
                        else {
                            //MCHT_40-J-T33 BackLog No4 存在しないオーダー

                            Common.Common.streamWriter(ResultLogOutput + "\\" + "error_" +
                               Common.Common.getTimeString().Replace("/", "").Substring(0, 8) + ".log",
                               Common.Common.getTimeString() + " >> " +
                               Path.GetFileName(strFiles[0]) + " Order is Not Exist" + "\r\n", 1);

                            logger.Debug(orderno + " is Not Exist");
                        }


                    }


                }
                catch (Exception ex)
                {
                    logger.Error("mediaCreatDoneNoticeSetMain Error ", ex);
                }
                finally{
                    //読んだファイルを消す。
                    try{
                        if(file != null){
                            file.deleteFile();
                        }
                    }
                    catch(Exception ex){
                        logger.Error("mediaCreatDoneNoticeSetMain Error ", ex);
                    }
                }
                
            }
        }
    }
}
