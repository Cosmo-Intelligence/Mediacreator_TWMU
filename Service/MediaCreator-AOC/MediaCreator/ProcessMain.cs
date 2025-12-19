using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading;
using System.Data;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;

using Oracle.DataAccess.Client;
using MediaCreator.Common;

//*******************************************************************************
// システム名称　　：MediaCreator
// プロセス名称　　：メイン
// 作成者          ：Y.Kitaoka
// 作成日付　　　　：2013/11/13
// 更新日付　　　　：
//                 ：
// 補　足　説　明　：
//                 ：
//*******************************************************************************
namespace MediaCreator
{
    class ProcessMain
    {

        //Log4Net
        private static readonly log4net.ILog logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);


 

        private Boolean isStop = false;
        private String ServiceName = "";

        public ProcessMain(String serviceName)
        {
            this.ServiceName = serviceName;
        }

        //開始
        public void Start()
        {

            isStop = false;
            logger.Info("Process Start");

            Main();

            logger.Info("Process End");
        }

        //停止
        public void Stop()
        {
            logger.Info("Stopping...");
            isStop = true;
        }

        //*****************************************************************************
        //関数名称：Main
        //機能概略：メイン処理
        //引数　　：
        //返り値　：
        //作成者　：
        //作成日時：　
        //*****************************************************************************
        private void Main()
        {


            String targetPath = Properties.Settings.Default.OrderDataFolder;
            String user = Properties.Settings.Default.NetworkUser;
            String pass = Properties.Settings.Default.NetworkPass;

            logger.Debug(String.Format("NetworkDirectory={0}", targetPath));
            logger.Debug(String.Format("NetworkUser={0}", user));

            DirectoryInfo outputDirectory = new DirectoryInfo(targetPath);

            //出力先チェック
            if (!Common.Common.connectNetworkDirectory(outputDirectory, user, pass)) {
                //ここではエラーは無視する。
                //定周期時にもチェックしてるので問題ない。
                //throw new Exception( "Failed to Connect to OutputDirectory");
            }

            int interval = Properties.Settings.Default.Interval;
            logger.Info(String.Format("Interval={0}", interval));



            while (!isStop)
            {
                try
                {

                    //logger.Debug("mediaCreatReqMain");
                    //メディア作成依頼ファイル 作成・配置処理
                    MediaCreatReq mCreatReq = new MediaCreatReq();
                    mCreatReq.mediaCreatReqMain();

                    //logger.Debug("mediaCreatDoneNoticeSetMain Status");
                    //メディア作成完了通知 監視
                    MediaCreatDoneNoticeSet mCreatDoneStatus = new MediaCreatDoneNoticeSet();
                    mCreatDoneStatus.mediaCreatDoneNoticeSetMain(MediaCreatDoneNoticeSet.EXTENSION_STATUS);

                    //logger.Debug("mediaCreatDoneNoticeSetMain Error");
                    //エラーファイル 監視
                    MediaCreatDoneNoticeSet mCreatDoneError = new MediaCreatDoneNoticeSet();
                    mCreatDoneError.mediaCreatDoneNoticeSetMain(MediaCreatDoneNoticeSet.EXTENSION_ERROR);
                
                }
                catch (Exception ex)
                {
                    logger.Fatal("Main Error ", ex);
                }
                //ポーリングのインターバル設定
                Thread.Sleep(interval);
            }
        }

    }
}
