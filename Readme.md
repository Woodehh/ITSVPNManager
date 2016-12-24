# ITSVPNManager

## Overview

**ITSVPNManager**, is a small singleton wrapper around the official but undocumented NEVPNManager, part of the NetworkExtension Framework. This class allows you to `create`,`remove`,`connect` and `disconnect`. It also includes a small Keychain wrapper, which is required to use the VPN tunnel.

## Requirements

### Objective-C knowledge
I'm not about teaching you Objective-C nor am i about clean and production code. You could use this in production, but i strongly recommend to use this as a reference on how to make this stuff work.

### Network Extension and Security Framework
You need to add the NetworkExtension and Security Framework to your target. Go to your target and click the plus sign under the section `Linked Frameworks and Libraries`. Search for Security and Network Extension. Add them and you're done.

### An iOS 8 development device.
Since this doesn't work on a simulator, you need a development device, thus a developer account. I'm not going to tell you how you should set up your provisioning profile to work with VPN. There is a lovely tutorial on this one from our iOS VPN Guru: [Mohammad Mahdi](ramezanpour.net/post/2014/08/03/configure-and-manage-vpn-connections-programmatically-in-ios-8/)

## Integration
To integrate ITSVPNManager, simply add the import line before your @interface

	#import "ITSVPNManager.h"
	
Then in your @interface:

	@property (nonatomic,retain) ITSVPNManager *ITSVpnWrapper;
    	
Then best practice would be to Synthesize this in your .m file, however it will be automatically synthesized with an underscore in front of it. But to let you know how this works, add the following line in your implementation section: 

	@synthesize ITSVpnWrapper = _ITSVpnWrapper

Your all set to make this VPN Thingy happen.


## Make it private!
You're now all set to create your first VPN Profile in your application. First you need to setup your username, password and secret in the keychain:

	[_ITSVpnWrapper setKeyChainString:@"username" forIdentifier:@"vpn_username"];
    [_ITSVpnWrapper setKeyChainString:@"password" forIdentifier:@"vpn_password"];
    [_ITSVpnWrapper setKeyChainString:@"supersecret" forIdentifier:@"vpn_secret"];
    
That's all set now, we need to make sure that the username and secret are set into the keychain, since NEVPNManager wants the Keychain reference for this.

###Creating a profile
	
	[_ITSVpnWrapper createProfileForServer:@"Some.ipsec.server"
                              withUsername:[_ITSVpnWrapper getKeyChainStringFromIdentifier:@"vpn_username"]
                               andPassword:[_ITSVpnWrapper getKeyChainItemReferenceFromIdentifier:@"vpn_password"]
                                 andSecret:[_ITSVpnWrapper getKeyChainItemReferenceFromIdentifier:@"vpn_secret"]
                                 withTitle:@"Some IPSEC VPN COnnection"
                               andProtocol:@"ipsec"
                           completionBlock:^{
                           		NSLog(@"We've successfully launched the native iOS install profile dialog");
	}];

iOS will now prompt the user for installing the profile. It's that easy!

###Updating/changing a profile
To update or change a profile (e.g. location, protocol, name, username, password, etc) just use the `[_ITSVpnWrapper createProfileForServer ..]` method. Once permission is given, you can update your profile.

###Starting a connection

    [_ITSVpnWrapper startVpnTunnel];

###Stopping a connection
	
	[_ITSVpnWrapper stopVPNTunnel];
	
###Removing a connection

	[_ITSVpnWrapper removeVpnConnection:^(BOOL isRemoved){
        if (isRemoved) {
        	NSLog(@"Connection removed");
        } else {
            NSLog(@"Isn't removed");
        }
    }];
    
## But but but, how do i check if a user actually installed the profile.
You mean when returning from the profile dialog? Quite easy: you don't. Apple doesnt really give you a method for this. So you need to do a small hack for this.

In your Appdelegate.m add the following line under your `applicationDidBecomeActive` section

	    [[NSNotificationCenter defaultCenter] postNotificationName:@"app_became_active" object:self];
	    
Then register this line in the completion block of: `[_ITSVPNManager createProfileForServer ..]`

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForProfile) name:@"app_became_active" object:nil];
	
Simply create a small method in your .m file:

	-(void)checkForProfile {
	    [_ITSVpnWrapper checkIfProfileIsInstalled:^(BOOL isInstalled){
    	    if (!isInstalled) {
        	    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning!", nil) message:NSLocalizedString(@"We need the profile to be installed, make sure you install and confirm this profile!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay!", nil) otherButtonTitles:nil, nil] show];
	        } else {
    	        [self proceedToLogin];
	        }
    	}];
	    [[NSNotificationCenter defaultCenter] removeObserver:self];
	}

This method is a bit of a hack, so i don't guarantee anything.	    


## That's it
I would just love to type more about this neat lil' plugin, but this is just all there is to it. Feel free to contribute and suggest stuff.

## Holy crap, that's easy!?
Yep it is, it was written because we needed an easy solution for a couple of websites. 

## Where can i pay?
You don't need to pay for this, but it's on GitHub so you probably knew that :-) 

However if you want to `donate`: Click the button below:

[![image](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=info%40its%2dvision%2enl&lc=NL&item_name=ITS%2dVision&item_number=ITSBootstrapCookie&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest)




