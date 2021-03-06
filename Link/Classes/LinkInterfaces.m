/*
 Copyright (c) 2015 funkensturm. https://github.com/halo/LinkLiar
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "LinkInterfaces.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import "LinkInterface.h"

@implementation LinkInterfaces

+ (LinkInterface*) interfaceByBSDNumber:(NSInteger)number {
  for (LinkInterface* interface in [self all]) {
    if (interface.BSDNumber == number) return interface;
  }
  return NULL;
}

+ (BOOL) leaking {
  for (LinkInterface* interface in [self all]) {
    if (interface.hasOriginalMAC) return YES;
  }
  return NO;
}

+ (NSArray*) all {
  NSMutableArray *result = [NSMutableArray new];
  @autoreleasepool {
    
    NSArray *interfaces = (NSArray*) CFBridgingRelease(SCNetworkInterfaceCopyAll());
    for (id interface_ in interfaces) {
      SCNetworkInterfaceRef interfaceRef = (__bridge SCNetworkInterfaceRef)interface_;

      LinkInterface* interface = [LinkInterface new];
      interface.BSDName = (__bridge NSString*)SCNetworkInterfaceGetBSDName(interfaceRef);
      interface.displayName = (__bridge NSString*)SCNetworkInterfaceGetLocalizedDisplayName(interfaceRef);
      interface.hardMAC = (__bridge NSString*)SCNetworkInterfaceGetHardwareAddressString(interfaceRef);
      interface.kind = (__bridge NSString*)SCNetworkInterfaceGetInterfaceType(interfaceRef);
      
      // It might be better to check for interface.kind == Ethernet or IEEE80211
      if (![interface.displayName containsString:@"Wi"] && ![interface.displayName containsString:@"thern"] && ![interface.displayName containsString:@"Air"]) continue;
      if (!interface.hardMAC) continue;
      if (!interface.softMAC) continue;
      
      [result addObject:interface];
    }
    
    return (NSArray*)result;
  }
}

@end
