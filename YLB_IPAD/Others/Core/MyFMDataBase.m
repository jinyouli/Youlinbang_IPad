//
//  MyFMDataBase.m
//  FMDataBaseDemo
//
//  Created by 黄嘉宏 on 15/9/6.
//  Copyright (c) 2015年 黄嘉宏. All rights reserved.
//

#import "MyFMDataBase.h"

@interface MyFMDataBase ()

//全局声明数据库dataBase
@property(nonatomic,strong)FMDatabase *dataBase;

@end

@implementation MyFMDataBase

+(MyFMDataBase *)shareMyFMDataBase{
    static MyFMDataBase * _manager;
    if (_manager == nil) {
        _manager = [[MyFMDataBase alloc]init];
    }
    
    if ([_manager createDataBaseWithDataBaseName:myUsername]){
        
    }
    
    return _manager;
}

#pragma mark - 创建一个数据库
-(BOOL)createDataBaseWithDataBaseName:(NSString *)dbName{
    @synchronized(self) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.sqlite",NSHomeDirectory(),dbName];
        
        if ([fileManager fileExistsAtPath:filePath]) {
            self.dataBase = [FMDatabase databaseWithPath:filePath];
        }else{
            self.dataBase = [[FMDatabase alloc]initWithPath:filePath];
        }
        
        //把数据库打开
        if (self.dataBase.open) {
            //SYLog(@"自己建立的数据库打开成功  路径：%@",filePath);
            return YES;
        }
        else{
            //SYLog(@"自己建立的数据库打开失败  路径：%@",filePath);
            return NO;
        }
        
    }
}

#pragma mark - 创建一个表单
-(void)createTableWithTableName:(NSString *)tableName tableArray:(NSArray *)tableArray{

    NSString *scutureString = @"";
    
    for (NSString *stringKey in tableArray) {
        scutureString = [NSString stringWithFormat:@"%@%@ varchar(64),",scutureString,stringKey];
    }
    
    NSString *scutureString2 = [scutureString substringToIndex:scutureString.length - 1];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id integer PRIMARY KEY AUTOINCREMENT,%@)",tableName,scutureString2];
    
    
    NSLog(@"创建表单语句 === %@",sql);
    
    //通过dataBase使用sql语句
    @synchronized(self) {
       BOOL isCreate = [self.dataBase executeUpdate:sql];
        if (isCreate) {
            NSLog(@"创建表单成功  表单名称 %@",tableName);
        }
        else{
            NSLog(@"创建表单失败  表单名称 %@",tableName);
        }
    }
}

#pragma mark - insert插入数据
-(void)insertDataWithTableName:(NSString *)tableName insertDictionary:(NSDictionary *)insertDictionary{

    NSString *scutureString = @"";
    
    for (NSString *keyString in insertDictionary.allKeys) {
        scutureString = [NSString stringWithFormat:@"%@,%@",scutureString,keyString];
    }
    NSString *scutureString2 = [scutureString substringFromIndex:1];
    
    //值字符串
    //字段名字符串
    NSString *valueString = @"";
    
    for (NSString *keyString in insertDictionary.allKeys) {
        valueString = [NSString stringWithFormat:@"%@,'%@'",valueString,insertDictionary[keyString]];
    }
    NSString *valueString2 = [valueString substringFromIndex:1];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)",tableName,scutureString2,valueString2];
    
    //SYLog(@"插入语句 ===   %@",sql);
    
    BOOL isInsert = [self.dataBase executeUpdate:sql];
    
    if (isInsert) {
        //SYLog(@"插入sql数据成功");
    }
    else{
        //SYLog(@"插入sql数据失败");
    }
}

#pragma mark - 修改表单中的数据
-(void)updateDataWithTableName:(NSString *)tableName updateDictionary:(NSDictionary *)updateArray whereArray:(NSDictionary *)whereArray{
    
    //拼接需要改变的字段名
    NSString *setString = @"";
    int i = 0;
    for (NSString *keyString in updateArray.allKeys) {
        setString = [NSString stringWithFormat:@"%@ = '%@',",keyString,updateArray[updateArray.allKeys[i]]];
        i++;
    }
    NSString *setString2 = [setString substringToIndex:setString.length - 1];
    
    //拼接条件字段名
    NSString *whereString = @"";
    int j = 0;
    for (NSString *keyString in whereArray.allKeys) {
        whereString = [NSString stringWithFormat:@"%@ = '%@',",keyString,whereArray[whereArray.allKeys[j]]];
        j++;
    }
    NSString *whereString2 = [whereString substringToIndex:whereString.length - 1];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,setString2,whereString2];
    
//    SYLog(@"修改表达内容语句 === %@",sql);
    
    //修改某个数据
    @synchronized(self) {

    BOOL isUpdate = [self.dataBase executeUpdate:sql];
    
        if (isUpdate) {
            NSLog(@"修改数据成功");
        }
        else{
            NSLog(@"修改数据失败");
        }

    }
}

#pragma mark - deleteData删除操作
-(void)deleteDataWithTableName:(NSString *)tableName delegeteDic:(NSDictionary *)delegeteDic{

    NSString *sql = @"";
    
    if (!delegeteDic) {
        sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    }
    else{
        NSString *whereString = @"";
        int j = 0;
        for (NSString *keyString in delegeteDic.allKeys) {
            whereString = [whereString stringByAppendingFormat:@"%@ = '%@' and ",keyString,delegeteDic[delegeteDic.allKeys[j]]];
            j++;
            NSLog(@"wherestr  ==  %@",whereString);
        }
        NSString *whereString2 = [whereString substringToIndex:whereString.length - 4];
        
        sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,whereString2];
    }
    
    
    NSLog(@"删除表单内容语句 === %@",sql);
    
    @synchronized(self) {
        BOOL isDelete = [self.dataBase executeUpdate:sql];
        
        if (isDelete) {
            NSLog(@"删除该数据成功");
        }
        else{
            NSLog(@"删除该数据失败");
        }
        
    }
}

#pragma mark - 查询数据表中的数据 筛选条件
-(NSArray *)selectDataWithTableName:(NSString *)tableName withDic:(NSDictionary *)selecDic{
    //sql的查询语句
    //拼接条件字段名
    NSString *whereString = @"";
    NSString *whereString2 = @"";
    if (selecDic) {
        
        for (NSString * keyString in selecDic.allKeys) {
            whereString = [NSString stringWithFormat:@"%@%@ = '%@' and ",whereString,keyString,selecDic[keyString]];
            
        }
        whereString2 = [whereString substringToIndex:whereString.length - 4];
    }
    
//    SYLog(@"whereString2 ==== %@",whereString2);
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ",tableName,whereString2];
    
    if (!selecDic || selecDic.count == 0) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    }
    
    NSLog(@"选择内容语句 === %@",sql);
    @synchronized(self) {
    NSMutableArray * mArr = [NSMutableArray array];
    FMResultSet *result = [self.dataBase executeQuery:sql];

    while ([result next]) {
        if ([tableName isEqualToString:@"sipModel"]) {
            SYUserInfoModel *model = [[SYUserInfoModel alloc] init];
            model.user_sip = [result stringForColumn:@"user_sip"];
            model.user_password = [result stringForColumn:@"user_password"];
            model.username = [result stringForColumn:@"username"];
            model.fs_ip = [result stringForColumn:@"fs_ip"];
            model.fs_port = [result stringForColumn:@"fs_port"];
            model.transport = [result stringForColumn:@"transport"];
            [mArr addObject:model];
        }
        
        else if ([tableName isEqualToString:@"AdvertModel"]) {
            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
            [mdic setObject:[result stringForColumn:@"fredirecturl"] forKey:@"fredirecturl"];
            [mdic setObject:[result stringForColumn:@"img_path"] forKey:@"img_path"];
            [mArr addObject:mdic];
        }
        else if ([tableName isEqualToString:@"RecommandTable"]) {
            
            SYRecommendModel *model = [[SYRecommendModel alloc] init];
            model.ftitle = [result stringForColumn:@"ftitle"];
            model.fpictureurl = [result stringForColumn:@"fpictureurl"];
            model.fcreatetime = [result stringForColumn:@"fcreatetime"];
            model.fnewsurl = [result stringForColumn:@"fnewsurl"];
            model.fcontent = [result stringForColumn:@"fcontent"];
            model.type = [result stringForColumn:@"type"];
            [mArr addObject:model];
        }
    }
    
    return mArr;
    }
}

#pragma mark - 关闭数据库
-(void)closeDataBase{
    //关闭数据库
    @synchronized(self) {
        
        BOOL isClose = [self.dataBase close];
        
        if (isClose) {
            NSLog(@"关闭数据库成功");
        }
        else{
            NSLog(@"关闭数据库失败");
        }
    }
}


@end
