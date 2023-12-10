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
import TransmissionAsync

public class AsyncNametagServerConnection: AsyncAuthenticatedConnection
{
    public var publicKey: PublicKey
    {
        return self.protectedPublicKey
    }

    public var network: AsyncConnection
    {
        return self.protectedConnection
    }

    let protectedConnection: AsyncConnection
    let protectedPublicKey: PublicKey

    required public init(_ base: AsyncConnection, _ logger: Logger) async throws
    {
        self.protectedConnection = base
        self.protectedPublicKey = try await Nametag.checkLive(connection: base)
    }
}
