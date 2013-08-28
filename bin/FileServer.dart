/*
  Dart code sample: Simple file server
  1. Download, uncompress and rename the folder to 'file_server'.
  2. Put files you want to send into the file_server/resources folder.
  3. From Dart Editor, File > Open Existing Folder and select this file_server folder.
  4. Run the FileServer.dart as server.
  5. Access the server from Chrome: http://localhost:8080/fserver
     or directly: http://localhost:8080/fserver/resources/readme.txt
    Ref.
      https://gist.github.com/2564561
      https://gist.github.com/2564562
      http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide.pdf (in Japanese)
    Modified May  2012, by Terry Mitsuoka.
    Revised July  2012 to include MIME library.
    Revised Sept. 2012 to incorporate catch syntax change.
    Revised Oct.  2012 to incorporate M1 changes.
    Revised Feb.  2013 to incorporate newly added dart:async library.
    Revised Feb.  2013 to incorporate M3 changes.
    Modified March 2013, modified for Github upload and incorporated API changes
    Modified June 2013, fixed API changes (request.queryParameters, file path etc.)
    Modified July 2013, modified main() to ruggedize.
    Revised Aug.  2013, API change (class Path deleted) incorporated.
    Revised Aug.  2013, API changes (removed StringDecoder and added dart:convert) fixed
*/


import 'dart:io';
import "dart:convert";
import '../packages/mime_type/mime_type.dart' as mime;
import 'dart:utf' as utf;
import 'dart:async';

final HOST = '127.0.0.1';
final PORT = 8080;
final REQUEST_PATH = "/fserver";
final LOG_REQUESTS = false;


void main() {
  HttpServer.bind(HOST, PORT)
  .then((HttpServer server) {
    server.listen(
        (HttpRequest request) {
          request.response.done.then((d){
            if (LOG_REQUESTS) print("sent response to the client for request : ${request.uri}");
          }).catchError((e) {
            print("new DateTime.now()} : Error occured while sending response: $e");
          });
          if (request.uri.path.contains(REQUEST_PATH)) {
            requestReceivedHandler(request);
          }
          else {
            new BadRequestHandler().onRequest(request);
          }
        });
    print("${new DateTime.now()} : Serving $REQUEST_PATH on http://${HOST}:${PORT}.");
  });
}


void requestReceivedHandler(HttpRequest request) {
  final HttpResponse response = request.response;
  String bodyString = "";      // request body byte data
  var completer = new Completer();
  if (request.method == "GET") {
    completer.complete("query string data received");
  }
  else if (request.method == "POST") {
    request
      .transform(UTF8.decoder) // decode the body as UTF
      .listen(
          (String str){bodyString = bodyString + str;},
          onDone: (){
            completer.complete("body data received");},
          onError: (e){
            print('exeption occured : ${e.toString()}');}
        );
  }
  else {
    response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
    response.close();
    return;
  }
  // process the request
  completer.future.then((data){
    try {
      if (LOG_REQUESTS) {
        print(createLogMessage(request, bodyString));
      }
      // selsect requests with 'fileName' query
      if (request.uri.queryParameters['fileName'] != null) {
        new FileHandler().onRequest(request);
      } else
      // select request without 'fileName' query
      {
        // select direct designation of the file
        String fName = request.uri.path.replaceFirst(REQUEST_PATH, '');
        if (fName.length > 2) {
          fName = fName.substring(1);
          if (fName.contains('resources/')) {
            new FileHandler().onRequest(request, '../' + fName);
          }
          else new InitialPageHandler().onRequest(request,
              'you can access files in resouces/ only!');
        }
        // new client, send initial page
        else {
//        new FileHandler().onRequest(request, '../resources/Client.html');
          new InitialPageHandler().onRequest(request);
        }
      }
    } catch(err, st) {
      print('File Handler error : $err.toString()');
      print(st);
    }
  });
}


// return requested file to the client
class FileHandler {

  void onRequest(HttpRequest request, [String fileName = null]) {
    File file;
    try {
      final HttpResponse response = request.response;
      if (fileName == null) {
        fileName = request.uri.queryParameters['fileName'];
        // check for absolute path
        file = new File(fileName);
        if (! file.existsSync()) {
          fileName = '../' + request.uri.queryParameters['fileName'];
        }
      }
      if (LOG_REQUESTS) {
        print('Requested file name : $fileName');
      }
      file = new File(fileName);
      String mimeType;
      if (file.existsSync()) {
        mimeType = mime.mime(fileName);
        if (mimeType == null) mimeType = 'text/plain; charset=UTF-8'; // default
        response.headers.set('Content-Type', mimeType);
//      response.headers.set('Content-Disposition', 'attachment; filename=\'${fileName}\'');
        // Get length of the file for Content-Length header.
        RandomAccessFile openedFile = file.openSync();
        response.contentLength = openedFile.lengthSync();
        openedFile.closeSync();
        // Pipe the file content into the response.
        file.openRead().pipe(response);
      } else {
        if (LOG_REQUESTS) {
          print('File not found: $fileName');
        }
        new NotFoundHandler().onRequest(request);
      }
    } catch (err, st) {
      print('File Handler error : $err.toString()');
      print(st);
    }
  }
}


class BadRequestHandler {
  String badRequestPage;
  static final String badRequestPageHtml = '''
<html><head>
<title>400 Bad Request</title>
</head><body>
<h1>Bad Request</h1>
<p>The request could not be understood by the server due to malformed syntax.</p>
</body></html>''';

  void onRequest(HttpRequest request, [String badRequestPage = null]){
    if (badRequestPage == null) {
      badRequestPage = badRequestPageHtml;
    }
    request.response
      ..statusCode = HttpStatus.BAD_REQUEST
      ..headers.set('Content-Type', 'text/html; charset=UTF-8')
      ..write(badRequestPage)
      ..close();
  }
}


class NotFoundHandler {
  String notFoundPage;

  static final String notFoundPageHtml = '''
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL or File was not found on this server.</p>
</body></html>''';

  void onRequest(HttpRequest request, [String notFoundPage = null]){
    if (notFoundPage == null) {
      notFoundPage = notFoundPageHtml;
    }
    request.response
      ..statusCode = HttpStatus.NOT_FOUND
      ..headers.set('Content-Type', 'text/html; charset=UTF-8')
      ..write(notFoundPage)
      ..close();
  }
}


class InitialPageHandler {

  void onRequest(HttpRequest request, [String warning = '']) {
    request.response
    ..headers.set('Content-Type', 'text/html; charset=UTF-8')
    ..write(createInitialPageHtml(warning).toString())
    ..close();
  }

  StringBuffer createInitialPageHtml(String warning){
  var sb = new StringBuffer('');
  sb.write(
      r'''
<!DOCTYPE html>
<html>
  <head>
    <title>Request File Download</title>
  </head>
  <body>
    <h1>Request a file</h1>
''');
  if (warning != '') {
    sb.write('    <br><h2><div style="color:red">$warning</div></h2><br>\n');
  }
  sb.write(
      r'''
    <h2>Choose from available files in resources/ directory</h2>
''');
  List<String> fileNames = fileList('../resources');
  fileNames.forEach((f) {
    var fn = '$f'.replaceFirst('../', '');
    sb.write('    <a href=http://localhost:8080/fserver/${fn}>$fn<br></a>\n');
  });
  sb.write(
      r'''
    <h2>Or, enter file name to download</h2>
    <form method="get" action="http://localhost:8080/fserver">
      <input type="text" name="fileName" value="resources/readme.txt" size="50">
      <br>
      <input type="submit" value=" Submit ">
    </form>
  </body>
</html>
''');
  return sb;
  }
}


// list files in specified path
List<String> fileList(String pathName) {
  List<String> fileNames = [];
  final directory = new Directory(pathName);
  final List<FileSystemEntity> fileList = directory.listSync(recursive: true);
  fileList.forEach((file){
    if (file is File) {
      fileNames.add(file.path.replaceAll(r'\', '/'));
    }
   });
  fileNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return fileNames;
}


// create log message for the request
StringBuffer createLogMessage(HttpRequest request, [String bodyString]) {
  var sb = new StringBuffer( '''request.headers.host : ${request.headers.host}
request.headers.port : ${request.headers.port}
request.connectionInfo.localPort : ${request.connectionInfo.localPort}
request.connectionInfo.remoteHost : ${request.connectionInfo.remoteHost}
request.connectionInfo.remotePort : ${request.connectionInfo.remotePort}
request.method : ${request.method}
request.persistentConnection : ${request.persistentConnection}
request.protocolVersion : ${request.protocolVersion}
request.contentLength : ${request.contentLength}
request.uri : ${request.uri}
request.uri.path : ${request.uri.path}
request.uri.query : ${request.uri.query}
request.uri.queryParameters :
''');
  request.uri.queryParameters.forEach((key, value){
    sb.write("  ${key} : ${value}\n");
  });
  sb.write('''request.cookies :
''');
  request.cookies.forEach((value){
    sb.write("  ${value.toString()}\n");
  });
  sb.write('''request.headers.expires : ${request.headers.expires}
request.headers :
  ''');
  var str = request.headers.toString();
  for (int i = 0; i < str.length - 1; i++){
    if (str[i] == "\n") { sb.write("\n  ");
    } else { sb.write(str[i]);
    }
  }
  sb.write('''\nrequest.session.id : ${request.session.id}
requset.session.isNew : ${request.session.isNew}
''');
  if (request.method == "POST") {
    var enctype = request.headers["content-type"];
    if (enctype[0].contains("text")) {
      sb.write("request body string : ${bodyString.replaceAll('+', ' ')}");
    } else if (enctype[0].contains("urlencoded")) {
      sb.write("request body string (URL decoded): ${urlDecode(bodyString)}");
    }
  }
  sb.write("\n");
  return sb;
}


// make safe string buffer data as HTML text
StringBuffer makeSafe(StringBuffer b) {
  var s = b.toString();
  b = new StringBuffer();
  for (int i = 0; i < s.length; i++){
    if (s[i] == '&') { b.write('&amp;');
    } else if (s[i] == '"') { b.write('&quot;');
    } else if (s[i] == "'") { b.write('&#39;');
    } else if (s[i] == '<') { b.write('&lt;');
    } else if (s[i] == '>') { b.write('&gt;');
    } else { b.write(s[i]);
    }
  }
  return b;
}


// URL decoder decodes url encoded utf-8 bytes
// Use this method to decode query string
// We need this kind of encoder and decoder with optional [encType] argument
String urlDecode(String s){
  int i, p, q;
   var ol = new List<int>();
   for (i = 0; i < s.length; i++) {
     if (s[i].codeUnitAt(0) == 0x2b) { ol.add(0x20); // convert + to space
     } else if (s[i].codeUnitAt(0) == 0x25) { // convert hex bytes to a single byte
       i++;
       p = s[i].toUpperCase().codeUnitAt(0) - 0x30;
       if (p > 9) p = p - 7;
       i++;
       q = s[i].toUpperCase().codeUnitAt(0) - 0x30;
       if (q > 9) q = q - 7;
       ol.add(p * 16 + q);
     }
     else { ol.add(s[i].codeUnitAt(0));
     }
   }
  return utf.decodeUtf8(ol);
}