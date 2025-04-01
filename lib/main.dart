// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';

void main() {
  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '여기에_카카오_네이티브_앱_키_입력');

  // 앱 실행 시 상태 표시줄 설정
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // 상태 표시줄 배경을 투명하게
    statusBarIconBrightness: Brightness.dark, // 상태 표시줄 아이콘을 어둡게 (검정색)
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark, // 상태 표시줄 아이콘 색상
        ),
      ),
      home: const WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // 플랫폼별 웹뷰 컨트롤러 설정
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    // 웹뷰 설정
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..addJavaScriptChannel(
        'KakaoLogin',
        onMessageReceived: (JavaScriptMessage message) {
          _handleKakaoLogin();
        },
      )
      ..addJavaScriptChannel(
        'AppleLogin',
        onMessageReceived: (JavaScriptMessage message) {
          _handleAppleLogin();
        },
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          _handleFlutterMessages(message.message);
        },
      )
      ..loadRequest(Uri.parse('https://test-app.ttokttok365.com'));

    // Android 플랫폼 특화 설정
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> _handleKakaoLogin() async {
    try {
      final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      final User user = await UserApi.instance.me();

      // 로그인 결과를 웹으로 전송
      final String result = '''
      {
        "accessToken": "${token.accessToken}",
        "refreshToken": "${token.refreshToken}",
        "userId": "${user.id}",
        "nickname": "${user.kakaoAccount?.profile?.nickname ?? ''}",
        "email": "${user.kakaoAccount?.email ?? ''}"
      }
      ''';

      await _controller.runJavaScript('window.onKakaoLoginResult($result);');
    } catch (error) {
      debugPrint('카카오 로그인 에러: $error');
      await _controller.runJavaScript('window.onKakaoLoginError("$error");');
    }
  }

  Future<void> _handleAppleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 로그인 결과를 웹으로 전송
      final String result = '''
      {
        "identityToken": "${credential.identityToken ?? ''}",
        "authorizationCode": "${credential.authorizationCode}",
        "userIdentifier": "${credential.userIdentifier ?? ''}",
        "givenName": "${credential.givenName ?? ''}",
        "familyName": "${credential.familyName ?? ''}"
      }
      ''';

      await _controller.runJavaScript('window.onAppleLoginResult($result);');
    } catch (error) {
      debugPrint('애플 로그인 에러: $error');
      await _controller.runJavaScript('window.onAppleLoginError("$error");');
    }
  }

  Future<void> _handleFlutterMessages(String message) async {
    try {
      // 메시지 처리 로직 추가
      debugPrint('웹에서 받은 메시지: $message');

      // 필요한 경우 웹으로 응답 전송
      await _controller.runJavaScript('window.onFlutterResponse("메시지 수신 완료");');
    } catch (error) {
      debugPrint('메시지 처리 에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상태 표시줄은 유지하되 앱 바는 사용하지 않음
      extendBodyBehindAppBar: false, // 본문을 앱 바 뒤로 확장하지 않음
      body: SafeArea(
        // SafeArea를 사용하여 상태 표시줄 영역을 제외하고 콘텐츠 표시
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
