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


@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *versionBtn;
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;// 下载文件显示
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;//下载进度条显示
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (nonatomic, strong) NSArray *fileNames;
@property (nonatomic, strong) NSDictionary *currentDict;
@property (nonatomic,strong) NSString *updateFilePath;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLeftBtn];
    
    //网络监控句柄
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //status:
        //AFNetworkReachabilityStatusUnknown          = -1,  未知
        //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
        //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
        //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
        
    }];
    
    //准备从远程下载文件. -> 请点击下面开始按钮启动下载任务
    
    [self.mTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HomeViewController"];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    
    //一进来就把升级文件列表下载下来
    [self downFileFromServer:@"http://hycosoft.cc/w200.json" hanlde:^(NSString *filePath) {
        NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        self.fileNames = [dict objectForKey:@"key"];
        [self.mTableView reloadData];
    }];
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
            if (!self.currentDict) {
                NSLog(@"未选择升级文件");
                return;
            }
            
            [self downFileFromServer:self.currentDict[@"url"] hanlde:^(NSString *filePath) {
                self.updateFilePath = filePath;
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 下载升级文件

- (void)downFileFromServer:(NSString *)urlStr hanlde:(void (^)(NSString *filePath))hanlde
{
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //下载Task操作
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (hanlde) {
            hanlde(filePath.path);
        }
        
    }];
    
    [downloadTask resume];
}


#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeViewController" forIndexPath:indexPath];
    NSDictionary *dict = self.fileNames[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentDict = self.fileNames[indexPath.row];
}

@end
