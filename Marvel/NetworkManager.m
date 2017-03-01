//
//  NetworkManager.m
//  Marvel
//
//  Created by Newcastle on 28.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import "NetworkManager.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NetworkManager


static NSString* PUBLIC_KEY = @"d0252ced33db6822796905951acea79a";
static NSString* PRIVATE_KEY = @"ca75da23c57246a682e7549436542d56ff131bfe";

static NSString* path = @"http://gateway.marvel.com/v1/public/";
static NSString* hash = @"&hash=";
static NSString* ts = @"&ts=";
static int timeStamp = 0;




+ (NSString *)MD5:(NSString *)input {
     const char *cStr = [input UTF8String];
     unsigned char digest[CC_MD5_DIGEST_LENGTH];
     CC_MD5( cStr, strlen(cStr), digest);
     
     NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
     for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
          [output appendFormat:@"%02x", digest[i]];
     }
     
     return  output;
}


+(NetworkManager*) Instance {
     static NetworkManager *manager = nil;
     
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:path]];
     });
     
     return manager;
}



- (instancetype)initWithBaseURL:(NSURL *)url
{
     self = [super initWithBaseURL:url];
     
     if (self) {
          self.responseSerializer = [AFJSONResponseSerializer serializer];
          self.requestSerializer = [AFJSONRequestSerializer serializer];
     }

     return self;
}







-(NSString*) createGetCharachtersRequestString {
     NSString* timeStampString = [NSString stringWithFormat:@"%i", ++timeStamp ];
     NSString* md5String =[timeStampString stringByAppendingString: [PRIVATE_KEY stringByAppendingString:PUBLIC_KEY]];
     NSString* hashKey = [NetworkManager MD5: md5String];
     
     NSString *string = [path stringByAppendingString:
                         [PUBLIC_KEY stringByAppendingString:
                          [ts stringByAppendingString:
                           [timeStampString stringByAppendingString:
                            [hash stringByAppendingString:hashKey]]]]];
     return string;
}





-(void) updateModel {
     NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
     NSString* timeStampString = [NSString stringWithFormat:@"%i", ++timeStamp ];
     NSString* md5String =[timeStampString stringByAppendingString: [PRIVATE_KEY stringByAppendingString:PUBLIC_KEY]];
     NSString* hashKey = [NetworkManager MD5: md5String];
     
     parameters[@"hash"] = hashKey;
     parameters[@"ts"] = timeStampString;
     parameters[@"apikey"] = PUBLIC_KEY;
     parameters[@"limit"] = [NSNumber numberWithInteger:50];
     
     
     [self GET:@"characters" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([self.delegate respondsToSelector:@selector(ncClient:didUpdate:)]) {
               [self.delegate ncClient:self didUpdate:responseObject];
          }
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(ncClient:didFailWithError:)]) {
               [self.delegate ncClient:self didFailWithError:error];
          }
     }];
     
     
}








@end
