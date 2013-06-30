//
//  RootViewController.m
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import "NaNoWriMoBuddiesAppDelegate.h"
#import "RootViewController.h"
#import "AddBuddyViewController.h"
#import "Buddy.h"
#import "AppDelegateMethods.h"


@implementation RootViewController
@synthesize addButtonItem;

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		self.addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																		   target:self 
																		   action:@selector(addButtonWasPressed)];
	}
	return self;
}

- (void)addButtonWasPressed {
	//NSLog(@"Add Button pressed");
	AddBuddyViewController *addBuddyViewController;
	addBuddyViewController = [[AddBuddyViewController alloc] initWithNibName:@"AddBuddyViewController" bundle:nil];
	addBuddyViewController.delegate = self;
	[self.navigationController pushViewController:addBuddyViewController animated:YES];
	[addBuddyViewController release];
}

- (void)addBuddyIdentifiedBy:(NSString *)buddyId{
	NaNoWriMoBuddiesAppDelegate *appDelegate = (NaNoWriMoBuddiesAppDelegate *)[[UIApplication sharedApplication] delegate];
	Buddy *newBuddy = [[Buddy alloc] init];
	newBuddy.uid = buddyId;
	newBuddy.uname = @"New buddy not loaded yet";
	newBuddy.user_wordcount = @"0";
	[newBuddy insertIntoDatabase];
	[NSThread detachNewThreadSelector:@selector(getBuddyData:) toTarget:appDelegate withObject:newBuddy];
	[appDelegate.buddies addObject:newBuddy];
	NSIndexPath *indexPath;
	indexPath = [NSIndexPath indexPathForRow:[appDelegate.buddies indexOfObject:newBuddy] inSection:0];
	[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NaNoWriMoBuddiesAppDelegate *appDelegate = (NaNoWriMoBuddiesAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.buddies count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Buddy";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //	if (cell == nil) {
	//        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	//    }
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	}
    
    // Set up the cell
	NaNoWriMoBuddiesAppDelegate *appDelegate = (NaNoWriMoBuddiesAppDelegate *)[[UIApplication sharedApplication] delegate];
	Buddy *buddy = (Buddy *)[appDelegate.buddies objectAtIndex:indexPath.row];
	//NSString *myText = [buddy.uname stringByAppendingString:@" - "];
	//cell.text = [myText stringByAppendingString:buddy.user_wordcount];
	cell.textLabel.text = buddy.uname;
	cell.detailTextLabel.text = buddy.user_wordcount;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic -- create and push a new view controller
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = self.addButtonItem;
	NSLog(@"view did load in root view controller called");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		NaNoWriMoBuddiesAppDelegate *appDelegate = (NaNoWriMoBuddiesAppDelegate *)[[UIApplication sharedApplication] delegate];
		Buddy *buddy = [appDelegate.buddies objectAtIndex:indexPath.row];
		[buddy deleteFromDatabase];
		[appDelegate.buddies removeObjectAtIndex:indexPath.row];
		
    }  
	[tableView endUpdates];
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support conditional editing of the list
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support rearranging the list
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the list
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[addButtonItem release];
    [super dealloc];
}


@end

