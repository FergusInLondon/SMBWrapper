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
-(BOOL) _SMBIOSdump;
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
-(BOOL) _SMBIOSdump {
    mach_port_t 					myMasterPort;
    CFMutableDictionaryRef        	myMatchingDictionary;
	kern_return_t					result;
    io_object_t                   	foundService;
	
    IOMasterPort(MACH_PORT_NULL, &myMasterPort);
	
    myMatchingDictionary = IOServiceMatching("AppleSMBIOS");
    foundService = IOServiceGetMatchingService( myMasterPort, myMatchingDictionary );
	if (foundService == 0)
	{
#ifdef DEBUG_msg
		printf("Error: IOServiceGetMatchingService() = %08x\n", foundService);
#endif
		printf("No \"AppleSMBIOS\" IOService in IORegistry");
		return false;
	}
    
    CFMutableDictionaryRef    properties    = NULL;
    CFDataRef                 smbiosdata;
    
    result = IORegistryEntryCreateCFProperties( foundService,
                                      &properties,
                                      kCFAllocatorDefault,
                                      kNilOptions );
	if (result != kIOReturnSuccess)
	{
#ifdef DEBUG_msg
		printf("Error: IORegistryEntryCreateCFProperties() = %08x\n", result);
#endif
		printf("No data in \"AppleSMBIOS\" IOService");
		return false;
	}
	
    result = CFDictionaryGetValueIfPresent( properties,
                                  CFSTR("SMBIOS"),
                                  (const void **)&smbiosdata );
	if (result != true)
	{
#ifdef DEBUG_msg
		printf("Error: CFDictionaryGetValueIfPresent() = %08x\n", result);
#endif
		printf("No \"SMBIOS\" property in \"AppleSMBIOS\" IOService");
		return false;
	}
	
    _SMBIOSdump = smbiosdata;
	//NSLog(@"%@", _SMBIOSdump);
	return true;
}

/**
 * init - Creates an instance of SMBWrapper
 */
-(id) init
{
	self = [super init];
	if (self) {
		[self _SMBIOSdump]; //dumps SMBIOS
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
