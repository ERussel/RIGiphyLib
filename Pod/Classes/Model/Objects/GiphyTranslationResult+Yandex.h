//
//  GiphyTranslationResult+Yandex.h
//  GiphyTest
//
//  Created by Russel on 09.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyTranslationResult.h"

/**
 *  Category to provide methods to transform Yandex responses to internal formats.
 */
@interface GiphyTranslationResult (Yandex)

/**
 *  Creates translation result object with response from Yandex service.
 *  @param response         Object representing response from Yandex service.
 *  @param originalText     NSString text reponse recieved for.
 *  @return Initialize GiphyTranslationResult object.
 */
+ (instancetype)translationResultFromYandexResponse:(id)response forOriginalText:(NSString*)originalText;

@end
