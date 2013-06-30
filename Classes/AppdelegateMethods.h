/*
 *  AppdelegateMethods.h
 *  NaNoWriMoBuddies
 *
 *  Created by Chris Beck on 11/13/08.
 *   Copyright 2008, Netphase, LLC. All rights reserved.
 *
 */
@class Buddy, NaNoWriMoBuddiesAppDelegate;

@interface NaNoWriMoBuddiesAppDelegate (AppDelegateMethods)

//- (void)showBuddyInfo:(Earthquake *)dictionary;
- (void)updateBuddyList:(Buddy *)bud;
- (BOOL)isDataSourceAvailable;

@end

