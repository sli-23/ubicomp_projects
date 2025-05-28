//
//  ViewModel.swift
//  DSC291-Assignment-1
//
//  Created by Shuying Li on 1/24/24.
//

import Foundation
import CoreMotion
import HealthKit

class SensorManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var altimeter = CMAltimeter()
    private var healthStore: HKHealthStore?

    @Published var accelerationData: [[Double]] = []
    @Published var accelerationAmplitudeData: [Double] = []
    @Published var barometerData: [(pressure: Double, relativeAltitude: Double)] = []
    @Published var stepsCount = 0
    @Published var shakeDetected = false
    
    private var lastAmplitude: Double = 0
    private var isTrendIncreasing = false
    var stepDetectionThreshold: Double = 0.5
    var shakeThreshold: Double = 1.0
    
    func startSensors() {
        stepsCount = 0
        shakeDetected = false
        
        // Accelerometer updates
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data else { return }
                
                let ax = data.acceleration.x
                let ay = data.acceleration.y
                let az = data.acceleration.z
                let acceleration = [ax, ay, az]
                let amplitude = sqrt(ax * ax + ay * ay + az * az)
                
                DispatchQueue.main.async {
                    self?.detectShake(ax: ax, ay: ay, az: az)
                    self?.processAmplitude(amplitude)
                    self?.accelerationData.append(acceleration)
                    self?.accelerationAmplitudeData.append(amplitude)
                }
            }
        }
        
        // Barometer updates
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data else { return }
                let pressure = data.pressure.doubleValue
                let relativeAltitude = data.relativeAltitude.doubleValue
                
                DispatchQueue.main.async {
                    self?.barometerData.append((pressure, relativeAltitude))
                    if self?.barometerData.count ?? 0 > 200 {
                        self?.barometerData.removeFirst()
                    }
                }
            }
        }
    }
    
    private func detectShake(ax: Double, ay: Double, az: Double) {
        let amplitude = sqrt(ax * ax + ay * ay + az * az)
        shakeDetected = amplitude >= shakeThreshold
    }
    
    private func processAmplitude(_ amplitude: Double) {
        let delta = amplitude - lastAmplitude
        if abs(delta) > stepDetectionThreshold {
            if delta > 0 && !isTrendIncreasing {
                stepsCount += 1
            }
            isTrendIncreasing = delta > 0
        }
        lastAmplitude = amplitude
    }
    
    func stopSensors() {
        motionManager.stopAccelerometerUpdates()
        altimeter.stopRelativeAltitudeUpdates()
    }
}
