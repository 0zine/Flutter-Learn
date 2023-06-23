import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatelessWidget {

  WebViewController? controller;

  //Const 생성자
  // 생성자 앞에 const 키워드를 추가하면 const 인스턴스를 생성할 수 있음
  // 한 번 생성된 const 인스턴스 위젯은 재활용되어서 하드웨어 리소스를 적게 사용할 수 있음
  // const
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('코드타이거'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {
              if (controller != null) {
                controller!.loadUrl('https://0zine.tistory.com');
              }
            },
            icon: Icon(
              Icons.home,
            ),
          )
        ],
      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller) {
          this.controller = controller;
        },
        initialUrl: 'https://0zine.tistory.com',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}