//
//  GiphyTranslationResult+Yandex.m
//  GiphyTest
//
//  Created by Russel on 09.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyTranslationResult+Yandex.h"

@implementation GiphyTranslationResult (Yandex)

+ (instancetype)translationResultFromYandexResponse:(id)response forOriginalText:(NSString*)originalText{
    if ([response isKindOfClass:[NSDictionary class]]) {
        // <l1> - <l2> formatted string
        NSString *language = response[@"lang"];
        NSArray *parsedLanguages = [language componentsSeparatedByString:@"-"];
        NSString *originalLanguage = [parsedLanguages count] > 0 ? [parsedLanguages objectAtIndex:0] : nil;
        NSString *resultLanguage = [parsedLanguages count] > 1 ? [parsedLanguages objectAtIndex:1] : nil;
    
        return [[GiphyTranslationResult alloc] initWithResults:response[@"text"]
                                               forOriginalText:originalText
                                        translatedFromLanguage:originalLanguage
                                                    toLanguage:resultLanguage];
    }
    
    // unsupported response object
    return nil;
}

@end
