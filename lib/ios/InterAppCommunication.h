//
//  CommunicationBus.h
//  GAMPreview - PROJETO GAM
//
//  Created by Tiago Stutz on 13/04/17.
//  Copyright © 2017 Banco do Brasil S.A. All rights reserved.
//

#import "React/RCTEventEmitter.h"
#import "React/RCTBridge.h"

@interface InterAppCommunication : RCTEventEmitter <RCTBridgeModule>

@end
