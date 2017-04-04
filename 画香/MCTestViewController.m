//
//  MCTestViewController.m
//  画香
//
//  Created by 左细平 on 2017/2/17.
//  Copyright © 2017年 Maycici. All rights reserved.
//

#import "MCTestViewController.h"
#import <Messages/Messages.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@interface MCTestViewController ()<NSCopying,NSSecureCoding>
- (IBAction)createMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
- (IBAction)didPress:(id)sender;
- (IBAction)sinaweiboShare:(UIButton *)sender;
- (IBAction)facebookShare:(id)sender;
- (IBAction)twitterShare:(id)sender;

@end

@implementation MCTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)shareByWay:(NSString *)way description:(NSString*)text image:(NSString *)imageName{
    NSLog(@"-----test code----");
    if ([way length]<= 0 || [text length]<=0 || [imageName length]<=0) {
        NSLog(@"Invalid argument!");
        return;
    }
    if ([SLComposeViewController isAvailableForServiceType:way]) {
        SLComposeViewController *facebook = [SLComposeViewController composeViewControllerForServiceType:way];
                [facebook setInitialText:text];
        [facebook addImage:[UIImage imageNamed:imageName]];
        [self presentViewController:facebook animated:YES completion:nil];
        [facebook setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                default:
                    break;
            }
        }];
    }else{
        NSLog(@"---Not support this way ---");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sharingStatus) name:ACAccountStoreDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ACAccountStoreDidChangeNotification object:nil];
}

-(void)sharingStatus{
    NSLog(@"---sharing status---");
    
}
- (IBAction)createMessage:(id)sender {
    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
//    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"test"];
//    [self presentViewController:viewController animated:YES completion:nil];
}

-(UIImage *)createImageForMessage{
    UIView *background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];

    background.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 75, 150, 150)];
    label.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    label.text = [NSString stringWithFormat:@"%d",self.stepper.value];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = label.frame.size.width/2;
    label.clipsToBounds = YES;
      [background addSubview:label];
    
    [self.view addSubview:background];
  
    
    UIGraphicsBeginImageContextWithOptions(background.frame.size, NO, [UIScreen mainScreen].scale);
    [background drawViewHierarchyInRect:background.frame afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    [background removeFromSuperview];
    return image;

}
- (IBAction)didPress:(id)sender {
    NSLog(@"Press");
    UIImage *image = [self createImageForMessage];
    MSConversation *conversation = [[MSConversation alloc]init];
    MSMessageTemplateLayout *layout = [[MSMessageTemplateLayout alloc]init];
    layout.image = image;
    layout.caption = @"Stepper Value";
    MSMessage *msg = [[MSMessage alloc]init];
    msg.layout = layout;
    msg.URL = [NSURL URLWithString:@"https://www.baidu.com"];
    [conversation insertMessage:msg completionHandler:^(NSError * _Nullable error) {
        NSLog(@"error ->%@",error.localizedDescription);
    }];
}

- (IBAction)sinaweiboShare:(UIButton *)sender {
    [self shareByWay:SLServiceTypeSinaWeibo description:@"这是我今天发的第一篇微博" image:@"luxing"];
    }

- (IBAction)facebookShare:(id)sender {
    [self shareByWay:SLServiceTypeFacebook description:@"这是我今天发的第一篇微博" image:@"luxing"];

}

- (IBAction)twitterShare:(id)sender {
    [self shareByWay:SLServiceTypeTwitter description:@"这是我今天发的第一篇微博" image:@"luxing"];

}
@end
