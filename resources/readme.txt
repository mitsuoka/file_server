Dart code sample: Simple file server

*** Caution ***

Do not use this code for actual applications. This is a sample and an attachment
to the "Dart Language Gide" written in Japanese:
www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide.pdf

Usage:

1. Download, uncompress and rename the folder to "file_server".
2. From Dart Editor, File > Open Folder and select this file_server folder.
3. Selsect Tools > Pub Install and install pub libraries.
4. Put files you want to send into the resouces/ folder.
5. Run the bin/FileServer.dart as server.
6. Access the server from your browser: 
   http://localhost:8080/fserver (Downloads the initial page)
7. From the initial page, choose a file from the file list.
   Or, enter the file_name and click the submit button.
8. Alternatively, you can specify the file from the address bar in your browser
   such as:
   http://localhost:8080/fserver/resouces/file_name

How to specify the file_name:

You can specify the file_name using relative path or absolute path. For example, 
let ÅgC:/dart_apps_server/file_serverÅh is the folder path of the file 
server and the Ågresources/readme.textÅh file is placed in the folder. Then 
specifing Ågresources/readme.textÅh is equivalent to 
ÅgC:/dart_apps_server/file_server/resources/readme.textÅh.

Likewise, Ågresources/images/Dart_Logo.jpgÅh is equivalent to 
ÅgC:/dart_apps_server/file_server/resources/images/Dart_Logo.jpgÅh.
