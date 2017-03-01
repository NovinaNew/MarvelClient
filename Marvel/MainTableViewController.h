//
//  MainTableViewController.h
//  Marvel
//
//  Created by Newcastle on 27.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"

//
//
// Я не успел написать без ARC.
// И лучше предоставлю такой вариант, чем с потенциальной ошибкой.
//


@interface MainTableViewController : UITableViewController<NetworkManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end
