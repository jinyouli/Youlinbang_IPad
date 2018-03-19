//
//  SYPropertyRepairModel.h
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 工单评论
@interface SYRepairOrderCommentModel : NSObject

@property (nonatomic,copy) NSString *fcontent ;
@property (nonatomic,copy) NSString *fcreatetime; // "2017-04-03 09:53:57";
@property (nonatomic,assign) int ftype;
@property (nonatomic,copy) NSString *commentID;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *record_new_name;
@property (nonatomic,copy) NSString *old_name;
@property (nonatomic,strong) NSArray *record_imag_list; //SYRepairsImagListModel

//=======自己添加的 json没有返回的字段，为了显示评论高度=======
@property (nonatomic,assign) float repairOrderCommentHeight;    //每个评论高度（不包含评论图片）
@property (nonatomic,assign) float repairOrderCommentImgHeight;    //每个评论图片高度（不包含评论内容高度）
@end

#pragma mark - 工单
@interface SYRepairsImagListModel : NSObject
@property (nonatomic,copy) NSString *fimagpath;
@end

@interface SYPropertyRepairModel : NSObject

@property (nonatomic,copy) NSString *deal_worker_id;    //
@property (nonatomic,copy) NSString *faddress;    //峻峰华亭一栋一单元1001";
@property (nonatomic,copy) NSString *fcreatetime;    //03-14 17:42";
@property (nonatomic,copy) NSString *fheadurl;    //;
@property (nonatomic,copy) NSString *fordernum; // 1489484546050;
@property (nonatomic,assign) int fremindercount;    // 0;
@property (nonatomic,assign) int fscore;
@property (nonatomic,copy) NSString *fservicecontent;    // Rrfff;
@property (nonatomic,assign) int fstatus;    // 1;
@property (nonatomic,copy) NSString *fworkername;
@property (nonatomic,assign) int record_num;
@property (nonatomic,copy) NSString *repair_id;    //ae0ace594e81432b9fdeb9fd75209948;
@property (nonatomic,strong) NSArray *repairs_imag_list;    //SYRepairsImagListModel


//=======自己添加的 ，为了显示评论=======
@property (nonatomic,strong) NSArray *repairOrderCommentModelArr;   //SYRepairOrderCommentModel
@property (nonatomic,assign) float propertyRepairCellHeight;    //工单高度（整个cell但不包含评论）
@property (nonatomic,assign) float repairOrderCommentHeight;    //所有评论总高度（不包含工单，但包含评论图片）
@property (nonatomic,assign) BOOL isExtensioned;   //是否展开

@property (nonatomic,assign) float fservicecontentHeight;//工单内容高度
@end


