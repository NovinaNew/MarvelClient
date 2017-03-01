//
//  DetailsViewController.h
//  Marvel
//
//  Created by Newcastle on 28.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hero.h"

@interface DetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *heroName;
@property (weak, nonatomic) IBOutlet UILabel *aboutHero;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property Hero* hero;


@end
