//
//  DetailViewController.m
//  LinkedME_DEMO
//
//  Created by LinkedME04 on 6/7/16.
//  Copyright © 2016 Bindx. All rights reserved.
//

#import "DetailViewController.h"
#import <LinkedME_iOS/LinkedME.h>
#import <LinkedME_iOS/LMUniversalObject.h>
#import <LinkedME_iOS/LMLinkProperties.h>
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"


static NSString * const H5_TEST_URL = @"http://192.168.10.101:8888/h5/summary?linkedme=";
static NSString * LINKEDME_SHORT_URL;

@interface DetailViewController ()<UMSocialUIDelegate>

@property (strong, nonatomic) LMUniversalObject *linkedUniversalObject;

@end

@implementation DetailViewController{
    BOOL deepLinking;
    NSInteger page;
    NSString *title;
    NSArray *arr;
    NSString * H5_LIVE_URL;
}

@synthesize deepLinkingCompletionDelegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initMoreButton];
    [self addPara];
}

- (void)configureControlWithData:(NSDictionary *)data{
    deepLinking = YES;
    _openUrl = [data objectForKey:@"tag"];
}


- (void)initData{
    NSString *Plist=[[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"plist"];
    arr = [[NSArray alloc]initWithContentsOfFile:Plist];
    if (!deepLinking) {
        _openUrl = arr[page][@"url"];
    }
    [self loadString:_openUrl];
    title = arr[page][@"key"];
}

- (void)setPage:(NSUInteger)index{
    page = index;
}

//初始化更多按钮
-(void)initMoreButton{
    UIButton *sharBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-50, 20, 40, 40)];
    [sharBtn setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    [sharBtn addTarget:self action:@selector(umShare) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *rightBraBttonItem = [[UIBarButtonItem alloc]initWithCustomView:sharBtn];
    self.navigationItem.rightBarButtonItem = rightBraBttonItem;
}

//友盟分享
- (void)umShare{
    NSString *summary = [[NSString alloc] initWithFormat:@"%@",arr[page][@"info"]];
    if (LINKEDME_SHORT_URL.length != 0) {
        //初始化社会化分享
        
        
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"560fce13e0f55a730c003844"
                                          shareText:summary
                                         shareImage:[UIImage imageNamed:@"share_logo.png"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToSms,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToEmail, nil]
                                           delegate:self];
        
    }
}

//友盟分享回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess){
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

//创建短链
-(void)addPara{
    self.linkedUniversalObject = [[LMUniversalObject alloc] initWithCanonicalIdentifier:@"item/12345"];
    self.linkedUniversalObject.title = title;
    self.linkedUniversalObject.contentDescription = @"My Content Description";
    self.linkedUniversalObject.imageUrl = @"https://s3-us-west-1.amazonaws.com/branchhost/mosaic_og.png";
    [self.linkedUniversalObject addMetadataKey:@"custom_key1" value:@"some custom data"];
    [self.linkedUniversalObject addMetadataKey:@"custom_key2" value:@"more custom data"];
    
    LMLinkProperties *linkProperties = [[LMLinkProperties alloc] init];
    linkProperties.channel = @"Wechat";
    linkProperties.tags=@[@"LinkedME",@"test"];
    linkProperties.alias = title;
    linkProperties.stage = @"test";
    linkProperties.source = @"iOS";
    [linkProperties addControlParam:@"$desktop_url" withValue:@"https://www.linkedme.cc"];
    [linkProperties addControlParam:@"$ios_url" withValue:@"https://www.linkedme.cc"];
    [linkProperties addControlParam:@"ViewId" withValue:arr[page][@"url"]];
    [linkProperties setAndroidPathControlParam:@"*"];
    [linkProperties setIOSKeyControlParam:@"*"];
    
    [self.linkedUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *err) {
        if (url) {
            NSLog(@"[LinkedME Info] SDK creates the url is:%@", url);
            //
            [H5_LIVE_URL stringByAppendingString:arr[page][@"form"]];
            [H5_LIVE_URL stringByAppendingString:@"?linkedme="];
            
            H5_LIVE_URL = [NSString stringWithFormat:@"https://www.linkedme.cc/h5/%@?linkedme=",arr[page][@"form"]];
            LINKEDME_SHORT_URL = [H5_LIVE_URL stringByAppendingString:url];
            
            [UMSocialWechatHandler setWXAppId:@"wxf3393dbc9b09f701" appSecret:@"b1fdeeb043a7684863fac222841f8fda" url:LINKEDME_SHORT_URL];
        } else {
            LINKEDME_SHORT_URL = H5_LIVE_URL;
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadString:(NSString *)str{
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
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
