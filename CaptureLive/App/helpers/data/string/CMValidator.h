//
//  Validator.h
//  CaptureMedia-Acme
//
//  Created by hatebyte on 11/6/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger NAME_LENGTH_MAX;
extern NSString *VALID_INPUT;
extern NSString *REACHED_MAX_LENGTH;

@interface CMValidator : NSObject

+ (NSString *)camelCaseToUnderscore:(NSString *)dataAttribute;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)createUid;
+ (BOOL)validateText: (NSString *)text withRegex:(NSString *)regex;
+ (NSString *)filterStringForSearch:(NSString *)search;
+ (NSString *)isFirstNameValid:(NSString *)text;
+ (NSString *)isLastNameValid:(NSString *)text;
+ (NSDictionary*)breakUpFirstAndLastName:(NSString*)fullname;
+ (NSString *)isUserNameValid:(NSString *)text;
+ (NSString *)isEmailValid:(NSString *)text;
+ (NSString *)isUrlValid:(NSString *)text;
+ (NSString *)isPasswordValid:(NSString *)text;
+ (NSString *)isBirthdateValid:(NSString *)text;
+ (NSString *)isWorkValid:(NSString *)text;
+ (NSString *)isSchoolValid:(NSString *)text;
+ (NSString *)formatUserName:(NSString*)text;
+ (NSString*)unFormatPhoneNumber:(NSString*)text;
+ (NSString *)formatPhoneNumber:(NSString*)text;
+ (id)formatPhoneNumber:(NSString*)text withRange:(NSRange)range;
+ (NSString *)validatePhoneNumber:(NSString*)text;
+ (BOOL)isValidPhoneNumber:(NSString*)text;
+ (NSString*)stripSpecialCharacters:(NSString*)text;
+ (NSString*)stripSpecialCharacters:(NSString*)text exceptCharacters:(NSString*)exceptions;
+ (NSString*)stripReturns:(NSString *)text;
+ (NSString*)removeBadEndsFromUserName:(NSString*)username;
+ (NSArray *)searchStringForResults:(NSString *)text withPattern:(NSString *)regexString;
+ (NSString *)correctForHttps:(NSString *)url;

@end
