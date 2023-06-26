//
//  TransmissionNametagClientConnection.swift
//
//
//  Created by Dr. Brandon Wiley on 10/4/22.
//

import Foundation
#if os(macOS)
import os.log
#else
import Logging
#endif

import Chord
import Datable
import KeychainTypes
import Nametag
import Net
import ShadowSwift
import Straw
import SwiftHexTools
import Transmission

// A connection to a server
public class NametagClientConnection: AuthenticatingConnection
{
    public let network: Transmission.Connection

    let logger: Logger
    let nametag: Nametag
    let straw = Straw()
    let lock = DispatchSemaphore(value: 1)

    var open = true

    public convenience init(config: ShadowConfig.ShadowClientConfig, keychain: KeychainProtocol, logger: Logger) throws
    {
        guard let nametag = Nametag(keychain: keychain) else
        {
            throw NametagClientConnectionError.nametagInitFailed
        }

        let parts = config.serverAddress.split(separator: ":")
        let hostPart = String(parts[0])
        let portPart = String(parts[1])
        let portInt = Int(string: portPart)

        guard let network = ShadowTransmissionClientConnection(host: hostPart, port: portInt, config: config, logger: logger) else
        {
            throw NametagClientConnectionError.connectionFailed
        }

        try self.init(network, nametag, logger)
    }

    public required init(_ base: TransmissionTypes.Connection, _ keychain: KeychainTypes.KeychainProtocol, _ logger: Logger) throws
    {
        guard let nametag = Nametag(keychain: keychain) else
        {
            throw NametagClientConnectionError.nametagInitFailed
        }

        self.network = base
        self.nametag = nametag
        self.logger = logger

        try self.nametag.proveLive(connection: self.network)
    }

    public required init(_ base: Transmission.Connection, _ nametag: Nametag, _ logger: Logger) throws
    {
        self.network = base
        self.nametag = nametag
        self.logger = logger

        try self.nametag.proveLive(connection: self.network)
    }
}

public enum NametagClientConnectionError: Error
{
    case readFailed
    case couldNotLoadDocument
    case keyEncodingFailed
    case nametagInitFailed
    case connectionFailed
    case serverSigningKeyMismatch
    case writeFailed
    case closed
    case badPort(String)
}
