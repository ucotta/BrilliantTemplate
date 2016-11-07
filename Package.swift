//
//  Package.swift
//  BrilliantTemplate
//
//  Created by Ubaldo Cotta on 2/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import PackageDescription


let package = Package(
	name: "BrilliantTemplate",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/ucotta/BrilliantHTML5Parser.git", majorVersion: 0)
	],
	exclude: ["BrilliantTemplateTest"]
	
)
