//
//  AppDelegate.m
//  ClassDumper
//
//  Created by Kramer on 11/20/14.
//  Copyright (c) 2014 Shmoopi. All rights reserved.
//

#import "AppDelegate.h"
#import <Security/Security.h>

@interface AppDelegate () <NSWindowDelegate>

@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }
    else
    {
        [self.window makeKeyAndOrderFront:self];// Window that you want open while click on dock app icon
        return YES;
    }
}

#pragma mark - Drag and Drop Methods

// When an item is dragged and dropped to the dock icon
- (void)application:(NSApplication *)sender openFiles:(NSArray *) fileNames {
    if (fileNames.count > 0) {
        NSString *dropped = [fileNames objectAtIndex:0];
        self.txtBinary.stringValue = dropped;
        if ([[dropped pathExtension] isEqualToString:@"app"]) {
            NSBundle *appBundle = [NSBundle bundleWithPath:dropped];
            self.txtBinary.stringValue = appBundle.executablePath;
        }
    }
}

// Do the actual dump
- (IBAction)dumpClasses:(id)sender {
    // Make sure the binary was input
    if (self.txtBinary.stringValue.length < 1) {
        // No input
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"No Binary Input"];
        [alert setInformativeText:@"Please enter a valid binary path to dump"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        return;
    } else if (![[NSFileManager defaultManager] fileExistsAtPath:self.txtBinary.stringValue]) {
        // No file found
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"No Binary Found"];
        [alert setInformativeText:@"Please enter a valid binary path to dump"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        return;
    }
    
    // Variables to check
    BOOL isDirectory = true;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:self.txtOutput.stringValue isDirectory:&isDirectory];
    
    // Make sure the output directory was selected
    if (self.txtOutput.stringValue.length < 1) {
        // No input
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"No Output Path Selected"];
        [alert setInformativeText:@"Please enter a valid output directory to dump the header files"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        return;
    } else if (!pathExists) {
        // No file found
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Invalid Output Path Selected"];
        [alert setInformativeText:@"Please enter a valid output directory to dump the header files"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        return;
    } else if (!isDirectory) {
        // Not a directory
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Not a directory"];
        [alert setInformativeText:@"Please enter a valid output directory to dump the header files"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        return;
    }
    
    // Variables for binary path
    NSString *binaryPath = self.txtBinary.stringValue;
    
    // Check if the path is a path to a .app folder
    if ([[self.txtBinary.stringValue pathExtension] isEqualToString:@"app"]) {
        // The binary is in the bundle
        NSBundle *appBundle = [NSBundle bundleWithPath:self.txtBinary.stringValue];
        binaryPath = appBundle.executablePath;
        [self.txtBinary setStringValue:binaryPath];
    }
    
    // Dump the classes to the output directory from the binary
    NSTask *classDump = [[NSTask alloc] init];
    
    //Sets launch path.
    [classDump setLaunchPath: [[NSBundle mainBundle] pathForResource:@"class-dump" ofType:nil]];
    //Sends the following command to irecovery.
    [classDump setArguments:[NSArray arrayWithObjects:@"-H", binaryPath, @"-o", self.txtOutput.stringValue, nil]];
    
    // Create the standard output
    NSPipe *outputPipe = [NSPipe pipe];
    [classDump setStandardOutput:outputPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    
    // Create the standard error
    NSPipe *errorPipe = [NSPipe pipe];
    [classDump setStandardError:errorPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[errorPipe fileHandleForReading]];
    [[errorPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    
    // Launch
    [classDump launch];
    [classDump waitUntilExit];
    
    // Check the output
    if ([classDump terminationStatus] != 0) {
        // Failed for some reason
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to dump the binary"];
        [alert setInformativeText:@"Please check the settings and try again..."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    } else {
        // Successful
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Binary Dumped Successfully!"];
        [alert setInformativeText:@"Check out the dumped headers"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        
        // Open a Finder window to the shared path
        [[NSWorkspace sharedWorkspace] openFile:self.txtOutput.stringValue withApplication:@"Finder"];
    }
}

// Standard Output
- (void)readCompleted:(NSNotification *)notification {
    // Check what the standard output is
    if ([[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]) {
        NSLog(@"Standard Output: %@", [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
}

// Standard Error
- (void)errorCompleted:(NSNotification *)notification {
    // Check what the standard error is
    if ([[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]) {
        NSLog(@"Standard Error: %@", [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
}

// Show the drawer window
- (IBAction)advancedOptions:(id)sender {
    if ([self.advancedPanel isVisible]) {
        [[NSApplication sharedApplication] endSheet:self.advancedPanel];
    } else {
        [[NSApplication sharedApplication] beginSheet:self.advancedPanel modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
    }
}

// Browse for the binary
- (IBAction)browseForInput:(id)sender {
    // Create the open dialog
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setPrompt:@"Select"];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setDirectoryURL:[NSURL URLWithString:@"/Applications/"]];
    // Block to handle the completion
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            // Get the selected file
            NSURL *file = [openDlg URL];
            [self.txtBinary setStringValue:file.path];
        }
    }];
}

// Choose the output directory
- (IBAction)browseForOutput:(id)sender {
    // Create the open dialog
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setPrompt:@"Select"];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    [openDlg setDirectoryURL:[NSURL URLWithString:@"~/Documents/"]];
    
    // Block to handle the completion
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            // Get the selected directory
            NSURL *file = [openDlg URL];
            [self.txtOutput setStringValue:file.path];
        }
    }];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (IBAction)showImplementationAddresses:(id)sender {
}

- (IBAction)chooseSpecificArchitecture:(id)sender {
}

- (IBAction)onlyDisplayClassesMatchingRegularExpression:(id)sender {
}

- (IBAction)showInstanceVariableOffsets:(id)sender {
}
- (IBAction)findStringInMethodName:(id)sender {
}

- (IBAction)generateHeaderFilesInCurrentDirectory:(id)sender {
}

- (IBAction)GenerateHeaderFilesInSpecifiedDirectory:(id)sender {
}

- (IBAction)sortClassesCategoriesAndProtocolsByInheritance:(id)sender {
}

- (IBAction)recursivelyExpandFrameworksAndFixedVMs:(id)sender {
}

- (IBAction)sortClassesAndCategoriesByName:(id)sender {
}

- (IBAction)sortMethodsByName:(id)sender {
}

- (IBAction)suppressHeaderInOutputForTesting:(id)sender {
}

- (IBAction)listArchesInTheFile:(id)sender {
}
@end
