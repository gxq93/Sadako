//
//  SadakoProtocol.h
//  Sadako
//
//  Created by GuYi on 2017/6/19.
//  Copyright © 2017年 GuYi. All rights reserved.
//

#import "GCDWebServer.h"

@protocol SadakoProtocol <NSObject>

@required
+ (id)createHtmlDataWithRequest:(GCDWebServerRequest *)request;
+ (id)createJsonDataWithRequest:(GCDWebServerRequest *)request;

@end

