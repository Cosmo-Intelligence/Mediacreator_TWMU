using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;


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

        private static readonly log4net.ILog logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);


        //接続切断するWin32 API を宣言
        [DllImport("mpr.dll", EntryPoint = "WNetCancelConnection2", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
        private static extern int WNetCancelConnection2(string lpName, Int32 dwFlags, bool fForce);

        //認証情報を使って接続するWin32 API宣言
        [DllImport("mpr.dll", EntryPoint = "WNetAddConnection2", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
        private static extern int WNetAddConnection2(ref NETRESOURCE lpNetResource, string lpPassword, string lpUsername, Int32 dwFlags);
        //WNetAddConnection2に渡す接続の詳細情報の構造体
        [StructLayout(LayoutKind.Sequential)]
        internal struct NETRESOURCE {
            public int dwScope;//列挙の範囲
            public int dwType;//リソースタイプ
            public int dwDisplayType;//表示オブジェクト
            public int dwUsage;//リソースの使用方法
            [MarshalAs(UnmanagedType.LPWStr)]
            public string lpLocalName;//ローカルデバイス名。使わないならNULL。
            [MarshalAs(UnmanagedType.LPWStr)]
            public string lpRemoteName;//リモートネットワーク名。使わないならNULL
            [MarshalAs(UnmanagedType.LPWStr)]
            public string lpComment;//ネットワーク内の提供者に提供された文字列
            [MarshalAs(UnmanagedType.LPWStr)]
            public string lpProvider;//リソースを所有しているプロバイダ名
        }


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
        //private static string OrderIndexOutput = Properties.Settings.Default.OrderIndexFolder;
        private static string OrderLogOutput = Properties.Settings.Default.OrderLogFolder;

        private static string ResultLogOutput = Properties.Settings.Default.ResultLogFolder;


        public static String getTimeString() {
            return DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss");
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
        private static void fileWriteCreateErrLogWrite(String filestr, String writdata, 
                                                       int mode, int type)
        {

            // ファイル名抽出
            string getFileName = filestr.Replace(OrderDataOutput + "\\", "");

            // フォルダ名抽出
            string getFolderName = filestr.Replace(getFileName, "");

            
            //Pathを設定
            string path;
            if (mode == CREATREQ)
            {
                path = OrderLogOutput + "\\" + "order_" +
                getTimeString().Replace("/", "").Substring(0, 8) + ".log";
            }
            else
            {
                path = ResultLogOutput + "\\" + "result_" +
                getTimeString().Replace("/", "").Substring(0, 8) + ".log";
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
            //DataBase.sqlDataSet(DataBase.tocodonicsinfoTableNgSet(errFileName));

            try
            {
                //ファイルが無い場合は作成し、同名のファイルがある場合は追記する
                using (var sw = new System.IO.StreamWriter(path,
                                           true, System.Text.Encoding.Default))
                {
                    sw.Write(Common.getTimeString() + " >> " + logReadme + Environment.StackTrace + "\r\n");
                }
            }
            catch (Exception ex)
            {
                logger.Fatal("fileCreateErrLogWrite Error " +
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
                        logger.Fatal("streamWriter Error", ex);

                        //書き込み中エラー
                        fileWriteCreateErrLogWrite(filestr, writdata, 
                                                   mode, WRITERR);
                    }
                }
            }
            catch (Exception ex)
            {
                logger.Fatal("streamWriter Error", ex);

                //書込みファイルの作成失敗
                fileWriteCreateErrLogWrite(filestr, writdata, 
                                           mode, CREATEERR);
            }
        }

        public static Boolean connectNetworkDirectory(DirectoryInfo outputDirectory, String user, String pass) {
            logger.Debug("Connect NetworkDirectory");


            logger.Debug(String.Format("NetworkUser={0}", user));


            if (!outputDirectory.FullName.StartsWith("\\\\")) {
                logger.Debug(String.Format("LocalDirectory Exists={0}", outputDirectory.Exists));
                return outputDirectory.Exists;
            }

            //DirectoryInfo dir = new DirectoryInfo(targetPath);
            //Boolean exists = dir.Exists;
            //logger.Debug(String.Format("Exists={0}",exists));

            Boolean exists = false;


            if (!exists) {

                // 接続情報を設定  
                NETRESOURCE netResource = new NETRESOURCE();
                netResource.dwScope = 0;
                netResource.dwType = 1;
                netResource.dwDisplayType = 0;
                netResource.dwUsage = 0;
                netResource.lpLocalName = ""; // ネットワークドライブにする場合は"z:"などドライブレター設定  
                netResource.lpRemoteName = outputDirectory.FullName;
                netResource.lpProvider = "";

                string password = pass;
                string userId = user;

                int ret = 0;
                try {
                    //既に接続してる場合があるので一旦切断する
                    //ret = WNetCancelConnection2(path, 0, true);
                    //共有フォルダに認証情報を使って接続
                    logger.Debug(String.Format("Connect To {0}", outputDirectory.FullName));
                    ret = WNetAddConnection2(ref netResource, password, userId, 0);

                    if (ret != 0) {
                        logger.Error(String.Format("NetworkDirectory Connect Error (ret={0})", ret));
                        return false;
                    }
                }
                catch (Exception ex) {
                    //エラー処理
                    logger.Error("OutputDirectory Error", ex);
                    return false;
                }

            }

            return true;
        }
    }
}