//
//  AuthenticatedConnection.swift
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
import TransmissionAsync

public protocol AsyncAuthenticatedConnection
{
    var publicKey: PublicKey { get }
    var network: AsyncConnection { get }

    init(_ base: any AsyncConnection, _ logger: Logger) async throws
}
