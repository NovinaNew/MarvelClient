//
//  MainTableViewController.h
//  Marvel
//
//  Created by Newcastle on 27.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NetworkManager.h"


//


@interface MainTableViewController : UITableViewController<NetworkManagerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSFetchedResultsController* frc;

@end
