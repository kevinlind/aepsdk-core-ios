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

struct StatesConstants {
    static let EXTENSION_NAME = "com.adobe.module.states"
    static let FRIENDLY_NAME = "States"
    static let EXTENSION_VERSION = "0.0.1"
    static let DATA_STORE_NAME = EXTENSION_NAME
    static let LOG_TAG = FRIENDLY_NAME
    
    struct Keys {
        static let NAMESPACE = "namespace"
        static let STATE_DATA = "statedata"
    }
    
    struct EventType {
        static let STATES = "com.adobe.eventType.states"
    }
}
