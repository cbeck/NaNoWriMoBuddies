//
//  NaNoWriMoBuddiesAppDelegate.h
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
// This includes the header for the SQLite library.
#import <sqlite3.h>

@interface NaNoWriMoBuddiesAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	NSMutableArray *buddies;
	// Opaque reference to the SQLite database.
    sqlite3 *database;
	BOOL _isDataSourceAvailable;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
// Makes the main array of buddy objects available to other objects in the application.
@property (nonatomic, retain) NSMutableArray *buddies;

- (BOOL)isDataSourceAvailable;

- (NSUInteger)countOfList;
- (id)objectInListAtIndex:(NSUInteger)theIndex;
- (void)getList:(id *)objsPtr range:(NSRange)range;
@end

