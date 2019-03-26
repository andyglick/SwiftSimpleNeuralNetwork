//
//  WineTest.swift
//  SwiftSimpleNeuralNetwork
//
//  Copyright 2016-2019 David Kopec
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

// Wine data set courtsey of:
// Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, School of Information and Computer Science.

import XCTest
import Foundation

/// Train on 150 wines and then successfully classify
/// 28 previously unseen wines.
class WineTest: XCTestCase {

    var network: Network = Network(layerStructure: [13,7,3], learningRate: 0.3, hasBias: true)
    // for training
    var wineParameters: [[Double]] = [[Double]]()
    var wineClassifications: [[Double]] = [[Double]]()
    // for testing/validation
    var wineSamples: [[Double]] = [[Double]]()
    var wineCultivars: [Int] = [Int]()
    
    func parseWineCSV() {
        let myBundle = Bundle.init(for: WineTest.self)
        let urlpath = myBundle.path(forResource: "wine", ofType: "csv")
        let url = URL(fileURLWithPath: urlpath!)
        let csv = try! String.init(contentsOf: url)
        let lines = csv.components(separatedBy: "\n")
        
        let shuffledLines = lines.shuffled
        for line in shuffledLines {
            if line == "" { continue }
            let items = line.components(separatedBy: ",")
            let parameters = items[1...13].map{ Double($0)! }
            wineParameters.append(parameters)
            let species = Int(items[0])!
            if species == 1 {
                wineClassifications.append([1.0, 0.0, 0.0])
            } else if species == 2 {
                wineClassifications.append([0.0, 1.0, 0.0])
            } else {
                wineClassifications.append([0.0, 0.0, 1.0])
            }
            wineCultivars.append(species)
        }
        normalizeByColumnMax(dataset: &wineParameters)
        wineSamples = Array(wineParameters.dropFirst(150))
        wineCultivars = Array(wineCultivars.dropFirst(150))
        wineParameters = Array(wineParameters.dropLast(28))
    }
    
    func interpretOutput(output: [Double]) -> Int {
        if output.max()! == output[0] {
            return 1
        } else if output.max()! == output[1] {
            return 2
        } else {
            return 3
        }
    }
    
    override func setUp() {
        super.setUp()
        parseWineCSV()
        // train over entire data set 200 times
        for _ in 0..<200 {
            network.train(inputs: wineParameters, expecteds: wineClassifications, printError: false)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSamples() {
        let results = network.validate(inputs: wineSamples, expecteds: wineCultivars, interpretOutput: interpretOutput)
        print("\(results.correct) correct of \(results.total) = \(results.percentage * 100)%")
        XCTAssertEqual(results.percentage, 1.00, accuracy: 0.05, "Did not come within a 95% confidence interval")
    }

}
