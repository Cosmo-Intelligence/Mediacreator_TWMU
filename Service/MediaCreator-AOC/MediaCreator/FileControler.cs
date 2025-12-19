using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace MediaCreator {

    //連携ファイル読み書きクラス
    public class FileControler {

        const String encode = "shift-jis";

        public enum FileClass { 
            Request,
            Responce
        }


        private FileClass fileType;


        private String allString = "";  //ファイルの全文

        public String AllString {
            get { return allString; }
            set { allString = value; }
        }


        private String filename;
        public String getFilename() {
            return filename;
        }
        public String getReadingFilename() {
            return filename + ".reading";
        }
        public String getWritingFilename() {
            return filename + ".writing";
        }
        
        private List<FileCategory> categories = new List<FileCategory>();

        public FileControler(FileClass type) {
            this.fileType = type;
        }

        public static FileControler loadFromFile(String filename,FileClass type){

            FileControler controler = new FileControler(type);
            controler.filename = filename;

            String readingfilename = controler.getReadingFilename();


            //読み込み中は.readingを付ける。
            for (int i = 0; i < 100; i++ ) {
                try {
                    File.Move(filename, readingfilename);
                    break;
                }
                catch (Exception ex) {
                    //ちょっとまってリトライ
                    if (i < 100) {
                        System.Threading.Thread.Sleep(100);
                    }
                    else {
                        throw ex;
                    }
                }
            }

            //全文
            controler.AllString = File.ReadAllText(readingfilename,System.Text.Encoding.GetEncoding(encode));

            //行区切りで全文
            String[] lines = File.ReadAllLines(readingfilename,System.Text.Encoding.GetEncoding(encode));

            String category = "";
            for(int i = 0; i < lines.Length; i++){

                String line = lines[i].Trim();

                //空行は読み飛ばす。
                if (line == "") {
                    continue;
                }

                //コメント行は読み飛ばす。
                if (line.StartsWith("#") || line.StartsWith(";")) {
                    continue;
                }

                if (line.StartsWith("[") && line.EndsWith("]")) {
                    //[]で括ってたらカテゴリ
                    category = line.Substring(1, line.Length - 2);
                }
                else {
                    if (category != "") {

                        int pos = line.IndexOf("=");

                        if (pos < 0) {
                            continue;
                        }

                        String key = line.Substring(0, pos);
                        String value = line.Substring(pos + 1);
                        
                        //値を保持
                        controler.setValue(category,key,value);
                    }
                }

            }

        
            return controler;
        }


        public void saveToFile(String filename) {

            this.filename = filename;

            String writingfilename = this.getWritingFilename();

            //書き込み中は.writingを付ける。
            using(System.IO.StreamWriter sw = new System.IO.StreamWriter(
                    writingfilename,
                    false,
                    System.Text.Encoding.GetEncoding(encode))) {

                foreach(FileCategory cat in this.categories){

                    sw.WriteLine(String.Format("[{0}]",cat.Category));
                    
                    foreach (FileItem item in cat.Items) {
                        sw.WriteLine(String.Format("{0}={1}", item.Key,item.Value));
                    }

                    sw.WriteLine("");
                    
                }

            
            }

            //.writingを外す。
            File.Move(writingfilename, filename);

        }

        public void deleteFile() {

            for (int i = 0; i < 100; i++) {
                try{
                    File.Delete(this.getReadingFilename());
                    break;
                }
                catch(Exception ex){
                    if (i < 100) {
                        System.Threading.Thread.Sleep(100);
                    }
                    else {
                        throw ex;
                    }
                }
            }
        }

        public void setValue(String category, String key, String value) {

            FileCategory newcat = null;

            foreach (FileCategory cat in this.categories) {
                if (category.ToUpper() == cat.Category.ToUpper()) {
                    newcat = cat;
                    break;
                }
            }

            if (newcat == null) {
                newcat = new FileCategory();
                newcat.Category = category;
                newcat.setValue(key,value);
                this.categories.Add(newcat);
            }
            else {
                newcat.setValue(key,value);
            }

        }

        public String getValue(String category, String key) {

            String ret = "";

            foreach (FileCategory cat in this.categories) {
                if (category.ToUpper() == cat.Category.ToUpper()) {
                    ret = cat.getValue(key);
                    break;
                }
            }

            return ret;
        }


        class FileItem {
            String key;
            String value;

            public FileItem(String key,String value) {
                this.key = key;
                this.value = value;
            }

            public String Key {
                get { return this.key; }
                set { this.key = value; }
            }

            public String Value {
                get { return this.value; }
                set { this.value = value; }
            }
            
        }


        class FileCategory {

            String category;

            public String Category {
                get { return category; }
                set { category = value; }
            }

            private List<FileItem> items = new List<FileItem>();

            public List<FileItem> Items {
                get { return items; }
                set { items = value; }
            }

            public String getValue(String key) {

                String ret = "";

                foreach (FileItem item in this.items) {
                    if (key.ToUpper() == item.Key.ToUpper()) {
                        ret = item.Value;
                        break;
                    }
                }

                return ret;
            
            }

            public void setValue(String key, String value) {

                FileItem newitem = null;

                foreach (FileItem item in this.items) {
                    if (key.ToUpper() == item.Key.ToUpper()) {
                        newitem = item;
                        break;
                    }
                }

                if (newitem == null) {
                    newitem = new FileItem(key, value);
                    this.items.Add(newitem);
                }
                else {
                    newitem.Value = value;
                }

            }

        }
    }
}
