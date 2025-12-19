using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading;

namespace MediaCreator {
    public partial class ServiceMain : ServiceBase {

        //Log4Net
        private static readonly log4net.ILog logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        ProcessMain proc = null;
        Thread th = null;
            
        public ServiceMain() {
            InitializeComponent();

            //ソースが存在していない時は、作成する
            if(!System.Diagnostics.EventLog.SourceExists(this.ServiceName)) {
                //ログ名を空白にすると、"Application"となる
                System.Diagnostics.EventLog.CreateEventSource(this.ServiceName, "");
            }

            //ログにプロセスIDを出すため
            log4net.GlobalContext.Properties["pid"] = System.Diagnostics.Process.GetCurrentProcess().Id;

            //例外処理
            Thread.GetDomain().UnhandledException += Application_UnhandledException;
        }

        protected override void OnStart(string[] args) {
            logger.Info("Service Start >>>>>");

            
            proc = new ProcessMain(this.ServiceName);

            th = new Thread(new ThreadStart(proc.Start));

            th.Start();

        }

        protected override void OnStop() {
            if(proc != null) {
                proc.Stop();
                th.Join();
            }
            logger.Info("Service Stop <<<<<");
        }

        public void Application_UnhandledException(object sender, UnhandledExceptionEventArgs e) {
            Exception ex = e.ExceptionObject as Exception;
            if(ex != null) {
                logger.Error("Error", ex);
                EventLog.WriteEntry(this.ServiceName, ex.Message, EventLogEntryType.Error);
                logger.Info("Service Stop On Error <<<<<");
                System.Environment.Exit(1);
            }
        }
    }
}
