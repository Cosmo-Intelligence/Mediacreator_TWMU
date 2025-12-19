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
    public class DataBase:DataBaseCore
    {

        //PropertiesよりOracle接続文字列を設定
        private static string connectionString = Properties.Settings.Default.ConnectionString;

        public static OracleConnection getConnection() {
            return getConnection(connectionString);
        }

        //TRANSFERSTATUS の送信チェックを行い、必要な情報を取得する
        public static DataTable getToCodonicsInfoList(OracleConnection conn){

            DataTable Dat = new DataTable();
            
            String sql = ""; 

            
            sql += "SELECT a.requestid , ";
            sql += "       b.* ";
            sql += "  FROM tocodonicsinfo a, ";
            sql += "       codonicsmediaordertable b ";
            sql += " WHERE a.ris_id = b.ris_id ";
            sql += "   AND a.requesttype = '00' "; 
            sql += "   AND a.transferstatus = '00' ";


            String where = "";


            sql += where;

            sql += " ORDER BY a.requestid ";

            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat;
        }

        //オーダーNoからToCodonicsInfoを取得
        public static DataTable getToCodonicsInfoByOrderNo(String orderno, OracleConnection conn) {

            DataTable Dat = new DataTable();

            String sql = "";


            sql += "SELECT a.* ";
            sql += "  FROM tocodonicsinfo a, ";
            sql += "       codonicsmediaordertable b ";
            sql += " WHERE a.ris_id = b.ris_id ";
            sql += "   AND b.orderno = :ORDERNO ";


            String where = "";


            sql += where;

            sql += " ORDER BY a.requestid ";

            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                cmd.Parameters.Add("ORDERNO", OracleDbType.Varchar2, orderno.Length).Value = orderno;



                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat;
        }

        
        //RIS_IDよりCODONICSMEDIAORDERSTUDYTABLE.ACCESSIONNO,KENSA_DATE,MODALITY_TYPE 情報取得
        public static DataTable getCodonicsMediaOrderStudyTable(String risid, OracleConnection conn){
            DataTable Dat = new DataTable();

            String sql = "";


            sql += "SELECT a.* ";
            sql += "  FROM codonicsmediaorderstudytable a ";
            

            String where = "";

            where += " WHERE ris_id = :RISID ";


            sql += where;

            sql += " ORDER BY a.no ";

            
            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                cmd.Parameters.Add("RISID", OracleDbType.Varchar2, risid.Length).Value = risid;

                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat;
        }

        //OrderMainTable
        public static DataTable getOrderMainTable(String risid, OracleConnection conn) {
            DataTable Dat = new DataTable();

            String sql = "";


            sql += "SELECT a.*, ";
            sql += "       b.kanjisimei, ";
            sql += "       b.kanasimei, ";
            sql += "       b.birthday, ";
            sql += "       b.sex, ";
            sql += "       CASE WHEN b.sex = 'M' THEN '男性' ";
            sql += "            WHEN b.sex = 'F' THEN '女性' ";
            sql += "            ELSE '不明' ";
            sql += "       END AS sex_name, ";
            sql += "       c.section_name ";
            sql += "  FROM ordermaintable a, ";
            sql += "       patientinfo b, ";
            sql += "       sectionmaster c";


            String where = "";

            where += " WHERE a.kanja_id = b.kanja_id(+)";
            where += "   AND a.irai_section_id = c.section_id(+)";
            where += "   AND a.ris_id = :RISID ";
            
            sql += where;

            
            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                cmd.Parameters.Add("RISID", OracleDbType.Varchar2, risid.Length).Value = risid;

                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat;
        }


        //ExtendOrderInfo
        public static DataTable getExtendOrderInfo(String risid, OracleConnection conn) {
            DataTable Dat = new DataTable();

            String sql = "";


            sql += "SELECT a.* ";
            sql += "  FROM extendorderinfo a ";


            String where = "";

            where += " WHERE ris_id = :RISID ";


            sql += where;

            

            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                cmd.Parameters.Add("RISID", OracleDbType.Varchar2, risid.Length).Value = risid;

                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat;
        }

        //ExMainTable
        public static DataTable getExMainTable(String risid, OracleConnection conn) {
            DataTable Dat = new DataTable();

            String sql = "";


            sql += "SELECT a.* ";
            sql += "  FROM exmaintable a ";


            String where = "";

            where += " WHERE ris_id = :RISID ";


            sql += where;

            
            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                cmd.Parameters.Add("RISID", OracleDbType.Varchar2, risid.Length).Value = risid;

                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat;
        }

        //ToHisInfoに登録するRequestId
        public static String getToHisInfoKey(OracleConnection conn) {
            DataTable Dat = new DataTable();

            String sql = "";


            sql += "SELECT FROMRISSEQUENCE.NEXTVAL FROM DUAL ";


            String where = "";

            sql += where;


            using (OracleCommand cmd = new OracleCommand(sql, conn)) {
                cmd.BindByName = true;

                
                using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                    oda.Fill(Dat);
                }

            }

            return Dat.Rows[0][0].ToString();

        }


    }
}
