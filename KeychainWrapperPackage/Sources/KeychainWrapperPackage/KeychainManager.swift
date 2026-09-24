// SPDX-License-Identifier: EUPL-1.2

//
//  KeychainManager.swift
//  KeychainWrapperPackage
//
//  Created by Matīss Mamedovs on 03/12/2024.
//

import Foundation
import os

private let keychainLog = Logger(subsystem: "lv.zzdats.KeychainWrapperPackage", category: "keychain")

final public class KeychainManager: Sendable {
    
    public static let shared = KeychainManager()

    private func hardenedForInsert(_ query: CFDictionary) -> CFDictionary {
        guard var attributes = query as? [String: Any] else {
            return query
        }
        
        let hasAccessControl = attributes[kSecAttrAccessControl as String] != nil
        let hasAccessibility = attributes[kSecAttrAccessible as String] != nil
        
        if !hasAccessControl && !hasAccessibility {
            attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
        
        if attributes[kSecAttrSynchronizable as String] == nil {
            attributes[kSecAttrSynchronizable as String] = false
        }
        
        return attributes as CFDictionary
    }
    
    private func log(_ status: OSStatus, operation: StaticString) {
        if status == errSecSuccess {
            keychainLog.debug("Keychain \(operation, privacy: .public) succeeded.")
        } else {
            keychainLog.error("Keychain \(operation, privacy: .public) failed with OSStatus \(status, privacy: .public).")
        }
    }
    
    public func addItemToKeychain(query: CFDictionary, completion: @escaping (Bool) -> Void) {
        SecItemDelete(query)
        let status = SecItemAdd(hardenedForInsert(query), nil)
        log(status, operation: "add")
        completion(status == errSecSuccess)
    }
    
    
    public func addItemToKeychainAsync(query: CFDictionary) async throws -> Bool {
        SecItemDelete(query)
        let status = SecItemAdd(hardenedForInsert(query), nil)
        log(status, operation: "add")
        return(status == errSecSuccess)
    }
    
    public func updateKeychainItem(query: CFDictionary, updateField: CFDictionary, completion: @escaping (Bool) -> Void) {
        let status = SecItemUpdate(query, updateField)
        log(status, operation: "update")
        completion(status == errSecSuccess)
    }
    
    public func delete(query: CFDictionary, completion: @escaping (Bool) -> Void) {
        let status = SecItemDelete(query)
        
        completion(status == errSecSuccess)
    }
    
    public func retrieve(query: CFDictionary, completion: @escaping (Data?) -> Void) {
        var item: AnyObject?
        _ = SecItemCopyMatching(query, &item)
                
        guard let passcodeDict = item as? NSDictionary else {
            completion(item as? Data)
            return
        }
        
        guard let passcode = passcodeDict[kSecValueData] as? Data else {
            completion(nil)
            return
        }
        
        completion(passcode)
    }
    
    public func throwRetrieve(query: CFDictionary) throws -> Data? {
        var item: AnyObject?
        _ = SecItemCopyMatching(query, &item)
                
        guard let passcodeDict = item as? NSDictionary else {
            return item as? Data
        }
        
        guard let passcode = passcodeDict[kSecValueData] as? Data else {
            return nil
        }
        
        return passcode
    }
    
    public func convertToData(item: String) -> Data? {
        return item.data(using: .utf8)
    }
    
    public func convertToString(item: Data) -> String? {
        return String(data: item, encoding: .utf8)
    }
    
    public func convertToInt(item: Data) -> Int32? {
        return item.withUnsafeBytes( {(pointer: UnsafeRawBufferPointer) -> Int32 in
            return pointer.load(as: Int32.self)
        })
    }
    
    public func convertToData(item: Int) -> Data? {
        return withUnsafeBytes(of: item) { Data($0) }
    }
    
}
