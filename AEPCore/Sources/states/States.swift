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
import AEPServices

class States: NSObject, Extension {
    var name: String = StatesConstants.EXTENSION_NAME
    
    var friendlyName: String = StatesConstants.FRIENDLY_NAME
    
    static var extensionVersion: String = StatesConstants.EXTENSION_VERSION
    
    var metadata: [String : String]? = nil
    
    var runtime: ExtensionRuntime
    
    /// Invoked when extension is registered with the `EventHub`.
    /// Registers listener to handle get/set shared state requests.
    func onRegistered() {
        registerListener(type: StatesConstants.EventType.STATES,
                         source: EventSource.requestContent,
                         listener: handleSharedStateEvent)
    }
    
    /// Invoked when extension is unregistered from the `EventHub` - currently a no-op.
    func onUnregistered() {}
    
    required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
    }
    
    /// States extension is always ready for an `Event`
    /// - Parameter event: an `Event`
    func readyForEvent(_ event: Event) -> Bool {
        return true
    }
    
    private func handleSharedStateEvent(event: Event) {
        guard let eventData = event.data else {
            Log.debug(label: StatesConstants.LOG_TAG, "Event '\(event.id)' contains no data, ignoring.")
            return
        }
        
        guard let namespace = eventData[StatesConstants.Keys.NAMESPACE] as? String else {
            Log.debug(label: StatesConstants.LOG_TAG, "Event '\(event.id)' does not contain required 'namespace' field, ignoring.")
            return
        }
        
        if let data = eventData[StatesConstants.Keys.STATE_DATA] as? [String: Any] {
            // Set shared state request if event has "statedata"
            handleSetSharedState(for: namespace, data: data, event: event)
        } else {
            // Get shared state request if no "statedata"
            handleGetSharedState(for: namespace, event: event)
        }
    }
    
    func handleSetSharedState(for namespace: String, data: [String: Any], event: Event) {
        runtime.createSharedState(for: namespace, data: data, event: event)
    }
    
    func handleGetSharedState(for namespace: String, event: Event) {
        let eventData: [String: Any] = runtime.getSharedState(for: namespace, extensionName: name, event: event, barrier: false, resolution: .any)?.value ?? [:]
        
        let event = event.createResponseEvent(name: "Namespaced Shared State Response",
                                              type: StatesConstants.EventType.STATES,
                                              source: EventSource.responseContent,
                                              data: eventData)
        runtime.dispatch(event: event)
    }
    
}
