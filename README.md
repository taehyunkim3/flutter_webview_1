# Flutter 웹뷰 앱 - JavaScript 브릿지 가이드

이 프로젝트는 Flutter에서 웹뷰를 사용하여 웹 페이지를 표시하고, 네이티브 앱과 웹 페이지 간의 통신을 구현한 샘플 앱입니다. 특히 카카오 로그인과 애플 로그인 기능을 네이티브에서 처리하고 그 결과를 웹으로 전달하는 브릿지를 포함하고 있습니다.

## 앱과 웹 사이의 통신 방식

Flutter 앱과 웹 페이지 간의 통신은 JavaScript 채널을 통해 이루어집니다. 통신은 크게 두 가지 방향으로 이루어집니다:

### 1. 웹에서 앱으로 통신 (Web → App)

웹 페이지에서 네이티브 앱의 기능을 호출하고자 할 때 사용합니다. 웹에서 특정 JavaScript 채널을 통해 메시지를 전송하면, 앱에서 해당 메시지를 받아 처리합니다.

```javascript
// 웹 페이지에서 앱으로 메시지 전송하는 방법
// 카카오 로그인 요청
window.KakaoLogin.postMessage("login");

// 애플 로그인 요청
window.AppleLogin.postMessage("login");

// 일반 메시지 전송
window.Flutter.postMessage("안녕하세요! 웹에서 보낸 메시지입니다.");
```

### 2. 앱에서 웹으로 통신 (App → Web)

앱에서 처리한 결과나 이벤트를 웹 페이지로 전달하고자 할 때 사용합니다. 앱에서 JavaScript 코드를 실행하여 웹 페이지의 함수를 호출합니다.

```dart
// 앱에서 웹으로 데이터 전송하는 방법
await webViewController.runJavaScript('window.onKakaoLoginResult($jsonResult);');
```

## 로그인 기능 구현 가이드

### 카카오 로그인 구현

#### 웹 페이지에서 필요한 설정

```javascript
// 1. 카카오 로그인 버튼 이벤트 핸들러 등록
document
  .getElementById("kakao-login-btn")
  .addEventListener("click", function () {
    // 앱으로 로그인 요청 전송
    window.KakaoLogin.postMessage("login");
  });

// 2. 앱으로부터 로그인 결과를 받을 콜백 함수 구현
window.onKakaoLoginResult = function (result) {
  console.log("카카오 로그인 성공:", result);
  // 로그인 성공 처리 로직
  // result 객체에는 accessToken, refreshToken, userId, nickname, email 등이 포함됨
};

// 3. 로그인 에러 처리 콜백 함수 구현
window.onKakaoLoginError = function (error) {
  console.error("카카오 로그인 실패:", error);
  // 로그인 실패 처리 로직
};
```

#### 앱에서의 구현 (이미 완료됨)

```dart
// 카카오 SDK 초기화 (main() 함수에서)
KakaoSdk.init(nativeAppKey: '여기에_카카오_네이티브_앱_키_입력');

// 카카오 로그인 채널 설정
controller.addJavaScriptChannel(
  'KakaoLogin',
  onMessageReceived: (JavaScriptMessage message) {
    _handleKakaoLogin();
  },
);

// 카카오 로그인 처리 함수
Future<void> _handleKakaoLogin() async {
  try {
    // 앱에서 카카오 SDK를 통한 로그인 처리
    final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
    final User user = await UserApi.instance.me();

    // 결과를 웹으로 전송
    final String result = '{ "accessToken": "${token.accessToken}", ... }';
    await _controller.runJavaScript('window.onKakaoLoginResult($result);');
  } catch (error) {
    // 에러 정보를 웹으로 전송
    await _controller.runJavaScript('window.onKakaoLoginError("$error");');
  }
}
```

### 애플 로그인 구현

#### 웹 페이지에서 필요한 설정

```javascript
// 1. 애플 로그인 버튼 이벤트 핸들러 등록
document
  .getElementById("apple-login-btn")
  .addEventListener("click", function () {
    // 앱으로 로그인 요청 전송
    window.AppleLogin.postMessage("login");
  });

// 2. 앱으로부터 로그인 결과를 받을 콜백 함수 구현
window.onAppleLoginResult = function (result) {
  console.log("애플 로그인 성공:", result);
  // 로그인 성공 처리 로직
  // result 객체에는 identityToken, authorizationCode, userIdentifier 등이 포함됨
};

// 3. 로그인 에러 처리 콜백 함수 구현
window.onAppleLoginError = function (error) {
  console.error("애플 로그인 실패:", error);
  // 로그인 실패 처리 로직
};
```

#### 앱에서의 구현 (이미 완료됨)

```dart
// 애플 로그인 채널 설정
controller.addJavaScriptChannel(
  'AppleLogin',
  onMessageReceived: (JavaScriptMessage message) {
    _handleAppleLogin();
  },
);

// 애플 로그인 처리 함수
Future<void> _handleAppleLogin() async {
  try {
    // 앱에서 애플 SDK를 통한 로그인 처리
    final credential = await SignInWithApple.getAppleIDCredential(/* ... */);

    // 결과를 웹으로 전송
    final String result = '{ "identityToken": "${credential.identityToken}", ... }';
    await _controller.runJavaScript('window.onAppleLoginResult($result);');
  } catch (error) {
    // 에러 정보를 웹으로 전송
    await _controller.runJavaScript('window.onAppleLoginError("$error");');
  }
}
```

### 일반 메시지 통신 구현

#### 웹 페이지에서 필요한 설정

```javascript
// 1. 앱으로 메시지 전송
function sendMessageToApp(message) {
  window.Flutter.postMessage(message);
}

// 2. 앱으로부터 응답 처리
window.onFlutterResponse = function (response) {
  console.log("앱으로부터 응답 받음:", response);
  // 응답 처리 로직
};
```

## 주의사항

1. 웹 페이지에서는 반드시 위에서 설명한 콜백 함수들(`onKakaoLoginResult`, `onAppleLoginResult`, `onKakaoLoginError`, `onAppleLoginError`, `onFlutterResponse`)을 구현해야 합니다.

2. 앱에서 카카오 SDK를 사용하기 위해서는 `KakaoSdk.init(nativeAppKey: '여기에_카카오_네이티브_앱_키_입력')`에 실제 카카오 네이티브 앱 키를 입력해야 합니다.

3. 애플 로그인을 iOS에서 사용하려면 Xcode에서 추가 설정이 필요합니다.

4. 로그인 후 받은 토큰은 보안을 위해 적절히 저장하고 관리해야 합니다.

## 테스트 방법

카카오 로그인과 애플 로그인 기능을 테스트하기 위해서는 실제 iOS 또는 Android 기기에서 테스트하는 것이 좋습니다. 시뮬레이터나 에뮬레이터에서는 일부 기능이 제한될 수 있습니다.
