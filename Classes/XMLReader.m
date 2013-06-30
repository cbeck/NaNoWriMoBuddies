//
//  XMLReader.m
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/13/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import "XMLReader.h"

//static NSUInteger parsedBuddiesCounter;

@implementation XMLReader

@synthesize currentBuddyObject = _currentBuddyObject;
@synthesize contentOfCurrentBuddyProperty = _contentOfCurrentBuddyProperty;

// Limit the number of parsed earthquakes to 50. Otherwise the application may run very slowly on the device.
//#define MAX_BUDDIES 50

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //parsedBuddiesCounter = 0;
}

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
    
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"Parsing Element");
	NSLog(elementName);
    if (qName) {
        elementName = qName;
    }
	
    // If the number of parsed earthquakes is greater than MAX_ELEMENTS, abort the parse.
    // Otherwise the application runs very slowly on the device.
    //if (parsedBuddiesCounter >= MAX_BUDDIES) {
    //    [parser abortParsing];
    //}
    
    if ([elementName isEqualToString:@"wc"]) {
        
        //parsedBuddiesCounter++;
        
        // An entry in the RSS feed represents a buddy, so create an instance of it.
		// Actually, need to set current buddy object to be one we are working with
        //self.currentBuddyObject = [[Buddy alloc] init];
        // Add the new Buddy object to the application's array of buddies.
		NSLog(self.currentBuddyObject.user_wordcount);
       // [(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(updateBuddyList:) withObject:self.currentBuddyObject waitUntilDone:YES];
		NSLog(@"got wc element");
        return;
    }
	
	// not loading this - it is set in db
    if ([elementName isEqualToString:@"uid"]) {
        // Create a mutable string to hold the contents of the 'uid' element.
        // The contents are collected in parser:foundCharacters:.
        //self.contentOfCurrentEarthquakeProperty = [NSMutableString string];
		self.contentOfCurrentBuddyProperty = [NSMutableString string];
		NSLog(@"has uid");
	} else if ([elementName isEqualToString:@"error"]) {
		self.contentOfCurrentBuddyProperty = [NSMutableString string];
		NSLog(@"has error");
	} else if ([elementName isEqualToString:@"uname"]) {
        // Create a mutable string to hold the contents of the 'uname' element.
        // The contents are collected in parser:foundCharacters:.
        self.contentOfCurrentBuddyProperty = [NSMutableString string];
		NSLog(@"got uname");
        
    } else if ([elementName isEqualToString:@"user_wordcount"]) {
        // Create a mutable string to hold the contents of the 'user_wordcount' element.
        // The contents are collected in parser:foundCharacters:.
        self.contentOfCurrentBuddyProperty = [NSMutableString string];
		NSLog(@"got wordcount");
    } else {
        // The element isn't one that we care about, so set the property that holds the 
        // character content of the current element to nil. That way, in the parser:foundCharacters:
        // callback, the string that the parser reports will be ignored.
        self.contentOfCurrentBuddyProperty = nil;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
	
	NSLog(@"setting up object");
	NSLog(elementName);
    
	// again, we will not set this one.
    if ([elementName isEqualToString:@"uid"]) {
        //self.currentBuddyObject.uid = self.contentOfCurrentEarthquakeProperty;
		NSLog(@"uid field");
		NSLog(self.contentOfCurrentBuddyProperty);
        
    } else if ([elementName isEqualToString:@"uname"]) {
        self.currentBuddyObject.uname = self.contentOfCurrentBuddyProperty;
		NSLog(@"setup uname");
		NSLog(self.contentOfCurrentBuddyProperty);
	
	} else if ([elementName isEqualToString:@"error"]) {
        //self.currentBuddyObject.uname = self.contentOfCurrentBuddyProperty;
		NSLog(@"setup uname error");
		NSLog(self.contentOfCurrentBuddyProperty);
		self.currentBuddyObject.uname = @"Inactive or Not found buddy";
		self.currentBuddyObject.user_wordcount = @"0";
		[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(updateBuddyList:) withObject:self.currentBuddyObject waitUntilDone:YES];
		
    } else if ([elementName isEqualToString:@"user_wordcount"]) {
        self.currentBuddyObject.user_wordcount = self.contentOfCurrentBuddyProperty;
		NSLog(@"setup wordcount");
		NSLog(self.contentOfCurrentBuddyProperty);
		NSLog(@"current buddy word count");
		NSLog(self.contentOfCurrentBuddyProperty);
		[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(updateBuddyList:) withObject:self.currentBuddyObject waitUntilDone:YES];
    }
	//[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(updateBuddyList:) withObject:self.currentBuddyObject waitUntilDone:YES];
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"in found characters");
	if (self.contentOfCurrentBuddyProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.contentOfCurrentBuddyProperty appendString:string];
    }
}

@end
