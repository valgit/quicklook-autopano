//
//  AutopanoReader.m
//  quicklook-autopano
//
//  Created by val on 06/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AutopanoReader.h"

@implementation AutopanoReader

- (void)dealloc;
{
    //[_dataStr dealloc];
    [super dealloc];    
}

- (id) initWithURL:(NSURL*)url;
{
    
    self = [super init];
	if (self != nil)
	{
        NSError *error = nil;
        
        NSString *fileContents=[NSString stringWithContentsOfURL:url  
                                                         encoding:NSASCIIStringEncoding  
                                                            error:&error]; // not used for now
        
        // TODO: should check error here 
        if( fileContents == nil ) NSLog( @"Error loading file: %@", error );
        //NSLog(@"%@ \n===\n",fileContents);
        //
        error = nil;
        NSString *regexStr = @"<Width>(.*)</Width>";
        NSRegularExpression *testRegex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
        if( testRegex == nil ) NSLog( @"Error making regex: %@", error );
        NSTextCheckingResult *result = [testRegex firstMatchInString:fileContents 
                                                             options:0 
                                                               range:NSMakeRange(0, [fileContents length])];
        NSRange range = [result rangeAtIndex:1];
        _width = [[fileContents substringWithRange:range] intValue];
        
        regexStr = @"<Height>(.*)</Height>";
        testRegex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
        if( testRegex == nil ) NSLog( @"Error making regex: %@", error );
        result = [testRegex firstMatchInString:fileContents 
                                       options:0 
                                         range:NSMakeRange(0, [fileContents length])];
        range = [result rangeAtIndex:1];
        _height = [[fileContents substringWithRange:range] intValue];
        
        regexStr = @"<Data>(.*)</Data>";
        testRegex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionDotMatchesLineSeparators error:&error];
        if( testRegex == nil ) NSLog( @"Error making regex: %@", error );
        result = [testRegex firstMatchInString:fileContents 
                                       options:0 
                                         range:NSMakeRange(0, [fileContents length])];
        range = [result rangeAtIndex:1];
        _dataStr = [fileContents substringWithRange:range];
        
    }
    return self;
}

- (size_t)width;
{
    return _width;
}

- (size_t)height;
{
    return _height;
}

/*
 - (NSString*) dataStr;
 {
 // - (unichar)characterAtIndex:(NSUInteger)index
 return _dataStr;
 }
 */

- (NSBitmapImageRep*) getThumbnail;
{
    NSUInteger i,n;
    
    // allocate enough memory for the thumbnail
    unsigned char *rawData = (unsigned char*) calloc([self height] * [self width] * 4, 
                                                     sizeof(unsigned char));   
    int n1,n2;
    unsigned char c;
    
    // convert ASCII hex to binary data
    for (i = 0,n=0; i < [_dataStr length]; i++) {
        c = [_dataStr characterAtIndex:i];
        if (c == '\r')    /* Doze style input file? */
            continue;
        
        n2 = n1;
        
        if (c >= '0' && c <= '9')
            n1 = c - '0';
        else if (c >= 'a' && c <= 'f')
            n1 = c - 'a' + 10;
        else if (c >= 'A' && c <= 'F')
            n1 = c - 'A' + 10;
        else
        {
            n1 = -1;
            continue;
        }
        //
        if (n2 >= 0 && n1 >= 0) {
            rawData[n++] = ((n2 << 4) | n1);
            n1 = -1;
        }
    }
    
    //printf("converted : %lu\n",n);
    size_t bytesPerRow = ((([self width] * 4)+ 0x0000000F) & ~0x0000000F); // 16 byte aligned is good

    // create the imagerep ARGB formt
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:(unsigned char **)&rawData
                                pixelsWide:[self width] pixelsHigh:[self height]
                                bitsPerSample:8
                                samplesPerPixel:4  // or 4 with alpha
                                hasAlpha:YES
                                isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bitmapFormat:NSAlphaFirstBitmapFormat
                                bytesPerRow:bytesPerRow  // 0 == determine automatically
                                bitsPerPixel:32];  // 0 == determine automatically
    
    //NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize([autopano width], 
    //                                                          [autopano height])];
    
    //[image addRepresentation:bitmap];
    free(rawData);
    
    return bitmap;
}

- (CGImageRef)thumbnail;
{
    return [[self getThumbnail] CGImage];
}

@end
