/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation

/// Implements the `States` public APIs
@objc
public extension MobileCore {
    
    /// Set event state context data to a named bucket.
    /// - Parameters:
    ///   - namespace: <#namespace description#>
    ///   - state: <#state description#>
    @objc(setSharedState:state:)
    static func setSharedState(namespace: String, state: [String: Any]) {
        let eventData: [String: Any] = [StatesConstants.Keys.NAMESPACE: namespace, StatesConstants.Keys.STATE_DATA: state]
        let event = Event(name: "Set Namespaced Shared State",
                          type: StatesConstants.EventType.STATES,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event)
    }
    
    /// Get event state context data previously saved to the named `namespace` bucket.
    /// - Parameters:
    ///   - namespace: <#namespace description#>
    ///   - completion: <#completion description#>
    @objc(getSharedState:completion:)
    static func getSharedState(namespace: String, _ completion: @escaping ([String: Any]?, Error?) -> Void) {
        let eventData: [String: Any] = [StatesConstants.Keys.NAMESPACE: namespace]
        let event = Event(name: "Get Namespaced Shared State",
                          type: StatesConstants.EventType.STATES,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event) { responseEvent in
            guard let responseEvent = responseEvent else {
                completion(nil, AEPError.callbackTimeout)
                return
            }
            
            if let data = responseEvent.data {
                completion(data, nil)
                return
            }
            
            completion(nil, AEPError.unexpected)
        }
    }
}
