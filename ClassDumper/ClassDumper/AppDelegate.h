//
//  AppDelegate.h
//  ClassDumper
//
//  Created by Kramer on 11/20/14.
//  Copyright (c) 2014 Shmoopi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// Advanced Panel
@property (weak) IBOutlet NSPanel *advancedPanel;

// Textfields
@property (weak) IBOutlet NSTextField *txtBinary;
@property (weak) IBOutlet NSTextField *txtOutput;

// Browse Buttons
@property (weak) IBOutlet NSButton *btnInputBrowse;
@property (weak) IBOutlet NSButton *btnOutputBrowse;

// Advanced Panel Objects
@property (weak) IBOutlet NSButton *checkboxShowInstanceVariableOffsets;
@property (weak) IBOutlet NSButton *checkboxShowImplementationAddresses;
@property (weak) IBOutlet NSButton *checkboxChooseSpecificArchitecture;
@property (weak) IBOutlet NSTextField *txtSpecificArchitecture;
@property (weak) IBOutlet NSButton *checkboxOnlyDisplayClassesMatchingRegularExpression;
@property (weak) IBOutlet NSTextField *txtRegularExpression;
@property (weak) IBOutlet NSButton *checkboxFindStringMethodName;
@property (weak) IBOutlet NSTextField *txtMethodNameString;
@property (weak) IBOutlet NSButton *checkboxGenerateHeaderFilesInCurrentDirectory;
@property (weak) IBOutlet NSButton *checkboxGenerateHeaderFilesInSpecifiedDirectory;
@property (weak) IBOutlet NSTextField *txtOutputDirectory;
@property (weak) IBOutlet NSButton *checkboxSortClassesCategoriesAndProtocolsByInheritance;
@property (weak) IBOutlet NSButton *checkboxRecursivelyExpandFrameworksAndFixedVMs;
@property (weak) IBOutlet NSButton *checkboxSortClassesAndCategoriesByName;
@property (weak) IBOutlet NSButton *checkboxSortMethodsByName;
@property (weak) IBOutlet NSButton *checkboxSuprressHeaderInOutputForTesting;
@property (weak) IBOutlet NSButton *checkboxListArchesInFile;

// Functions

// Dump files/folders on the dock icon
- (void)application:(NSApplication *)sender openFiles:(NSArray *) fileNames;

// Actions for buttons on the main view
- (IBAction)dumpClasses:(id)sender;
- (IBAction)advancedOptions:(id)sender;
- (IBAction)browseForInput:(id)sender;
- (IBAction)browseForOutput:(id)sender;

// Actions for buttons on the advanced view
- (IBAction)showInstanceVariableOffsets:(id)sender;
- (IBAction)showImplementationAddresses:(id)sender;
- (IBAction)chooseSpecificArchitecture:(id)sender;
- (IBAction)onlyDisplayClassesMatchingRegularExpression:(id)sender;
- (IBAction)findStringInMethodName:(id)sender;
- (IBAction)generateHeaderFilesInCurrentDirectory:(id)sender;
- (IBAction)GenerateHeaderFilesInSpecifiedDirectory:(id)sender;
- (IBAction)sortClassesCategoriesAndProtocolsByInheritance:(id)sender;
- (IBAction)recursivelyExpandFrameworksAndFixedVMs:(id)sender;
- (IBAction)sortClassesAndCategoriesByName:(id)sender;
- (IBAction)sortMethodsByName:(id)sender;
- (IBAction)suppressHeaderInOutputForTesting:(id)sender;
- (IBAction)listArchesInTheFile:(id)sender;

@end