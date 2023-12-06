//
//  NametagServerConnection.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/20/23.
//

import Foundation
import Logging

import Keychain
import Nametag
import TransmissionTypes

public class NametagServerConnection: AuthenticatedConnection
{
    public var publicKey: PublicKey
    {
        return self.protectedPublicKey
    }

    public var network: TransmissionTypes.Connection
    {
        return self.protectedConnection
    }

    let protectedConnection: TransmissionTypes.Connection
    let protectedPublicKey: PublicKey

    required public init(_ base: TransmissionTypes.Connection, _ logger: Logger) throws
    {
        self.protectedConnection = base
        self.protectedPublicKey = try Nametag.checkLive(connection: base)
    }
}
