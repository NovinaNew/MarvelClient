//
//  DetailsViewController.m
//  Marvel
//
//  Created by Newcastle on 28.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "DetailsViewController.h"


@interface DetailsViewController ()
@end





@implementation DetailsViewController

@synthesize hero;

- (void)viewDidLoad {
     [super viewDidLoad];
     
     _heroName.text = hero.name;
     _aboutHero.text = hero.desc;
     
     NSURL *url = [NSURL URLWithString: hero.imagePath];
     NSURLRequest *request = [NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                          timeoutInterval:10];
     UIImage *placeholderImage = [UIImage imageNamed:@"test"];
     
     [_image setImageWithURLRequest:request
                       placeholderImage:placeholderImage
                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                     self.image.image = image;
                                } failure:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
