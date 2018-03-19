//
//  InfomationViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "SYWebPageCtrl.h"

@interface SYWebPageCtrl ()
@property (nonatomic,copy) NSString *webUrl;
@property (nonatomic,copy) NSString *webTitle;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UIButton *btnReturn;
@property (nonatomic,strong) UILabel *lblTitle;
@end

@implementation SYWebPageCtrl

- (instancetype)initWithUrl:(NSString *)urlStr title:(NSString *)webTitle
{
    if (self = [super init]) {
        self.webUrl = urlStr;
        self.webTitle = webTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    self.btnReturn = btnReturn;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.bounds.size.width - 100, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = self.webTitle;
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 50)];
    NSURL *url = [NSURL URLWithString:self.webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    self.webView = webView;
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    self.btnReturn.frame = CGRectMake(0, 10, 70, 50);
    self.lblTitle.frame = CGRectMake(50, 10, self.view.bounds.size.width - 100, 50);
    self.webView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
