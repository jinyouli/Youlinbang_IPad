//
//  SYTextDescriptionViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYTextDescriptionViewController.h"

@interface SYTextDescriptionViewController ()

@property (nonatomic, assign) DescriptionType type;
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation SYTextDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:16.0];
    lab.textAlignment = NSTextAlignmentCenter;
    
    if (self.type == functionType) {
        lab.text = @"友邻邦功能介绍";
    }else if (self.type == itemType){
        lab.text = @"友邻邦使用条款和隐私政策";
    }
    self.navigationItem.titleView = lab;
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithType:(DescriptionType)type{
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)initUI{
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    UIScrollView *bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 60, self.view.width - 20, self.view.height - 70)];
    bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    bgScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgScrollView];
 
    NSString *str = nil;
    if (self.type == functionType) {
        str = @"1.一键开锁\n在APP主页下方，门锁列表中，选择对应的门锁，滑动解锁。\n\n2.设置子账号\n通过设置子账号，为家人或租客绑定房产，门口机呼入时，所有在线的子账号手机会同时振铃，一人接听其他人手机会停止振铃。（必须是业主才能设置子账号）\n设置方法：【我的】→【房产管理】，点击需要设置的房产，点击【添加子账号】输入需要添加的手机号码（该号码必须已经注册app账号），录入别名，点击【完成】按钮，完成添加子账号。\n\n3.电话开锁\n当用户APP不在线时，门口机呼叫直接呼叫住户预设的手机号码上，住户接听来电后，可以按手机键盘上的“#”，为来访者远程开锁。\n\n4.视频监视 \n在APP主页下方，门锁列表中，选择对应的门锁，点击视频监控按钮，可以通过门口机上的摄像头监视单元门周围环境情况，单次监视时长30秒。\n\n5.物业服务\n物业服务包括咨询、投诉、报事、建议以及物业报修和工单管理等功能。\n\n6.社区公告\n实时接收最新的物业通知，系统公告，随时查阅通知，公告记录。";
    }else if (self.type == itemType){
        str = @"        请务必认真阅读和理解本《用户服务协议》（以下简称《协议》）中规定的所有权利和限制。除非您接受本《协议》条款，否则您无权注册、登录或使用本协议所涉及的相关服务。您一旦注册、登录、使用或以任何方式使用本《协议》所涉及的相关服务的行为将视为对本《协议》的接受，即表示您同意接受本《协议》各项条款的约束。如果您不同意本《协议》中的条款，请不要注册、登录或使用本《协议》相关服务。 本《协议》是用户与赛翼云社区之间的法律协议。\n1. 服务内容\n1.1赛翼云社区是基于物联网和移动互联网技术与智慧社区应用相结合的云社区管理平台。主要内容包括云视频对讲、远程控制、社区服务等功能服务。\n1.2 您一旦注册成功成为用户，您将得到一个密码和帐号，您需要对自己在帐户中的所有活动和事件负全责。如果由于您的过失导致您的帐号和密码脱离您的控制，则由此导致的针对您、或任何第三方造成的损害，您将承担全部责任。\n1.3 用户理解并接受，赛翼云社区仅提供相关的云社区服务，除此之外与相关云社区服务有关的设备（如个人平板电脑、手机、及其他与接入互联网或移动互联网有关的装置）及所需的费用（如为接入互联网而支付的电话费及上网费、为使用移动网而支付的手机费）均应由用户自行负担。\n2. 用户使用规则\n2.1 用户在申请使用赛翼云社区服务时，必须向赛翼云社区提供准确的个人资料，如个人资料有任何变动，必须及时更新。因用户提供个人资料不准确、不真实而引发的一切后果由用户承担。\n2.2 用户应妥善保存帐号、密码，避免以任何脱离用户控制的形式交由他人使用。如用户发现其帐号遭他人非法使用，应立即通知赛翼云社区。因黑客行为或用户的保管疏忽导致帐号、密码遭他人非法使用，赛翼云社区不承担任何责任。\n2.3 用户应当为自身注册帐户下的一切行为负责，因用户行为而导致的用户自身或其他任何第三方的任何损失或损害，赛翼云社区不承担责任。\n2.4 用户理解并接受赛翼云社区提供的服务中可能包括增值服务、广告，用户同意在使用过程中显示赛翼云社区和第三方供应商、合作伙伴提供的广告。\n2.5 用户在使用赛翼云社区网络服务过程中，必须遵循以下原则：\n2.5.1 遵守中国有关的法律和法规；\n2.5.2 遵守所有与云社区服务有关的网络协议、规定和程序；\n2.5.3 不得为任何非法目的而使用云社区服务系统；\n2.5.4 不得利用赛翼云社区服务系统进行任何可能对互联网或移动网正常运转造成不利影响的行为；\n2.5.5 不得利用赛翼云社区提供的网络服务上传、展示或传播任何虚假的、骚扰性的、中伤他人的、辱骂性的、恐吓性的、庸俗淫秽的或其他任何非法的信息资料；\n2.5.6 不得侵犯赛翼云社区和其他任何第三方的专利权、著作权、商标权、名誉权或其他任何合法权益；\n2.5.7 不得利用赛翼云社区服务系统进行任何不利于赛翼云社区的行为；\n2.5.8 如发现任何非法使用用户帐号或帐号出现安全漏洞的情况，应立即通告赛翼云社区。\n2.6 如用户在使用网络服务时违反任何上述规定，赛翼云社区或其授权的人有权要求用户改正或直接采取一切必要的措施（包括但不限于更改或删除用户收藏的内容等、暂停或终止用户使用网络服务的权利）以减轻用户不当行为造成的影响。\n3. 服务变更、中断或终止\n3.1 鉴于网络服务的特殊性，用户同意赛翼云社区有权根据业务发展情况随时变更、中断或终止部分或全部的网络服务而无需通知用户，也无需对任何用户或任何第三方承担任何责任；\n3.2 用户理解，赛翼云社区需要定期或不定期地对提供网络服务的平台（如社区云平台网站等）或相关的设备进行检修或者维护，如因此类情况而造成网络服务在合理时间内的中断，赛翼云社区无需为此承担任何责任，但赛翼云社区应尽可能事先进行通告。\n3.3 如发生下列任何一种情形，赛翼云社区有权随时中断或终止向用户提供本《协议》项下的网络服务（包括收费网络服务）而无需对用户或任何第三方承担任何责任：\n3.3.1 用户提供的个人资料不真实；\n3.3.2 用户违反本《协议》中规定的使用规则。\n4. 知识产权\n4.1 提供的网络服务中包含的任何文本、图片、图形、音频和/或视频资料均受版权、商标和/或其它财产所有权法律的保护，未经相关权利人同意，上述资料均不得用于任何商业目的。\n5. 隐私保护\n5.1 保护用户隐私是赛翼云社区的一项基本政策，赛翼云社区保证不对外公开或向第三方提供单个用户的注册资料及用户在使用网络服务时存储在赛翼云社区的非公开内容，但下列情况除外：\n5.1.1 事先获得用户的明确授权；\n5.1.2 根据有关的法律法规要求；\n5.1.3 按照相关政府主管部门的要求；\n5.1.4 为维护社会公众的利益；\n5.1.5 为维护赛翼云社区的合法权益。\n5.2 赛翼云社区可能会与第三方合作向用户提供相关的网络服务，在此情况下，如该第三方同意承担与赛翼云社区同等的保护用户隐私的责任，则赛翼云社区有权将用户的注册资料等提供给该第三方。\n5.3 在不透露单个用户隐私资料的前提下，赛翼云社区有权对整个用户数据库进行分析并对用户数据库进行商业上的利用。\n5.4 赛翼云社区制定了以下四项隐私权保护原则，指导我们如何来处理产品中涉及到用户隐私权和用户信息等方面的问题：\n（1） 利用我们收集的信息为用户提供有价值的产品和服务。\n（2） 开发符合隐私权标准和隐私权惯例的产品。\n（3） 将个人信息的收集透明化，并由权威第三方监督。\n（4） 尽最大的努力保护我们掌握的信息。\n6. 免责声明\n6.1 赛翼云社区不担保网络服务一定能满足用户的要求，也不担保网络服务不会中断，对网络服务的及时性、安全性、准确性也都不作担保。\n6.2 赛翼云社区不保证为向用户提供便利而设置的外部链接的准确性和完整性，同时，对于该等外部链接指向的不由赛翼云实际控制的任何网页上的内容，赛翼云社区不承担任何责任。\n6.3 对于因电信系统或互联网网络故障、计算机故障或病毒、信息损坏或丢失、计算机系统问题或其它任何不可抗力原因而产生损失，赛翼云社区不承担任何责任，但将尽力减少因此而给用户造成的损失和影响。\n7. 附则\n7.1 本协议的订立、执行和解释及争议的解决均应适用中华人民共和国法律。\n7.2 如果本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，或违反任何适用的法律，则该条款被视为删除，但本协议的其余条款仍应有效并且有约束力。\n7.3 赛翼云社区有权随时根据有关法律、法规的变化以及公司经营状况和经营策略的调整等修改本协议，而无需另行单独通知用户。用户可随时通过网站浏览最新服务协议条款。当发生有关争议时，以最新的协议文本为准。如果不同意赛翼云社区对本协议相关条款所做的修改，用户有权停止使用网络服务。如果用户继续使用网络服务，则视为用户接受赛翼云社区对本协议相关条款所做的修改。\n7.4 本协议解释权及修订权归广东赛翼智能科技股份有限公司所有。";
    }
    
    UIFont *font = [UIFont systemFontOfSize:12.0];
    CGSize size = [str sizeWithFont:font andSize:CGSizeMake(bgScrollView.width - 20, MAXFLOAT)];
    UILabel *appVersionLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, size.width, size.height)];
    appVersionLab.textColor = UIColorFromRGB(0x999999);
    appVersionLab.font = font;
    appVersionLab.text = str;
    appVersionLab.numberOfLines = 0;
    [bgScrollView addSubview:appVersionLab];
    
    bgScrollView.contentSize = CGSizeMake(size.width, size.height + 20);
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 100, 10, 200, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle = lblTitle;
    if (self.type == functionType) {
        lblTitle.text = @"友邻邦功能介绍";
    }else if (self.type == itemType){
        lblTitle.text = @"用户服务协议";
    }
    [self.view addSubview:lblTitle];
}

- (void)viewWillLayoutSubviews{
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeFeedBackDrawer"
                                                        object:nil];
}

@end
