//
//  SYWKWebViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYWKWebViewController.h"
#import <WebKit/WebKit.h>
@interface SYWKWebViewController ()<WKNavigationDelegate>
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) NSString *titleStr;
@end

@implementation SYWKWebViewController

- (instancetype)initWithURL:(NSString *)url{
    if (self = [super init]) {
        self.urlStr = url;
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url Title:(NSString *)title{
    if (self = [super init]) {
        self.urlStr = url;
        self.titleStr = title;
    }
    return self;
}

- (NSString *)backBtnTitle{
    return self.titleStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    
    if (self.urlStr) {
        if (![self.urlStr hasPrefix:@"http"]) {
            self.urlStr = [NSString stringWithFormat:@"https://%@",self.urlStr];
        }
        NSLog(@"连接==%@",self.urlStr);
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    }
}

//#pragma mark - overwrite
//- (NSString *)backBtnTitle{
//    return @"社区头条";
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{

}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    NSString *js = @"document.getElementsByTagName('img')[0].style.width = '100%';";
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {

    }];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [self showErrorWithContent:@"加载失败，请检查网络" duration:1];
}
@end
