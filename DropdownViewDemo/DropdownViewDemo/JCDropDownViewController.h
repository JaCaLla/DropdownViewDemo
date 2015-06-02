//
//  JCDropDownViewController.h
//
//
//  Created by JAVIER CALATRAVA LLAVERIA on 31/05/15.
//
//

#import <UIKit/UIKit.h>

#define SUBVIEW_HEIGHT 0.5f
#define MIN_Y_UPPER_MARGIN_POINT 50

#define BUTTON_WIDTH 50
#define BUTTON_HEIGHT 50

@interface JCDropDownViewController : UIViewController

@property (strong,nonatomic) UIView *svwUpperSubview;
@property (strong,nonatomic) UIButton *btnFoldButton;


-(void) setUpperView:(UIView*)aView button:(UIButton*)aButton;

@end
