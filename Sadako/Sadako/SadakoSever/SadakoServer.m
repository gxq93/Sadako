//
//  HttpSever.m
//  Sadako
//
//  Created by GuYi on 2017/6/11.
//  Copyright © 2017年 GuYi. All rights reserved.
//

#import "SadakoServer.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface SadakoServer ()
@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic, assign) ClientType clientType;
@property (nonatomic, assign) Class<SadakoProtocol> middleware;
@end

@implementation SadakoServer

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SadakoServer *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [SadakoServer new];
    });
    return sharedInstance;
}

- (void)registerMiddleware:(Class<SadakoProtocol>)middleware {
    self.middleware = middleware;
}

- (void)switchClientType:(ClientType)clientType {
    self.clientType = clientType;
}

- (void)startServer{
    [self.webServer startWithPort:8080 bonjourName:@""];
}

- (void)stopServer {
    [self.webServer stop];
    self.webServer = nil;
}

- (GCDWebServerDataResponse *)createResponseBody:(GCDWebServerRequest* )request {
    GCDWebServerDataResponse *response = nil;
    switch (self.clientType) {
        case WEB:
            response = [GCDWebServerDataResponse responseWithHTML:[self.middleware createHtmlDataWithRequest:request]];
            break;
        case CLI:
            response = [GCDWebServerDataResponse responseWithJSONObject:[self.middleware createJsonDataWithRequest:request]];
            break;
        default:
            response = nil;
            break;
    }
    return response;
}

- (GCDWebServer *)webServer {
    if (!_webServer) {
        _webServer = [[GCDWebServer alloc] init];
        __weak __typeof__(self) weakSelf = self;
        [_webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                      return [weakSelf createResponseBody:request];
                                  }];
    }
    return _webServer;
}

@end
