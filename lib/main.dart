import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 이 위젯은 애플리케이션의 루트입니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 이것은 애플리케이션의 테마입니다.
        //
        // 시도해보세요: "flutter run"으로 애플리케이션을 실행해보세요.
        // 애플리케이션에 보라색 툴바가 있는 것을 볼 수 있습니다.
        // 앱을 종료하지 않고, 아래의 colorScheme에서 seedColor를 Colors.green으로
        // 변경한 다음 "hot reload"를 실행해보세요 (변경사항을 저장하거나 Flutter를 지원하는
        // IDE에서 "hot reload" 버튼을 누르거나, 명령줄에서 앱을 시작한 경우 "r"을 누르세요).
        //
        // 카운터가 0으로 초기화되지 않은 것을 주목하세요; 애플리케이션의 상태는
        // 리로드 중에 유지됩니다. 상태를 초기화하려면 hot restart를 사용하세요.
        //
        // 이것은 값뿐만 아니라 코드에도 적용됩니다: 대부분의 코드 변경사항은
        // hot reload로 테스트할 수 있습니다.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 이 위젯은 애플리케이션의 홈 페이지입니다. Stateful 위젯이므로,
  // 모양에 영향을 미치는 필드를 포함하는 State 객체가 있습니다.

  // 이 클래스는 상태의 설정입니다. 부모(이 경우 App 위젯)에서 제공한 값(이 경우
  // 제목)을 보관하며 State의 build 메서드에서 사용됩니다. Widget 하위 클래스의
  // 필드는 항상 "final"로 표시됩니다.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // setState 호출은 Flutter 프레임워크에 이 State에서 변경사항이 있음을 알립니다.
      // 이는 아래의 build 메서드를 다시 실행하도록 하여 화면이 업데이트된 값을
      // 반영할 수 있게 합니다. setState()를 호출하지 않고 _counter를 변경하면,
      // build 메서드가 다시 호출되지 않아 아무 일도 일어나지 않는 것처럼 보입니다.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이 메서드는 setState가 호출될 때마다 다시 실행됩니다. 예를 들어 위의
    // _incrementCounter 메서드에 의해 호출됩니다.
    //
    // Flutter 프레임워크는 build 메서드를 빠르게 다시 실행할 수 있도록
    // 최적화되어 있어서, 업데이트가 필요한 부분만 다시 빌드할 수 있습니다.
    return Scaffold(
      appBar: AppBar(
        // 시도해보세요: 여기서 색상을 특정 색상(예: Colors.amber)으로 변경하고
        // hot reload를 실행하여 AppBar의 색상이 변경되는 것을 확인해보세요.
        // 다른 색상은 그대로 유지됩니다.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 여기서는 App.build 메서드에 의해 생성된 MyHomePage 객체의 값을 가져와
        // appbar 제목을 설정합니다.
        title: Text(widget.title),
      ),
      body: Center(
        // Center는 레이아웃 위젯입니다. 단일 자식 위젯을 받아 부모의 중앙에
        // 배치합니다.
        child: Column(
          // Column도 레이아웃 위젯입니다. 자식 위젯들의 목록을 받아 수직으로
          // 배치합니다. 기본적으로 자식들의 수평 크기에 맞추고, 부모의 높이에 맞춰
          // 높아지려고 합니다.
          //
          // Column은 크기 조절과 자식 위젯 배치를 제어하는 다양한 속성을 가집니다.
          // 여기서는 mainAxisAlignment를 사용하여 자식들을 수직으로 중앙에 배치합니다;
          // Column이 수직이므로 주축은 수직축입니다 (횡축은 수평축입니다).
          //
          // 시도해보세요: "디버그 페인팅"을 실행해보세요 (IDE에서 "Toggle Debug Paint"
          // 작업을 선택하거나, 콘솔에서 "p"를 누르세요)하여 각 위젯의 와이어프레임을
          // 확인해보세요.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '버튼을 누른 횟수:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: '증가',
        child: const Icon(Icons.add),
      ), // 이 후행 쉼표는 build 메서드의 자동 포맷팅을 더 좋게 만듭니다.
    );
  }
}
