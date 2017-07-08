//
//  HttpSever.h
//  Sadako
//
//  Created by GuYi on 2017/6/11.
//  Copyright © 2017年 GuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SadakoProtocol.h"

typedef NS_ENUM(NSUInteger, ClientType) {
    WEB = 0,
    CLI,
};

@interface SadakoServer : NSObject

+ (instancetype)sharedInstance;

- (void)registerMiddleware:(Class<SadakoProtocol>)middleware;
- (void)switchClientType:(ClientType)clientType;

- (void)startServer;
- (void)stopServer;

@end
