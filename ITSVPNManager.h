//
//  ITSVPNClass.h
//  Simple VPN Wrapper
//
//  Created by Benjamin de Bos on 21-06-15.
//  Copyright (c) 2015 ITS-Vision. All rights reserved.
//

#import <NetworkExtension/NetworkExtension.h>
#import <Security/Security.h>


@interface ITSVPNManager : NSObject

//setup the VPN Manager
@property (nonatomic,retain) NEVPNManager *vpnmanager;

//create profile
-(void)createProfileForServer:(NSString*)server
                 withUsername:(NSString*)username
                  andPassword:(NSData*)password
                    andSecret:(NSData*)secret
                    withTitle:(NSString*)title
                  andProtocol:(NSString*)protocol
              completionBlock:(void (^)(void))completionBlock;

//checking if the profile is installed
-(void)checkIfProfileIsInstalled:(void (^)(BOOL isInstalled))completionBlock;

//removing a tunnel
-(void)removeVpnConnection:(void (^)(BOOL isRemoved))completionBlock;

//starting the tunnel
-(void)startVpnTunnel;

//stopping the tunnel
-(void)stopVPNConnection;

//get reference from keychain
-(NSData *)getKeyChainItemReferenceFromIdentifier:(NSString *)identifier;

//get keychain item as a string
-(NSString*)getKeyChainStringFromIdentifier:(NSString*)identifier;

//setting an item
-(BOOL)setKeyChainString:(NSString*)string forIdentifier:(NSString*)identifier;
@end
