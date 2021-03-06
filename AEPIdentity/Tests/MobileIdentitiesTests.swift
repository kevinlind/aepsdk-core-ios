/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

@testable import AEPCore
@testable import AEPIdentity
import XCTest

class MobileIdentitiesTests: XCTestCase {
    let configurationSharedState = [ConfigurationConstants.Keys.EXPERIENCE_CLOUD_ORGID: "test-orgid"]
    var identitySharedState: [String: Any] {
        return buildIdentitySharedState()
    }

    private func buildIdentitySharedState() -> [String: Any] {
        var identitySharedState = [String: Any]()
        identitySharedState[IdentityConstants.EventDataKeys.VISITOR_ID_ECID] = "test-ecid"

        let customIdOne = CustomIdentity(origin: "origin1", type: "type1", identifier: "id1", authenticationState: .authenticated)
        let customIdTwo = CustomIdentity(origin: "origin2", type: "type2", identifier: "id2", authenticationState: .loggedOut)
        let customIdThree = CustomIdentity(origin: "origin3", type: "DSID_20915", identifier: "test-advertisingId", authenticationState: .loggedOut)

        identitySharedState[IdentityConstants.EventDataKeys.VISITOR_IDS_LIST] = [customIdOne, customIdTwo, customIdThree].map({$0.asDictionary()})
        identitySharedState[IdentityConstants.EventDataKeys.ADVERTISING_IDENTIFIER] = "test-advertisingId"
        identitySharedState[IdentityConstants.EventDataKeys.PUSH_IDENTIFIER] = "test-pushid"

        return identitySharedState
    }

    // MARK: areSharedStatesReady() tests

    /// Tests that when all shared states are pending that we return false
    func testAreSharedStatesReadyAllPending() {
        // setup
        let event = Event(name: "test event", type: EventType.hub, source: EventSource.sharedState, data: nil)

        // test
        let ready = MobileIdentities().areSharedStatesReady(event: event) { (_, _) -> SharedStateResult? in
            SharedStateResult(status: .pending, value: nil)
        }

        // verify
        XCTAssertFalse(ready)
    }

    /// Tests that when all shared states set to none that we return true
    func testAreSharedStatesReadyAllNone() {
        // setup
        let event = Event(name: "test event", type: EventType.hub, source: EventSource.sharedState, data: nil)

        // test
        let ready = MobileIdentities().areSharedStatesReady(event: event) { (_, _) -> SharedStateResult? in
            SharedStateResult(status: .none, value: nil)
        }

        // verify
        XCTAssertTrue(ready)
    }

    /// Tests that when all shared states are set that we return true
    func testAreSharedStatesReadyAllSet() {
        // setup
        let event = Event(name: "test event", type: EventType.hub, source: EventSource.sharedState, data: nil)

        // test
        let ready = MobileIdentities().areSharedStatesReady(event: event) { (_, _) -> SharedStateResult? in
            SharedStateResult(status: .set, value: nil)
        }

        // verify
        XCTAssertTrue(ready)
    }

    // MARK: getAllIdentifiers() tests

    /// Tests that when configuration and identity provide shared state that we include them in getAllIdentifiers
    func testGetAllIdentifiersHappy() {
        // setup
        let event = Event(name: "test event", type: EventType.hub, source: EventSource.sharedState, data: nil)

        // test
        var mobileIdentities = MobileIdentities()
        mobileIdentities.collectIdentifiers(event: event) { (extensionName, _) -> SharedStateResult? in
            if extensionName == ConfigurationConstants.EXTENSION_NAME {
                return SharedStateResult(status: .set, value: configurationSharedState)
            } else if extensionName == IdentityConstants.EXTENSION_NAME {
                return SharedStateResult(status: .set, value: identitySharedState)
            }

            return SharedStateResult(status: .set, value: nil)
        }

        let encodedIdentities = try? JSONEncoder().encode(mobileIdentities)
        let identifiers = String(data: encodedIdentities!, encoding: .utf8)

        // verify
        let expected = "{\"users\":[{\"userIDs\":[{\"namespace\":\"4\",\"value\":\"test-ecid\",\"type\":\"namespaceId\"},{\"namespace\":\"type1\",\"value\":\"id1\",\"type\":\"integrationCode\"},{\"namespace\":\"type2\",\"value\":\"id2\",\"type\":\"integrationCode\"},{\"namespace\":\"DSID_20915\",\"value\":\"test-advertisingId\",\"type\":\"integrationCode\"},{\"namespace\":\"20920\",\"value\":\"test-pushid\",\"type\":\"integrationCode\"}]}],\"companyContexts\":[{\"namespace\":\"imsOrgID\",\"marketingCloudId\":\"test-orgid\"}]}"
        XCTAssertEqual(expected, identifiers)
    }

    /// Tests that when configuration provides shared state that we include configuration identities in getAllIdentifiers
    func testGetAllIdentifiersOnlyConfiguration() {
        // setup
        let event = Event(name: "test event", type: EventType.hub, source: EventSource.sharedState, data: nil)

        // test
        var mobileIdentities = MobileIdentities()
        mobileIdentities.collectIdentifiers(event: event) { (extensionName, _) -> SharedStateResult? in
            if extensionName == ConfigurationConstants.EXTENSION_NAME {
                return SharedStateResult(status: .set, value: configurationSharedState)
            }

            return SharedStateResult(status: .set, value: nil)
        }

        let encodedIdentities = try? JSONEncoder().encode(mobileIdentities)
        let identifiers = String(data: encodedIdentities!, encoding: .utf8)

        // verify
        let expected = "{\"companyContexts\":[{\"namespace\":\"imsOrgID\",\"marketingCloudId\":\"test-orgid\"}]}"
        XCTAssertEqual(expected, identifiers)
    }

    /// Tests that when identity provides shared state that we include identity identities in getAllIdentifiers
    func testGetAllIdentifiersOnlyIdentity() {
        // setup
        let event = Event(name: "test event", type: EventType.hub, source: EventSource.sharedState, data: nil)

        // test
        var mobileIdentities = MobileIdentities()
        mobileIdentities.collectIdentifiers(event: event) { (extensionName, _) -> SharedStateResult? in
            if extensionName == IdentityConstants.EXTENSION_NAME {
                return SharedStateResult(status: .set, value: identitySharedState)
            }

            return SharedStateResult(status: .set, value: nil)
        }

        let encodedIdentities = try? JSONEncoder().encode(mobileIdentities)
        let identifiers = String(data: encodedIdentities!, encoding: .utf8)

        // verify
        let expected = "{\"users\":[{\"userIDs\":[{\"namespace\":\"4\",\"value\":\"test-ecid\",\"type\":\"namespaceId\"},{\"namespace\":\"type1\",\"value\":\"id1\",\"type\":\"integrationCode\"},{\"namespace\":\"type2\",\"value\":\"id2\",\"type\":\"integrationCode\"},{\"namespace\":\"DSID_20915\",\"value\":\"test-advertisingId\",\"type\":\"integrationCode\"},{\"namespace\":\"20920\",\"value\":\"test-pushid\",\"type\":\"integrationCode\"}]}]}"
        XCTAssertEqual(expected, identifiers)
    }
}
