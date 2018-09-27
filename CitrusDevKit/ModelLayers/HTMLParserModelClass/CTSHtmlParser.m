//
//  CTS_HTMLParser.m
//  HTMLParser
//
//  Created by Vikas Singh on 11/13/15.
//  Copyright © 2015 Vikas Singh. All rights reserved.
//

#import "CTSHtmlParser.h"

@implementation CTSHtmlParser



-(id) loadHtmlByURL:(NSString *)urlString
{

//    NSURL *url = [NSURL fileURLWithPath:urlString];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSData *data = [[NSData alloc]
//                      initWithContentsOfURL:url];
   
    NSData* data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    self.elementArray = [[NSMutableArray alloc] init];
    self.parser = [[NSXMLParser alloc] initWithData:data];
    self.parser.delegate = self;
    [self.parser parse];
    self.currentHTMLElement = [[CTSHtmlElement alloc]init];
    return self;
}


- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementname
                                         namespaceURI:(NSString *)namespaceURI
                                        qualifiedName:(NSString *)qName
                                           attributes:(NSDictionary *)attributeDict
{
    if (!self.currentHTMLElement) {
         self.currentHTMLElement = [[CTSHtmlElement alloc]init];
    }
   
}


- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.currentNodeContent = (NSMutableString *) [string
                                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementname
                                       namespaceURI:(NSString *)namespaceURI
                                      qualifiedName:(NSString *)qName
{
//    if ([elementname isEqualToString:@"title"])
//    {
//        self.currentHTMLElement.tag = elementname;
//        self.currentHTMLElement.value = self.currentNodeContent;
//        [self.elementArray addObject:self.currentHTMLElement];
//        self.currentHTMLElement = nil;
//        self.currentNodeContent = nil;
//    }
    if ([elementname isEqualToString:@"h2"])
    {
        self.currentHTMLElement.tag = elementname;
        self.currentHTMLElement.value = self.currentNodeContent;
        if (self.currentHTMLElement.value.length>0) {
            [self.elementArray addObject:self.currentHTMLElement];
        }
        self.currentHTMLElement = nil;
        self.currentNodeContent = nil;
    }
//    if ([elementname isEqualToString:@"p"])
//    {
//        self.currentHTMLElement.tag = elementname;
//        self.currentHTMLElement.value = self.currentNodeContent;
//        [self.elementArray addObject:self.currentHTMLElement];
//        self.currentHTMLElement = nil;
//        self.currentNodeContent = nil;
//    }
    if ([elementname isEqualToString:@"div"])
    {
        self.currentHTMLElement.tag = elementname;
        self.currentHTMLElement.value = self.currentNodeContent;
        if (self.currentHTMLElement.value.length>0) {
            [self.elementArray addObject:self.currentHTMLElement];
        }
        self.currentHTMLElement = nil;
        self.currentNodeContent = nil;
    }
}



@end
