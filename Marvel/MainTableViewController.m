//
//  MainTableViewController.m
//  Marvel
//
//  Created by Newcastle on 27.02.17.
//  Copyright © 2017 Newcastle. All rights reserved.
//

#import "MainTableViewController.h"
#import "MainTableViewCell.h"
#import "DetailsViewController.h"
#import "AppDelegate.h"
#import "Hero.h"


#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"



@interface MainTableViewController ()

@property (strong) NSManagedObjectContext *managedObjectContext;
@property NetworkManager *client;

@end





@implementation MainTableViewController

static NSMutableArray *heroModel = nil;//simple, bun better use - NSFetchedResultController
static NSString *ENTITY_NAME = @"HeroEntity";



- (Hero*) getHero:(int)index {
     if(heroModel != nil
        && index < [heroModel count]
        && heroModel[index] != nil) {
          return heroModel[index];
     }
     else return nil;
}





- (void) viewDidLoad {
     [super viewDidLoad];
     
     [self hideView];
     [self configureView];
     
     [self initNetworkManager];
     [self initializeCoreData];

}



-(void) showView {
     [UIView animateWithDuration:0.5
                           delay:0.1
                         options: UIViewAnimationOptionCurveEaseInOut
                      animations:^
      {
           CGRect frame = self.view.frame;
           frame.origin.y = 0; //-self.view.frame.size.height;
           frame.origin.x = 0;
           
           self.view.frame = frame;
      }
                      completion:^(BOOL finished)
      {
           NSLog(@"Completed");
           
      }];
}


-(void) hideView {
     CGRect frame = self.view.frame;
     frame.origin.y = self.view.frame.size.height ;
     frame.origin.x = 0;
     self.view.frame = frame;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) initNetworkManager {
     _client = [NetworkManager Instance];
     _client.delegate = self;
     
     [_client updateModel];
}


-(void) configureView {
     
//     UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_screen"]];
//     [self.view addSubview:backgroundImage];
     heroModel = [[NSMutableArray alloc] init];
     
   
     _mainTableView.rowHeight = UITableViewAutomaticDimension;
     _mainTableView.estimatedRowHeight = 140;
     
     self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marvel"]];
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return heroModel == nil ? 0 : [heroModel count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableCell"
                                                               forIndexPath:indexPath];
     
     [cell.image setImage:nil];
     
     if(heroModel != nil && indexPath.row < [heroModel count]) {
          Hero* hero = heroModel[indexPath.row];
          if(hero != nil) {
               
               cell.name.text = hero.name;
               cell.about.text = hero.desc;
               
               NSURL *url = [NSURL URLWithString: hero.imagePath];
               NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:10];
               
               UIImage *placeholderImage = [UIImage imageNamed:@"test"];
               
               
               __weak MainTableViewCell *weakCell = cell;
               [cell.image setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   weakCell.image.image = image;
                                                   [weakCell setNeedsLayout];
                                              } failure:nil];
               
          }
          
     }
     
    
     
     return cell;
}



-(void)ncClient:(NetworkManager *)client didUpdate:(id)responseObject
{
     NSDictionary* responseArray = (NSDictionary *)responseObject;
     NSArray * dict = [responseArray valueForKeyPath:@"data.results"];
     if(dict != nil) {
          [self clearModel];
     }
     
     for(int i = 0; i < [dict count]; i++) {
          NSDictionary* dictElement = dict[i];
          if(dictElement != nil) {
               Hero* hero = [[Hero alloc] init];
               [hero setName: [dictElement valueForKey:@"name"]];
               [hero setDesc: [dictElement valueForKey:@"description"]];

               NSDictionary* imageDict = [dictElement valueForKey:@"thumbnail"];
               NSString* pathString = [imageDict valueForKey:@"path"];
               NSString* extensionString = [imageDict valueForKey:@"extension"];
               NSString* imagePath = [pathString stringByAppendingString:
                                      [@"." stringByAppendingString:extensionString]];

               [hero setImagePath:imagePath];
               
               [self saveHero:hero];
               
               [heroModel insertObject:hero atIndex:[heroModel count]];
          }
     }
     [self.tableView reloadData];
     [self showView];
     
     
}


- (void)ncClient:(NetworkManager *)client didFailWithError:(NSError *)error
{

     UIAlertController *alertView = [UIAlertController
                                     alertControllerWithTitle:@"Error"
                                     message: [error localizedDescription]
                                     preferredStyle:UIAlertControllerStyleAlert];


     [alertView addAction:[UIAlertAction
                           actionWithTitle:@"Ok"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                                NSLog([error description]);
                                [self loadModel];
                           }]];

     [self presentViewController:alertView animated:YES completion:nil];
     [self showView];

     
     
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     if(heroModel != nil && indexPath.row < [heroModel count]) {
          Hero* hero = heroModel[indexPath.row];
          if(hero != nil) {
               if([[hero desc] length] < 200) {
                    return 160;
               }
          }
     }
     return -1;
     
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([[segue identifier] isEqualToString:@"Show_Details"]) {
          DetailsViewController *vc = [segue destinationViewController];
          Hero* hero = [self getHero: (int)[self.tableView indexPathForSelectedRow].row];
          if(hero != nil) {
               [vc setHero:hero];
          }
     }
}









#pragma mark - Core data things

//TODO: NSFetchedResultController


- (void)saveHero:(Hero*) hero {
     NSManagedObjectContext *context = [self managedObjectContext];
     if(context == nil) { return; }
     
     NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                             inManagedObjectContext:context];
     [entity setValue: hero.name forKey:@"name"];
     [entity setValue: hero.desc forKey:@"desc"];
     [entity setValue: hero.imagePath forKey:@"imagePath"];
     
     NSError *error = nil;
     
     if (![context save:&error]) {
          NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
     }
     
}



- (void)initializeCoreData {
     
     NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Marvel" withExtension:@"momd"];
     
     NSAssert(modelURL != nil, @"Error Model Load");
     
     NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
     NSAssert(managedObjectModel != nil, @"Error initializing Managed Object Model");
     
     NSPersistentStoreCoordinator *presStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
     
     [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
     [self.managedObjectContext setPersistentStoreCoordinator:presStoreCoordinator];
     
     
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
     NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Marvel.sqlite"];
     
     dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
          NSError *error = nil;
          NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
          NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:nil error:&error];
          
          NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
     });
}


-(NSArray *) getItemsFromContext:(NSError* )error {
     if(_managedObjectContext == nil) { return nil; }
     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
     return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}



- (void) clearModel {
     NSLog(@"Clear Model");
     
     NSError *error = nil;
     NSArray *items = [self getItemsFromContext:error];

     for (NSManagedObject *managedObject in items) {
          [_managedObjectContext deleteObject:managedObject];
     }
     if (![_managedObjectContext save:&error]) { /*Empty*/ }

}


-(void) loadModel {
     NSLog(@"Load Model");
     
     NSError *error = nil;
     NSArray *items = [self getItemsFromContext:error];
     if (!items) {
          NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
          return;
     }
     else {
          for(int i = 0; i < [items count]; i++) {
               Hero* hero = [[Hero alloc] init];
               NSManagedObject* object = items[i];
               if(object != nil) {
                    [hero setName: [object valueForKey:@"name"]];
                    [hero setDesc: [object valueForKey:@"desc"]];
                    [hero setImagePath: [object valueForKey:@"imagePath"]];
               }
               
               [heroModel insertObject:hero atIndex:[heroModel count]];
          }
          [_mainTableView reloadData];
          
     }
     
}




@end
