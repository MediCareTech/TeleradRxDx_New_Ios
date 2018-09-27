//
//  MediaVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 21/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "MediaVC.h"
#import "UIImageView+WebCache.h"

@interface MediaVC ()
{
    MBProgressHUD *HUD;
    CGFloat lastScale;
}
@end

@implementation MediaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //imageShowVc
    if (self.webUrl !=nil) {
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        self.scrollView.hidden = YES;
        [self.scrollView removeFromSuperview];
        self.webView.scalesPageToFit=YES;
        self.webView.delegate = self;
        //NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrlQAImg,self.webUrl];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
    } else {
        
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        
        
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.strImage] placeholderImage:[UIImage imageNamed:@"loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unsupported Format" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }else
                    self.imageView .image = image;
                
            }];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Webview Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@" webViewDidStartLoad success");
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@" webViewDidFinishLoad success");
    [HUD hide:YES];
    [HUD removeFromSuperview];
}

- (IBAction)dismissBtnClicked:(id)sender
{
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}


- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

// MARK: - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
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
