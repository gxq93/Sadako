//
//  LogServerWeb.m
//  Sadako
//
//  Created by GuYi on 2017/6/11.
//  Copyright © 2017年 GuYi. All rights reserved.
//

#import "LogMiddleWare.h"
#import "SystemLogManager.h"

@implementation LogMiddleWare

+ (id)createHtmlDataWithRequest:(GCDWebServerRequest *)request {
    NSString* path = request.path;
    NSDictionary* query = request.query;
    NSMutableString* string;
    if ([path isEqualToString:@"/"]) {
        string = [self initialHtml];
    }
    else if ([path isEqualToString:@"/output"] && query[@"after"]) {
        double time = [query[@"after"] doubleValue];
        string = [[NSMutableString alloc] init];
        [self appendHtmlTo:string afterAbsoluteTime:time];
    }
    else {
        string = [self noDataHtml];
    }
    if (string == nil) {
        string = [@"" mutableCopy];
    }
    return string;
}

+ (id)createJsonDataWithRequest:(GCDWebServerRequest *)request {
    NSString* path = request.path;
    NSDictionary* query = request.query;
    NSMutableDictionary* response;
    if ([path isEqualToString:@"/"]) {
        response = [self initialJson];
    }
    else if ([path isEqualToString:@"/output"] && query[@"after"]) {
        double time = [query[@"after"] doubleValue];
        response = [[NSMutableDictionary alloc] init];
        [self appendTextTo:response afterAbsoluteTime:time];
    }
    else {
        response = [self noDataJson];
    }
    if (response == nil) {
        response = [self noDataJson];
    }
    return response;
}

+ (NSMutableString *)initialHtml {
    NSError *error;
    NSString *cssString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Log" ofType:@"css"]
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    NSAssert(cssString, @"Error reading css:%@", [error localizedFailureReason]);
    NSString *jsString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Log" ofType:@"js"]
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    NSAssert(cssString, @"Error reading js:%@", [error localizedFailureReason]);
    
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"<!DOCTYPE html><html lang=\"en\">"];
    [string appendString:@"<head><meta charset=\"utf-8\"></head>"];
    [string appendFormat:@"<title>%s[%i]</title>", getprogname(), getpid()];
    [string appendFormat:@"<style>%@</style>", cssString];
    [string appendFormat:@"<script type=\"text/javascript\">%@</script>", jsString];
    [string appendString:@"</head>"];
    [string appendString:@"<body>"];
    [string appendString:@"<table><tbody id=\"content\">"];
    [self appendHtmlTo:string afterAbsoluteTime:0.0];
    [string appendString:@"</tbody></table>"];
    [string appendString:@"<div id=\"footer\"></div>"];
    [string appendString:@"</body>"];
    [string appendString:@"</html>"];
    return string;
}

+ (NSMutableString *)noDataHtml {
    return [[NSMutableString alloc] initWithString:@"<html><body><p>无数据</p></body></html>"];
}

+ (void)appendHtmlTo:(NSMutableString*)string afterAbsoluteTime:(double)time {
    __block double maxTime = time;
    NSArray<SystemLogMessage *>  *allMsg = [SystemLogManager allLogAfterTime:time];
    [allMsg enumerateObjectsUsingBlock:^(SystemLogMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        const char* style = "color: dimgray;";
        NSString* formattedMessage = [NSString stringWithFormat:@"<td>%@</td> <td>%@</td> <td>%@</td>",[SystemLogMessage logTimeStringFromDate:obj.date], obj.sender, obj.messageText];
        [string appendFormat:@"<tr style=\"%s\">%@</tr>", style, formattedMessage];
        if (obj.timeInterval > maxTime) {
            maxTime = obj.timeInterval;
        }
    }];
    [string appendFormat:@"<tr id=\"maxTime\" data-value=\"%f\"></tr>", maxTime];
}

+ (NSMutableDictionary *)initialJson {
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [self appendTextTo:json afterAbsoluteTime:0.0];
    return json;
}
+ (NSMutableDictionary *)noDataJson {
    return [[NSMutableDictionary alloc] initWithDictionary:@{@"error": @"暂无打印"}];
}
+ (void)appendTextTo:(NSMutableDictionary*)json afterAbsoluteTime:(double)time {
    __block double maxTime = time;
    NSArray<SystemLogMessage *>  *allMsg = [SystemLogManager allLogAfterTime:time];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [allMsg enumerateObjectsUsingBlock:^(SystemLogMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *text = [NSString stringWithFormat:@"%@-%@-%@", [SystemLogMessage logTimeStringFromDate:obj.date], obj.sender, obj.messageText];
        if (obj.timeInterval > maxTime) {
            maxTime = obj.timeInterval;
        }
        [dataArray addObject:text];
    }];
    [json setValue:dataArray forKey:@"data"];
    [json setValue:[NSString stringWithFormat:@"%f", maxTime] forKey:@"maxTime"];
}

@end
