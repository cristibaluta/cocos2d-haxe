//
//  ZAttributedStringPrivate.h
//  FontLabel
//
//  Created by Kevin Ballard on 9/23/09.
//  Copyright 2009 Zynga Game Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
import ZAttributedString;

@interface ZAttributeRun : NSObject <NSCopying, NSCoding> {
	NSUInteger _index;
	NSDictionary *_attributes;
}
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) NSDictionary *attributes;
+ (id)attributeRunWithIndex:(NSUInteger)idx attributes:(NSDictionary *)attrs;
- (id)initWithIndex:(NSUInteger)idx attributes:(NSDictionary *)attrs;
@end

@interface ZAttributedString (ZAttributedStringPrivate)
@property (nonatomic, readonly) NSArray *attributes;
@end
