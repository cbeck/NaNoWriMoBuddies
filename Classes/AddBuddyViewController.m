//
//  AddBuddyViewController.m
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import "AddBuddyViewController.h"


@implementation AddBuddyViewController
@synthesize buddyTextField;
@synthesize delegate;
/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

- (IBAction)addBuddyButtonWasPressed:(id)sender{
	NSLog(@"Add Buddy Button pressed");
	NSLog(buddyTextField.text);
	[delegate addBuddyIdentifiedBy:buddyTextField.text];
	NSLog(@"delegate completed");
	[buddyTextField resignFirstResponder];
	NSLog(@"first responder resigned");
	[self.navigationController popViewControllerAnimated:YES];
	NSLog(@"nav controller view popped.");
	// gave me a warning about this return - says it returns void
	// return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[delegate addBuddyIdentifiedBy:textField.text];
	[textField resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
	return YES;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    buddyTextField.returnKeyType = UIReturnKeyDone;
	buddyTextField.delegate = self;
	[buddyTextField becomeFirstResponder];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[buddyTextField release];
	[delegate release];
    [super dealloc];
}


@end
