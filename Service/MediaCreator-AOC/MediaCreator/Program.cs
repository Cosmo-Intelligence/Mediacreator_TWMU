using System;
using System.ServiceProcess;

namespace MediaCreator
{
    static class Program
    {
        //Log4Net
        private static readonly log4net.ILog logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// 処理モード：GUI
        /// </summary>
        const string MODE_GUI = "gui";

        /// <summary>
        /// 処理モード：タスクスケジューラ
        /// </summary>
        const string MODE_TASK = "task";

        /// <summary>
        /// 処理モード：サービス
        /// </summary>
        const string MODE_SERVICE = "serv";

        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        static void Main()
        {
            string[] args = Environment.GetCommandLineArgs();
            // 処理モード取得
            string mode = GetMode(args);

            // 処理モード判定
            if (!string.IsNullOrEmpty(mode))
            {
                // debug用
                try
                {
                    // GUIモード
                    ProcessMain proc = new ProcessMain(mode);
                    proc.Start();

                    return;
                }
                catch (Exception ex)
                {
                    logger.Fatal(ex);
                    return;
                }
                finally
                {
                    logger.Info("アプリケーションを終了します。");
                }
            }

            // サービス起動
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[] 
            {
                new ServiceMain() 
            };
            ServiceBase.Run(ServicesToRun);
        }

        /// <summary>
        /// 処理モード取得
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        static string GetMode(string[] args)
        {
            if (args == null)
            {
                return string.Empty;
            }

            if (args.Length != 2)
            {
                return string.Empty;
            }

            return args[1].ToLower();
        }

    }
}
