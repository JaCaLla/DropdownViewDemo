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
    CGPoint currentMovingPoint;
    CGRect fOriginalFrame;
    
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
    
    
    if(!aButton || !aUpperView)
        return;
    
    
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    
    
    if(self.svwUpperSubview)
        [self.svwUpperSubview removeFromSuperview];
    
    if(aUpperView.frame.size.width>screenSize.width){
        CGRect aResizedFrame= aUpperView.frame;
        aResizedFrame.size.width=screenSize.width;
        aUpperView.frame=aResizedFrame;
    }
    
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
        
    }
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(panDetected:)];
    [self.btnFoldButton addGestureRecognizer:panRecognizer];
    panRecognizer.cancelsTouchesInView = YES;
    
    [self.btnFoldButton addTarget:self action:@selector(buttonTouchDownRepeat:event:) forControlEvents:UIControlEventTouchDownRepeat];
    
    
    fOriginalFrame=self.svwUpperSubview.frame;
    
    foldedState=kFullyFolded;
    
    
    
    finalLowerPoint.x= screenWidth/2-self.btnFoldButton.frame.size.width/2;
    finalLowerPoint.y=self.svwUpperSubview.frame.size.height;
    if(self.navigationController)
        finalLowerPoint.y+=self.navigationController.navigationBar.frame.size.height;
    
    
    startMovingPoint = finalLowerPoint;;
    //finalLowerPoint=startMovingPoint;
    
    finalUpperPoint=startMovingPoint;
    finalUpperPoint.y=MIN_Y_UPPER_MARGIN_POINT;
    if(self.navigationController)
        finalUpperPoint.y+=self.navigationController.navigationBar.frame.size.height;
    
    currentMovingPoint=startMovingPoint;
    
    
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
    
    //aButtonPoint.y=self.svwUpperSubview.frame.size.height+self.svwUpperSubview.bounds.origin.y;
    
    return aButtonPoint;
}

-(void)panDetected:(UIPanGestureRecognizer*)pan
{
    
    static CGFloat ini;
    if(pan.state == UIGestureRecognizerStateBegan){
        ini = self.btnFoldButton.frame.origin.y;
        //NSLog(@"%f",ini);
        
        startMovingPoint = [self getPointFromButton:self.btnFoldButton];
        currentMovingPoint=startMovingPoint;
        
    }
    else if(pan.state == UIGestureRecognizerStateEnded)
    {
        // NSLog(@"End");
        startMovingPoint=currentMovingPoint;
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
        currentMovingPoint = [self getNewPointForOffset:offset
                                            withInitial:startMovingPoint
                                               andFinal:finalUpperPoint];
    else
        currentMovingPoint = [self getNewPointForOffset:offset
                                            withInitial:startMovingPoint
                                               andFinal:finalLowerPoint];
    
    if(isnan(currentMovingPoint.x) || isnan(currentMovingPoint.y))
        return;
    
    // NSLog(@"currentPlayButtonOrigin:%@",NSStringFromCGPoint(currentPlayButtonOrigin));
    
    
    if(currentMovingPoint.y < finalUpperPoint.y){
        currentMovingPoint=finalUpperPoint;//return;// [self goToFinal:YES];
        foldedState=kFullyUnfolded;
    }
    else if(currentMovingPoint.y > finalLowerPoint.y){
        currentMovingPoint=finalLowerPoint;//return;//   [self goToInitial:YES];
        foldedState=kFullyFolded;
    }
    else
    {
        foldedState=kMidleFolded;
        
        [self move:self.btnFoldButton toOrigin:currentMovingPoint withAlpha:1.0 animated:NO withCompletion:nil];
        //[self shrinkView:self.svwUpperSubview foldButton:self.btnFoldButton animated:NO];
        
        
        CGFloat fHeight=self.btnFoldButton.center.y-self.btnFoldButton.frame.size.height/2;
        
        if(self.navigationController)
            fHeight-=self.navigationController.navigationBar.frame.size.height;
        
        [self shrinkView:self.svwUpperSubview height:fHeight  animated:NO];
        
    }
    
}


-(void) shrinkView:(UIView*)aView height:(CGFloat)height animated:(BOOL)animated{
    
    
    
    if(animated)
    {
        
        [UIView  animateWithDuration:time animations:^{
            CGRect aViewFrame = aView.frame;
            aViewFrame.size.height = height;
            
            aView.frame=aViewFrame;
        } completion:nil];
    }
    else
    {
        CGRect aViewFrame = aView.frame;
        aViewFrame.size.height = height;
        aView.frame=aViewFrame;
    }
    
}




- (void)goToLowerFinalPoint:(BOOL)animated
{
    
    [self move:self.btnFoldButton toOrigin:finalLowerPoint withAlpha:1.0 animated:animated withCompletion:^{
        
    }];
    
    //[self shrinkView:self.svwUpperSubview foldButton:self.btnFoldButton animated:animated];
    CGFloat fHeight=fOriginalFrame.size.height;
    [self shrinkView:self.svwUpperSubview height:fHeight  animated:animated];
    
    foldedState=kFullyFolded;
}

- (void)goToUpperFinalPoint:(BOOL)animated
{
    
    
    [self move:self.btnFoldButton  toOrigin:finalUpperPoint withAlpha:1.0 animated:animated withCompletion:^{
    }];
    
    CGFloat fHeight=MIN_Y_UPPER_MARGIN_POINT;
    [self shrinkView:self.svwUpperSubview height:fHeight  animated:animated];
    
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
    CGFloat distance;
    
    
    if(currentOrigin.y > origin.y)
        distance=currentOrigin.y-origin.y;
    else
        distance= origin.y-currentOrigin.y;
    
    time = 1/velocity * distance;
    
    CGRect f = view.frame;
    f.origin = origin;
    if(!self.navigationController)
        f.origin.y -= view.frame.size.height/2;
    
    
    if(animated)
    {
        [UIView animateWithDuration:time animations:^{
            view.frame = f;
            view.alpha = alpha;
        } completion:^(BOOL finished) {
            if(completion)
                completion();
        }];
    }
    else
    {
        view.frame = f;
        view.alpha = alpha;
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
