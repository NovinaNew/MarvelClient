//
//  NetworkManager.h
//  Marvel
//
//  Created by Newcastle on 28.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@protocol NetworkManagerDelegate;

@interface NetworkManager : AFHTTPSessionManager
@property (nonatomic) id<NetworkManagerDelegate> delegate;

+ (NetworkManager *)Instance;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void) updateModel;
- (void) loadNewPage;

@end


@protocol NetworkManagerDelegate <NSObject>
@optional

-(void)ncClient:(NetworkManager *)client didUpdate:(id)data;
-(void)ncClient:(NetworkManager *)client didLoadNewPage:(id)data;
-(void)ncClient:(NetworkManager *)client didFailWithError:(NSError *)error;

@end
