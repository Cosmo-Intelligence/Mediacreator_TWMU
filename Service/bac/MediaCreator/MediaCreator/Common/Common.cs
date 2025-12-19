using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;

//*******************************************************************************
// システム名称　　：MediaCreator
// プロセス名称　　：共通処理
// 作成者          ：Y.Kitaoka
// 作成日付　　　　：2013/11/14
// 更新日付　　　　：
//                 ：
// 補　足　説　明　：
//                 ：
//*******************************************************************************
namespace MediaCreator.Common
{
    public class Common
    {

        /************/
        /* 定数定義 */
        /************/
        const int ROW0 = 0;
        const int COL0 = 0;

        const int CREATREQ = 0;

        const int CREATEERR = 0;
        const int WRITERR = 1;

        // Propertiesより情報取得
        private static string OrderDataOutput = Properties.Settings.Default.OrderDataFolder;
        private static string OrderIndexOutput = Properties.Settings.Default.OrderIndexFolder;
        private static string OrderLogOutput = Properties.Settings.Default.OrderLogFolder;

        private static string ResultLogOutput = Properties.Settings.Default.ResultLogFolder;

        //サーバーの日付を取得する
        public static string serverTimeGet
        {
            get
            {
                var dt = new DataTable();
                DataBase.sqlDataGet(DataBase.sysDateGet, dt);

                //No23 作成時刻のフォーマット
                //return dt.Rows[ROW0][COL0].ToString();
                return ((DateTime)dt.Rows[ROW0][COL0]).ToString("yyyy/MM/dd HH:mm:ss");
            }
        }

        //*****************************************************************************
        //関数名称：fileWriteCreateErrLogWrite
        //機能概略：書き込み中エラー、書込みファイルの作成失敗
        //引数　　：I:string filestr  保存先フォルダ/ファイル名
        //　　　　：I:string writdata 書込み内容
        //　　　　：I:int mode        0:MediaCreatReq 1:MediaCreatDoneNoticeSet
        //　　　　：I:int type        0:ファイル作成エラー 1:ファイル書き込み中エラー
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/19
        //*****************************************************************************
        private static void fileWriteCreateErrLogWrite(string filestr, string writdata, 
                                                       int mode, int type)
        {

            // ファイル名抽出
            string getFileName = filestr.Replace(OrderDataOutput + "\\", "");

            // フォルダ名抽出
            string getFolderName = filestr.Replace(getFileName, "");

            //.idxファイル時の対応
            if (0 <= filestr.IndexOf("INDEX"))
            {
                // ファイル名抽出
                getFileName = filestr.Replace(OrderIndexOutput + "\\", "");

                // フォルダ名抽出
                getFolderName = filestr.Replace(getFileName, "");
            }

            // .tmp 拡張子削除
            getFileName = getFileName.Replace(".tmp", "");

            //Pathを設定
            string path;
            if (mode == CREATREQ)
            {
                path = OrderLogOutput + "\\" + "order_" +
                serverTimeGet.Replace("/", "").Substring(0, 8) + ".log";
            }
            else
            {
                path = ResultLogOutput + "\\" + "result_" +
                serverTimeGet.Replace("/", "").Substring(0, 8) + ".log";
            }

            //ログ記載内容
            string logReadme;

            if (type == CREATEERR) 
            {
                logReadme = getFileName + " の作成に失敗しました。 " +
                getFolderName + " への書き込み権限を確認してください。" + "\r\n";
            }
            else 
            {
                logReadme = getFileName + " の書き込み中にエラーが発生しました。" + "\r\n" +
                writdata + "\r\n";
            }

            //拡張子が.datでは無い場合は、.idxに変換
            string errFileName = getFileName;
            if (0 <= errFileName.IndexOf(".dat"))
            {
                errFileName = errFileName.Replace(".dat", ".idx");
            }

            //TOCODONICSINFO.TRANSFERSTATUSを 02:メディア作成依頼ファイル作成異常 と 処理日時を設定
            DataBase.sqlDataSet(DataBase.tocodonicsinfoTableNgSet(errFileName));

            try
            {
                //ファイルが無い場合は作成し、同名のファイルがある場合は追記する
                using (var sw = new System.IO.StreamWriter(path,
                                           true, System.Text.Encoding.Default))
                {
                    sw.Write(Common.serverTimeGet + " >> " + logReadme + Environment.StackTrace + "\r\n");
                }
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("fileCreateErrLogWrite Error " +
                                         " filestr=" + filestr, ex);
            }
        }

        //*****************************************************************************
        //関数名称：streamWriter
        //機能概略：ファイル作成処理
        //引数　　：I:string filestr  保存先フォルダ/ファイル名
        //　　　　：I:string writData 保存内容
        //　　　　：I:int mode        0:MediaCreatReq 1:MediaCreatDoneNoticeSet
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        public static void streamWriter(string filestr, string writdata, int mode)
        {
            try
            {
                //ファイルが無い場合は作成し、同名のファイルがある場合は追記する
                using (var sw = new System.IO.StreamWriter(filestr,
                          true, System.Text.Encoding.Default))
                {
                    try
                    {
                        sw.Write(writdata);
                    }
                    catch (Exception ex)
                    {
                        ProcessMain.logger.Fatal("streamWriter Error", ex);

                        //書き込み中エラー
                        fileWriteCreateErrLogWrite(filestr, writdata, 
                                                   mode, WRITERR);
                    }
                }
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("streamWriter Error", ex);

                //書込みファイルの作成失敗
                fileWriteCreateErrLogWrite(filestr, writdata, 
                                           mode, CREATEERR);
            }
        }
    }
}