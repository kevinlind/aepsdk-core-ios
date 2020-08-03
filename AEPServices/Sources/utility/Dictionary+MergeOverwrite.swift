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

import Foundation

// TODO: - Confirm optional Any as the expected value type for this
extension Dictionary where Key == String, Value == Any? {
    private static let SUFFIX_FOR_OBJECT = "[*]"
    ///
    /// Merges the new dictionary into this Dictionary, overwriting matching key value pairs from the new dictionary
    /// - Parameters
    ///     - new: The new Dictionary containing the higher priority key value pairs
    ///     - deleteIfEmpty: A bool indicating whether a key should be removed if the value is nil
    mutating func mergeOverwrite(new: [String: Any?], deleteIfEmpty: Bool) {
       // First, overwrite all matching key value pairs with new values, and recursively handle nested dictionaries
       self.merge(new, uniquingKeysWith: { (old, new) in
        guard let newDict = new as? [String: Any?] else { return new }
        guard var oldDict = old as? [String: Any?] else { return new }
        oldDict.mergeOverwrite(new: newDict, deleteIfEmpty: deleteIfEmpty)
        return oldDict
       })
        
        for (k, v) in self {
            // Secondly, now we must check for the unique SUFFIX_FOR_OBJECT in the key to attach the data in the internal dict
            if k.range(of: Dictionary.SUFFIX_FOR_OBJECT) != nil {
                guard let range = k.range(of: Dictionary.SUFFIX_FOR_OBJECT) else { continue }
                let keyWithoutSuffix: String = String(k[..<range.lowerBound])
                // The KV exists without the suffix, so we must attach the data to each item in the Array
                if self[keyWithoutSuffix] != nil {
                    // If the new attach data dict value is nil, set nil and continue
                    // Must do this because new[k] == nil checks if the key exists, not if the value is nil
                    if new.keys.contains(k), new[k]! == nil {
                        self.updateValue(nil, forKey: keyWithoutSuffix)
                        continue
                    }
                    // The array of items which will receive the attach data payload
                    guard let arrOfReceivers: [Any?] = self[keyWithoutSuffix] as? [Any?] else { continue }
                    let arrWithAttachedData = arrOfReceivers.map { item -> Any? in
                        // check if the item is a dictionary, if so, attach data to it
                        guard var itemDict = item as? [String: Any?] else { return item }
                        guard let attachData = self[k] as? [String: Any?] else { return item }
                        itemDict.mergeOverwrite(new: attachData, deleteIfEmpty: deleteIfEmpty)
                        return itemDict
                    }
                    
                    self[keyWithoutSuffix] = arrWithAttachedData
                    // Remove the attach data from the merged dict
                    self.removeValue(forKey: k)
                }
            } else if deleteIfEmpty {
                // If it's a nested dictionary, handle internal nil values
                if var innerDict = v as? [String: Any?] {
                    innerDict.mergeOverwrite(new: [:], deleteIfEmpty: deleteIfEmpty)
                    self[k] = innerDict
                }
            }
        }
        
        if deleteIfEmpty {
            // Remove top level nils
            let nonilDict = self.compactMapValues { $0 }
            self = nonilDict
        }
    }
}
