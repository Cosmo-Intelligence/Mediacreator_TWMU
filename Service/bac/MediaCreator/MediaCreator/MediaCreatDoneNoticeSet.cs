using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using MediaCreator.Common;
using System.Threading;

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

        /************/
        /* 定数定義 */
        /************/
        const int NOTHING = 0;
        const int ZERO_ORIGIN = 0;

        const int ZERO_ORI = 1;
        const int ROW0 = 0;
        const int COL0 = 0;
        const int COL1 = 1;
        const int COL2 = 2;
        const int COL3 = 3;
        const int DISK_PUBLISHER_ID_BYTE = 16;
        const int PATIENT_ID_BYTE = 10;
        const int INSPECTION_COUNT_BYTE = 3;
        const int ACCESSION_NO_BYTE = 16;
        const int MODALITY_INFO_BYTE = 3;
        const int UNSENT = 0;

        // Propertiesより情報取得
        string ResultDataInput = Properties.Settings.Default.ResultDataFolder;
        string ResultIndexInput = Properties.Settings.Default.ResultIndexFolder;
        string ResultLogOutput = Properties.Settings.Default.ResultLogFolder;

        //*****************************************************************************
        //関数名称：stReaderErr
        //機能概略：メディア作成完了通知ファイル内容読込 エラー処理
        //　　　　: ファイルの読込は.datしか行わないため、.idxは考慮しない。
        //引数　　：R:string fpath_name ファイルパス名
        //返り値　：-
        //作成者　：Y.Kitaoka
        //作成日時：2013/11/19
        //*****************************************************************************
        private void stReaderErr(string fpath_name)
        {
            try
            {
                string ngPath;

                //ファイル名抽出
                string stTarget = fpath_name.Replace(ResultDataInput + "\\", "");

                //サーバーの日付を取得し、ログファイルのパスを作成する
                string path = ResultLogOutput + "\\result_" +
                              Common.Common.serverTimeGet.Replace("/", "").Substring(0, 8) + ".log";
                //エラーメッセージの作成
                string errMess = stTarget + "の読み込みに失敗しました。ファイルの読み込み権限を確認してください。" + "\r\n";

                //ログを出力する
                Common.Common.streamWriter(path, Common.Common.serverTimeGet + " >> " + errMess, 1);

                //メディア作成完了通知ファイル(DATA)を"ERR_DATA"に移動
                ngPath = ResultDataInput + "\\ERR_DATA" + fpath_name.Replace(ResultDataInput, "");

                // ファイルを移動する
                System.IO.File.Move(fpath_name, ngPath);
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("stReaderErr Error " +
                                         " fpath_name=" + fpath_name, ex);
            }
        }

        //*****************************************************************************
        //関数名称：stReader
        //機能概略：メディア作成完了通知ファイル内容 読込
        //引数　　：I:string fpath_name ファイルパス名
        //　　　　：R:string orderno    Orderno
        //　　　　：R:string diskid     DiskID
        //　　　　：R:string readmefile Readme
        //返り値　：R:true 正常終了、false 異常終了
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/14
        //*****************************************************************************
        private Boolean stReader(string fpath_name, ref string orderno,
                              ref string diskid, ref string readmefile)
        {
            try
            {
                //ファイル名からOrderNo(オーダ番号 AccessionNo)を取得
                string stTarget = fpath_name.Replace(ResultDataInput + "\\", "")
                                     .Replace("result_", "").Replace(".dat", "");

                //一文字づつ判定し、OrderNoを取出し
                int i = 0;
                foreach (int n in stTarget)
                {
                    if (Convert.ToString(stTarget[i]) != "_")
                    {
                        orderno += Convert.ToString(stTarget[i]);
                        i++;
                    }
                    else
                    {
                        //AccessionNo(OrderNo)取り込み完了 処理を抜ける
                        break;
                    }
                }

                // 読込んだ結果をすべて格納するための変数を宣言する
                readmefile = "";
                // メディア作成完了通知ファイル内容 読込
                using (var cReader = (new System.IO.StreamReader(fpath_name, System.Text.Encoding.Default)))
                {
                    // 読込みできる文字がなくなるまで繰り返す
                    while (cReader.Peek() >= NOTHING)
                    {
                        // ファイルを 1 行ずつ読込む
                        string stBuffer = cReader.ReadLine();

                        // "Disc ID:"を発見したら、整形し変数に保持
                        if ((stBuffer.Contains("Disc ID:")))
                        {
                            diskid = stBuffer.Replace("Disc ID:", "").Replace(" ", "");
                        }

                        // 読込んだものを追加で格納する
                        readmefile += stBuffer + System.Environment.NewLine;
                    }
                }

                //正常終了
                return true;
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("stReader Error " +
                                         " fpath_name=" + fpath_name +
                                         " orderno=" + orderno +
                                         " diskid=" + diskid +
                                         " readmefile=" + readmefile, ex);

                //ファイル読込エラー処理
                stReaderErr(fpath_name);

                //異常終了
                return false;
            }
        }

        //*****************************************************************************
        //関数名称：fileMoveErr
        //機能概略：ファイル移動エラー処理
        //引数　　：I:string moveFolder
        //　　　　：I:string Passfunc
        //　　　　：I:string stTarget
        //返り値　：
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/19
        //*****************************************************************************
        private void fileMoveErr(string moveFolder, string Passfunc, string stTarget)
        {
            try
            {
                //ファイルの移動エラー
                string errMess = moveFolder + "から" +
                                 moveFolder + Passfunc + "に" +
                                 stTarget + "を移動中にエラーが発生しました。" + "\r\n" +
                                 Environment.StackTrace + "\r\n";

                //サーバーの日付を取得し、エラーログ作成
                Common.Common.streamWriter(ResultLogOutput + "\\result_" +
                                           Common.Common.serverTimeGet.Replace("/", "").Substring(0, 8) + ".log",
                                           Common.Common.serverTimeGet + " >> " + errMess, 1);
            }

            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("fileMoveErr Error " +
                                         " moveFolder" + moveFolder +
                                         " Passfunc=" + Passfunc +
                                         " stTarget=" + stTarget, ex);
            }
        }


        //*****************************************************************************
        //関数名称：fileMove
        //機能概略：メディア作成完了通知ファイルのファイル移動処理
        //引数　　：I:string fpath_name
        //　　　　：I:string moveFolder
        //返り値　：R:true 正常終了、false 異常終了
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/14
        //*****************************************************************************
        private Boolean fileMove(string fpath_name, string moveFolder)
        {

            //Pass設定
            string Passfunc = "\\OK_DATA\\";
            if (moveFolder != ResultDataInput)
            {
                Passfunc = "\\OK_INDEX\\";
                fpath_name = fpath_name.Replace("\\DATA\\", "\\INDEX\\").Replace(".dat", ".idx");
            }

            try
            {
                //ファイル移動処理
                System.IO.File.Move(fpath_name, moveFolder +
                                    Passfunc + fpath_name.Replace(moveFolder + "\\", ""));
            }
            catch (Exception ex)
            {
                //ファイル移動エラー処理
                fileMoveErr(moveFolder, Passfunc, fpath_name.Replace(moveFolder + "\\", ""));
                //ログ採取
                ProcessMain.logger.Fatal("fileMove Error " +
                                         " fpath_name" + fpath_name +
                                         " moveFolder=" + moveFolder, ex);

                //異常終了
                return false;
            }

            //正常終了
            return true;
        }

        //*****************************************************************************
        //関数名称：mediaCreatDoneNoticeSetMain
        //機能概略：メディア作成完了通知ファイル　メイン処理
        //引数　　：-
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        public void mediaCreatDoneNoticeSetMain()
        {

            // 拡張子が*.datのファイル名を取得する
            string[] strFiles = Directory.GetFiles(ResultDataInput, "*.dat");

            // メディア作成完了通知ファイル(.dat)が存在していない場合は処理しない
            if (strFiles.Length != NOTHING)
            {
                try
                {
                    string orderno = null;
                    string diskid = null;
                    string readfile = null;
                    Boolean okng;

                    //OrderNo(オーダ番号 AccessionNo),DiskID(メディア書込みID),Readme(通信ファイル) を取得
                    okng = stReader(strFiles[ZERO_ORIGIN], ref orderno, ref diskid, ref readfile);

                    //メディア作成完了通知ファイル(DATA)を"OK_DATA"に移動 読み込み処理異常時には処理しない
                    if (okng) okng = fileMove(strFiles[ZERO_ORIGIN], ResultDataInput);

                    //.datファイル移動失敗時には処理しない
                    if (okng)
                    {
                        //メディア作成完了通知ファイル(INDEX)を"OK_INDEX"に移動
                        okng = fileMove(strFiles[ZERO_ORIGIN], ResultIndexInput);

                        //.idxファイル生成のタイムラグを考慮し、1000ms待ってから１度だけリトライ
                        if (!okng)
                        {
                            Thread.Sleep(1000);
                            //メディア作成完了通知ファイル(INDEX)を"OK_INDEX"に移動
                            okng = fileMove(strFiles[ZERO_ORIGIN], ResultIndexInput);
                        }

                        //.idxファイル 移動失敗時には 以降の処理はしない
                        if (okng)
                        {
                            //情報をDB(CODONICSMEDIACOMPLETETABLE)にインサート
                            DataBase.sqlDataSet(DataBase.codonicsmediacompleteTableSet(orderno, diskid, readfile));


                            /* 2013/12/06 仕様変更 */


                            //サーバーの日付を取得し、Logファイル 作成
                            Common.Common.streamWriter(ResultLogOutput + "\\" + "result_" +
                               Common.Common.serverTimeGet.Replace("/", "").Substring(0, 8) + ".log",
                               Common.Common.serverTimeGet + " >> " +
                               strFiles[ZERO_ORIGIN].Replace(ResultDataInput + "\\", "") +
                               " normal end" + "\r\n", 1);
                        }

                    }

                }
                catch (Exception ex)
                {
                    ProcessMain.logger.Error("mediaCreatDoneNoticeSetMain Error ", ex);
                }
            }
        }
    }
}
