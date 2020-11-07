//
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

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
	var location: CLLocation {
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
	private func radians(from degrees: CLLocationDegrees) -> Double {
		return degrees * .pi / 180.0
	}
	
	private func degrees(from radians: Double) -> CLLocationDegrees {
		return radians * 180.0 / .pi
	}
	
	func adjust(by distance: CLLocationDistance, at bearing: CLLocationDegrees) -> CLLocationCoordinate2D {
		let distanceRadians = distance / 6_371.0   // 6,371 = Earth's radius in km
		let bearingRadians = radians(from: bearing)
		let fromLatRadians = radians(from: latitude)
		let fromLonRadians = radians(from: longitude)
		
		let toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians)
			+ cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) )
		
		var toLonRadians = fromLonRadians + atan2(sin(bearingRadians)
			* sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians)
				- sin(fromLatRadians) * sin(toLatRadians))
		
		// adjust toLonRadians to be in the range -180 to +180...
		toLonRadians = fmod((toLonRadians + 3.0 * .pi), (2.0 * .pi)) - .pi
		
		let result = CLLocationCoordinate2D(latitude: degrees(from: toLatRadians), longitude: degrees(from: toLonRadians))
		
		return result
	}
}

