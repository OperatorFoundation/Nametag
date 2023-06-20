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
import TransmissionTypes

public protocol AuthenticatedConnection
{
    var publicKey: PublicKey { get }

    init(_ base: any TransmissionTypes.Connection, _ logger: Logger) throws
}
