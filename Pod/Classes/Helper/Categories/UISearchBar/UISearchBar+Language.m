//
//  UISearchBar+Language.m
//  GiphyTest
//
//  Created by Russel on 17.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "UISearchBar+Language.h"

@implementation UISearchBar (Language)

- (NSString*)inputLanguageCode{
    UITextInputMode *inputMode = [self textInputMode];
    NSString *language = inputMode.primaryLanguage;
    NSArray *languageComponents = [language componentsSeparatedByString:@"-"];
    return [languageComponents count] > 0 ? [languageComponents firstObject] : nil;
}

@end
