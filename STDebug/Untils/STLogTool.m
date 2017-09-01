//
//  STLogTool.m
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import "STLogTool.h"
#import "STDebugger.h"


@interface STLogTool()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSFileHandle *>* redirectRelationship;
@property (nonatomic, strong) NSMutableString *mutableLogs;
@property (nonatomic, strong) NSMutableArray <NSString *> *tempLogs;
@property (nonatomic, strong) NSMutableArray <NSString *> *loadLogs;
@property (nonatomic, strong) NSMutableArray <NSString *> *formatLines;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) int stdoutDescriptor;

@end

@implementation STLogTool

+ (instancetype)shared {
    static STLogTool* s_logTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_logTool = [[STLogTool alloc] init];
    });
    return s_logTool;
}

- (instancetype)init {
    if (self = [super init]) {
        self.mutableLogs = [[NSMutableString alloc] initWithCapacity:4096];
        self.redirectRelationship = [NSMutableDictionary dictionaryWithCapacity:8];
        self.formatLines = [NSMutableArray arrayWithCapacity:4096];
        self.loadLogs = [NSMutableArray arrayWithCapacity:4096];
        self.formatWidth = 320;
        self.formatFont = [UIFont systemFontOfSize:16];
        self.tempLogs = [NSMutableArray arrayWithCapacity:16];
        self.loading = NO;
        self.showOnConsole = YES;
        self.stdoutDescriptor = dup(STDERR_FILENO);
    }
    return self;
}

- (void)redirectFileDescriptor:(int)fileDescriptor {
    NSPipe * pipe = [NSPipe pipe] ;
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fileDescriptor) ;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    [pipeReadHandle readInBackgroundAndNotify];
    [self.redirectRelationship setObject:pipeReadHandle forKey:@(fileDescriptor)];
}

- (void)stopRedirectFileDescriptor:(int)fileDescriptor {
    dup2(fileDescriptor, fileDescriptor);
    [self.redirectRelationship[@(fileDescriptor)] closeFile];
    [self.redirectRelationship removeObjectForKey:@(fileDescriptor)];
}

- (void) redirectNotificationHandle:(NSNotification *)nf {
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    for (NSString *filter in self.filters) {
        if ([str rangeOfString:filter].location != NSNotFound) {
            [[nf object] readInBackgroundAndNotify];
            return;
        }
    }
    if (self.headerStyle) {
        NSString *header = @"";
        if (self.headerStyle == STLogHeaderStyleSimple) {
            header = [str substringWithRange:NSMakeRange(11, 8)];
            header = [NSString stringWithFormat:@"[%@] ",header];
        }
        str = [str stringByReplacingOccurrencesOfString:@"\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d+\\+\\d+ \\w+\\[\\d+:\\d+\\]" withString:header options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];
    }
    
    if (self.showOnConsole) {
        write(self.stdoutDescriptor, [str UTF8String], strlen([str UTF8String])+1);
    }
    
    [self.mutableLogs appendString:str];
    [self.mutableLogs appendString:@"\n"];
    [[nf object] readInBackgroundAndNotify];
    if (self.loading) {
        return;
    }
    dispatch_async(dispatch_queue_create("com.stone.STDebug.appendingLog", NULL), ^{
        NSArray *array = [self formattedLinesWithString:str formatWidth:self.formatWidth andFont:self.formatFont];
        [self.tempLogs addObjectsFromArray:array];
        if ([self.delegate respondsToSelector:@selector(logTool:shouldShowNewLogs:)]
            && self.tempLogs.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate logTool:self shouldShowNewLogs:self.tempLogs];
                [self.tempLogs removeAllObjects];
            });
        }
    });
}

- (void)setFormatWidth:(float)formatWidth {
    _formatWidth = formatWidth;
    self.loading = YES;
    dispatch_async(dispatch_queue_create("com.stone.STDebug.formatLog", NULL), ^{
        [self formatLog];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading = NO;
            if ([self.delegate respondsToSelector:@selector(logTool:reloadCompletedWithLogs:)] && self.loadLogs.count) {
                [self.delegate logTool:self reloadCompletedWithLogs:self.loadLogs];
            }
            if ([self.delegate respondsToSelector:@selector(logToolFormatCompleted:)]) {
                [self.delegate logToolFormatCompleted:self];
            }
        });
    });
    
}

- (void) formatLog {
    [self.loadLogs removeAllObjects];
    [self.loadLogs addObjectsFromArray:[self formattedLinesWithString:self.mutableLogs formatWidth:self.formatWidth andFont:self.formatFont]];
}

- (NSArray <NSString *>*) formattedLinesWithString:(NSString *)string formatWidth:(NSInteger)width andFont:(UIFont *)font {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:16];
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByLines usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        for (NSUInteger startIndex = 0; startIndex < substring.length;) {
            NSUInteger len = width/16;
            for (;startIndex + len < substring.length; ) {
                NSString *aString = [substring substringWithRange:NSMakeRange(startIndex, len)];
                CGFloat currentWidth = [aString sizeWithAttributes:@{NSFontAttributeName:font}].width;
                if (currentWidth > width) {
                    break;
                }
                NSInteger crease = (width - currentWidth)/16;
                if (crease < 1) {
                    crease = 1;
                }
                len += crease;
            }
            if (len > substring.length - startIndex) {
                len = substring.length -startIndex;
            }
            NSString *lineString = [substring substringWithRange:NSMakeRange(startIndex, len)];
            [lines addObject:lineString];
            startIndex = startIndex + len;
        }
    }];
    return lines;
}

- (void)clearLogs {
    [self.mutableLogs setString:@""];
    [self formatLog];
    if ([self.delegate respondsToSelector:@selector(logTool:reloadCompletedWithLogs:)]) {
        [self.delegate logTool:self reloadCompletedWithLogs:self.loadLogs];
    }
    if ([self.delegate respondsToSelector:@selector(logToolFormatCompleted:)]) {
        [self.delegate logToolFormatCompleted:self];
    }
}

@end
