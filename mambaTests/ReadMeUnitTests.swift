//
//  ReadMeUnitTests.swift
//  mamba
//
//  Created by David Coufal on 9/26/17.
//  Copyright © 2017 Comcast Corporation.
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
//

import XCTest
import mamba

/*
 This test exists only to test the code provided in the README.md.
 
 If this test fails or fails to compile, that's a canary that means we should update
 the README.md file, because something has changed.
 */

class ReadMeUnitTests: XCTestCase {
    
    func testMambaReadmeCode() {
        
        // Parsing a HLS Manifest
        //***********************
        
        let parser = HLSParser()
        
        let myManifestData: Data = FixtureLoader.load(fixtureName: "bipbopall.m3u8")! as Data // source of HLS data
        let myManifestURL: URL = URL(string: "https://not.a.real.server/main.m3u8")! // the URL of this manifest resource
        
        parser.parse(manifestData: myManifestData,
                     url: myManifestURL,
                     success: { manifest in
                        // do something with the parsed HLSManifest object
        },
                     failure: { parserError in
                        // handle the HLSParserError
        })
        
        let manifest: HLSManifest
        do {
            // note: could take several milliseconds for large transcripts!
            manifest = try parser.parse(manifestData: myManifestData,
                                        url: myManifestURL)
        }
        catch {
            // we received an error in parsing this manifest
            return
        }
        
        // Validating a HLS Manifest
        //**************************
        
        let issues = HLSCompleteManifestValidator.validate(hlsManifest: manifest)
        
        // Writing a HLS Manifest
        //***********************
        
        let writer = HLSWriter()
        
        let stream = OutputStream.toMemory() // stream to receive the HLS Manifest
        stream.open()
        
        do {
            try writer.write(hlsManifest: manifest, toStream: stream)
        }
        catch {
            // there was an error severe enough for us to stop writing the data
        }
        
        // Cleanup code
        //*************
        
        XCTAssertNil(issues)
        stream.close()
    }
}

// Using Custom Tags
//******************

// #EXT-MY-CUSTOM-TAG:CUSTOMDATA1="Data1",CUSTOMDATA2="Data1"

enum MyCustomTagSet: String {
    // define your custom tags here
    case EXT_MY_CUSTOM_TAG = "EXT-MY-CUSTOM-TAG"
}

extension MyCustomTagSet: HLSTagDescriptor {
    // conform to HLSTagDescriptor here
    
    func toString() -> String {
        return self.rawValue
    }
    
    func isEqual(toTagDescriptor: HLSTagDescriptor) -> Bool {
        return false
    }
    
    func scope() -> HLSTagDescriptorScope {
        return .unknown
    }
    
    func type() -> HLSTagDescriptorType {
        return .keyValue
    }
    
    static func parser(forTag: HLSTagDescriptor) -> HLSTagParser? {
        return nil
    }
    
    static func writer(forTag: HLSTagDescriptor) -> HLSTagWriter? {
        return nil
    }
    
    static func validator(forTag: HLSTagDescriptor) -> HLSTagValidator? {
        return nil
    }
    
    static func constructDescriptor(fromStringRef: HLSStringRef) -> HLSTagDescriptor? {
        return nil
    }
}

let customParser = HLSParser(tagTypes: [MyCustomTagSet.self])

enum MyCustomValueIdentifiers: String {
    // define your custom value identifiers here
    case CUSTOMDATA1 = "CUSTOMDATA1"
    case CUSTOMDATA2 = "CUSTOMDATA2"
}

extension MyCustomValueIdentifiers: HLSTagValueIdentifier {
    // conform to HLSTagValueIdentifier here
    
    func toString() -> String {
        return self.rawValue
    }
}
