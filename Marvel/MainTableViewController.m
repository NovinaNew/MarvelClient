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

static bool inInfinitiQuery = false;


static NSString *ENTITY_NAME = @"HeroEntity";


- (void) viewDidAppear:(BOOL)animated {
     [self.view.superview setContentMode:UIViewContentModeScaleToFill];
     [self.view.superview setBackgroundColor: [UIColor colorWithPatternImage:
                                               [UIImage imageNamed:@"launch_screen"]]];
     
}


- (void) viewDidLoad {
     [super viewDidLoad];
   
     [self configureView];
     
     [self initNetworkManager];
     [self initializeCoreData];
}



-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
     CGFloat bottom = scrollView.contentSize.height - scrollView.frame.size.height;
     CGFloat buffer = scrollView.frame.size.height * 4;
     CGFloat scrollPosition = scrollView.contentOffset.y;
     
     if (!inInfinitiQuery
         && (scrollPosition > bottom - buffer)) {
          
          NSLog(@"Load more");
          inInfinitiQuery = true;
          
          [_client loadNewPage];
     }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



-(void) initNetworkManager {
     _client = [NetworkManager Instance];
     _client.delegate = self;
     
     [_client updateModel];
}


-(void) configureView {
//     self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
     _mainTableView.rowHeight = UITableViewAutomaticDimension;
     _mainTableView.estimatedRowHeight = 140;
     self.navigationItem.titleView = [[UIImageView alloc] initWithImage:
                                      [UIImage imageNamed:@"marvel"]];
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
     
     return [sectionInfo numberOfObjects];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableCell"
                                                               forIndexPath:indexPath];
     
     [cell.image setImage:nil];

     Hero* hero = [self.frc objectAtIndexPath:indexPath];
     
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
               Hero* hero = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                          inManagedObjectContext:_managedObjectContext];
               
               
               [hero setName: [dictElement valueForKey:@"name"]];
               [hero setDesc: [dictElement valueForKey:@"description"]];

               NSDictionary* imageDict = [dictElement valueForKey:@"thumbnail"];
               NSString* pathString = [imageDict valueForKey:@"path"];
               NSString* extensionString = [imageDict valueForKey:@"extension"];
               NSString* imagePath = [pathString stringByAppendingString:
                                      [@"." stringByAppendingString:extensionString]];

               [hero setImagePath:imagePath];
               
               NSManagedObjectContext *context = [self managedObjectContext];
               if(context == nil) { return; }
               
               NSError *error = nil;
               if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
               }
          }
     }
     
     
}





-(void)ncClient:(NetworkManager *)client didLoadNewPage:(id)responseObject
{
     NSDictionary* responseArray = (NSDictionary *)responseObject;
     NSArray * dict = [responseArray valueForKeyPath:@"data.results"];
     NSManagedObjectContext *context = [self managedObjectContext];
     
     
     for(int i = 0; i < [dict count]; i++) {
          NSDictionary* dictElement = dict[i];
          
          if(dictElement != nil) {
               Hero* hero = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                          inManagedObjectContext:_managedObjectContext];
               
               [hero setName: [dictElement valueForKey:@"name"]];
               [hero setDesc: [dictElement valueForKey:@"description"]];
               
               NSDictionary* imageDict = [dictElement valueForKey:@"thumbnail"];
               NSString* pathString = [imageDict valueForKey:@"path"];
               NSString* extensionString = [imageDict valueForKey:@"extension"];
               NSString* imagePath = [pathString stringByAppendingString:
                                      [@"." stringByAppendingString:extensionString]];
               
               [hero setImagePath: imagePath];
               
               
               if(context == nil) { return; }
               
               NSError *error = nil;
               if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
               }
          }
     }
     inInfinitiQuery = false;
     
     
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
                                NSLog(@"On Error");
                                NSLog(@"%@", [error description]);
                                
//                                [self loadModel];
                           }]];

     [self presentViewController:alertView animated:YES completion:nil];

     
     
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     
     
     Hero* hero = [self.frc objectAtIndexPath:indexPath];
     
     if(hero != nil) {
          if([[hero desc] length] < 200) {
               return 160;
          }
     }
     
     return -1;
     
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([[segue identifier] isEqualToString:@"Show_Details"]) {
          DetailsViewController *vc = [segue destinationViewController];
          
          Hero* hero = [self.frc objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
          if(hero != nil) {
               [vc setHero:hero];
          }
     }
}









#pragma mark - Core data things

//TODO: NSFetchedResultController





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
     
     
     //init FRC
     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
     NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
     fetchRequest.sortDescriptors = @[sortDesc];
     self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                  managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
     
     
     self.frc.delegate = self;
     NSError* error;
     if([self.frc performFetch: &error]) {
          NSLog(@"@Loaded");
     }
     
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




- (void)saveHero:(Hero*) hero {
     NSLog(@"Save Hero");
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



#pragma mark - NSFetchedController



-(void) controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
     
     if(type == NSFetchedResultsChangeDelete) {
          [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
     }
     else if (type == NSFetchedResultsChangeInsert) {
          [self.tableView insertRowsAtIndexPaths: @[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
     }
     
}


-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
     [CATransaction begin];
     [CATransaction setDisableActions:YES];
     
     [self.tableView beginUpdates];
}


-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
     [self.tableView endUpdates];
     [CATransaction commit];
}


//- (void)viewDidAppear:(BOOL)animated
//{
//     [super viewDidAppear:animated];
//
//     [UIView animateWithDuration:1.0
//                      animations:^{
//                           [self.view setAlpha:0];
//                           [self.view setCenter:CGPointMake(self.view.center.x+50.0,
//                                                            self.view.center.y+50.0)];
//                      }
//                      completion:^(BOOL finished) {
////                           [self.view removeFromSuperview];
//                      }];
//}



@end
