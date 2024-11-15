//
// Copyright 2023 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import Foundation

public struct ClassFinder {
    private static func allClasses() -> [AnyClass] {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        if numberOfClasses > 0 {
            let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
            let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
            let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
            // TODO this assert may hold true if dependencies are refreshed (i.e. pod update) while app built without full clean
            assert(numberOfClasses == count)
            defer { classesPtr.deallocate() }
            let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
            return classes
        }
        return []
    }

    public static func classes(conformToProtocol `protocol`: Protocol) -> [AnyClass] {
        let classes = self.allClasses().filter { foundClass in
            var anyClass: AnyClass? = foundClass
            while let foundClass = anyClass {
                if class_conformsToProtocol(foundClass, `protocol`) { return true }
                anyClass = class_getSuperclass(foundClass)
            }
            return false
        }
        return classes
    }

    public static func classesFromBundleAEPKey() -> [AnyClass] {
        var classes: [AnyClass] = []
        for bundle in Bundle.allFrameworks {
            guard let bundleIdentifier = bundle.bundleIdentifier, bundleIdentifier.hasPrefix("com.adobe.aep.") else {
                continue
            }

            //Log.trace(label: "ClassFinder", "Found bundle for \(bundleIdentifier)")

            guard let plist = bundle.infoDictionary, 
                    let extensionClass = plist["AEPExtensionClass"] as? String
            else {
                continue
            }

            if let cls: AnyClass = NSClassFromString("\(extensionClass)") {
                classes.append(cls)
            }

        }

        return classes
    }

    public static func classesFromBundleWithExistingKeys() -> [AnyClass] {
        var classes: [AnyClass] = []
        for bundle in Bundle.allFrameworks {
            guard let bundleIdentifier = bundle.bundleIdentifier, bundleIdentifier.hasPrefix("com.adobe.aep.") else {
                continue
            }

            //Log.trace(label: "ClassFinder", "Found bundle for \(bundleIdentifier)")

            guard let plist = bundle.infoDictionary,
                  let bundleExecutable = plist["CFBundleExecutable"] as? String,
                  let bundleName = plist["CFBundleName"] as? String
            else {
                //Log.trace(label: "ClassFinder", "Failed to get Plist, executable, or name for \(bundleIdentifier)")
                continue
            }

            let namespace = bundleExecutable.replacingOccurrences(of: " ", with: "_")
            let className = bundleName.dropFirst(3)

            if let cls: AnyClass = NSClassFromString("\(namespace).\(className)") {
                classes.append(cls)
            }

        }

        return classes
    }
}
