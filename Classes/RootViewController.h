//
//  RootViewController.h
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface RootViewController : UITableViewController {
	UIBarButtonItem *addButtonItem;
	sqlite3 *database;
}
@property (nonatomic, retain) UIBarButtonItem *addButtonItem;

- (void)addButtonWasPressed;
- (void)addBuddyIdentifiedBy:(NSString *)buddyId;
@end
