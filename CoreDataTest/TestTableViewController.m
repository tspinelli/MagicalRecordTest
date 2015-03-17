//
//  TestTableViewController.m
//  CoreDataTest
//
//  Created by Anthony Spinelli on 3/17/15.
//  Copyright (c) 2015 CDT. All rights reserved.
//

#import "TestTableViewController.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "File.h"
#import "Folder.h"

@interface TestTableViewController ()
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation TestTableViewController

// This one works
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//        Folder *folder1 = [Folder MR_createInContext:localContext];
//        folder1.name = @"Folder 1";
//        for (int i=0;i<4;i++) {
//            File *file = [File MR_createInContext:localContext];
//            file.folder = folder1;
//            file.name = [NSString stringWithFormat:@"%@, File %li",file.folder.name,(long)i];
//        }
//        
//        Folder *folder2 = [Folder MR_createInContext:localContext];
//        folder2.name = @"Folder 2";
//    }];
//    NSLog(@"Folders added: %ld",[Folder MR_countOfEntities]);
//    
//    self.fetchedResultsController = [File MR_fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"folder == %@",[Folder MR_findFirstByAttribute:@"name" withValue:@"Folder 1"]] sortedBy:@"name" ascending:YES];
//   self.fetchedResultsController.delegate = self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create Folders
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Folder *folder1 = [Folder MR_createInContext:localContext];
        folder1.name = @"Folder 1";
        
        Folder *folder2 = [Folder MR_createInContext:localContext];
        folder2.name = @"Folder 2";
    }];
    
    // Create fetched Results Controller
    NSLog(@"Folders added: %ld",[Folder MR_countOfEntities]);
    self.fetchedResultsController = [File MR_fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"folder == %@",[Folder MR_findFirstByAttribute:@"name" withValue:@"Folder 1"]] sortedBy:@"name" ascending:YES];
    self.fetchedResultsController.delegate = self;
    
    // Now add files after adding results controller
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Folder *folder1 = [Folder MR_findFirstByAttribute:@"name" withValue:@"Folder 1" inContext:localContext];
        
        for (int i=0;i<4;i++) {
            File *file = [File MR_createInContext:localContext];
            file.folder = folder1;
            file.name = [NSString stringWithFormat:@"%@, File %li",file.folder.name,(long)i];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeFile:) userInfo:nil repeats:NO];
}

-(void)removeFile:(NSTimer*)timer
{
    NSArray *array = [File MR_findAllSortedBy:@"name" ascending:YES];
    File *file = array[2];
    NSLog(@"Remove file %@",file.name);
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        File *localFile = [file MR_inContext:localContext];
        Folder *localFolder2 = [Folder MR_findFirstByAttribute:@"name" withValue:@"Folder 2" inContext:localContext];
        localFile.folder = localFolder2;
        
        NSArray *localArray = [File MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"folder.name == %@",@"Folder 1"] inContext:localContext];
        NSLog(@"Objects Left: %ld",[localArray count]);
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"Remove done!");
        //        NSArray *folders = [Folder ]
        //        NSLog(@")
        NSLog(@"Objects Left: %ld",[[self.fetchedResultsController fetchedObjects] count]);
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addFile:) userInfo:nil repeats:NO];
    }];
}

-(void)addFile:(NSTimer*)timer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
        Folder *folder2 = [Folder MR_findFirstByAttribute:@"name" withValue:@"Folder 2" inContext:localContext];
        File *file = [[[folder2 files] allObjects] firstObject];
        
        NSLog(@"Add file back %@",file.name);
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            File *localFile = [file MR_inContext:localContext];
            Folder *localFolder1 = [Folder MR_findFirstByAttribute:@"name" withValue:@"Folder 1" inContext:localContext];
            localFile.folder = localFolder1;
        } completion:^(BOOL success, NSError *error) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeFile:) userInfo:nil repeats:NO];
            NSLog(@"Adding done!");
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//                [NSManagedObjectContext MR_defaultContext]
//            });
        }];

    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.fetchedResultsController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    File *file = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"%@",file.name];
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FetchedResultsController Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
