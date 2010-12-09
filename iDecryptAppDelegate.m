//
//  iDecryptAppDelegate.m
//  iDecrypt
//
//  Created by Ben on 31/10/2010.
//  Copyright 2010 Techizmo. All rights reserved.
//

#import "iDecryptAppDelegate.h"

@implementation iDecryptAppDelegate

@synthesize window, dmgFile, dmgSize, selectDMG, outputFolder, selectOutputFolder, autoDMGKey, decryptNow, progressWheel, outputConsole, consoleView, toggleConsoleView, versionString, decryptStatus, errorImage;

- (IBAction)openDMG:(id)sender
{
	NSOpenPanel *dmgSelector = [[NSOpenPanel openPanel] retain];
	[dmgSelector beginForDirectory:nil file:nil types:[NSArray arrayWithObject:@"dmg"] modelessDelegate:self didEndSelector:@selector(dmgSelectorDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)dmgSelectorDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		[dmgFile setStringValue:[NSString stringWithFormat:@"%@", [panel filename]]];
		
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert setMessageText:@"Warning"];
		[alert setInformativeText:@"This should be the rootfs DMG and not the restore/update ramdisks, you can tell the difference by the file size of the DMG's. The biggest one is the rootfs and other two are the ramdisks these can ONLY be decrypted using xPwn (for Mac)/xPwnTool (for Windows)."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(someMethodDidEnd:returnCode:contextInfo:) contextInfo:nil];
		
		NSDictionary      *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:[dmgFile stringValue] traverseLink:FALSE];
		[dmgSize setStringValue:[[[fileAttributes objectForKey:NSFileSize] stringValue] stringByAppendingString:@" bytes"]];
		
		//lets get the key for this dmg now...
		NSString *dmg_file = [dmgFile stringValue];
		NSString *lPC = [dmg_file lastPathComponent];
		NSString* dpath = [[NSBundle mainBundle] pathForResource:@"iDeviceKeys" ofType:@"plist"];
		NSDictionary* deviceMl = [NSDictionary dictionaryWithContentsOfFile:dpath];
		NSString* iKeys = [deviceMl objectForKey:lPC];
		NSLog(@"RootFileSystem => %@", lPC);
		NSLog(@"VFDecrypt Key => %@", iKeys);
		[autoDMGKey setStringValue:[NSString stringWithFormat:@"%@", iKeys]];

		
	}
}

- (void) someMethodDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertFirstButtonReturn)
	{
		// Do something
	}
}

- (IBAction)pickOutput:(id)sender
{
	NSOpenPanel *selectOutput = [[NSOpenPanel openPanel] retain];
	[selectOutput beginForDirectory:nil file:nil types:nil modelessDelegate:self didEndSelector:@selector(selectOutputDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	[selectOutput setCanChooseFiles:NO]; //this should be set to NO to prevent users selecting files instead of folders, this could also lead to problems down the line!!!
	[selectOutput setCanChooseDirectories:YES];
	[selectOutput setCanCreateDirectories:YES];
}

- (void)selectOutputDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString* short_name = [dmgFile stringValue];
		NSString* realshort = [short_name lastPathComponent];
		NSString* delExt = [realshort stringByDeletingPathExtension];
		[outputFolder setStringValue:[NSString stringWithFormat:@"%@/%@_decrypted.dmg", [panel filename],delExt]];
		[decryptNow setEnabled:YES];
		[decryptNow setNeedsDisplay:YES];
	}
}



- (IBAction)decryptIt:(id)sender
{
	//get the values from the inputted textfields
	NSString *dmg_file = [dmgFile stringValue];
	NSString *output_folder = [outputFolder stringValue];
	NSString *dmg_key = [autoDMGKey stringValue];
	NSString *dmg_file_short = [dmg_file lastPathComponent];
	NSString *empty = @"";
	
	//Bugfix - Check textfields to see if they have data before even attempting to decrypt!
	if (![dmg_file isEqualToString:empty] && ![output_folder isEqualToString:empty] && ![dmg_key isEqualToString:empty])
	{

		[errorImage setHidden:YES];
		[errorImage setNeedsDisplay:YES];
		
		
	[progressWheel startAnimation:sender];
	[progressWheel setNeedsDisplay:YES];
	[decryptStatus setHidden:NO];
	[decryptStatus setNeedsDisplay:YES];
	
	//disable buttons
	
	[selectDMG setEnabled:NO];
	[selectDMG setNeedsDisplay:YES];
	[selectOutputFolder setEnabled:NO];
	[selectOutputFolder setNeedsDisplay:YES];
	[decryptNow setEnabled:NO];
	[decryptNow setNeedsDisplay:YES];
	[autoDMGKey setEnabled:NO];
	[autoDMGKey setNeedsDisplay:YES];
	[dmgFile setEnabled:NO];
	[dmgFile setNeedsDisplay:YES];
	[outputFolder setEnabled:NO];
	[outputFolder setNeedsDisplay:YES];
	[toggleConsoleView setEnabled:NO];
	[toggleConsoleView setNeedsDisplay:YES];
	[decryptNow setTitle:@"Decrypting..."];
	[decryptStatus setStringValue:[NSString stringWithFormat:@"Decrypting '%@'....", dmg_file_short]];
	
	//start the process...
	NSString *oPath = [[NSBundle mainBundle] pathForResource:@"vfdecrypt" ofType:nil];
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:oPath];
    [task setArguments:[NSArray arrayWithObjects:@"-i",dmg_file,@"-k",dmg_key,@"-o",output_folder,nil]];
    [task setStandardOutput:[NSPipe pipe]];
    [task setStandardError:[task standardOutput]];
    [task launch];
	[task waitUntilExit];
    NSData* output = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
    NSString* out_string = [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] autorelease];
    [outputConsole setString:out_string];
	
	NSString* shortfilename = [dmg_file lastPathComponent];
	NSString* renamedto = [output_folder lastPathComponent];
	NSString* successMsg = [NSString stringWithFormat:@"You have successfully decrypted the rootfs!\n\nDecrypted => '%@'\nLocated => %@\n\nYou can mount it by double clicking on the dmg itself and explore the rootfs that way. So enjoy and thanks for using iDecrypt!", shortfilename,output_folder,renamedto];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Success!"];
	[alert setInformativeText:successMsg];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(someMethodDidEnd2:returnCode:contextInfo:) contextInfo:nil];
	
	//Reset everything!
	[selectDMG setEnabled:YES];
	[selectDMG setNeedsDisplay:YES];
	[selectOutputFolder setEnabled:YES];
	[selectOutputFolder setNeedsDisplay:YES];
	[decryptNow setEnabled:YES];
	[decryptNow setNeedsDisplay:YES];
	[autoDMGKey setEnabled:YES];
	[autoDMGKey setNeedsDisplay:YES];
	[dmgFile setEnabled:YES];
	[dmgFile setNeedsDisplay:YES];
	[outputFolder setEnabled:YES];
	[outputFolder setNeedsDisplay:YES];
	[progressWheel stopAnimation:sender];
	[progressWheel setNeedsDisplay:YES];
	[toggleConsoleView setEnabled:YES];
	[toggleConsoleView setNeedsDisplay:YES];
	[decryptNow setTitle:@"Decrypt DMG"];
	[decryptStatus setHidden:YES];
	[decryptStatus setNeedsDisplay:YES];
	
	}
	else {
		[errorImage setHidden:NO];
		[errorImage setNeedsDisplay:YES];
		[decryptStatus setHidden:NO];
		[decryptStatus setStringValue:@"You have left one or more boxes empty!"];
		[decryptStatus setNeedsDisplay:YES];
	}

}

- (IBAction)toggleConsole:(id)sender
{
	[consoleView orderFront:sender];
	[consoleView retain];
}

- (void) someMethodDidEnd2:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertFirstButtonReturn)
	{
		// Do something
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	// Insert code here to initialize your application
	[errorImage setHidden:YES];
	NSString* appVersion = [NSString stringWithFormat:@"v%@ build (%@)",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	[versionString setStringValue:appVersion];
}

@end
