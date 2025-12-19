using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using MediaCreator.Common;
using System.IO;

//*******************************************************************************
// システム名称　　：MediaCreator
// プロセス名称　　：メディア作成依頼ファイル処理　メイン
// 作成者          ：Y.Kitaoka
// 作成日付　　　　：2013/11/13
// 更新日付　　　　：2013/11/22
//                 ：
// 補　足　説　明　：
//                 ：
//*******************************************************************************
namespace MediaCreator
{
    public class MediaCreatReq
    {
        /************/
        /* 定数定義 */
        /************/
        const int ZERO_ORI = 1;
        const int ROW0 = 0;

        const int COL0 = 0;
        const int COL1 = 1;
        const int COL2 = 2;
        const int COL3 = 3;
        const int COL4 = 4;
        const int COL5 = 5;
        const int COL6 = 6;

        const int DISK_PUBLISHER_ID_BYTE = 16;
        const int PATIENT_ID_BYTE = 10;
        const int INSPECTION_COUNT_BYTE = 3;
        const int ACCESSION_NO_BYTE = 16;
        const int MODALITY_INFO_BYTE = 3;
        const int STUDYINSTANCE_UID_BYTE = 64;

        const int FILE_NAME_BYTE = 42;

        const int UNSENT = 0;

        /**************/
        /* 構造体定義 */
        /**************/
        //メディア作成依頼ファイル用
        struct mediaCreatReqData
        {
            public string requestid;
            public string requestdate;
            public string ris_id;
            public string kensakiki;
            public string media_flg;
            public string kanja_id;
            public string ris_id_cnt;
            public string indexFilename;
            public string[] accessionno;
            public string[] kensa_date;
            public string[] modality_type;
            public string[] studyinstance_uid;
        }

        /* 2013/12/06 仕様変更 */
        //メディア作成依頼ファイル用
        public struct mediaCreatDoneNotisSet
        {
            public string requestid;
            public string requestdate;
            public string ris_id;
            public string kanja_id;
            public string requestuser;
            public string requestterminallid;
            public string requesttype;
            public string transferstatus;
            public string orderno;
        }
        /* 2013/12/06 仕様変更 */

        // Propertiesより情報取得
        string OrderDataOutput = Properties.Settings.Default.OrderDataFolder;
        string OrderIndexOutput = Properties.Settings.Default.OrderIndexFolder;
        string OrderLogOutput = Properties.Settings.Default.OrderLogFolder;

        //*****************************************************************************
        //関数名称：associationTableSet
        //機能概略：関係テーブル設定処理(TOHISINFO)
        //引数　　：I:string orderno
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/15
        //*****************************************************************************
        private void associationTableSet(string orderno)
        {
            try
            {
                // メディア作成依頼ファイル用構造体定義
                var mdSet = new mediaCreatDoneNotisSet();

                DataTable dt;

                // HIS送信リクエストテーブル(CODONICSMEDIAORDERTABLE)に情報を選択 取得
                dt = new DataTable();
                DataBase.sqlDataGet(DataBase.mcdCodonicsmediaorderTableGet(orderno), dt);
                mdSet.kanja_id = dt.Rows[ROW0][COL0].ToString();
                mdSet.requestdate = dt.Rows[ROW0][COL1].ToString();
                mdSet.ris_id = dt.Rows[ROW0][COL2].ToString();

                mdSet.orderno = orderno;
                mdSet.requesttype = "OP01";
                mdSet.transferstatus = "00";

                //RIS_IDより EXTENDORDERINFO.RIS_HAKKO_USER,RIS_HAKKO_TERMINAL を取得
                dt = new DataTable();
                DataBase.sqlDataGet(DataBase.extendOrderInfoleTableGet(mdSet.ris_id), dt);
                mdSet.requestuser = dt.Rows[ROW0][COL0].ToString();
                mdSet.requestterminallid = dt.Rows[ROW0][COL1].ToString();

                // RIS_IDより EXMAINTABLE のステータスが既に90の場合は
                // ToHisInfoテーブルに情報追加はしない
                dt = new DataTable();
                DataBase.sqlDataGet(DataBase.exmaintableTableStatusGet(mdSet.ris_id), dt);
                if (dt.Rows[ROW0][COL0].ToString() != "90")
                {
                    //FROMRISSEQUENCE.NEXTVALにて、設定するREQUESTIDの採番
                    dt = new DataTable();
                    DataBase.sqlDataGet(DataBase.nextvalGet, dt);
                    mdSet.requestid = dt.Rows[ROW0][COL0].ToString();

                    // ToHisInfoテーブルに情報追加
                    DataBase.sqlDataSet(DataBase.mcdTohisinfoTableSet(mdSet));

                    // EXMAINTABLE のステータス更新(exmaintable.statusに"90"を設定)
                    DataBase.sqlDataSet(DataBase.exmaintableTableSet(mdSet.ris_id));
                }

            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("associationTableSet Error " +
                                         " orderno=" + orderno, ex);
            }
        }

        //*****************************************************************************
        //関数名称：mediaCreatReqFileMake
        //機能概略：メディア作成依頼ファイルの内容作成
        //引数　　：I:mediaCreatReqData mdreq メディア作成依頼用構造体情報
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        private string mediaCreatReqFileMake(mediaCreatReqData mdreq)
        {
            string file = null;
            int strLen;

            try
            {
                //CREATE_DATE + CREATE_TIME
                file = mdreq.requestdate.Replace("/", "").Replace(" ", "").Replace(":", "");

                //DISK_PUBLISHER_ID 規定のByte数に満たない場合は半角スペースで埋める
                if (mdreq.kensakiki == null)
                {
                    mdreq.kensakiki = " ";
                }
                strLen = mdreq.kensakiki.Length;
                file += mdreq.kensakiki;
                for (int i = 0; i < (DISK_PUBLISHER_ID_BYTE - strLen); i++) file += " ";

                //MEDIA
                if (mdreq.media_flg == null)
                {
                    mdreq.media_flg = " ";
                }
                file += mdreq.media_flg;

                //PATIENT_ID 規定のByte数に満たない場合は半角スペースで埋める
                if (mdreq.kanja_id == null)
                {
                    mdreq.kanja_id = " ";
                }
                strLen = mdreq.kanja_id.Length;
                file += mdreq.kanja_id;
                for (int i = 0; i < (PATIENT_ID_BYTE - strLen); i++) file += " ";

                //INSPECTION_COUNT 規定のByte数に満たない場合は半角スペースで埋める
                strLen = mdreq.ris_id_cnt.Length;
                file += mdreq.ris_id_cnt;
                for (int i = 0; i < (INSPECTION_COUNT_BYTE - strLen); i++) file += " ";

                //RIS_ID分情報を設定
                for (int cntloop = 0; cntloop < Convert.ToInt32(mdreq.ris_id_cnt); cntloop++)
                {
                    //ACCESSION_NO_BYTE 規定のByte数に満たない場合は半角スペースで埋める
                    strLen = mdreq.accessionno[cntloop].Length;
                    file += mdreq.accessionno[cntloop];
                    for (int i = 0; i < (ACCESSION_NO_BYTE - strLen); i++) file += " ";

                    //INSPECTION_DATE
                    //先頭8文字 YYYYMMDD
                    //No30 特定の患者でメディア作成できない  2014/05/26 S.Terakata(STI)
                    if (mdreq.kensa_date[cntloop] == "") {
                        mdreq.kensa_date[cntloop] = mdreq.kensa_date[cntloop].PadRight(8, ' ');
                    }
                    file += mdreq.kensa_date[cntloop].Replace("/", "").Substring(0, 8);

                    //MODALITY_INFO 規定のByte数に満たない場合は半角スペースで埋める
                    strLen = mdreq.modality_type[cntloop].Length;
                    file += mdreq.modality_type[cntloop];
                    for (int i = 0; i < (MODALITY_INFO_BYTE - strLen); i++) file += " ";

                    //STUDYINSTANCE_UID 規定のByte数に満たない場合は半角スペースで埋める
                    strLen = mdreq.studyinstance_uid[cntloop].Length;
                    file += mdreq.studyinstance_uid[cntloop];
                    for(int i = 0; i < (STUDYINSTANCE_UID_BYTE - strLen); i++) file += " ";
                
                }

            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("mediaCreatReqFileMake Error ", ex);
            }

            return file;
        }

        //*****************************************************************************
        //関数名称：mediaCreatReqDatWrite
        //機能概略：メディア作成依頼ファイルを指定フォルダに作成
        //引数　　：I:string ris_id
        //引数　　：I:string file
        //返り値　：-
        //作成者　：　Y.Kitaoka
        //作成日時：　2013/11/13
        //*****************************************************************************
        private void mediaCreatReqDatWrite(mediaCreatReqData mdreq, string file)
        {

            try
            {
                //インデックスファイル名を取得
                string filenameIndex = mdreq.indexFilename;

                //拡張子置換
                string filenameData = mdreq.indexFilename.Replace(".idx", ".idx.tmp").Replace(".idx.tmp", ".dat.tmp");

                //Dataファイル 作成
                Common.Common.streamWriter(OrderDataOutput + "\\" + filenameData, file, 0);

                //ファイル書き込み後、拡張子を.datに変換
                string filenameDataNew = filenameData.Replace(".dat.tmp", ".dat");

                //ファイル名を変更する(上書きはできない)
                File.Move(OrderDataOutput + "\\" + filenameData, OrderDataOutput + "\\" + filenameDataNew);

                //FILE_NAMEを既定の文字数に合わせる
                int strLen = filenameDataNew.Length;
                for (int i = 0; i < (FILE_NAME_BYTE - strLen); i++) filenameDataNew += " ";

                //Indexファイル 作成
                Common.Common.streamWriter(OrderIndexOutput + "\\" + filenameIndex,
                                           Common.Common.serverTimeGet.Replace("/", "").Replace(" ", "").Replace(":", "") +
                                           filenameDataNew, 0);

                //ファイル書き込み後、拡張子を.idxに変換
                string filenameIndexNew = filenameIndex.Replace(".idx.tmp", ".idx");

                //ファイル名を変更する(上書きはできない)
                try
                {
                    File.Move(OrderIndexOutput + "\\" + filenameIndex, OrderIndexOutput + "\\" + filenameIndexNew);
                }
                catch
                {
                    //Indexファイル書込みエラー時は、エラーとなるため処理をスルー
                }

                // Logファイル 作成
                Common.Common.streamWriter(OrderLogOutput + "\\" + "order_" +
                                           Common.Common.serverTimeGet.Replace("/", "").Substring(0, 8) + ".log",
                                           Common.Common.serverTimeGet + " >> " + filenameDataNew + " normal end" + "\r\n", 0);
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("mediaCreatReqDatWrite Error " +
                                         " file=" + file, ex);
            }
        }

        //*****************************************************************************
        //関数名称：mediaCreatReqMain
        //機能概略：メディア作成依頼ファイル処理 メイン
        //引数　　：-
        //返り値　：-
        //作成者　：Y.Kitaoka
        //作成日時：2013/11/13
        //*****************************************************************************
        public void mediaCreatReqMain()
        {

            try
            {
                //REQUESTID,REQUESTDATE,RIS_ID 情報取得
                var dt = new DataTable();
                DataBase.sqlDataGet(DataBase.elementTableGet, dt);

                //ToCodonicsInfo.TransferStatus 未送信'00' が無い場合は処理しない
                if (dt.Rows.Count != UNSENT)
                {
                    //メディア作成依頼ファイル用構造体定義
                    var mdreq = new mediaCreatReqData();
                    mdreq.requestid = dt.Rows[ROW0][COL0].ToString();
                    mdreq.ris_id = dt.Rows[ROW0][COL1].ToString();
                    mdreq.indexFilename = dt.Rows[ROW0][COL2].ToString();
                    mdreq.kanja_id = dt.Rows[ROW0][COL3].ToString();
                    mdreq.kensakiki = dt.Rows[ROW0][COL4].ToString();
                    mdreq.media_flg = dt.Rows[ROW0][COL5].ToString();

                    //REQUESTIDよりTOCODONICSINFO.REQUESTDATE 情報取得
                    dt = new DataTable();
                    DataBase.sqlDataGet(DataBase.codonicsinfoTableReqDateGet(mdreq.requestid), dt);
                    mdreq.requestdate = dt.Rows[ROW0][COL0].ToString();

                    //CODONICSMEDIAORDERSTUDYTABLE.ACCESSIONNO,KENSA_DATE,MODALITY_TYPE 情報をDataSetより取得
                    dt = new DataTable();
                    DataBase.sqlDataGet(DataBase.codonicsmediaorderstudyTableGet(mdreq.ris_id), dt);

                    //メンバ用の配列を生成 (DataTableのカラム数)
                    mdreq.accessionno = new string[dt.Rows.Count];
                    mdreq.kensa_date = new string[dt.Rows.Count];
                    mdreq.modality_type = new string[dt.Rows.Count];
                    mdreq.studyinstance_uid = new string[dt.Rows.Count];

                    //RIS_ID 設定数を代入
                    mdreq.ris_id_cnt = Convert.ToString(dt.Rows.Count);

                    //RIS_ID分情報を設定
                    int cntloop = 0;
                    foreach (DataRow dr in dt.Rows)
                    {
                        mdreq.accessionno[cntloop] = dt.Rows[cntloop][COL0].ToString();
                        mdreq.kensa_date[cntloop] = dt.Rows[cntloop][COL1].ToString();
                        mdreq.modality_type[cntloop] = dt.Rows[cntloop][COL2].ToString();
                        mdreq.studyinstance_uid[cntloop] = dt.Rows[cntloop][COL3].ToString();
                        cntloop++;
                    }

                    //メディア作成依頼ファイルを作成・配置
                    mediaCreatReqDatWrite(mdreq, mediaCreatReqFileMake(mdreq));

                    //TOCODONICSINFO.TRANSFERSTATUSを 01:送信済みに設定
                    //TOCODONICSINFO.TRANSFERDATE に処理日時を設定
                    DataBase.sqlDataSet(DataBase.tocodonicsinfoTableSet(mdreq.requestid));

                    /* 2013/12/06 仕様変更 */
                    // orderno抜き出す
                    string orderno = mdreq.indexFilename.Replace("order_", "");
                    orderno = orderno.Substring(0, orderno.IndexOf("_"));

                    // 関係テーブル設定処理(TOHISINFO)
                    associationTableSet(orderno);
                    /* 2013/12/06 仕様変更 */

                }
            }
            catch (Exception ex)
            {
                ProcessMain.logger.Fatal("mediaCreatReqMain Error ", ex);
            }
        }
    }
}
