//
//  Buddy.m
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import "Buddy.h"

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *update_user_wordcount_statement = nil;
static sqlite3_stmt *update_uname_statement = nil;

@implementation Buddy

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) {
        sqlite3_finalize(insert_statement);
        insert_statement = nil;
    }
    if (init_statement) {
        sqlite3_finalize(init_statement);
        init_statement = nil;
    }
    if (delete_statement) {
        sqlite3_finalize(delete_statement);
        delete_statement = nil;
    }
	if (update_user_wordcount_statement) {
        sqlite3_finalize(update_user_wordcount_statement);
        update_user_wordcount_statement = nil;
    }
	if (update_uname_statement) {
        sqlite3_finalize(update_uname_statement);
        update_uname_statement = nil;
    }
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
	NSLog(@"Initing Buddy with pk");
    if (self = [super init]) {
        primaryKey = pk;
        database = db;
        // Compile the query for retrieving buddy data. See insertNewBuddyIntoDatabase: for more detail.
        if (init_statement == nil) {
            const char *sql = "SELECT uid, uname, user_wordcount FROM nanobuddylist WHERE key=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			NSLog(@"in row");
            self.uid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			char *my_name = (char *)sqlite3_column_text(init_statement, 1);
			if (my_name) {
				self.uname = [NSString stringWithUTF8String:my_name];
			} else {
				self.uname = @"Unknown buddy";
			}
			char *my_count = (char *)sqlite3_column_text(init_statement, 2);
			if (my_count) {
				self.user_wordcount = [NSString stringWithUTF8String:my_count]; 
			} else {
				self.user_wordcount = @"0";
			}
			NSLog(self.uid);
			NSLog(self.uname);
			NSLog(self.user_wordcount);
        } else {
            self.uname = @"Unknown buddy";
			self.uid = @"000000";
			self.user_wordcount = @"0";
        }			
			
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
		sqlite3_close(database);
        dirty = NO;
    }
	
	return self;
}

- (void)insertIntoDatabase {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"nanobuddies.db"];
	NSLog(path);
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    sqlite3_stmt *dbps;
	
	//if (insert_statement == nil) {
		NSString *insertStatementNS = [[NSString alloc] initWithFormat:@"insert into \"nanobuddylist\" (uid, uname, user_wordcount) values (\"%@\", \"New buddy not loaded\", \"0\")", uid];
		NSLog(insertStatementNS);
        //static char *sql = "INSERT INTO nanobuddylist (uid) VALUES (?)";
		const char *insertStmt = [insertStatementNS UTF8String];
		int insertLength = [insertStatementNS length];
        if (sqlite3_prepare_v2(database, insertStmt, insertLength, &dbps, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    //}
    //sqlite3_bind_text(insert_statement, 1, [uid UTF8String], -1, SQLITE_TRANSIENT);
    //int success = sqlite3_step(insert_statement);
	int success = sqlite3_step(dbps);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_reset(insert_statement);
	if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey = sqlite3_last_insert_rowid(database);
    }
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    // hydrated = YES;
	sqlite3_finalize(dbps);
	}
    sqlite3_close(database);
}

- (void)updateWordCount:(sqlite3 *)db {
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (update_user_wordcount_statement == nil) {
        static char *sql = "UPDATE nanobuddylist set user_wordcount=? where key=?";
        if (sqlite3_prepare_v2(database, sql, -1, &update_user_wordcount_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(update_user_wordcount_statement, 1, [user_wordcount UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_user_wordcount_statement, 2, primaryKey);
    int success = sqlite3_step(update_user_wordcount_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(update_user_wordcount_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(database));
    }
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    // hydrated = YES;
	sqlite3_close(database);
}

- (void)updateUserName:(sqlite3 *)db {
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (update_uname_statement == nil) {
        static char *sql = "UPDATE nanobuddylist set uname=? where key=?";
        if (sqlite3_prepare_v2(database, sql, -1, &update_uname_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(update_uname_statement, 1, [uname UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_uname_statement, 2, primaryKey);
    int success = sqlite3_step(update_uname_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(update_uname_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to update the database with message '%s'.", sqlite3_errmsg(database));
    }
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    // hydrated = YES;
	sqlite3_close(database);
}


- (void)dealloc {
    [uid release];
    [uname release];
    [user_wordcount release];
    [super dealloc];
}

- (void)deleteFromDatabase {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"nanobuddies.db"];
	NSLog(path);
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		
    // Compile the delete statement if needed.
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM nanobuddylist WHERE key=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
	}
	sqlite3_close(database);
}
/*
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)hydrate {
    // Check if action is necessary.
    if (hydrated) return;
    // Compile the hydration statement, if needed.
    if (hydrate_statement == nil) {
        const char *sql = "SELECT author, copyright FROM book WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement);
    if (success == SQLITE_ROW) {
        char *str = (char *)sqlite3_column_text(hydrate_statement, 0);
        self.author = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.copyright = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(hydrate_statement, 1)];
    } else {
        // The query did not return 
        self.author = @"Unknown";
        self.copyright = [NSDate date];
    }
    // Reset the query for the next use.
    sqlite3_reset(hydrate_statement);
    // Update object state with respect to hydration.
    hydrated = YES;
}

// Flushes all but the primary key and title out to the database.
- (void)dehydrate {
    if (dirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement == nil) {
            const char *sql = "UPDATE book SET title=?, author=?, copyright=? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(dehydrate_statement, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(dehydrate_statement, 2, [author UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(dehydrate_statement, 3, [copyright timeIntervalSince1970]);
        sqlite3_bind_int(dehydrate_statement, 4, primaryKey);
        // Execute the query.
        int success = sqlite3_step(dehydrate_statement);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    // if dehydrate is called multiple times.
    [author release];
    author = nil;
    [copyright release];
    copyright = nil;
    [data release];
    data = nil;
    // Update the object state with respect to hydration.
    hydrated = NO;
}
*/
#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey {
    return primaryKey;
}

- (NSString *)uid {
    return uid;
}

- (void)setUid:(NSString *)aString {
    if ((!uid && !aString) || (uid && aString && [uid isEqualToString:aString])) return;
    dirty = YES;
    [uid release];
    uid = [aString copy];
}

- (NSString *)uname {
    return uname;
}

- (void)setUname:(NSString *)aString {
    if ((!uname && !aString) || (uname && aString && [uname isEqualToString:aString])) return;
    dirty = YES;
    [uname release];
    uname = [aString copy];
	[self updateUserName:database];
}

- (NSString *)user_wordcount {
    return user_wordcount;
}

- (void)setUser_wordcount:(NSString *)aString {
    if ((!user_wordcount && !aString) || (user_wordcount && aString && [user_wordcount isEqualToString:aString])) return;
    [user_wordcount release];
    user_wordcount = [aString copy];
	[self updateWordCount:database];
}

@end
