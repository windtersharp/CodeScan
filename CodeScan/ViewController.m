//
//  ViewController.m
//  CodeScan
//
//  Created by tian on 16/7/22.
//  Copyright © 2016年 windtersharp. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanView.h"

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic,strong) AVCaptureMetadataOutput *captureDeviceOutput;
@property (nonatomic,strong) AVCaptureConnection *captureConnection;
@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) ScanView *scanView;

@property (nonatomic,assign) BOOL cameraValidate;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self cameraCheck]; //扫描
//    [self generateQRCode];//生成二维码
//    [self recognizeImage:[UIImage imageNamed:@"二维码"]];//识别二维码
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.captureSession startRunning]; //扫描开始



}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.captureSession stopRunning];  //扫描停止
    
    

}

#pragma mark - 二维码识别
-(void)recognizeImage:(UIImage*)image{
    CIContext *content = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:content options:nil];
    CIImage *cimage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:cimage];
    CIQRCodeFeature *f = [features firstObject];
    NSLog(@"f.messageString:%@",f.messageString);
    
}

#pragma mark - 二维码生成
- (void)generateQRCode{
    // 1.创建生成二维码的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.把数据输入给滤镜
    NSString *url = @"http://www.baidu.com";
    NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
    //需要把NSString 转为 NSData
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 3.获得滤镜生成的二维码
    CIImage *image = [filter outputImage];
    // 4.为图片设置image
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:imageView];
    imageView.image = [self createNonInterpolatedUIImageFormCIImage:image withSize:200];

}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}




#pragma mark - 二维码扫描
#pragma mark - CameraCheck
- (void)cameraCheck{
    if ([self canUseCamera] && [self validateCamera]) {
         [self initCapture];
    }

}

-(BOOL)canUseCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

-(BOOL)validateCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}


#pragma mark - InitCapture
- (void)initCapture{
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    [self.view addSubview:self.scanView];


}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if ([metadataObjects count] > 0){
        //停止扫描
//        [self.captureSession stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
    
         NSLog(@" 扫描后的url是:%@", metadataObject.stringValue);
    }
    NSLog(@"无结果");
}










#pragma mark - Getter
- (AVCaptureDevice *)captureDevice{
    if (_captureDevice == nil) {
        _captureDevice = [self getCaptureDeviceWithPosition:AVCaptureDevicePositionBack];
        
    }
    return _captureDevice;
}

- (AVCaptureDeviceInput *)captureDeviceInput{
    if (_captureDeviceInput == nil) {
        NSError *error = nil;
        _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:&error];
    }
    return _captureDeviceInput;
}

- (AVCaptureMetadataOutput *)captureDeviceOutput{
    if (_captureDeviceOutput == nil) {
        _captureDeviceOutput = [[AVCaptureMetadataOutput alloc]init];
        [_captureDeviceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _captureDeviceOutput.rectOfInterest = CGRectMake((CGRectGetMidY(self.view.bounds) - 120) / SCREEN_SIZE.height,
                                                         (CGRectGetMidX(self.view.bounds) - 120) / SCREEN_SIZE.width,
                                                         240 / SCREEN_SIZE.height,
                                                         240 / SCREEN_SIZE.width
                                                         );
    }
    return _captureDeviceOutput;
}

- (AVCaptureConnection *)captureConnection{
    if (_captureConnection == nil) {
        _captureConnection = [self.captureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
        _captureConnection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;

    }
    return _captureConnection;
}

- (AVCaptureSession *)captureSession{
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc]init];
        if ([_captureSession canAddInput:self.captureDeviceInput]) {
             [_captureSession addInput:self.captureDeviceInput];
        }
        if ([_captureSession canAddOutput:self.captureDeviceOutput]) {
             [_captureSession addOutput:self.captureDeviceOutput];
            //必须先addOutput 才能 设置metadataObjectTypes，要不会崩溃
            self.captureDeviceOutput.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                                         AVMetadataObjectTypeCode39Code,
                                                         AVMetadataObjectTypeCode39Mod43Code,
                                                         AVMetadataObjectTypeEAN13Code,
                                                         AVMetadataObjectTypeEAN8Code,
                                                         AVMetadataObjectTypeCode93Code,
                                                         AVMetadataObjectTypeCode128Code,
                                                         AVMetadataObjectTypePDF417Code,
                                                         AVMetadataObjectTypeQRCode,
                                                         AVMetadataObjectTypeAztecCode];
        }
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {//设置输出分辨率
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh; //默认AVCaptureSessionPresetHigh，也可不写
        }
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer{
    if (_captureVideoPreviewLayer == nil) {
        _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResize;
        _captureVideoPreviewLayer.frame = self.view.bounds;
    }
    return _captureVideoPreviewLayer;
}

- (ScanView *)scanView{
    if (_scanView == nil) {
        _scanView = [[ScanView alloc]initWithFrame:self.view.bounds];
        _scanView.backgroundColor = [UIColor clearColor];
    }
    return _scanView;
}


#pragma mark - Tool
- (AVCaptureDevice *)getCaptureDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}












//- (CGRect)screenBounds {
//    UIScreen *screen = [UIScreen mainScreen];
//    CGRect screenRect;
//    if (![screen respondsToSelector:@selector(fixedCoordinateSpace)] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
//        screenRect = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
//    } else {
//        screenRect = screen.bounds;
//    }
//    return screenRect;
//}
//
//- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if (orientation == UIInterfaceOrientationPortrait) {
//       
//        return AVCaptureVideoOrientationPortrait;
//        
//    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
//  
//        return AVCaptureVideoOrientationLandscapeLeft;
//        
//    } else if (orientation == UIInterfaceOrientationLandscapeRight){
//       
//        return AVCaptureVideoOrientationLandscapeRight;
//    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
//
//        return AVCaptureVideoOrientationPortraitUpsideDown;
//    }
//    return AVCaptureVideoOrientationPortrait;
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
