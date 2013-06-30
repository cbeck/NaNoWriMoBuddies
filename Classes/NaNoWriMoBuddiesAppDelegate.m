//
//  NaNoWriMoBuddiesAppDelegate.m
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import "NaNoWriMoBuddiesAppDelegate.h"
#import "RootViewController.h"
#import "Buddy.h"
#import "XMLReader.h"
#import <SystemConfiguration/SystemConfiguration.h>

static NSString *feedURLString = @"http://www.nanowrimo.org/wordcount_api/wc/";

// Private interface for AppDelegate - internal only methods.
@interface NaNoWriMoBuddiesAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
@end

@implementation NaNoWriMoBuddiesAppDelegate

@synthesize window, navigationController, buddies;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.     
    [self createEditableCopyOfDatabaseIfNeeded];
    // Call internal method to initialize database connection
    [self initializeDatabase];
    // Add the navigation controller's view to the window
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
	if ([self isDataSourceAvailable] == NO) {
        return;
    }
	// Spawn a thread to fetch the buddy data so that the UI is not blocked while the 
    // application parses the XML file.
	NSEnumerator *enumerator = [buddies objectEnumerator];
	id anObject;
	
	while (anObject = [enumerator nextObject]) {
		Buddy *aBuddy = (Buddy *)anObject;
		NSLog(aBuddy.uid);
		// [NSThread detachNewThreadSelector:@selector(getBuddyData:) toTarget:self withObject:aBuddy];
		NSThread *spawned = [[NSThread alloc] initWithTarget:self selector:@selector(getBuddyData:) object:aBuddy];
		[spawned start];
		if ([spawned isFinished]) {
			NSLog(@"finished thread");
		} else {
			NSLog(@"executing thread");
		}
		
	}
	//Buddy *mybuddy = [buddies lastObject]; 
	//NSLog(@"main app sleeping...");
	//[NSThread sleepForTimeInterval:10.0];
	//NSLog(@"main app awake");
	NSLog(@"done loading app.");
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
	
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"nanobuddies.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
		NSLog(@"Found the db file in the documents dir.");
		return;
	}
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"nanobuddies.db"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
		NSLog(@"Uh oh, could no move database!");
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
	NSLog(@"initializing db");
    NSMutableArray *buddyArray = [[NSMutableArray alloc] init];
    self.buddies = buddyArray;
    [buddyArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"nanobuddies.db"];
	NSLog(path);
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		NSLog(@"DB opened");
        // Get the primary key for all books.
        const char *sql = "SELECT key FROM nanobuddylist";
        sqlite3_stmt *statement;
		//NSString *queryStatementNS = @"select key, uid, uname, user_wordcount from nanobuddylist order by uname"; 
		//const char *sql = [queryStatementNS UTF8String];
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			NSLog(@"Got rows");
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
				NSLog(@"Setpping through row");
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
				NSLog(@"Initializing buddy");
                Buddy *buddy = [[Buddy alloc] initWithPrimaryKey:primaryKey database:database];
                [buddies addObject:buddy];
                [buddy release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
		sqlite3_close(database);
		NSLog(@"DB init ok");
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

// Use the SystemConfiguration framework to determine if the host that provides
// the RSS feed is available.
- (BOOL)isDataSourceAvailable
{
    static BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;    
        const char *host_name = "www.nanowrimo.org";
		
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
}

- (NSUInteger)countOfList {
	return [buddies count];
}

- (id)objectInListAtIndex:(NSUInteger)theIndex {
	return [buddies objectAtIndex:theIndex];
}

- (void)getList:(id *)objsPtr range:(NSRange)range {
	[buddies getObjects:objsPtr range:range];
}


// need to roll through buddy list and get data for each buddy, then update buddy
- (void)getBuddyData:(Buddy *)buddy
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSError *parseError = nil;
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XMLReader *streamingParser = [[XMLReader alloc] init];
	
	//Buddy *buddy = [buddies lastObject];	
	NSString *urlString = [feedURLString stringByAppendingString:buddy.uid];    
	[streamingParser setCurrentBuddyObject:buddy];
	[streamingParser parseXMLFileAtURL:[NSURL URLWithString:urlString] parseError:&parseError];
	
    [streamingParser release];        
    [pool release];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// This keeps blowing up. Need way to update cells individually.
- (void)reloadTable
{
	// not sure about this one...
    [[(RootViewController *)[self.navigationController topViewController] tableView] reloadData];
}

- (void)updateBuddyList:(Buddy *)myBuddy
{
	NSLog(@"updating buddy list");
	//NSLog(myBuddy.user_wordcount);
    //[self.buddies addObject:myBuddy];
    // The XML parser calls addToBuddyList: each time it creates a buddy object.
    // The table needs to be reloaded to reflect the new content of the list.
    [self reloadTable];
}

@end
