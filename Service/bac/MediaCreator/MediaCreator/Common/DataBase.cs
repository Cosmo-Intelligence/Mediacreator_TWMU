using System;
using System.Collections.Generic;
using System.Web;
using System.Configuration;
using System.Data;
using System.Collections;
using Oracle.DataAccess.Client;

//*******************************************************************************
// システム名称　　：MediaCreator
// プロセス名称　　：データベース関連処理
// 作成者          ：Y.Kitaoka
// 作成日付　　　　：2013/11/14
// 更新日付　　　　：
//                 ：
// 補　足　説　明　：
//                 ：
//*******************************************************************************
namespace MediaCreator.Common
{
    public class DataBase
    {

        //PropertiesよりOracle接続文字列を設定
        private static string connectionString = Properties.Settings.Default.ConnectionString;

       //サーバー時間を取得する
        public static string sysDateGet
        {
            get
            {
                return "SELECT SYSDATE FROM DUAL";
            }
        }
        
#region "MediaCreatReq SQL"

        //TRANSFERSTATUS の送信チェックを行い、必要な情報を取得する
        public static string elementTableGet
        {
            get
            {
                return "SELECT REQUESTID , TOCODONICSINFO.RIS_ID , " +
                       "INDEXFILENAME , KANJA_ID , KENSAKIKI , MEDIA_FLG " +
                       "FROM TOCODONICSINFO INNER JOIN CODONICSMEDIAORDERTABLE " +
                       "ON CODONICSMEDIAORDERTABLE.RIS_ID = TOCODONICSINFO.RIS_ID " +
                       "WHERE REQUESTTYPE = '00' AND TRANSFERSTATUS = '00'";
            }
        }

        //RIS_IDよりTOCODONICSINFO.REQUESTDATE 情報取得
        public static string codonicsinfoTableReqDateGet(string requestid)
        {
            return "SELECT TO_CHAR(REQUESTDATE,'YYYY/MM/DD HH24:MI:SS') " +
                     "FROM TOCODONICSINFO WHERE REQUESTID = '" + requestid + "'";
        }

        //RIS_IDよりCODONICSMEDIAORDERSTUDYTABLE.ACCESSIONNO,KENSA_DATE,MODALITY_TYPE 情報取得
        public static string codonicsmediaorderstudyTableGet(string ris_id)
        {
            return "SELECT ACCESSIONNO , TO_CHAR(KENSA_DATE,'YYYY/MM/DD HH24:MI:SS') , MODALITY_TYPE, STUDYINSTANCEUID " +
                     "FROM CODONICSMEDIAORDERSTUDYTABLE " +
                     "WHERE RIS_ID = '" + ris_id + "'";
        }

        //TOCODONICSINFO.TRANSFERSTATUSを 01:送信済み と 処理日時を設定
        public static string tocodonicsinfoTableSet(string requestid)
        {
            return "UPDATE TOCODONICSINFO SET TRANSFERSTATUS = '01' , " +
                   "TRANSFERDATE = (SELECT SYSDATE FROM DUAL) " +
                   "WHERE REQUESTID = " + requestid + " AND TRANSFERSTATUS <> '02'";
        }

        //TOCODONICSINFO.TRANSFERSTATUSを 02:メディア作成依頼ファイル作成異常 と 処理日時を設定
        public static string tocodonicsinfoTableNgSet(string indexfilename)
        {
            return "UPDATE TOCODONICSINFO SET TRANSFERSTATUS = '02' , " +
                   "TRANSFERDATE = (SELECT SYSDATE FROM DUAL) " +
                   "WHERE INDEXFILENAME = '" + indexfilename + "'";
        }

        /* 2013/12/06 仕様変更 */
        //ToHisInfoテーブルに設定
        public static string mcdTohisinfoTableSet(MediaCreatReq.mediaCreatDoneNotisSet mdSet)
        {
            return "INSERT INTO TOHISINFO(REQUESTID , REQUESTDATE , RIS_ID , REQUESTUSER , REQUESTTERMINALID , " +
                                         "REQUESTTYPE , MESSAGEID1 , MESSAGEID2 , TRANSFERSTATUS) " +
                          "VALUES(" + mdSet.requestid + ", TO_DATE( '" + mdSet.requestdate + "','YYYY/MM/DD HH24:MI:SS')" + ",'" +
                                  mdSet.ris_id + "','" + mdSet.requestuser + "','" + mdSet.requestterminallid + "','" +
                                  mdSet.requesttype + "','" + mdSet.orderno + "','" + mdSet.kanja_id + "','" +
                                  mdSet.transferstatus + "') ";
        }
        /* 2013/12/06 仕様変更 */

#endregion


#region "MediaCreatDoneNoticeSet SQL"

        //CODONICSMEDIACOMPLETETABLE に各種情報を挿入
        public static string codonicsmediacompleteTableSet(string orderno, string diskid, string readfile)
        {
            return "INSERT INTO CODONICSMEDIACOMPLETETABLE " +
                 "VALUES ('" + orderno + "','" + diskid + "','" + readfile + "')";
        }

        //HIS送信リクエストテーブルに情報をセット
        public static string mcdCodonicsmediaorderTableGet(string orderno)
        {
            return "SELECT KANJA_ID , TO_CHAR(REQUESTDATE,'YYYY/MM/DD HH24:MI:SS') , RIS_ID " +
                         "FROM CODONICSMEDIAORDERTABLE " +
                         "WHERE ORDERNO = '" + orderno + "'";
        }

        //EXTENDORDERINFO.RIS_HAKKO_USER,RIS_HAKKO_TERMINAL を取得
        public static string extendOrderInfoleTableGet(string ris_id)
        {
            return "SELECT RIS_HAKKO_USER , RIS_HAKKO_TERMINAL FROM EXTENDORDERINFO WHERE RIS_ID = " + ris_id;
        }

        //FROMRISSEQUENCE.NEXTVALにて、設定するREQUESTIDの採番
        public static string nextvalGet
        {
            get
            {
                return "SELECT FROMRISSEQUENCE.NEXTVAL FROM DUAL";
            }
        }

        //exmaintable.statusを取得
        public static string exmaintableTableStatusGet(string ris_id)
        {
            return "SELECT STATUS FROM EXMAINTABLE WHERE RIS_ID = " + ris_id;
        }

        //exmaintable.statusに"90"を設定
        public static string exmaintableTableSet(string ris_id)
        {
            return "UPDATE EXMAINTABLE SET STATUS = 90 WHERE RIS_ID = " + ris_id;
        }

#endregion

        //*****************************************************************************
        //関数名称：sqlDataGet
        //機能概略：SQL(SELECT)の結果をDataSetに格納する
        //引数　　：I:string spl,SQLコマンド(SELECT)
        //返り値　：R:DataSet Ds,DataSet
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        public static void sqlDataGet(string sql, DataTable Dt)
        {

            try
            {
                using (var con = new OracleConnection(connectionString))
                {
                    con.Open();

                    var OraCmd = new OracleCommand(sql, con);
                    var Da = new OracleDataAdapter(OraCmd);

                    // DataTableに結果設定
                    Da.Fill(Dt);
                }
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("sqlDataGet Error" + "sql=" + sql, ex);
            }

        }

        //*****************************************************************************
        //関数名称：sqlDataSet
        //機能概略：SQLコマンドを発行
        //引数　　：I:string spl,SQLコマンド
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        public static void sqlDataSet(string sql)
        {
            try
            {
                using (var con = new OracleConnection(connectionString))
                {
                    con.Open();
                    var OraCmd = new OracleCommand(sql, con);
                    OraCmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("sqlDataSet Error" + "sql=" + sql, ex);
            }
        }
    }
}
