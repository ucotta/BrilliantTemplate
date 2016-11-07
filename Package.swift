//
//  Package.swift
//  BrilliantTemplate
//
//  Created by Ubaldo Cotta on 2/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import PackageDescription

print("---------------------------------------------------------------------------------")
print("BrilliantTemplate depends libxml2, please, configure Xcode by reading the wiki:")
print("\n\thttps://github.com/ucotta/BrilliantTemplate/wiki/Prerequisites-and-Setup")
print("\nYep, you dont read docs, ok, do it:")
print("\n\tbrew install libxml2")
print("\nNow open xcode and change this settings in your project:")
print("\n\tIn Other Linker flags in PROJECT:\n\t\tadd -lxml2")
print("\tIn Header Search Paths in Kanna and your project: \n\t\tadd $(SDKROOT)/usr/include/libxml2")
print("\tObjective-C Bridging Header in Kanna and your project: \n\t\tadd $PROJECT_DIR/Sources/Bridging-Header.h")
print("\nCopy Bridging-Header.h from Packages/BrilliantTemplate-X.X/Sources into ")
print("  your Sources path and add it to Xcode")
print("---------------------------------------------------------------------------------")


let package = Package(
	name: "BrilliantTemplate",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/ucotta/Kanna.git", majorVersion: 2)
	]
)
