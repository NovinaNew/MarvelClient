//
//  MainTableViewCell.h
//  Marvel
//
//  Created by Newcastle on 27.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *about;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
