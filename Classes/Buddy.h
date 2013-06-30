//
//  Buddy.h
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Buddy : NSObject {
	// Opaque reference to the underlying database.
    sqlite3 *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Attributes.
    NSString *uid;
    NSString *uname;
    NSString *user_wordcount;
    // Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    // BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;	
}

// Property exposure for primary key and other attributes. The primary key is 'assign' because it is not an object, 
// nonatomic because there is no need for concurrent access, and readonly because it cannot be changed without 
// corrupting the database.
@property (assign, nonatomic, readonly) NSInteger primaryKey;
// The remaining attributes are copied rather than retained because they are value objects.
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *uname;
@property (copy, nonatomic) NSString *user_wordcount;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key and uname and user_wordcount is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Inserts the buddy into the database and stores its primary key.
- (void)insertIntoDatabase;
- (void)updateWordCount:(sqlite3 *)database;
- (void)updateUserName:(sqlite3 *)database;

// May change implementation of this since I really want all three items in memory at one time.
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
// - (void)hydrate;
// Flushes all but the primary key and title out to the database.
// - (void)dehydrate;
// Remove the buddy complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

@end
