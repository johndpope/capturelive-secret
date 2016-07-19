//
//  Validator.m
//  CaptureMedia-Acme
//
//  Created by hatebyte on 11/6/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

#import "CMValidator.h"

static NSString *const INVALID_NAME_CHARACTERS      = @".*[0-9/:;!~&=#@`_%£€¥•\(\\)\\$\"\\|\{\\}\?\\^\\*\\+]+.*";

@implementation CMValidator

+ (NSString *)camelCaseToUnderscore:(NSString *)dataAttribute {
    NSRegularExpression *capitals                   = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]"
                                                                                                options:0
                                                                                                  error:nil];
    dataAttribute                                   = [capitals stringByReplacingMatchesInString:dataAttribute
                                                                                         options:0
                                                                                           range:NSMakeRange(0, dataAttribute.length)
                                                                                    withTemplate:@"_$0"];
    return [dataAttribute lowercaseString];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)createUid {
    CFUUIDRef newUniqueId                                                       = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uidString                                                         = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    return [uidString lowercaseString];
}

+ (BOOL)validateText: (NSString *)text withRegex:(NSString *)regex {
    NSPredicate *validateTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [validateTest evaluateWithObject:text];
}

+(NSString *)filterStringForSearch:(NSString *)search {
    NSString *filteredText = [search stringByReplacingOccurrencesOfString:@"*" withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"^" withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"/" withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"'" withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"." withString:@""];
    return filteredText;
}

+ (NSString *)invalidFirstNameCharacters {
    return INVALID_NAME_CHARACTERS;
}

+ (NSString *)invalidLastNameCharacters {
    return INVALID_NAME_CHARACTERS;
}

+ (NSString *)isFirstNameValid:(NSString *)text {
    if (text.length == 0) {
        return  NSLocalizedString(@"Please enter your first name.", @"user didnt fill firstname field error msg");
    } else if ([self stringWithoutWhiteSpace:text].length < 2 || text.length > 18) {
        return  NSLocalizedString(@"First name shoud be between 2-18 characters", @"firstname is not proper length error msg");
    } else if ([self validateText:text withRegex:[self invalidFirstNameCharacters]]) {
        return  NSLocalizedString(@"Please use letters only in your first name.", @"firstname has invalid characters error msg");
    }
    return VALID_INPUT;
}

+ (NSString *)isLastNameValid:(NSString *)text {
    if (text.length == 0) {
        return  NSLocalizedString(@"Please enter your last name.", @"user didnt fill lastname field error msg");
    } else if ([self stringWithoutWhiteSpace:text].length < 2 || text.length > 18) {
        return  NSLocalizedString(@"Last name shoud be between 2-18 characters", @"lastname is not proper length error msg");
    } else if ([self validateText:text withRegex:[self invalidLastNameCharacters]]) {
        return  NSLocalizedString(@"Please use letters only in your last name.", @"lastname has invalid characters error msg");
    }
    return VALID_INPUT;
}

+ (NSDictionary*)breakUpFirstAndLastName:(NSString*)fullname {
    NSArray *components = [fullname componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSString *lastname = [components objectAtIndex:components.count-1];
    NSString *firstname = [fullname stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",lastname] withString:@""];
    
    if ([firstname isEqualToString:@""]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:lastname, @"firstName",  @"", @"lastName", nil];
    } else {
        return [NSDictionary dictionaryWithObjectsAndKeys:firstname, @"firstName",  lastname, @"lastName", nil];
    }
}

+ (NSString *)isUserNameValid:(NSString *)text {
    if (text.length <= 1) {
        return  NSLocalizedString(@"Please enter a username.", @"user didnt fill username field error msg");
    } else if (text.length > 20) {
        return  NSLocalizedString(@"Well, your username cannot exceed 20 characters.", @"user didnt fill username field error msg");
    } else if (![CMValidator validateText:[text substringFromIndex:1] withRegex:@"^[A-Z0-9a-z]*([._-][A-Z0-9a-z]+){0,3}$"]) {
        return  NSLocalizedString(@"Username is invalid.", @"username has invalid characters error msg");
    }
    return VALID_INPUT;
}

+ (NSString *)isEmailValid:(NSString *)text {
    if (text.length == 0) {
        return NSLocalizedString(@"Please enter your email address.", @"user didnt fill email field error msg");
    } else if (![CMValidator validateText:text withRegex: @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"]) {
        return NSLocalizedString(@"Invalid email address.", @"malformed email error msg");
    }
    return VALID_INPUT;
}

+ (NSString *)isUrlValid:(NSString *)text {
    NSString *urlRegEx =  @"(?<=(\\s|^))((http|https)://)?([-\\da-zA-Z]+\\.)+([a-z]{2,6})(/+[-\\da-zA-Z?&=_%]*)*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    if ([urlTest evaluateWithObject:text]) {
        return VALID_INPUT;
    } else {
        return NSLocalizedString(@"Invalid url.", @"malformed url error msg");
    }
}

//The password length must be greater than or equal to 6
//The password cannot have special characters
+ (NSString *)isPasswordValid:(NSString *)text {
    if (text.length == 0) {
        return NSLocalizedString(@"Please create a password.", @"user didnt fill password field error msg");
    } else if (![CMValidator validateText:text withRegex:@"^(?=.*[A-Za-z])[A-Za-z\\d]{8,}$"]) {
        return NSLocalizedString(@"Password must be at least 8 characters with no special characters.", @"password has invalid characters error msg");
    } else if (text.length < 8) {
        return NSLocalizedString(@"Password must be at least 8 characters with no special characters.", @"short pass error msg");
    }
    return VALID_INPUT;
}

+ (NSString *)isWorkValid:(NSString *)text {
    if (text.length > 100) {
        return NSLocalizedString(@"Work has to be less than 100 characters.", @"work exceeded 100 characters msg");
    }
    return VALID_INPUT;
}

+ (NSString *)isSchoolValid:(NSString *)text {
    if (text.length > 100) {
        return NSLocalizedString(@"School has to be less than 100 characters.", @"school exceeded 100 characters msg");
    }
    return VALID_INPUT;
}

+ (NSString *)isBirthdateValid:(NSString *)text {
    return text.length >= 8 ? NSLocalizedString(@"Please enter a valid date of birth.", @"user didnt fill birthday field error msg") : VALID_INPUT;
}

+ (NSString *)formatUserName:(NSString*)text {
    NSString *at = [NSString stringWithFormat:@"@"];
    if (text.length == 0) {
        return at;
    }
    if (![[text substringWithRange:NSMakeRange(0, 1)] isEqualToString:at]) {
        return [at stringByAppendingString:text];
    }
    return text;
}

+ (NSString*)unFormatPhoneNumber:(NSString*)text  {
    text = [text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@")" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"." withString:@""];
    return text;
}

+ (NSString *)formatPhoneNumber:(NSString*)text {
    NSString *unformatted = [self unFormatPhoneNumber:text];
    int countryCodeLength = (int)unformatted.length - 10;
    if (countryCodeLength > 0) {
        NSString *code                          = [NSString stringWithFormat:@"%@+ ",[unformatted substringToIndex:countryCodeLength] ];
        unformatted                             = [unformatted substringWithRange:NSMakeRange(countryCodeLength, unformatted.length - countryCodeLength)];
        return [NSString stringWithFormat:@"%@(%@) %@-%@", code, [unformatted  substringToIndex:3], [unformatted substringWithRange:NSMakeRange(3,3)], [unformatted substringFromIndex:6]];
    } else {
        return [NSString stringWithFormat:@"(%@) %@-%@", [unformatted  substringToIndex:3], [unformatted substringWithRange:NSMakeRange(3,3)], [unformatted substringFromIndex:6]];
    }
}

+ (id)formatPhoneNumber:(NSString*)text withRange:(NSRange)range {
    NSString *unformatted = [self unFormatPhoneNumber:text];
    int unformattedLength = (int)unformatted.length;
    NSString *digits =(unformattedLength >= 14) ? [unformatted substringToIndex:14] : unformatted;
   
    switch (unformattedLength) {
        case 3:
            if(range.length > 0) {
                return [NSString stringWithFormat:@"%@",[digits substringToIndex:3]];
            } else {
                return [NSString stringWithFormat:@"(%@) ", digits];
            }
            break;
        case 6:
            if(range.length > 0) {
                return [NSString stringWithFormat:@"(%@) %@",[digits substringToIndex:3],[digits substringFromIndex:3]];
            } else {
                return [NSString stringWithFormat:@"(%@) %@-", [digits  substringToIndex:3],[digits substringFromIndex:3]];
        }
            break;
        case 10 :
        case 11 :
        case 12 :
        case 13 : {
            if(range.length > 0 ) {
                return [self formatInternationalNumberForDeletion:digits];
            } else {
                return [self formatInternationalNumberForAddition:digits];
            }
        }
            break;
        case 14:
            if(range.length > 0 ) {
                return [self formatInternationalNumberForDeletion:digits];
            } else {
                return REACHED_MAX_LENGTH;
            }
            break;
    }
    
    return text;
}

+ (NSString *)formatInternationalNumberForAddition:(NSString *)text {
    int countryCodeLength                       = (int)text.length - 9;
    NSString *code                              = @"";
    if (countryCodeLength > 0) {
        code                                    = [NSString stringWithFormat:@"%@+ ",[text substringToIndex:countryCodeLength] ];
        text                                    = [text substringWithRange:NSMakeRange(countryCodeLength, text.length - countryCodeLength)];
    } else {
        countryCodeLength = 0;
    }
    return [NSString stringWithFormat:@"%@(%@) %@-%@", code, [text  substringToIndex:3], [text substringWithRange:NSMakeRange(3,3)], [text substringFromIndex:6]];
}

+ (NSString *)formatInternationalNumberForDeletion:(NSString *)text {
    int countryCodeLength                       = (int)text.length - 10;
    NSString *code                              = @"";
    if (countryCodeLength >= 2) {
        code                                    = [NSString stringWithFormat:@"%@+ ", [text substringToIndex:countryCodeLength-1] ];
        text                                    = [text substringFromIndex:countryCodeLength-1];
        return [NSString stringWithFormat:@"%@(%@) %@-%@", code, [text  substringToIndex:3], [text substringWithRange:NSMakeRange(3,3)], [text substringWithRange:NSMakeRange(6, text.length - 6)]];
    }
    return [NSString stringWithFormat:@"(%@) %@-%@", [text  substringToIndex:3], [text substringWithRange:NSMakeRange(3,3)], [text substringWithRange:NSMakeRange(6, text.length - 6)]];
}

+ (NSString *)validatePhoneNumber:(NSString*)text {
    return (![self isValidPhoneNumber:text]) ? NSLocalizedString(@"Invalid telephone number.", @"phonenumber is not proper length error msg") : VALID_INPUT;
}

+ (BOOL)isValidPhoneNumber:(NSString*)text {
    NSString *unformatted                       = [self unFormatPhoneNumber:text];
    NSString *badcharacters                     = [[unformatted componentsSeparatedByCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] componentsJoinedByString:@""];
    if (badcharacters.length > 0) {
        return false;
    }
    return ( (unformatted.length > 9) && (unformatted.length <= 14) );
}

+ (NSString *)stringWithoutWhiteSpace:(NSString*)text {
    return [text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString*)stripSpecialCharacters:(NSString*)text {
    return [self stripSpecialCharacters:text exceptCharacters:@""];
}

+ (NSString*)stripSpecialCharacters:(NSString*)text exceptCharacters:(NSString*)exceptions {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:[@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" stringByAppendingString:exceptions]] invertedSet];
    NSArray *components = [text componentsSeparatedByCharactersInSet:notAllowedChars];
    return [components objectAtIndex:1];
}

+ (NSString*)stripReturns:(NSString *)text {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\r|\\n)+" options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@"\\\n"];
}

+ (NSString*)removeBadEndsFromUserName:(NSString*)username {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:[@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" stringByAppendingString:@".-_"]] invertedSet];
    username = [[username componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSString *lastCharacter = [username substringFromIndex:username.length-1];
    if ([lastCharacter rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@".-_"]].location != NSNotFound && username.length > 1) {
        return [self removeBadEndsFromUserName:[username substringToIndex:username.length-1]];
    } else {
        return username;
    }
}

+ (NSArray *)searchStringForResults:(NSString *)text withPattern:(NSString *)regexString {
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionUseUnixLineSeparators error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
    }
    
    NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    return results;
}

+ (NSString *)correctForHttps:(NSString *)url {
    NSString *protocol = @"http://";
    if ([url rangeOfString:@"https"].location != NSNotFound) {
        protocol = @"https://";
    }
    NSString* stringWithoutHttp             = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    stringWithoutHttp                       = [stringWithoutHttp stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    return [NSString stringWithFormat:@"%@%@", protocol, stringWithoutHttp];
}

@end


NSUInteger NAME_LENGTH_MAX             = 18;
NSString *VALID_INPUT                  = @"VALID_INPUT";
NSString *REACHED_MAX_LENGTH           = @"max_length_reached";
