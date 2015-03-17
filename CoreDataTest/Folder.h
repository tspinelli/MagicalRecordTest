//
//  Folder.h
//  CoreDataTest
//
//  Created by Anthony Spinelli on 3/17/15.
//  Copyright (c) 2015 CDT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Folder : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *files;
@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addFilesObject:(NSManagedObject *)value;
- (void)removeFilesObject:(NSManagedObject *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

@end
