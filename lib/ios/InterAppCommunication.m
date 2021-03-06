#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#endif

#import "InterAppCommunication.h"
#import "React/RCTLog.h"
#import "React/RCTAssert.h"
#import "React/RCTUtils.h"


@implementation InterAppCommunication
{
  NSInteger _listenerCount;
  dispatch_queue_t _communicationRequestQueue;
  dispatch_queue_t _communicationResponseQueue;
  NSMutableDictionary *_callbacks;
}

RCT_EXPORT_MODULE(InterAppCommunication);

- (instancetype)init
{
  self = [super init];
  if (self) {
    _communicationRequestQueue = dispatch_queue_create("br.com.bb.gam.communication.Integration.request", DISPATCH_QUEUE_CONCURRENT);
    _communicationResponseQueue = dispatch_queue_create("br.com.bb.gam.communication.Integration.response", DISPATCH_QUEUE_CONCURRENT);
    
    _callbacks = [NSMutableDictionary dictionary];

    
  }
  return self;
}


- (NSArray<NSString *> *)supportedEvents {
  NSLog(@"O metodo `addListener` e o metodo `sendEventWithName` foram sobrescritos e nao usam mais essa lista de eventos");
  return @[@"emit"];
}


RCT_EXPORT_METHOD(addListener:(NSString *)eventName)
{
  if (_listenerCount == 0) {
    [self startObserving];
  }
  _listenerCount++;
}

//Criar método "sendUIEvent" que passa pelo RCTDeviceEventEmitter para garantir que dispare eventos de UI
//Eventos apenas de comunicação, usar a queue de comunicação
//Pensar em como fazer isso
- (void)sendEventWithName:(NSString *)eventName body:(id)body
{
  if (_listenerCount > 0) {
    
      [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                          method:@"emit"
                            args:body ? @[eventName, body] : @[eventName]
                      completion:NULL];
    
  } else {
    RCTLogWarn(@"Sending `%@` with no listeners registered.", eventName);
  }
}


RCT_EXPORT_METHOD(invokeJSFunction:(NSString *)appId
                  serviceURI:(NSString *)serviceURI
                  params:(NSDictionary *)params
                  callback:(RCTResponseSenderBlock)callback)
{
  dispatch_async(_communicationRequestQueue, ^{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    _callbacks[uuid] = @{@"status": @"waiting", @"value":@""};
    
    NSMutableDictionary *paramsAug = [NSMutableDictionary dictionaryWithDictionary:params];
    paramsAug[@"callback"] = uuid;
    
    [self.bridge enqueueJSCall:serviceURI args:[paramsAug allValues]];
    NSLog(@"%@", _callbacks[uuid][@"status"]);
    while(true) {
      if ([_callbacks[uuid][@"status"]  isEqual: @"resolved"]) {
        break;
      }
    }
    callback(@[_callbacks[uuid][@"value"]]);
  });
}

RCT_EXPORT_METHOD(sendJSFunctionResult:(NSString *)appId
                  callbackUUID:(NSString *)callbackUUID
                  result:(NSDictionary *)result)
{
  dispatch_async(_communicationResponseQueue, ^{
    _callbacks[callbackUUID] = @{@"status": @"resolved", @"value":result};
  });
}

@end
