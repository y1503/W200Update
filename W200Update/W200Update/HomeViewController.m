//
//  HomeViewController.m
//  W200Update
//
//  Created by 鱼鱼 on 2016/12/20.
//  Copyright © 2016年 鱼鱼. All rights reserved.
//

#import "HomeViewController.h"
#import <Masonry.h>
#import <AFNetworking.h>

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *versionBtn;
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;// 下载文件显示
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;//下载进度条显示

@property (weak, nonatomic) NSURLSessionDownloadTask *downloadTask;// 下载句柄
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLeftBtn];
}

#pragma mark -- 添加右上角图标
- (void)addLeftBtn
{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"resize_music"]];
    [leftView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftView).offset(0);
        make.width.mas_equalTo(@30);
        make.top.mas_equalTo(leftView).offset(0);
        make.bottom.mas_equalTo(leftView).offset(0);
    }];
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    lbl.text = @"W200升级";
    lbl.textColor = [UIColor blackColor];
    lbl.textAlignment = NSTextAlignmentLeft;
    [leftView addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageView.mas_right).offset(5);
        make.width.mas_greaterThanOrEqualTo(@0);
        make.top.mas_equalTo(leftView).offset(0);
        make.bottom.mas_equalTo(leftView).offset(0);
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
}

#pragma mark -- 处理各个按钮点击事件
- (IBAction)clickedBtn:(UIButton *)btn {
    switch (btn.tag) {
        case 101://开始升级
        {
            
        }
            break;
        case 201://查看版本
        {
            
        }
            break;
        case 301://下载升级文件
        {
            [self downFileFromServer];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 下载升级文件
- (void)downFileFromServer
{
    //远程地址
    NSURL *URL = [NSURL URLWithString:@"http://img03.tooopen.com/images/20131102/sy_45238929299.jpg"];
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //下载Task操作
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"已下载：%lli/总共大小：%lli",downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //设置下载完成操作
        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
        
        NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
        UIImage *img = [UIImage imageWithContentsOfFile:imgFilePath];
        self.imageView.image = img;
        
    }];
    
    [_downloadTask resume];
}


@end
