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

/// provides all the services needed by an `Extension`
@objc(AEPExtensionServiceProvider)
public class ExtensionServiceProvider: NSObject {
    
    private let tenant: Tenant
    
    private let logger: Logger
    
    // TODO - store service instances in variable so they are created once.
    
    init(tenant: Tenant) {
        self.tenant = tenant
        logger = TenantLogger(tenant: tenant)
    }
    
    /// Returns an instance of `NamedCollectionDataStore` with the given `name` appended with this tenant instance's name.
    /// - Parameter name: the name of this data store
    /// - Returns: an instance of type `NamedCollectionDataStore` with the given data store `name` appended with this tenant's name.
    public func getNamedCollectionDataStore(name: String) -> NamedCollectionDataStore {
        return NamedCollectionDataStore(name: name.tenantAwareName(for: tenant))
    }
    
    /// Returns an instance of `DataQueue` with the given `label` appended with this tenant instance's name.
    /// The `DataQueue` instance is provided by the shared `ServiceProvider`.
    /// - Parameter label: the  label assigned to the `DataQueue` when created
    /// - Returns: an instance of type `DataQueue` with the given `label` appended with this tenant's name
    public func getDataQueue(label: String) -> DataQueue? {
        return ServiceProvider.shared.dataQueueService.getDataQueue(label: label.tenantAwareName(for: tenant))
    }
    
    /// Returns an instance of `Cache` with the given cache `name` appended with this tenant instance's name.
    /// - Parameter name: the name of the cache
    /// - Returns: an instance of `Cache` with the given `name` appended with this tenant's name.
    public func getCache(name: String) -> Cache {
        return Cache(name: name.tenantAwareName(for: tenant))
    }
    
    /// Returns an instance of type `Logger` specific to a tenant.
    /// - Returns: a tenant-aware instance of type `Logger`
    public func getLogger() -> Logger {
        return logger
    }
    
    /// Returns a shared instance of tye `Networking` provided by the shared `ServiceProvider`.
    /// The network service is not specific to any tenant.
    /// - Returns: a shared instance of type `Networking`
    public func getNetworkService() -> Networking {
        return ServiceProvider.shared.networkService
    }
    
    /// Returns a shared instance of type `SystemInfoService` provided by the shared `ServiceProvider`.
    /// The system info service provides system level utilities which are not specific to any tenant.
    /// - Returns: a shared instance of type `SystemInfoService`
    public func getSystemInfoService() -> SystemInfoService {
        return ServiceProvider.shared.systemInfoService
    }
    
}

@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension ExtensionServiceProvider {
    
    /// Returns a shared instance of type `URLOpening` provided by the shared `ServiceProvider`.
    /// The URL service is not specific to any tenant.
    /// - Returns: a shared instance of type `URLOpening`
    public func getUrlService() -> URLOpening {
        return ServiceProvider.shared.urlService
    }
    
    #if os(iOS)
    /// Returns a shared instance of type `UIService` provided by the shared `ServiceProvider`.
    /// The UI service is not specific to any tenant.
    /// - Returns: a shared instance of type `UIService`
    public func getUIService() -> UIService {
        return ServiceProvider.shared.uiService
    }
    #endif
}
