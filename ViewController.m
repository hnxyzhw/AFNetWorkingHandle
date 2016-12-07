//
//  ViewController.m
//  AFNetWorkingHandle
//
//  Created by andson-zhw on 16/12/7.
//  Copyright © 2016年 andson. All rights reserved.
//

#import "ViewController.h"
#import "DES.h"
#import "SBJsonParser.h"
#import "TBXML.h"
#import "ZHWResuestURLSessionDataTask.h"


#define kCompleteCallback @"completeCallback"
#define kFailureCallback @"failureCallback"
#define USER_INFO_KEY_TYPE          @"requestType"

@interface ViewController ()
@property(nonatomic,strong)UIButton *testbtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.testbtn = [[UIButton alloc]init];
    self.testbtn.frame = CGRectMake(40, 40, 50, 50);
    self.testbtn.backgroundColor = [UIColor orangeColor];
    
    [self.testbtn setTitle:@"点击" forState:UIControlStateNormal];
    [self.testbtn setTitle:@"松开" forState:UIControlStateHighlighted];
    //处理按钮点击事件
    [self.testbtn addTarget:self action:@selector(setpostReuqust)forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:self.testbtn];
    
}


-(void)setpostReuqust{
    [self doLoginRequestBy:@"" andPwd:@"" callback:^(id record) {
        NSLog(@"-----callback %@",record);
    } failureCallback:^(NSString *resp) {
        
    }];
}


- (void)doLoginRequestBy:(NSString*)userName andPwd:(NSString*)pwd
                callback:(void (^)(id record))callback
         failureCallback:(void (^)(NSString *resp))failureCallback {
 
    NSString *urlString = [NSString stringWithFormat:@"%@/api/loan/mobile/login.json",SERVER_URL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:server_agent forHTTPHeaderField:@"User-Agent"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //    params = @{@"loginName":@"18515873141",@"loginPwd":@"zhw611/",@"sts_identify":sts_identify,@"version":APP_version,@"login_name_type":@"0"}.mutableCopy;
    params = [NSMutableDictionary dictionaryWithDictionary:[self DESHandle]].mutableCopy;
    ZHWResuestURLSessionDataTask *reuqestTask = [[ZHWResuestURLSessionDataTask alloc]init];
    
    NSArray *objects = @[[callback copy], [failureCallback copy]];
    NSArray *keys = @[kCompleteCallback, kFailureCallback];
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
    [requestInfo addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:2],USER_INFO_KEY_TYPE, nil]];
    [reuqestTask setUserInfo:requestInfo];
    
    reuqestTask = (ZHWResuestURLSessionDataTask *)[manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSLog(@"The return class is subclass %@",NSStringFromClass([NSHTTPURLResponse class]));
            //            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            //            NSDictionary *allHeaders = response.allHeaderFields;
            //            NSLog(@"---responHeadder: %@",allHeaders);
            [self requestFinshed:task responseObject:responseObject withRequestTask:reuqestTask];
        }else{
            NSLog(@"The return class is not subclass %@",NSStringFromClass([NSHTTPURLResponse class]));
        }
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",jsonDic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

    
    
    

   
}


-(NSDictionary *)DESHandle{
    NSString *loginName = [DES encryptUseDES:@"18515873141"];
    NSString *loginPwd = [DES encryptUseDES:@"zhw611/"];
    NSString *sts_iden = [DES encryptUseDES:sts_identify];
    NSString *version = [DES encryptUseDES:APP_version];
    NSString *login_name_type = [DES encryptUseDES:@"0"];
    NSDictionary *dic = @{@"loginName":loginName,@"loginPwd":loginPwd,@"sts_identify":sts_iden,@"version":version,@"login_name_type":login_name_type};
    return dic;
}


-(void)requestFinshed:(NSURLSessionDataTask * _Nonnull)task responseObject:(id _Nullable) responseObject withRequestTask:(ZHWResuestURLSessionDataTask *)reuqestTask{
     NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSDictionary *respinfo = response.allHeaderFields;
    NSString *contentType = [respinfo objectForKey:@"Content-Type"];
    
    if([contentType hasPrefix:@"text/html"] ||
       [contentType hasPrefix:@"text/javascript"] ||
       [contentType hasPrefix:@"application/json;charset=UTF-8"])  { // txt
        
        NSString * responseString = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id returnObject = [parser objectWithString:responseString];
        
        NSMutableDictionary *packedData = [[NSMutableDictionary alloc]init];
        if ([returnObject isKindOfClass:[NSDictionary class]]) {
            [packedData setValue:(NSDictionary*)returnObject forKey:@"packedData"];
        } else if ([returnObject isKindOfClass:[NSArray class]]) {
            [packedData setValue:(NSArray*)returnObject forKey:@"packedData"];
        }
        else {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:responseString,@"respvalue",@"0",@"status",nil];
            [packedData setValue:dict forKey:@"packedData"];
        }
        
        [packedData addEntriesFromDictionary:[reuqestTask userInfo]];
        [reuqestTask setUserInfo:packedData];
        NSLog(@"---%@",packedData);
        
    } else if ([contentType hasPrefix:@"text/xml"]){ // xml
//        NSString * responseString = [request responseString];
//        NSString *jsonBody;
//        
//        NSError *error;
//        TBXML * tbxml = [TBXML newTBXMLWithXMLString:responseString error:&error];
//        jsonBody = [TBXML textForElement:tbxml.rootXMLElement];
//        [tbxml release];
//        
//        responseString = jsonBody;
//        
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        id returnObject = [parser objectWithString:responseString];
//        
//        [parser release];
//        if ([returnObject isKindOfClass:[NSDictionary class]]) {
//            NSString *errorString = [returnObject  objectForKey:@"error"];
//            if (errorString != nil && ([errorString isEqualToString:@"auth faild!"] ||
//                                       [errorString isEqualToString:@"expired_token"] ||
//                                       [errorString isEqualToString:@"invalid_access_token"])) {
//                NSLog(@"-------------------------detected auth faild!");
//            }
//        }
//        
//        NSMutableDictionary *packedData = [[NSMutableDictionary alloc]init];
//        if ([returnObject isKindOfClass:[NSDictionary class]]) {
//            [packedData setValue:(NSDictionary*)returnObject forKey:@"packedData"];
//        } else if ([returnObject isKindOfClass:[NSArray class]]) {
//            [packedData setValue:(NSArray*)returnObject forKey:@"packedData"];
//        }
//        else {
//            return;
//        }
//        
//        [packedData addEntriesFromDictionary:[request userInfo]];
//        [request setUserInfo:packedData];
    }
    
    NSDictionary *requestDictionary = [reuqestTask userInfo];
    NSDictionary *packData = [requestDictionary objectForKey:@"packedData"];
    if ([[requestDictionary objectForKey:USER_INFO_KEY_TYPE]floatValue] == 2) {
        id callback  = [requestDictionary objectForKey:kCompleteCallback];
        //HWLog(@"result :%@",packData);
        //KA360Account *account = [[KA360Account alloc]initWithJsonDictionary:packData];
        //((void(^)(id))callback)(account);
        ((void(^)(id))callback)(packData);
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
