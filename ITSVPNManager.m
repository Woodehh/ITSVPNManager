//
//  ITSVPNClass.m
//  Simple VPN Wrapper
//
//  Created by Benjamin de Bos on 21-06-15.
//  Copyright (c) 2015 ITS-Vision. All rights reserved.
//

#import "ITSVPNManager.h"


#define kVpnKeychain @"com.umbravpn.iosclient.keychain.library"


@implementation ITSVPNManager

@synthesize vpnmanager = _vpnmanager;


-(id) init {
    if ([super init] == self) {
        _vpnmanager = [NEVPNManager sharedManager];
    }
    return self;
}

-(void)checkIfProfileIsInstalled:(void (^)(BOOL isInstalled))completionBlock {
    [_vpnmanager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error occured: %@",error.localizedDescription);
        }
        if ([[NSString stringWithFormat:@"%@",_vpnmanager.protocol] rangeOfString:@"persistentReference"].location != NSNotFound) {
            completionBlock(YES);
        } else {
            completionBlock(NO);
        }
    }];
    
}

-(void)removeVpnConnection:(void (^)(BOOL isRemoved))completionBlock {
    [_vpnmanager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        [_vpnmanager removeFromPreferencesWithCompletionHandler:^(NSError *error) {
            if (error)
                completionBlock(NO);
            else
                completionBlock(YES);
        }];
    }];
}

-(void)createProfileForServer:(NSString*)server
                 withUsername:(NSString*)username
                  andPassword:(NSData*)password
                    andSecret:(NSData*)secret
                    withTitle:(NSString*)title
                  andProtocol:(NSString*)protocol
              completionBlock:(void (^)(void))completionBlock {
    
    [_vpnmanager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        
        if ([protocol isEqualToString:@"ipsec"]) {
            NEVPNProtocolIPSec *ipsec = [[NEVPNProtocolIPSec alloc] init];
            ipsec.username = username;
            ipsec.serverAddress = server;
            ipsec.passwordReference = password;
            ipsec.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
            ipsec.sharedSecretReference = secret;
            ipsec.disconnectOnSleep = NO;
            ipsec.useExtendedAuthentication = YES;
            [_vpnmanager setProtocol:ipsec];
            [_vpnmanager setOnDemandEnabled:YES];
            [_vpnmanager setLocalizedDescription:[NSString stringWithFormat:@"UmbraVPN IPSec - %@",server]];
            [_vpnmanager setEnabled:YES];
            
        } else {
            
            NEVPNProtocolIKEv2 *p = [[NEVPNProtocolIKEv2 alloc] init];
            p.username = username;
            p.passwordReference = password;
            p.serverAddress = server;
            p.authenticationMethod = NEVPNIKEv2EncryptionAlgorithmDES;
            p.sharedSecretReference = secret;
            p.disconnectOnSleep = NO;
            p.useExtendedAuthentication = YES;
            [_vpnmanager setProtocol:p];
            [_vpnmanager setOnDemandEnabled:YES];
            [_vpnmanager setLocalizedDescription:[NSString stringWithFormat:@"UmbraVPN IKEv2 - %@",server]];
            [_vpnmanager setEnabled:YES];
        }
        
        [_vpnmanager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if(error) {
                NSLog(@"Save error: %@", error);
            } else {
                completionBlock();
            }
        }];
        
    }];
}

-(NEVPNManager*)getManager {
    return _vpnmanager;
}

-(void)startVpnTunnel {
    [_vpnmanager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        NSError *startError;
        [_vpnmanager.connection startVPNTunnelAndReturnError:&startError];
        if(startError) {
            NSLog(@"Start error: %@", startError.localizedDescription);
        } else {
            NSLog(@"Zou goed motten gaan");
        }
    }];
}

-(void)stopVPNConnection {
    [_vpnmanager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        [_vpnmanager.connection stopVPNTunnel];
    }];
}




-(NSMutableDictionary *)buildDefaultDictionaryForIdentity:(NSString*)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = kVpnKeychain;
    
    return searchDictionary;
}


- (NSData *)getKeyChainItemReferenceFromIdentifier:(NSString *)identifier {
    return [self getKeyChainItemReferenceFromIdentifier:identifier returnReference:YES];
}

- (NSData *)getKeyChainItemReferenceFromIdentifier:(NSString *)identifier returnReference:(BOOL)referenceOnly{

    //get default dictionary
    NSMutableDictionary *dict = [self buildDefaultDictionaryForIdentity:identifier];
    
    //set for searching
    dict[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    //need reference
    if (referenceOnly)
        dict[(__bridge id)kSecReturnPersistentRef] = @YES;
    else
        dict[(__bridge id)kSecReturnData] = @YES;
    
    //create result object
    CFTypeRef result = NULL;

    //Get that shit
    SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);

    //return that shit
    return (__bridge_transfer NSData *)result;
}

//got from: http://useyourloaf.com/blog/2010/03/29/simple-iphone-keychain-access.html
-(NSString*)getKeyChainStringFromIdentifier:(NSString*)identifier {
    NSData *keychainData = [self getKeyChainItemReferenceFromIdentifier:identifier returnReference:NO];
    return [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
}


-(BOOL)setKeyChainString:(NSString*)string forIdentifier:(NSString*)identifier {

    NSMutableDictionary *searchDictionary = [self buildDefaultDictionaryForIdentity:identifier];
    NSData *keychainValue = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    
    if ([self getKeyChainItemReferenceFromIdentifier:identifier] == nil) {
        [searchDictionary setObject:keychainValue forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
        if (status == errSecSuccess) {
            return YES;
        }
        return NO;
    } else {
        NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
        [updateDictionary setObject:keychainValue forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                        (__bridge CFDictionaryRef)updateDictionary);
        
        if (status == errSecSuccess) {
            return YES;
        }
        return NO;
    }
}

@end
