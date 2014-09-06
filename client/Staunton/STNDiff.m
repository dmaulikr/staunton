#import "STNDiff.h"

@interface STNDiff ()

@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) CGPoint point;

@end

@implementation STNDiff

- (instancetype)initWithEmail:(NSString *)email point:(CGPoint)point {
    if (self = [super init]) {
        self.email = email;
        self.point = point;
    }
    return self;
}

- (void)visitWithInsertBlock:(void (^)(STNDiffInsert *))insertBlock removeBlock:(void (^)(STNDiffRemove *))removeBlock updateBlock:(void (^)(STNDiffUpdate *))updateBlock {
    NSParameterAssert(@"abstract method");
}

- (BOOL)isInsert {
    return NO;
}

- (BOOL)isUpdate {
    return NO;
}

- (BOOL)isRemove {
    return NO;
}

@end

@implementation STNDiffInsert

- (void)visitWithInsertBlock:(void (^)(STNDiffInsert *))insertBlock removeBlock:(void (^)(STNDiffRemove *))removeBlock updateBlock:(void (^)(STNDiffUpdate *))updateBlock {
    insertBlock(self);
}

- (BOOL)isInsert {
    return YES;
}

@end

@implementation STNDiffRemove

- (void)visitWithInsertBlock:(void (^)(STNDiffInsert *))insertBlock removeBlock:(void (^)(STNDiffRemove *))removeBlock updateBlock:(void (^)(STNDiffUpdate *))updateBlock {
    removeBlock(self);
}

- (BOOL)isRemove {
    return YES;
}

@end

@implementation STNDiffUpdate

- (void)visitWithInsertBlock:(void (^)(STNDiffInsert *))insertBlock removeBlock:(void (^)(STNDiffRemove *))removeBlock updateBlock:(void (^)(STNDiffUpdate *))updateBlock {
    updateBlock(self);
}

- (BOOL)isUpdate {
    return YES;
}

@end