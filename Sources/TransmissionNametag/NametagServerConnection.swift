//
//  NametagServerConnection.swift
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

import Keychain
import Nametag
import TransmissionTypes

public class NametagServerConnection: AuthenticatedConnection
{
    public var publicKey: PublicKey
    {
        return self.protectedPublicKey
    }

    let protectedPublicKey: PublicKey

    required public init(_ base: TransmissionTypes.Connection, _ logger: Logger) throws
    {
        self.protectedPublicKey = try Nametag.checkLive(connection: base)
    }
}
