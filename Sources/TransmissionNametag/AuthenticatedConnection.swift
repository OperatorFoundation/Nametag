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
import TransmissionTypes

public protocol AuthenticatedConnection
{
    var publicKey: PublicKey { get }
    var network: TransmissionTypes.Connection { get }

    init(_ base: any TransmissionTypes.Connection, _ logger: Logger) throws
}
