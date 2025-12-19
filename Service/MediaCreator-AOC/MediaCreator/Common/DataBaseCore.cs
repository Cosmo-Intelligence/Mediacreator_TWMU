using System;
using System.Collections.Generic;
using System.Web;
using System.Configuration;
using System.Data;
using System.Collections;

using Oracle.DataAccess.Client;

/// <summary>
/// DataBase の概要の説明です
/// </summary>
public abstract class DataBaseCore
{


    public static OracleConnection getConnection(String ConnectionString) {
        OracleConnection conn;

        conn = new OracleConnection(ConnectionString);
        conn.Open();
        return conn;
    }

    public static void closeConection(OracleConnection conn){
        try {
            conn.Close();
        }
        catch{
            //無視
        }
    }


    public static bool updateTable(String tableName, String[] keys, DataRow row, OracleConnection conn) {

        String sql = "";

        DataTable dat = new DataTable();

        sql += " SELECT * ";
        sql += "   FROM " + tableName;

        for(int i = 0; i < keys.Length; i++) {
            if(i == 0) {
                sql += " WHERE " + keys[i] + " = :" + keys[i];
            }
            else {
                sql += "   AND " + keys[i] + " = :" + keys[i];
            }
        }

        using(OracleCommand cmd = createCommand(sql,keys,row,conn)){
            using(OracleDataAdapter oda = new OracleDataAdapter(cmd)){
                oda.Fill(dat);
            }        
        }

        sql = "";
        int colCount = 0;
        ArrayList paramArray = new ArrayList();

		if(dat.Rows.Count == 0){
			sql += "INSERT INTO " + tableName + " ( ";
			colCount = 0;
			for(int i = 0; i < dat.Columns.Count; i++){
                if (row.Table.Columns.Contains(dat.Columns[i].ColumnName)) {
					if(colCount > 0){
						sql += " , ";
					}
					sql += dat.Columns[i].ColumnName;
					colCount++;
				}
			}
			sql += " ) VALUES (";
			colCount = 0;
			for(int i = 0; i < dat.Columns.Count; i++){
                if (row.Table.Columns.Contains(dat.Columns[i].ColumnName)) {
					if(colCount > 0){
						sql += " , ";
					}
					sql += " :" + dat.Columns[i].ColumnName;
                    paramArray.Add(dat.Columns[i].ColumnName);
                    colCount++;
				}
			}
			sql += " ) ";
		}
		else{
			sql += "UPDATE " + tableName + " SET ";
            colCount = 0;
			for(int i = 0; i < dat.Columns.Count; i++){
				bool isKey = false;
                if (row.Table.Columns.Contains(dat.Columns[i].ColumnName)) {
                    if (Array.IndexOf(keys, dat.Columns[i].ColumnName) >= 0) {
                        isKey = true;
                    }
                    if (!isKey) {
                        if (row.Table.Columns.Contains(dat.Columns[i].ColumnName)) {
                            if (colCount > 0) {
                                sql += " , ";
                            }
                            sql += dat.Columns[i].ColumnName + " = :" + dat.Columns[i].ColumnName;
                            paramArray.Add(dat.Columns[i].ColumnName);
                            colCount++;
                        }
                    }
                }
			}
			for(int i= 0; i < keys.Length; i++){
				if( i == 0 ){
					sql += " WHERE ";
				}
				else{
					sql += "  AND ";
				}
				sql += keys[i] + " = :" + keys[i];
                paramArray.Add(keys[i]);
			}
		}

        String[] paramNames = new String[paramArray.Count];
        paramArray.CopyTo(paramNames);

        using(OracleCommand cmd = createCommand(sql,paramNames,row,conn)){
            cmd.ExecuteNonQuery();
        }
       
        return true;
    }


    private static OracleCommand createCommand(String sql, String[] paramNames, DataRow row, OracleConnection conn) {

        OracleCommand cmd = new OracleCommand(sql, conn);
        cmd.BindByName = true;

        for(int i = 0; i < paramNames.Length; i++) {
            if(row[paramNames[i]].GetType() == typeof(long)){
                cmd.Parameters.Add(paramNames[i], OracleDbType.Decimal).Value = (long)row[paramNames[i]];
            }
            else if(row[paramNames[i]].GetType() == typeof(int)) {
                cmd.Parameters.Add(paramNames[i], OracleDbType.Decimal).Value = (int)row[paramNames[i]];
            }
            else if(row[paramNames[i]].GetType() == typeof(double)) {
                cmd.Parameters.Add(paramNames[i], OracleDbType.Decimal).Value = (double)row[paramNames[i]];
            }
            else if(row[paramNames[i]].GetType() == typeof(float)) {
                cmd.Parameters.Add(paramNames[i], OracleDbType.Decimal).Value = (float)row[paramNames[i]];
            }
            else if(row[paramNames[i]].GetType() == typeof(String)) {
                cmd.Parameters.Add(paramNames[i], OracleDbType.Varchar2, ((String)row[paramNames[i]]).Length).Value = (String)row[paramNames[i]];
            }
            else if(row[paramNames[i]].GetType() == typeof(DateTime)) {
                cmd.Parameters.Add(paramNames[i], OracleDbType.Date).Value = (DateTime)row[paramNames[i]];
            }
            else {
                cmd.Parameters.Add(paramNames[i], OracleDbType.Varchar2, row[paramNames[i]].ToString().Length).Value = row[paramNames[i]].ToString();
            }
        }

        return cmd;
    }


    public static bool deleteTable(String tableName, String[] keys, DataRow row, OracleConnection conn) {
        
        String sql = "";
        
        DataTable dat = new DataTable();

        sql += " DELETE ";
        sql += "   FROM " + tableName;

        for(int i = 0; i < keys.Length; i++) {
            if(i == 0) {
                sql += " WHERE " + keys[i] + " = :" + keys[i];
            }
            else {
                sql += "   AND " + keys[i] + " = :" + keys[i];
            }
        }

        using(OracleCommand cmd = createCommand(sql,keys,row,conn)){
            cmd.ExecuteNonQuery();
        }

        return true;
    }

    public static DateTime getSysdate(OracleConnection conn){
        return getSysdate(0, conn);
    }

    public static DateTime getSysdate(int offset, OracleConnection conn) {

        String sql = "";
        DataTable dat = new DataTable();

        sql += "SELECT SYSDATE + " + offset.ToString() + " AS SYSDATE2 FROM dual";

        using(OracleCommand cmd = new OracleCommand(sql, conn)) {
            using(OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                oda.Fill(dat);
            }
        }

        return (DateTime)dat.Rows[0]["SYSDATE2"];

    }

    public static DateTime getSysdateTimestamp(OracleConnection conn) {

        String sql = "";
        DataTable dat = new DataTable();

        sql += "SELECT SYSTIMESTAMP FROM dual";

        using (OracleCommand cmd = new OracleCommand(sql, conn)) {
            using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                oda.Fill(dat);
            }
        }

        return (DateTime)dat.Rows[0]["SYSTIMESTAMP"];

    }

    public static DateTime getSysdateTrunc(OracleConnection conn) {
        return getSysdateTrunc(0, conn);
    }

    public static DateTime getSysdateTrunc(int offset, OracleConnection conn) {

        String sql = "";
        DataTable dat = new DataTable();

        sql += "SELECT TRUNC(SYSDATE + " + offset.ToString() + ") AS sysdatetrunc FROM dual";

        using(OracleCommand cmd = new OracleCommand(sql, conn)) {
            using(OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                oda.Fill(dat);
            }
        }

        return (DateTime)dat.Rows[0]["SYSDATETRUNC"];

    }

    //レコードなしのテーブル構造を返す。
    public static DataRow getEmptyTableRow(String tablename, OracleConnection conn) {
        return getEmptyTableRow(tablename, null, conn);
    }
    //レコードなしのテーブル構造を返す。
    public static DataRow getEmptyTableRow(String tablename, String[] columns, OracleConnection conn) {
        return getEmptyTable(tablename, columns, conn).NewRow();
    }

    //レコードなしのテーブル構造を返す。
    public static DataTable getEmptyTable(String tablename, OracleConnection conn) {
        return getEmptyTable(tablename, null, conn);
    }
    
    //レコードなしのテーブル構造を返す。
    public static DataTable getEmptyTable(String tablename, String[] columns, OracleConnection conn) {

        String sql = "";
        DataTable dat = new DataTable();

        sql += "SELECT ";

        if (columns == null) {
            sql += " * ";
        }
        else if (columns.Length == 0) {
            sql += " * ";
        }
        else {
            for (int i = 0; i < columns.Length; i++) {
                sql += " " + columns[i] + " ";

                if (i < columns.Length - 1) {
                    sql += ",";
                }
            }
        }
        
        sql += "  FROM " + tablename + " WHERE 1 = 0 ";

        using (OracleCommand cmd = new OracleCommand(sql, conn)) {
            using (OracleDataAdapter oda = new OracleDataAdapter(cmd)) {
                oda.Fill(dat);
            }
        }

        return dat;
    }

}

