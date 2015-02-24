/*
 * Apple System Management Control (SMC) Tool
 * Copyright (C) 2015 Perceval Faramaz
 *
 * The MIT License (MIT)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "SMBWrapper.h"
static SMBWrapper *sharedInstance = nil;

@interface SMBWrapper() //private methods
  
@end

@implementation SMBWrapper //public methods
/**
 * sharedWrapper - Singleton instance retrieval method. Used to get an instance of SMBWrapper.
 */
+(SMBWrapper *) sharedWrapper{
	if ( sharedInstance == nil ){
		sharedInstance = [[SMBWrapper alloc] init];
	}
	return sharedInstance;
}

/**
 * dump - Calls "AppleSMBIOS" IOService to get SMBIOS tables
 */
-(CFDataRef) dump {
    mach_port_t myMasterPort;
    IOMasterPort(MACH_PORT_NULL, &myMasterPort);
    CFMutableDictionaryRef        myMatchingDictionary;
    
    io_object_t                   foundService;
    myMatchingDictionary = IOServiceMatching("AppleSMBIOS");
    foundService = IOServiceGetMatchingService( myMasterPort, myMatchingDictionary );
    
    CFMutableDictionaryRef    properties    = NULL;
    CFDataRef                 smbiosdata;
    
    IORegistryEntryCreateCFProperties( foundService,
                                      &properties,
                                      kCFAllocatorDefault,
                                      kNilOptions );
    
    CFDictionaryGetValueIfPresent( properties,
                                  CFSTR("SMBIOS"),
                                  (const void **)&smbiosdata );
    
    /*FILE* f;
     CFIndex len = CFDataGetLength(smbiosdata);
     UInt8* data = new UInt8[len];
     CFDataGetBytes(smbiosdata, CFRangeMake(0, len), data);
     
     f = fopen("dump.bin","w");
     fwrite(data, len, 1, f);
     fclose(f);
     
     return 0;*/
    return smbiosdata;
}

/**
 * init - Creates an instance of SMBWrapper
 */
-(id) init
{
	self = [super init];
	if (self) {
		[self _SMBDump]; //dumps SMBIOS
	}
	return self;
}

/**
 * dealloc - 
 */
-(void) dealloc
{
	return;
}
@end
