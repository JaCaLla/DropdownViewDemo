//
//  ViewController.m
//  borrame
//
//  Created by JAVIER CALATRAVA LLAVERIA on 30/05/15.
//  Copyright (c) 2015 CELERI.ES. All rights reserved.
//

#import "ViewController.h"
#import "JCDropDownViewController.h"

@interface ViewController(){
    
    __weak IBOutlet UIView *svwUpper;
    __weak IBOutlet UIButton *btnDropDownbutton;
}

@end


@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [super setUpperView:svwUpper button:btnDropDownbutton];
    
}

#pragma mark - IBAction


@end
