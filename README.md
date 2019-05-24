file_server
==
 
**file_server** is a **Dart 2** sample HTTP file server application. Do not use this code without security and stability enhancement for actual applications. This is a code sample and an attachment to the ["Dart 2 Language Gide"](https://www.cresc.co.jp/tech/java/Google_Dart2/introduction/main_page.html) written in Japanese.

## Installing  
  1. Download this repository, uncompress and rename the folder to "file_server".
  2. From Dart Editor, File > Open Existing Folder and select this file_server folder.
  3. Select Tools > Pub Install to install pub libraries.
  4. Put files you want to send into the resources/ folder.
  5. Run the bin/file_server.dart as server.

## Try it
  1. Access the server from your browser:
    `http://localhost:8080/fserver` (Downloads the initial page)  
  2. From the initial page, choose a file from the file list. 
      Or, enter the file_name and click the submit button.  
  3. Alternatively, you can specify the file from the address bar in your browser
  such as:   
    `http://localhost:8080/fserver/resouces/file_name`

  You can specify the `file_name` using relative path or absolute path. For example,
    let `C:/dart_apps_server/file_server` is the folder path of the file
    server and the `resources/readme.text` file is placed in the folder. Then,
    specifying `resources/readme.text` is equivalent to
    `C:/dart_apps_server/file_server/resources/readme.text`.

  Likewise, `resources/images/Dart_Logo.jpg` is equivalent to
    `C:/dart_apps_server/file_server/resources/images/Dart_Logo.jpg`.

## License
This sample is licensed under [MIT License](http://www.opensource.org/licenses/mit-license.php).