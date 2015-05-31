//
//  JCDropDownViewController.m
//  
//
//  Created by JAVIER CALATRAVA LLAVERIA on 31/05/15.
//
//

#import "JCDropDownViewController.h"

#define NowPlayingAnimationVelocity 1000;


#define LANDSCAPE UIInterfaceOrientationIsLandscape(self.interfaceOrientation)
#define LANDSCAPE_RIGHT [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft
#define LANDSCAPE_LEFT [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight
#define PORTRAIT UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
#define PORTRAIT_REVERSE [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown


typedef enum {kFullyFolded=0,kMidleFolded,kFullyUnfolded} tFoldedState;

@interface JCDropDownViewController (){
    CGPoint startMovingPoint;
    CGPoint finalUpperPoint;
    CGPoint finalLowerPoint;
    CGPoint currentPlayButtonOrigin;
    
    CGFloat time;
    
    tFoldedState foldedState;

    
}


@end

@implementation JCDropDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    foldedState=kFullyFolded;

    
    [self setupUIControls:nil button:nil];
    
}

-(void) setUpperView:(UIView*)aView button:(UIButton*)aButton{
    [self setupUIControls:aView button:aButton];
}

- (void)setupUIControls:(UIView*)aUpperView button:(UIButton*)aButton{
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    
    
    if(self.svwUpperSubview)
        [self.svwUpperSubview removeFromSuperview];
    
    if(aUpperView.frame.size.width>screenSize.width){
        CGRect aResizedFrame= aUpperView.frame;
        aResizedFrame.size.width=screenSize.width;
        aUpperView.frame=aResizedFrame;
    }
    
    CGRect aUpperSubviewFrame =(aUpperView)?aUpperView.frame:CGRectMake(0, 0, screenSize.width, screenSize.height*SUBVIEW_HEIGHT);
    self.svwUpperSubview = aUpperView;//[[UIView alloc] initWithFrame:aUpperSubviewFrame];
    
    NSLog(@"%@",NSStringFromCGRect(aUpperView.frame));
    //[self.view addSubview:self.svwUpperSubview];
    //[self.svwUpperSubview addSubview:aUpperView];
    self.svwUpperSubview.clipsToBounds=YES;
    
    
    if(self.btnFoldButton)
        [self.btnFoldButton removeFromSuperview];
    
    if(aButton) {
        
        if(self.btnFoldButton)
            [self.btnFoldButton removeFromSuperview];

        self.btnFoldButton=aButton;

    }else{
        CGRect aButtonFolderFrame =CGRectMake(screenSize.width/2-BUTTON_WIDTH/2, self.svwUpperSubview.frame.size.height-BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT);
        self.btnFoldButton = [[UIButton alloc] initWithFrame:aButtonFolderFrame];
        self.btnFoldButton.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:self.btnFoldButton];
    }
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(panDetected:)];
    [self.btnFoldButton addGestureRecognizer:panRecognizer];
    panRecognizer.cancelsTouchesInView = YES;
    
    [self.btnFoldButton addTarget:self action:@selector(buttonTouchDownRepeat:event:) forControlEvents:UIControlEventTouchDownRepeat];
    
    finalLowerPoint=[self getPointFromButton:self.btnFoldButton];
    startMovingPoint = finalLowerPoint;;
    finalLowerPoint=startMovingPoint;
    finalUpperPoint=startMovingPoint;
    finalUpperPoint.y=MIN_Y_UPPER_MARGIN_POINT;
    currentPlayButtonOrigin=startMovingPoint;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) buttonTouchDownRepeat:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if(touch.tapCount == 2) {
        if(foldedState==kFullyFolded){
            [self goToUpperFinalPoint:YES];
        }else{
            [self goToLowerFinalPoint:YES];
        }
    }
}

-(CGPoint) getPointFromButton:(UIButton*)aUIButton{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    
    
    CGPoint aButtonPoint = aUIButton.frame.origin;
    aButtonPoint.x= screenWidth/2-aUIButton.frame.size.width/2;
    
    return aButtonPoint;
}

-(void)panDetected:(UIPanGestureRecognizer*)pan
{
    
    static CGFloat ini;
    if(pan.state == UIGestureRecognizerStateBegan){
        ini = self.btnFoldButton.frame.origin.y;
        //NSLog(@"%f",ini);
        
        startMovingPoint = [self getPointFromButton:self.btnFoldButton];
        currentPlayButtonOrigin=startMovingPoint;
        
    }
    else if(pan.state == UIGestureRecognizerStateEnded)
    {
        // NSLog(@"End");
        startMovingPoint=currentPlayButtonOrigin;
        //NSLog(@"startMovingPoint:%@",NSStringFromCGPoint(startMovingPoint));
        return;
        
    }
    CGPoint translation = [pan translationInView:self.btnFoldButton.superview];
    
    // NSLog(@"translateTo:%f",translation.y);
    [self translateTo:translation.y];
    
    //NSLog(@"currentP:%@",NSStringFromCGPoint(currentPlayButtonOrigin));
    
}

- (void)translateTo:(CGFloat)offset
{
    
    
    if(offset<0)
        currentPlayButtonOrigin = [self getNewPointForOffset:offset
                                                 withInitial:startMovingPoint
                                                    andFinal:finalUpperPoint];
    else
        currentPlayButtonOrigin = [self getNewPointForOffset:offset
                                                 withInitial:startMovingPoint
                                                    andFinal:finalLowerPoint];
    
    if(isnan(currentPlayButtonOrigin.x) || isnan(currentPlayButtonOrigin.y))
        return;
    
    // NSLog(@"currentPlayButtonOrigin:%@",NSStringFromCGPoint(currentPlayButtonOrigin));
    
    
    if(currentPlayButtonOrigin.y < finalUpperPoint.y){
        currentPlayButtonOrigin=finalUpperPoint;//return;// [self goToFinal:YES];
        foldedState=kFullyUnfolded;
    }
    else if(currentPlayButtonOrigin.y > finalLowerPoint.y){
        currentPlayButtonOrigin=finalLowerPoint;//return;//   [self goToInitial:YES];
        foldedState=kFullyFolded;
    }
    else
    {
        foldedState=kMidleFolded;
        
        [self move:self.btnFoldButton toOrigin:currentPlayButtonOrigin withAlpha:1.0 animated:NO withCompletion:nil];
        [self shrinkView:self.svwUpperSubview foldButton:self.btnFoldButton animated:NO];
        
    }
    
}


-(void) shrinkView:(UIView*)aView foldButton:(UIButton*)foldButton animated:(BOOL)animated{
    
    
    
    if(animated)
    {
        
        [UIView  animateWithDuration:time animations:^{
            CGRect aViewFrame = aView.frame;
            aViewFrame.size.height = foldButton.center.y;
            aView.frame=aViewFrame;
        } completion:nil];
    }
    else
    {
        CGRect aViewFrame = aView.frame;
        aViewFrame.size.height = foldButton.center.y;
        aView.frame=aViewFrame;
    }
    
}


- (void)goToLowerFinalPoint:(BOOL)animated
{
    
    [self move:self.btnFoldButton toOrigin:finalLowerPoint withAlpha:1.0 animated:animated withCompletion:^{
        
    }];
    
    [self shrinkView:self.svwUpperSubview foldButton:self.btnFoldButton animated:animated];
    
    foldedState=kFullyFolded;
}

- (void)goToUpperFinalPoint:(BOOL)animated
{
    
    
    [self move:self.btnFoldButton  toOrigin:finalUpperPoint withAlpha:1.0 animated:animated withCompletion:^{
        // [playButton setModeHidde];
    }];
    
    [self shrinkView:self.svwUpperSubview foldButton:self.btnFoldButton animated:animated];
    
    foldedState=kFullyUnfolded;
    
}



- (void)move:(UIView*)view toOrigin:(CGPoint)origin withAlpha:(CGFloat)alpha animated:(BOOL)animated withCompletion:(void (^)())completion
{
    if(view.frame.origin.y == origin.y)
    {
        if(completion) completion();
        return;
    }
    
    CGFloat velocity = NowPlayingAnimationVelocity;
    CGPoint currentOrigin = view.frame.origin;
    CGFloat distance = (currentOrigin.y > origin.y) ? currentOrigin.y-origin.y : origin.y-currentOrigin.y;
    
    time = 1/velocity * distance;
    
    CGRect f = view.frame;
    f.origin = origin;
    
    if(animated)
    {
        [UIView animateWithDuration:time animations:^{
            view.frame = f;
            view.alpha = alpha;
            //            self.fadeOutBackgroundView.alpha=alpha;
        } completion:^(BOOL finished) {
            if(completion)
                completion();
        }];
    }
    else
    {
        view.frame = f;
        view.alpha = alpha;
        //        self.fadeOutBackgroundView.alpha=alpha;
        if(completion)
            completion();
    }
    
}

- (CGPoint)getNewPointForOffset:(CGFloat)offset withInitial:(CGPoint)ini andFinal:(CGPoint)final
{
    CGFloat d = offset/(ini.y - final.y);
    
    CGFloat x = (ini.x-final.x)*d;
    x+=ini.x;
    
    CGFloat y = (ini.y-final.y)*d;
    y += ini.y;
    
    return CGPointMake(x, y);
}



@end
