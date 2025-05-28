//
//  ContentView.swift
//  DSC291-Assignment1
//
//  Created by Shuying Li on 1/24/24.
//

import SwiftUI
import SwiftUICharts
import CoreMotion

struct ContentView: View {
    @State private var isSensing = false
    @State private var shakeThresholdInput = "4.0"
    @State private var shakeDetectedStatus: String = "N/A"
    @StateObject private var sensorManager = SensorManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    // Barometer data
                    HStack{
                        Image(systemName: "barometer")
                            .font(.title)
                        
                        Text("Barometer value")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.black, lineWidth: 2.5)
                                .background(Color.white)
                            )
                        
                        if let lastBarometerReading = sensorManager.barometerData.last {
                            Text("\(lastBarometerReading.pressure, specifier: "%.2f")")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.green, lineWidth: 2)
                                .background(Color.white)
                                )
                        } else {
                            Text("N/A")
                        }
                        Spacer()
                    }.padding(.horizontal)
                    
                    
                    
                    // 3D Acceleration values
                    HStack {
                        Image(systemName: "gearshape")
                            .font(.title)
                        
                        Text("Acceleration values")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.black, lineWidth: 2.5)
                                .background(Color.white)
                            )
                        
                        if let lastAcceleration = sensorManager.accelerationData.last {
                            Text("\(lastAcceleration[0], specifier: "%.2"), \(lastAcceleration[1], specifier: "%.2f"), \(lastAcceleration[2], specifier: "%.2f")")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.green, lineWidth: 2)
                                .background(Color.white))
                        } else {
                            Text("0, 0, 0")
                        }
                        Spacer()
                    }.padding(.horizontal)
                                     
                    // Shake detector
                    HStack {
                        Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                            .font(.title)
                        
                        Text("The Shake Detector")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.black, lineWidth: 2.5)
                                .background(Color.white)
                            )
                        
                        Text("\(shakeDetectedStatus)")
                        
                        Spacer()
                    }.padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Sensor Data Graph
                    LineChartView(
                        data: sensorManager.accelerationAmplitudeData.isEmpty ? [0] : sensorManager.accelerationAmplitudeData,
                        title: "Sensor Data Graph",
                        legend: "Magnitude",
                        form: ChartForm.extraLarge,
                        dropShadow: false
                    )
                    .padding(.horizontal)
                    
                    Divider().padding()
                    
                    // EditText - User input for step threshold
                    HStack{
                        Image(systemName: "number.square")
                            .font(.largeTitle)
                        
                        TextField("Shake threshold", text: $shakeThresholdInput)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(.black, lineWidth: 2.5))
                            .padding(.horizontal)
                            
                        
                        // Start sensing button
                        Button("Start") {
                            if let threshold = Double(shakeThresholdInput) {
                                sensorManager.shakeThreshold = threshold
                            }
                            sensorManager.startSensors()
                            isSensing = true
                        }
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                        .fontWeight(.bold)
                        
                    }.padding()
                    
                    HStack {
                        // Displaying the step count
                        Image(systemName: "shoeprints.fill")
                            .font(.title)
                        
                        Text("Steps counted: \(sensorManager.stepsCount)")
                            .font(.headline)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.black, lineWidth: 2.5)
                                .background(Color.white)
                        )
                        
                        // Stop sensing button
                        Button("Stop") {
                            sensorManager.stopSensors()
                            isSensing = false
                            shakeDetectedStatus = sensorManager.shakeDetected ? "Shake" : "No Shake"
                        }
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                        .fontWeight(.bold)
                        
                    }.padding(.horizontal)
                    
                    Spacer()
                }.navigationBarTitle("Assignment One")
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}
