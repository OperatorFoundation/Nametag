//
//  File.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/20/23.
//

import Foundation
#if os(macOS)
import os.log
#else
import Logging
#endif

import KeychainTypes
import Nametag
import TransmissionTypes

public protocol AuthenticatingConnection
{
    var publicKey: PublicKey { get }
    var network: TransmissionTypes.Connection { get }

    init(_ base: any TransmissionTypes.Connection, _ keychain: KeychainProtocol, _ logger: Logger) throws
}
