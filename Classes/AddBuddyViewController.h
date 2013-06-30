//
//  AddBuddyViewController.h
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/12/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"RootViewController.h"


@interface AddBuddyViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *buddyTextField;
	RootViewController *delegate;
}
@property (nonatomic, retain) UITextField *buddyTextField;
@property (nonatomic, retain) RootViewController *delegate;

- (IBAction)addBuddyButtonWasPressed:(id)sender;
@end
