/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation
import MapKit

class NewRunViewController: UIViewController {
  
//  @IBOutlet weak var launchPromptStackView: UIStackView!
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet var speedUnitLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
//	@IBOutlet var mapContainerView: UIView!
	@IBOutlet var bgView: UIVisualEffectView!
	
	@IBOutlet var buttons: [UIButton]!
	private var run: Run?
	private let locationManager = LocationManager.shared
	private var start = Date()
	private var seconds: Int {
		return -Int(start.timeIntervalSinceNow)
	}
	private var timer: Timer?
	private var distance = Measurement(value: 0, unit: UnitLength.meters)
	private var currentSpeed = Measurement(value: 0, unit: UnitSpeed.metersPerSecond)
	private var locationList: [CLLocation] = []
	private var findingIntialLocation = true
	
	
	
	func showStats() {
		UIView.animate(withDuration: 0.5) {
			self.dataStackView.isHidden = false
			self.startButton.isHidden = true
			self.stopButton.isHidden = false
			self.bgView.isHidden = false
		}
		
	}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataStackView.isHidden = true
		bgView.isHidden = true
		findingIntialLocation = true
		startLocationUpdates()
		customizeViews()
		stopButton.isHidden = true
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		timer?.invalidate()
		locationManager.stopUpdatingLocation()
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
	
	func customizeViews() {
		for button in buttons {
			button.layer.cornerRadius = 10
		}
		
		bgView.contentView.layer.cornerRadius = 10
		
	}
	
  @IBAction func startTapped() {
		startRun()
  }
  
  @IBAction func stopTapped() {

		let alertController = UIAlertController(title: "End run?",
		                                        message: "Do you wish to end your run?",
		                                        preferredStyle: .actionSheet)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
			self.stopRun()
			self.saveRun()
			self.navigationController?.setNavigationBarHidden(false, animated: true)
			self.performSegue(withIdentifier: .details, sender: nil)
		})
		
		alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
			self.stopRun()
//      _ = self.navigationController?.popToRootViewController(animated: true)
		})
		
		present(alertController, animated: true)
  }
	
	private func startRun() {
//		launchPromptStackView.isHidden = true
//		navigationController?.navigationBar.isHidden = true
		navigationController?.setNavigationBarHidden(true, animated: true)
		start = Date()
		
		findingIntialLocation = false
		
		showStats()
		
//		seconds = 0
		distance = Measurement(value: 0, unit: UnitLength.meters)
		locationList.removeAll()
		updateDisplay()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
			self.eachSecond()
		}
		startLocationUpdates()
//		mapView.userTrackingMode = .followWithHeading
//		mapView.mapType
//		mapContainerView.isHidden = false
		mapView.removeOverlays(mapView.overlays)
		UIApplication.shared.isIdleTimerDisabled = true
	}
	
	private func stopRun() {
//		launchPromptStackView.isHidden = false
//		navigationController?.navigationBar.isHidden = false
    UIView.animate(withDuration: 0.5) {
      self.dataStackView.isHidden = true
      self.bgView.isHidden = true
      self.startButton.isHidden = false
      self.stopButton.isHidden = true
    }
		locationManager.stopUpdatingLocation()
//		mapContainerView.isHidden = true
		UIApplication.shared.isIdleTimerDisabled = false

	}
	
	private func startLocationUpdates() {
		print(#function)

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManager.activityType = .fitness
		locationManager.distanceFilter = 1
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.showsBackgroundLocationIndicator = true
		locationManager.startUpdatingLocation()
	}
	
	func eachSecond() {
//		seconds += 1
		updateDisplay()
	}
	
	private func updateDisplay() {
		let formattedDistance = FormatDisplay.distance(distance)
		let formattedTime = FormatDisplay.time(seconds)
//		let formattedPace = FormatDisplay.pace(distance: distance,
//		                                       seconds: seconds,
//		                                       outputUnit: UnitSpeed.minutesPerMile)
//		let formattedSpeed = FormatDisplay.speedFormatter.string(from: currentSpeed)
		let formattedSpeed = FormatDisplay.speedFormatter.string(from: currentSpeed)
//    print("Speed Unit: \()")
		
		distanceLabel.text = "\(formattedDistance)"
		timeLabel.text = "\(formattedTime)"
		paceLabel.text = "\(formattedSpeed)" // \(formattedPace) -
//    speedUnitLabel.text = "\(UnitSpeed.milesPerHour.symbol)" // \(formattedPace) -

	}
	
	private func saveRun() {
		let newRun = Run(context: CoreDataStack.context)
		newRun.distance = distance.value
		newRun.duration = Int16(seconds)
		newRun.timestamp = Date()
		
		for location in locationList {
			let locationObject = Location(context: CoreDataStack.context)
			locationObject.timestamp = location.timestamp
			locationObject.latitude = location.coordinate.latitude
			locationObject.longitude = location.coordinate.longitude
			newRun.addToLocations(locationObject)
		}
		
		CoreDataStack.saveContext()
		
		run = newRun
	}
  
}

extension NewRunViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case details = "RunDetailsViewController"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .details:
			let destination = segue.destination as! RunDetailsViewController
			destination.run = run
		}
	}
}

extension NewRunViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		for newLocation in locations {
			let howRecent = newLocation.timestamp.timeIntervalSinceNow
			guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
//				print("Rejecting bad location.")
				continue
				
			}
			
			guard !findingIntialLocation else {
//				print("Found Initial Location.")

				findingIntialLocation = false
				locationManager.stopUpdatingLocation()
				let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
				mapView.setRegion(region, animated: true)
				return
			}
			
			if let lastLocation = locationList.last {
				let delta = newLocation.distance(from: lastLocation)
				distance = distance + Measurement(value: delta, unit: UnitLength.meters)
//				let coordinates = [lastLocation.coordinate, newLocation.coordinate]
//				mapView.add(MKPolyline(coordinates: coordinates, count: 2))
//				let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 200, 200)
//				mapView.setRegion(region, animated: true)
				
			}
			currentSpeed = Measurement(value: newLocation.speed, unit: UnitSpeed.metersPerSecond)
			locationList.append(newLocation)
			let center = newLocation.coordinate.adjust(by: 200 / 1000, at: newLocation.course)
			let camera = MKMapCamera(lookingAtCenter: center, fromDistance: 600, pitch: 80, heading: newLocation.course)
			mapView.setCamera(camera, animated: true)
		}
		
//		guard let lastLocation = locations.last else { return }
		
	}
}

extension NewRunViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MKPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = .blue
		renderer.lineWidth = 3
		return renderer
	}
}
