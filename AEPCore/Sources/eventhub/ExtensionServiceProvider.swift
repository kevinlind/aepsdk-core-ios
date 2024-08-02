//
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

/// provides all the methods needed by an `Extension`
@objc(AEPExtensionServiceProvider)
public class ExtensionServiceProvider: NSObject {
    
    private let tenant: Tenant
    
    // TODO - store service instances in variable so they are created once.
    init(tenant: Tenant) {
        self.tenant = tenant
    }
    
    public func getNamedCollectionDataStore(name: String) -> NamedCollectionDataStore {
        return NamedCollectionDataStore(name: name.tenantAwareName(for: tenant))
    }
    
    public func getDataQueue(label: String) -> DataQueue? {
        return ServiceProvider.shared.dataQueueService.getDataQueue(label: label.tenantAwareName(for: tenant))
    }
    
    public func getCache(name: String) -> Cache {
        return Cache(name: name.tenantAwareName(for: tenant))
    }
    
    public func getLog() -> TenantLogger {
        return TenantLogger(tenantId: tenant.id)
    }
    
    // TODO - create wrapper for Networking service to pass in tenant ID
    public func getNetworkService() -> Networking {
        return ServiceProvider.shared.networkService
    }
    
    // TODO - create wrapper/overload init to pass in tenant ID
    public func getSystemInfoService() -> SystemInfoService {
        return ServiceProvider.shared.systemInfoService
    }
    
}
