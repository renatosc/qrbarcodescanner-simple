//
//  RBScannerViewController.m
//  QRBarcodeScanner Simple
//
//  Created by Renato
//
// A very simple code that show how to capture a QR / barcode in Objective-C using AVFoundation.
//
// This code was inpired by :
// . CodeScanner
//      https://github.com/shinobicontrols/iOS7-day-by-day/tree/master/16-qr-codes-avfoundation
//      https://www.shinobicontrols.com/blog/ios7-day-by-day-day-16-decoding-qr-codes-with-avfoundation)
//
// .  iPhone QR Code scanning iOS 7
//    https://gist.github.com/Alex04/6976945
//    http://www.ama-dev.com/iphone-qr-code-library-ios-7/)
//
//
//
//

#import "RBScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

//A class extension of RBScanViewController
@interface RBScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@end

@implementation RBScannerViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // checking if we have at least one camera device
    NSArray *allTypes = @[AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ];
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:allTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSArray *devices = discoverySession.devices;
    
    BOOL hasCamera = [devices count] > 0;
    
    if (hasCamera){
        [self setupScanner];
    } else {
        NSLog(@"No Camera available");
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// perform the main setup
- (void) setupScanner {
    
    // creating the camera device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // creating the input
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!self.input){
        NSLog(@"error setting up scanner: %@", error);
        return;
    }
    
    // creating the ouput
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    
    // creating the session (which is responsible for managing the data flow between input/output)
    self.session = [[AVCaptureSession alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    // setting self to be the delegate
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // specifying which metadata we want to capture. In this case we are setting it to only look for QR codes.
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code];
    
    // Line below lists available metadata for this device.
    //NSLog(@"This device support identifying the following metadatas = %@", [self.output availableMetadataObjectTypes]);
    
    // creating the preview layer
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view.layer addSublayer:self.preview];
    
    [self.session startRunning];
    
}


//  AVCaptureMetadataOutputObjectsDelegate  -  here is where the decoding takes place!
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for (AVMetadataObject *metadata in metadataObjects) {
        
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode] | [metadata.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            NSLog(@"We found a QR  or EAN13 barcode!");
            
            // Transforming the metadata coordinates to screen coordinates so we can show a rect around it if we want to (not showing it in this simple example)
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[self.preview transformedMetadataObjectForMetadataObject:metadata];
            
            // printing the decoded text to console
            NSLog(@"%@", [transformed stringValue]);
            
        }

    }
    
}


@end
