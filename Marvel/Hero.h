//
//  Hero.h
//  Marvel
//
//  Created by Newcastle on 28.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface Hero : NSManagedObject

@property NSString *name;
@property NSString *desc;
@property NSString *imagePath;

@end
