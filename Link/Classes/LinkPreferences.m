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

#import "LinkPreferences.h"

#import "LinkInterface.h"

const NSString *InterfaceModifierFlag = @"modifier";
const NSString *InterfaceModifierRandom = @"random";
const NSString *InterfaceModifierDefine = @"define";
const NSString *InterfaceModifierOriginal = @"original";
const NSString *InterfaceModifierReset = @"reset";

@implementation LinkPreferences

+ (void) randomizeInterface:(LinkInterface*)interface {
  DDLogDebug(@"Remembering to randomize hardware MAC %@ of %@", interface.hardMAC, interface.displayNameAndBSDName);
  NSString *key = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierFlag];
  [self setObject:InterfaceModifierRandom forKey:key];
}

+ (void) originalizeInterface:(LinkInterface*)interface {
  DDLogDebug(@"Remembering to keep hardware MAC %@ of %@ in original state", interface.hardMAC, interface.displayNameAndBSDName);
  NSString *key = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierFlag];
  [self setObject:InterfaceModifierOriginal forKey:key];
}

+ (void) defineInterface:(LinkInterface*)interface withMAC:(NSString*)address {
  DDLogDebug(@"Defining hardware MAC %@ of %@ to be %@", interface.hardMAC, interface.displayNameAndBSDName, address);
  NSString *modifier = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierFlag];
  [self setObject:InterfaceModifierDefine forKey:modifier];
  NSString *flag = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierDefine];
  [self setObject:address forKey:flag];
}

+ (void) resetInterface:(LinkInterface*)interface {
  DDLogDebug(@"Remembering to reset MAC %@ of %@", interface.hardMAC, interface.displayNameAndBSDName);
  NSString *key = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierFlag];
  [self setObject:InterfaceModifierReset forKey:key];
}

+ (void) forgetInterface:(LinkInterface*)interface {
  DDLogDebug(@"Forgetting MAC %@ of %@", interface.hardMAC, interface.displayNameAndBSDName);
  NSString *key = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierFlag];
  [self removeObjectForKey:key];
}

+ (NSString*) definitionOfInterface:(LinkInterface*)interface {
  NSString *result = @"";
  if ([self modifierOfInterface:interface] == ModifierDefine) {
    NSString *key = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierDefine];
    NSString *address = [self getObjectForKey:key];
    if (address) result = address;
  }
  return result;
}

+ (NSUInteger) modifierOfInterface:(LinkInterface*)interface {
  NSString *key = [NSString stringWithFormat:@"%@.%@", interface.hardMAC, InterfaceModifierFlag];
  NSString *modifier = [NSString stringWithFormat:@"%@", [self getObjectForKey:key]];
  if ([InterfaceModifierRandom isEqualToString:modifier]) {
    return ModifierRandom;
  } else if ([InterfaceModifierDefine isEqualToString:modifier]) {
    return ModifierDefine;
  } else if ([InterfaceModifierOriginal isEqualToString:modifier]) {
    return ModifierOriginal;
  } else if ([InterfaceModifierReset isEqualToString:modifier]) {
    return ModifierReset;
  } else {
    //DDLogWarn(@"Don't know what to do with hardware MAC %@ of %@", interface.hardMAC, interface.displayNameAndBSDName);
    return ModifierUnknown;
  }
}

/*
+ (NSString*) preferenceFilePath {
  NSString *path = @"~/Library/Preferences";
  path = [path stringByExpandingTildeInPath];
  path = [path stringByAppendingPathComponent:[self bundleID]];
  return path;
}
 */

+ (void) setObject:(id)object forKey:(NSString*)key {
  [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) removeObjectForKey:(NSString*)key {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) getObjectForKey:(NSString*)key {
  return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

@end