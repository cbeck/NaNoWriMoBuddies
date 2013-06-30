//
//  XMLReader.h
//  NaNoWriMoBuddies
//
//  Created by Chris Beck on 11/13/08.
//  Copyright 2008, Netphase, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Buddy.h"

/*
 To get the current wordcount, use the following URL, using your numerical uid.
 
 http://www.nanowrimo.org/wordcount_api/wc/405940 
 
 If you are currently logged in, your uid is shown in the example above. You can find any user's uid by navigating to their profile page and examining the URL.
 
 The current wordcount will be returned in an XML structure:
 
 <!DOCTYPE wc [
 <!ELEMENT wc (uid, error, uname, user_wordcount)>
 <!ELEMENT uid (#PCDATA)>
 <!ELEMENT error (#PCDATA)>
 <!ELEMENT uname (#PCDATA)>
 <!ELEMENT user_wordcount (#PCDATA)>
 ]>
 
 For example, you might see:
 
 <wc>
 <uid>30837</uid>
 <uname>NewMexicoKid</uname>
 <user_wordcount>2699</user_wordcount>
 </wc>
 
 When NSXMLParser encounters a <wc> element, it invokes the delegate method parser:didStartElement:namespaceURI:qualifiedName:attributes:.
 This sample's implementation of that method instantiates an instance of the Earthquake class and adds it to the list of objects
 that the application's delegate manages.
 
 When NSXMLParser reports an element other than a <wc> element, in parser:didStartElement:namespaceURI:qualifiedName:attributes:
 this sample allocates an NSMutableString and sets the contentOfCurrentEarthquakeProperty property, which is used to hold
 the content of child elements of the current <wc> element.
 
 For example, if the current element is <uid>, the sample creates a mutable string for the contentOfCurrentEarthquakeProperty property.
 When NSXMLParser reports that it found characters in the parser:foundCharacters: delegate method, those characters are 
 appended to the contentOfCurrentEarthquakeProperty mutable string. 
 
 When the parser finishes processing an element, it invokes the delegate method 
 parser:didEndElement:namespaceURI:qualifiedName:. At that point, the sample sets the value of the property in the current
 Earthquake object (the currentEarthquakeObject property) to the value of the contentOfCurrentEarthquakeProperty string.
 
 */

@interface XMLReader : NSObject {
	
@private  
	Buddy *_currentBuddyObject;
    NSMutableString *_contentOfCurrentBuddyProperty;

}

@property (nonatomic, retain) Buddy *currentBuddyObject;
@property (nonatomic, retain) NSMutableString *contentOfCurrentBuddyProperty;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;


@end
