//
//  AuthenticatedConnection.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/20/23.
//

import Foundation
import Logging

import KeychainTypes
import Nametag
import TransmissionAsync

public protocol AsyncAuthenticatedConnection
{
    var publicKey: PublicKey { get }
    var network: AsyncConnection { get }

    init(_ base: any AsyncConnection, _ logger: Logger) async throws
}
