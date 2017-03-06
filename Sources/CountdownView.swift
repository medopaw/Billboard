//
//  CountdownView.swift
//  Countdown
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import Foundation
import ScreenSaver

class CountdownView: ScreenSaverView {

	// MARK: - Properties

	fileprivate let placeholderLabel: Label = {
		let view = Label()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.stringValue = "Open Screen Saver Options to set your date."
		view.textColor = .white
		view.isHidden = true
		return view
	}()

	fileprivate let daysView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "DAYS"
		return view
	}()

	fileprivate let hoursView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "HOURS"
		return view
	}()

	fileprivate let minutesView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "MINUTES"
		return view
	}()

	fileprivate let secondsView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "SECONDS"
		return view
	}()

	fileprivate let placesView: NSStackView = {
		let view = NSStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	fileprivate lazy var configurationWindowController: NSWindowController = {
		return ConfigurationWindowController()
	}()

	fileprivate var date: Date? {
		didSet {
			updateFonts()
		}
	}


	// MARK: - Initializers

	convenience init() {
		self.init(frame: CGRect.zero, isPreview: false)
	}

	override init!(frame: NSRect, isPreview: Bool) {
		super.init(frame: frame, isPreview: isPreview)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	

	// MARK: - NSView

	override func draw(_ rect: NSRect) {
		let backgroundColor: NSColor = .black

		backgroundColor.setFill()
		NSBezierPath.fill(bounds)
	}

	// If the screen saver changes size, update the font
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
		updateFonts()
	}


	// MARK: - ScreenSaverView

	override func animateOneFrame() {
		placeholderLabel.isHidden = date != nil
		placesView.isHidden = !placeholderLabel.isHidden

		guard let date = date else { return }

		let units: NSCalendar.Unit = [.day, .hour, .minute, .second]
		let now = Date()
		let components = (Calendar.current as NSCalendar).components(units, from: now, to: date, options: [])

		daysView.textLabel.stringValue = String(format: "%02d", abs(components.day!))
		hoursView.textLabel.stringValue = String(format: "%02d", abs(components.hour!))
		minutesView.textLabel.stringValue = String(format: "%02d", abs(components.minute!))
		secondsView.textLabel.stringValue = String(format: "%02d", abs(components.second!))
	}

	override func hasConfigureSheet() -> Bool {
		return true
	}

	override func configureSheet() -> NSWindow? {
		return configurationWindowController.window
	}
	

	// MARK: - Private

	/// Shared initializer
	fileprivate func initialize() {
		// Set animation time interval
		animationTimeInterval = 1 / 30

		// Recall preferences
		date = Preferences().date as Date?

		// Setup the views
		addSubview(placeholderLabel)

		placesView.addArrangedSubview(daysView)
		placesView.addArrangedSubview(hoursView)
		placesView.addArrangedSubview(minutesView)
		placesView.addArrangedSubview(secondsView)
		addSubview(placesView)

		updateFonts()

		addConstraints([
			placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

			placesView.centerXAnchor.constraint(equalTo: centerXAnchor),
			placesView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])

		// Listen for configuration changes
		NotificationCenter.default.addObserver(self, selector: #selector(dateDidChange), name: NSNotification.Name(rawValue: Preferences.dateDidChangeNotificationName), object: nil)
	}

	/// Age calculation
	fileprivate func ageFordate(_ date: Date) -> Double {
		return 0
	}

	/// date changed
	@objc fileprivate func dateDidChange(_ notification: Notification?) {
		date = Preferences().date as Date?
	}

	/// Update the font for the current size
	fileprivate func updateFonts() {
		placesView.spacing = floor(bounds.width * 0.05)

		placeholderLabel.font = fontWithSize(floor(bounds.width / 30), monospace: false)

		let places = [daysView, hoursView, minutesView, secondsView]
		let textFont = fontWithSize(round(bounds.width / 8), weight: NSFontWeightUltraLight)
		let detailTextFont = fontWithSize(floor(bounds.width / 38), weight: NSFontWeightThin)

		for place in places {
			place.textLabel.font = textFont
			place.detailTextLabel.font = detailTextFont
		}
	}

	/// Get a font
	fileprivate func fontWithSize(_ fontSize: CGFloat, weight: CGFloat = NSFontWeightThin, monospace: Bool = true) -> NSFont {
		let font = NSFont.systemFont(ofSize: fontSize, weight: weight)

		let fontDescriptor: NSFontDescriptor
		if monospace {
			fontDescriptor = font.fontDescriptor.addingAttributes([
				NSFontFeatureSettingsAttribute: [
					[
						NSFontFeatureTypeIdentifierKey: kNumberSpacingType,
						NSFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
					]
				]
			])
		} else {
			fontDescriptor = font.fontDescriptor
		}

		return NSFont(descriptor: fontDescriptor, size: max(4, fontSize))!
	}
}
