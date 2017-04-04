//
//  ViewController.m
//  画香
//
//  Created by 左细平 on 2016/12/1.
//  Copyright © 2016年 Maycici. All rights reserved.
//

#import "ViewController.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AFNetworking/AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GCDAsyncUdpSocket.h"


//[[NSUserDefaults standardUserDefaults] valueForKey:@"SBFormattedPhoneNumber"];


extern NSString* CTSettingCopyMyPhoneNumber();

static NSString *kMusicURL = @"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4B880E697A0E68980E69C89222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696334382E74632E71712E636F6D2F586B30305156342F4141414130414141414E5430577532394D7A59344D7A63774D4C6735586A4C517747335A50676F47443864704151526643473444442F4E653765776B617A733D2F31303130333334372E6D34613F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D30222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31342E71716D757369632E71712E636F6D2F33303130333334372E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E4B880E697A0E68980E69C89222C22736F6E675F4944223A3130333334372C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E5B494E581A5222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D313574414141416A41414141477A4C36445039536A457A525467304E7A38774E446E752B6473483833344843756B5041576B6D48316C4A434E626F4D34394E4E7A754450444A647A7A45304F513D3D2F33303130333334372E6D70333F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D3026616D703B73747265616D5F706F733D35227D";
static NSString *kMusicDataURL = @"http://stream20.qqmusic.qq.com/32464723.mp3";
#define WX_ACCESS_TOKEN @"access_token"
#define WX_OPEN_ID @"openid	"
#define WX_REFRESH_TOKEN @"refresh_token"
#define WX_BASE_URL @"https://api.weixin.qq.com/sns"
#define WXPatient_App_ID @"wx_patient_app_id"

@interface ViewController ()<GCDAsyncUdpSocketDelegate>{
    CTTelephonyNetworkInfo *networkInfo;
}
@property(nonatomic,copy)void (^requestForUserInfoBlock)();
- (IBAction)shareText:(id)sender;
- (IBAction)sharePicture:(id)sender;
- (IBAction)shareMusic:(id)sender;
- (IBAction)wechatLogin:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test];
    
    
}

-(void)test{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@""];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentUrl = [[NSFileManager defaultManager]URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentUrl URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File downloaded to:%@",filePath);
    }];
    [downloadTask resume];
}


-(void)shareText{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.text = @"come on ,show sweet";
    req.bText = YES;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
}



- (IBAction)shareText:(id)sender {
    [self shareText];
}

- (IBAction)sharePicture:(id)sender {
    [self sharePicture];
}

- (IBAction)shareMusic:(id)sender {
    [self shareMusic];
}

- (IBAction)wechatLogin:(id)sender {
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    // 如果已经请求过微信授权登录，那么考虑用已经得到的access_token
    if (accessToken && openID) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_REFRESH_TOKEN];
        NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WX_BASE_URL, WXPatient_App_ID, refreshToken];
        [manager GET:refreshUrlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            //
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"请求reAccess的response = %@", responseObject);
            NSDictionary *refreshDict = [NSDictionary dictionaryWithDictionary:responseObject];
            NSString *reAccessToken = [refreshDict objectForKey:WX_ACCESS_TOKEN];
            // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
            if (reAccessToken) {
                // 更新access_token、refresh_token、open_id
                [[NSUserDefaults standardUserDefaults] setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:[refreshDict objectForKey:WX_OPEN_ID] forKey:WX_OPEN_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[refreshDict objectForKey:WX_REFRESH_TOKEN] forKey:WX_REFRESH_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 当存在reAccessToken不为空时直接执行AppDelegate中的wechatLoginByRequestForUserInfo方法
                !self.requestForUserInfoBlock ? : self.requestForUserInfoBlock();
            }
            else {
                [self thirdWCLogin];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);

        }];
    }else{
        [self thirdWCLogin];
    }
//        [manager GET:refreshUrlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"请求reAccess的response = %@", responseObject);
//            NSDictionary *refreshDict = [NSDictionary dictionaryWithDictionary:responseObject];
//            NSString *reAccessToken = [refreshDict objectForKey:WX_ACCESS_TOKEN];
//            // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
//            if (reAccessToken) {
//                // 更新access_token、refresh_token、open_id
//                [[NSUserDefaults standardUserDefaults] setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
//                [[NSUserDefaults standardUserDefaults] setObject:[refreshDict objectForKey:WX_OPEN_ID] forKey:WX_OPEN_ID];
//                [[NSUserDefaults standardUserDefaults] setObject:[refreshDict objectForKey:WX_REFRESH_TOKEN] forKey:WX_REFRESH_TOKEN];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                // 当存在reAccessToken不为空时直接执行AppDelegate中的wechatLoginByRequestForUserInfo方法
//                !self.requestForUserInfoBlock ? : self.requestForUserInfoBlock();
//            }
//            else {
//                [self wechatLogin];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);
//        }];
//    }
//    else {
//        [self thirdLogin];
//    }
    
    }

-(void)thirdWCLogin{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc]init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    }
    else{
        NSLog(@"请先安装微信客户端");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

-(void)sharePicture{
    NSLog(@"%s",__func__);
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"res1thumb.png"]];
    WXImageObject *imageObject = [WXImageObject object];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"res1" ofType:@"jpg"];
    imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
    
}

-(void)shareMusic{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"张靓颖";
    message.description = @"海豚音";
    [message setThumbImage:[UIImage imageNamed:@"res5thumb"]];
    
    WXMusicObject *object = [WXMusicObject object];
    object.musicUrl = kMusicURL;
    object.musicLowBandUrl = object.musicUrl;
    object.musicDataUrl = kMusicDataURL;
    object.musicLowBandDataUrl =object.musicDataUrl;
    message.mediaObject = object;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
    
    
}

-(NSString *)getMobileNum{
    NSString *number = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    return number;
   }

-(NSString *) getPhoneNumber {
    NSString *phone = CTSettingCopyMyPhoneNumber();
    
    return phone;
}







@end
