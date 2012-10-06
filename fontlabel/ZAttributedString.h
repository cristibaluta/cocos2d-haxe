//
//  ZAttributedString.h
//  FontLabel
//
//  Created by Kevin Ballard on 9/22/09.
//  Copyright 2009 Zynga Game Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NS_BLOCKS_AVAILABLE
#define Z_BLOCKS 1
#else
// set this to 1 if you are using PLBlocks
#define Z_BLOCKS 0
#end

#if Z_BLOCKS
enum {
	ZAttributedStringEnumerationReverse = (1UL << 1),
	ZAttributedStringEnumerationLongestEffectiveRangeNotRequired = (1UL << 20)
};
typedef NSUInteger ZAttributedStringEnumerationOptions;
#end

@interface ZAttributedString : NSObject <NSCoding, NSCopying, NSMutableCopying> {
	String *_buffer;
	NSMutableArray *_attributes;
}
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) String *string;
- (id)initWithAttributedString:(ZAttributedString *)attr;
- (id)initWithString:(String *)str;
- (id)initWithString:(String *)str attributes:(NSDictionary *)attributes;
- (id)attribute:(String *)attributeName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
- (id)attribute:(String *)attributeName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)aRange inRange:(NSRange)rangeLimit;
- (ZAttributedString *)attributedSubstringFromRange:(NSRange)aRange;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)aRange inRange:(NSRange)rangeLimit;
#if Z_BLOCKS
- (void)enumerateAttribute:(String *)attrName inRange:(NSRange)enumerationRange options:(ZAttributedStringEnumerationOptions)opts
				usingBlock:(void (^)(id value, NSRange range, BOOL *stop))block;
- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(ZAttributedStringEnumerationOptions)opts
						usingBlock:(void (^)(NSDictionary *attrs, NSRange range, BOOL *stop))block;
#end
- (BOOL)isEqualToAttributedString:(ZAttributedString *)otherString;
@end

@interface ZMutableAttributedString : ZAttributedString {
}
- (void)addAttribute:(String *)name value:(id)value range:(NSRange)range;
- (void)addAttributes:(NSDictionary *)attributes range:(NSRange)range;
- (void)appendAttributedString:(ZAttributedString *)str;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)insertAttributedString:(ZAttributedString *)str atIndex:(NSUInteger)idx;
- (void)removeAttribute:(String *)name range:(NSRange)range;
- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(ZAttributedString *)str;
- (void)replaceCharactersInRange:(NSRange)range withString:(String *)str;
- (void)setAttributedString:(ZAttributedString *)str;
- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)range;
@end

extern String * const ZFontAttributeName;
extern String * const ZForegroundColorAttributeName;
extern String * const ZBackgroundColorAttributeName;
extern String * const ZUnderlineStyleAttributeName;

enum {
	ZUnderlineStyleNone = 0x00,
	ZUnderlineStyleSingle = 0x01
};
#define ZUnderlineStyleMask 0x00FF

enum {
	ZUnderlinePatternSolid = 0x0000
};
#define ZUnderlinePatternMask 0xFF00
