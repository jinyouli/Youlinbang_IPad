//
//  SYFeedbackViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/15.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYFeedbackViewController.h"
#import "SYPersonalSpaceHttpDAO.h"

@interface SYFeedbackViewController ()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *contentTxtView;
@property (nonatomic, strong) UILabel *leftLetters; //还剩多少个字
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIButton *btnReturn;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *routeChangeBtn;
@end

@implementation SYFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"反馈意见";
}


#pragma mark - private
- (void)initUI{
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    //上面的内容
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 60, self.view.width_sd - 20, 120)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    self.contentTxtView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, contentView.width_sd - 20, 90)];
    self.contentTxtView.font = [UIFont systemFontOfSize:14];
    self.contentTxtView.delegate = self;
    [contentView addSubview:self.contentTxtView];
    
    self.leftLetters = [[UILabel alloc] initWithFrame:CGRectMake(contentView.width_sd - 100, self.contentTxtView.bottom_sd, 90, 20)];
    self.leftLetters.font = [UIFont systemFontOfSize:12];
    self.leftLetters.textAlignment = NSTextAlignmentRight;
    
    NSString *leftNumber = [NSString stringWithFormat:@"%u",100 - self.contentTxtView.text.length];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"还剩%@个字", leftNumber]];
    [attStr setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xd23023)} range:NSMakeRange(2, leftNumber.length)];
    self.leftLetters.attributedText = attStr;
    [contentView addSubview:self.leftLetters];
    
    //==========提交按钮=======
    UIButton *routeChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    routeChangeBtn.frame = CGRectMake(self.view.frame.size.width - 65, 10, 60, 50);
    routeChangeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [routeChangeBtn setTitle:@"提交" forState:UIControlStateNormal];
    [routeChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [routeChangeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:routeChangeBtn];
    self.routeChangeBtn = routeChangeBtn;
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    self.btnReturn = btnReturn;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"反馈建议";
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
}

- (void)viewWillLayoutSubviews{
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);

    self.contentView.frame = CGRectMake(10, 60, self.view.width_sd - 20, 120);
    self.contentTxtView.frame = CGRectMake(10, 10, self.contentView.width_sd - 20, 90);
    self.leftLetters.frame = CGRectMake(self.contentView.width_sd - 100, self.contentTxtView.bottom_sd, 90, 20);
    
    //==========提交按钮=======
    self.routeChangeBtn.frame = CGRectMake(self.view.frame.size.width - 65, 10, 60, 50);
    self.btnReturn.frame = CGRectMake(0, 10, 70, 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeFeedBackDrawer"
                                                        object:nil];
}

- (void)backLastVC{
    [FrameManager popViewControllerAnimated:YES];
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    [self.view endEditing:YES];
    
    NSString *strSubmit = [self.contentTxtView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (strSubmit.length == 0) {
        [self showMessageWithContent:@"请输入反馈内容" duration:1];
        return;
    }
    WEAK_SELF;
    SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
    [personalSpaceHttpDAO saveFeedbackWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id WithContent:strSubmit Succeed:^{
        [weakSelf showSuccessWithContent:@"提交成功" duration:1];
        
        [weakSelf performSelector:@selector(ExitSubView) withObject:nil afterDelay:1];
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
    }];
}


#pragma mark - textView delegate
- (void)textViewDidChange:(UITextView *)textView{
    
    //NSString *strMessage = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strMessage = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    NSLog(@"字符串的长度==%zd",strMessage.length);
    if (strMessage.length >= 100) {
        strMessage = [strMessage substringToIndex:100];
        textView.text = strMessage;
    }
    
    NSString *leftNumber = [NSString stringWithFormat:@"%zd",100 - strMessage.length];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"还剩%@个字", leftNumber]];
    [attStr setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xd23023)} range:NSMakeRange(2, leftNumber.length)];
    self.leftLetters.attributedText = attStr;
}


#pragma mark - touchesBegan delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.contentTxtView resignFirstResponder];
}

@end
