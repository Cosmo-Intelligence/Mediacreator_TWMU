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
        public static readonly log4net.ILog logger =
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

            int interval = Properties.Settings.Default.Interval;
            logger.Info(String.Format("Interval={0}", interval));

            while (!isStop)
            {
                try
                {
                    //メディア作成依頼ファイル 作成・配置処理
                    var mCreatReq = new MediaCreatReq();
                    mCreatReq.mediaCreatReqMain();

                    //メディア作成完了通知 書き出し
                    var mCreatDone = new MediaCreatDoneNoticeSet();
                    mCreatDone.mediaCreatDoneNoticeSetMain();
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
