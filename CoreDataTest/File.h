//
//  File.h
//  CoreDataTest
//
//  Created by Anthony Spinelli on 3/17/15.
//  Copyright (c) 2015 CDT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Folder *folder;

@end
