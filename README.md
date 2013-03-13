file_server
==

**file_server** is a Dart sample HTTP file server application. Do not use this code without security enhansments for actual applications. This is a code
 sample and an attachment
to the ["Dart Language Gide"](http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide.pdf) written in Japanese.

このサンプルは[「プログラミング言語Dartの基礎」](http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide_about.html)の
添付資料です。詳細は「HTTPサーバ (HttpServer)」の章の「ファイル・サーバ」の節をご覧ください。


### Installing ###

1. Download this repositorie, uncompress and rename the folder to "file_server".
2. From Dart Editor, File > Open Existion Folder and select this file_server folder.
3. Selsect Tools > Pub Install to install pub libraries.
4. Put files you want to send into the resouces/ folder.
5. Run the bin/FileServer.dart as server.

### Try it ###

1. Access the server from your browser: 
   `http://localhost:8080/fserver` (Downloads the initial page)
2. From the initial page, choose a file from the file list.
   Or, enter the file_name and click the submit button.
3. Alternatively, you can specify the file from the address bar in your browser
   such as:
   `http://localhost:8080/fserver/resouces/file_name`

You can specify the `file_name` using relative path or absolute path. For example, 
let `C:/dart_apps_server/file_server` is the folder path of the file 
server and the `resources/readme.text` file is placed in the folder. Then 
specifing `resources/readme.text` is equivalent to 
`C:/dart_apps_server/file_server/resources/readme.text`.

Likewise, `resources/images/Dart_Logo.jpg` is equivalent to 
`C:/dart_apps_server/file_server/resources/images/Dart_Logo.jpg`.

In case of downloading HTML files through the download page, browsers will not execute 
scripts in the downloaded HTML file.

### License ###
This sample is licensed under [MIT License][MIT].
[MIT]: http://www.opensource.org/licenses/mit-license.php