//
//  ITSVPNClass.h
//  Simple VPN Wrapper
//
//  Created by Benjamin de Bos on 21-06-15.
//  Copyright (c) 2015 ITS-Vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import <Security/Security.h>


@interface ITSVPNManager : NSObject


@property (nonatomic,retain) NEVPNManager *vpnmanager;

-(void)checkIfProfileIsInstalled:(void (^)(BOOL isInstalled))completionBlock;
-(void)removeVpnConnection:(void (^)(BOOL isRemoved))completionBlock;
-(void)createProfileForServer:(NSString*)server
                 withUsername:(NSString*)username
                  andPassword:(NSData*)password
                    andSecret:(NSData*)secret
                    withTitle:(NSString*)title
                  andProtocol:(NSString*)protocol
              completionBlock:(void (^)(void))completionBlock;
-(void)startVpnTunnel;
-(void)stopVPNConnection;


//keychain stuffies
-(NSData *)getKeyChainItemReferenceFromIdentifier:(NSString *)identifier;
-(NSString*)getKeyChainStringFromIdentifier:(NSString*)identifier;
-(BOOL)setKeyChainString:(NSString*)string forIdentifier:(NSString*)identifier;
-(NEVPNManager*)getManager;
@end
