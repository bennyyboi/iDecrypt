//
//  iDecryptAppDelegate.h
//  iDecrypt
//
//  Created by Ben on 31/10/2010.
//  Copyright 2010 Techizmo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iDecryptAppDelegate : NSObject <NSApplicationDelegate> 
{
    NSWindow *window;
	IBOutlet NSTextField *dmgFile;
	IBOutlet NSTextField *dmgSize;
	IBOutlet NSButton *selectDMG;
	IBOutlet NSTextField *outputFolder;
	IBOutlet NSButton *selectOutputFolder;
	IBOutlet NSTextField *autoDMGKey;
	IBOutlet NSButton *decryptNow;
	IBOutlet NSProgressIndicator *progressWheel;
	IBOutlet NSTextView *outputConsole;
	IBOutlet NSPanel *consoleView;
	IBOutlet NSButton *toggleConsoleView;
	IBOutlet NSTextField *versionString;
	IBOutlet NSTextField *decryptStatus;
	IBOutlet NSImageView *errorImage;

}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSTextField *dmgFile;
@property (nonatomic, retain) IBOutlet NSButton *toggleConsoleView;
@property (nonatomic, retain) IBOutlet NSTextField *dmgSize;
@property (nonatomic, retain) IBOutlet NSButton *selectDMG;
@property (nonatomic, retain) IBOutlet NSTextField *outputFolder;
@property (nonatomic, retain) IBOutlet NSButton *selectOutputFolder;
@property (nonatomic, retain) IBOutlet NSTextField *autoDMGKey;
@property (nonatomic, retain) IBOutlet NSButton *decryptNow;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progressWheel;
@property (nonatomic, retain) IBOutlet NSTextView *outputConsole;
@property (nonatomic, retain) IBOutlet NSPanel *consoleView;
@property (nonatomic, retain) IBOutlet NSTextField *versionString;
@property (nonatomic, retain) IBOutlet NSTextField *decryptStatus;
@property (nonatomic, retain) IBOutlet NSImageView *errorImage;

- (IBAction)openDMG:(id)sender;
- (IBAction)decryptIt:(id)sender;
- (IBAction)pickOutput:(id)sender;
- (IBAction)toggleConsole:(id)sender;

@end
