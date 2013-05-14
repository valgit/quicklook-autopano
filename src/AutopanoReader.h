//
//  AutopanoReader.h
//  quicklook-autopano
//
//  Created by val on 06/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AutopanoReader : NSObject {
    
    float *red, *green, *blue;
    size_t _width, _height;   // width and height
    uint8 spp;          // samples per pixel
    uint8 bps;          // bit per sample
    uint8 channels;     // channels
    uint  cp;           // color depth (#colors)
    
    NSString* _dataStr;
}

// general case
- (id) initWithURL:(NSURL*)url;
- (void)dealloc;

- (CGImageRef)thumbnail;
- (NSBitmapImageRep*) getThumbnail;
- (size_t)width;
- (size_t)height;
//- (NSString*) dataStr;

@end
