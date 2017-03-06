//
//  PreviewWindowController.swift
//  Preview
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import AppKit

class PreviewWindowController: NSWindowController {

	// MARK: - Properties

	let screenSaver = CountdownView()


	// MARK: - NSWindowController

	override func windowDidLoad() {
		super.windowDidLoad()

		window?.contentView = screenSaver

		Timer.scheduledTimer(timeInterval: screenSaver.animationTimeInterval, target: screenSaver, selector: #selector(CountdownView.animateOneFrame), userInfo: nil, repeats: true)
	}


	// MARK: - Actions

	@IBAction func showConfiguration(sender: AnyObject?) {
		if let sheet = screenSaver.configureSheet() {
			window?.beginSheet(sheet, completionHandler: nil)
		}
	}
}
