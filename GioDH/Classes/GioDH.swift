//
//  GioDH.swift
//  GioDH
//
//  Created by Sercan on 31/08/16.
//  Copyright © 2016 Netas. All rights reserved.
//

import Foundation
import BigInt

public class GioDH{
    /*//////////////////////////////////////////////// */
    /*////////////////////TYPE ALIASes//////////////// */
    /*//////////////////////////////////////////////// */
    private static let dl = dlopen("/usr/lib/system/libcommonCrypto.dylib", RTLD_NOW)
    private typealias CCDHParameters = UnsafePointer<Void>
    private typealias CCDHRef = UnsafePointer<Void>
    
    private typealias CCDHParametersCreateFromDataT = @convention(c)(
        p: UnsafeMutablePointer<Void>,
        plen: size_t,
        g: UnsafeMutablePointer<Void>,
        gLen: size_t) -> CCDHParameters
    private static let CCDHParametersCreateFromData: CCDHParametersCreateFromDataT? = getFunc(dl, f: "CCDHParametersCreateFromData")
    
    private typealias kCCDHRFC3526Group5TM = UnsafePointer<CCDHParameters>
    private static let kCCDHRFC3526Group5M: kCCDHRFC3526Group5TM? =
        getFunc(dl, f: "kCCDHRFC3526Group5")
    private static let kCCDHRFC3526Group5 = kCCDHRFC3526Group5M?.memory
    
    private typealias CCDHCreateT = @convention(c) (
        dhParameter: CCDHParameters) -> CCDHRef
    private static let CCDHCreate: CCDHCreateT? = getFunc(dl, f: "CCDHCreate")
    
    private typealias CCDHGenerateKeyT = @convention(c) (
        ref: CCDHRef,
        output: UnsafeMutablePointer<Void>, outputLength: UnsafeMutablePointer<size_t>) -> CInt
    private static let CCDHGenerateKey: CCDHGenerateKeyT? = getFunc(dl, f: "CCDHGenerateKey")
    
    private typealias CCDHComputeKeyT = @convention(c) (
        sharedKey: UnsafeMutablePointer<Void>, sharedKeyLen: UnsafeMutablePointer<size_t>,
        peerPubKey: UnsafePointer<Void>, peerPubKeyLen: size_t,
        ref: CCDHRef) -> CInt
    private static let CCDHComputeKey: CCDHComputeKeyT? = getFunc(dl, f: "CCDHComputeKey")
    
    
    /*//////////////////////////////////////////////// */
    /*/////////////////////Variables////////////////// */
    /*//////////////////////////////////////////////// */
    public enum DHParam {
        case rfc3526Group5
    }

    private var ref: CCDHRef = nil
    private var _p,_g:BigInt?
    
    /**
     Constructor method
    */
    public init(){
        self.createRef()
    }
    
    /**
     Constructor
    */
    public init(p:BigInt,g:BigInt){
        self.setPG(p, g: g)
        self.createRef()
    }
    
    /**
     Constructor
     */
    public init(p:String,g:String){
        self.setPG(BigInt(p,radix: 10)!, g: BigInt(g,radix: 10)!)
        self.createRef()
    }
    
    /**
     Constructor
     */
    public init(p:String,g:String,radix:Int){
        self.setPG(BigInt(p,radix: radix)!, g: BigInt(g,radix: radix)!)
        self.createRef()
    }
    
    /**
     Set p and g values
     */
    public func setPG(p:BigInt,g:BigInt){
        self._p = p
        self._g = g
    }
    
    /**
     Creates CCDHRef
    */
    private func createRef(){
        //TODO error handling
        if(self._p == nil || self._g == nil){
            ref = GioDH.CCDHCreate!(dhParameter: GioDH.kCCDHRFC3526Group5!)
        }
        else{
            let tempParams: CCDHParameters = GioDH.CCDHParametersCreateFromData!(p: &self._p, plen: sizeofValue(self._p) ,g: &self._g, gLen: sizeofValue(self._g))
            ref = GioDH.CCDHCreate!(dhParameter:tempParams)
        }
    }
    
    /**
     Generate the public key for use in a Diffie-Hellman handshake according to ref obj
     */
    public func generateKey() throws -> NSData {
        var outputLength = 8192
        let output = NSMutableData(length: outputLength)!
        let status = GioDH.CCDHGenerateKey!(
            ref: self.ref,
            output: output.mutableBytes, outputLength: &outputLength)
        output.length = outputLength
       /* guard status != -1 else {
            throw NSERROR(.paramError)
        }*/
        return output
    }
    
    
    /**
     Compute the shared Diffie-Hellman key using the peer's public key.
     */
    public func computeKey(peerKey: NSData) throws -> NSData {
        var sharedKeyLength = 8192
        let sharedKey = NSMutableData(length: sharedKeyLength)!
        let status = GioDH.CCDHComputeKey!(
            sharedKey: sharedKey.mutableBytes, sharedKeyLen: &sharedKeyLength,
            peerPubKey: peerKey.bytes, peerPubKeyLen: peerKey.length,
            ref: ref)
        sharedKey.length = sharedKeyLength
        /*guard status == 0 else {
            throw CCError(.paramError)
        }*/
        return sharedKey
    }
}

/**
 Bridge between c lib
 */
private func getFunc<T>(from: UnsafeMutablePointer<Void>, f: String) -> T? {
    let sym = dlsym(from, f)
    guard sym != nil else {
        return nil
    }
    return unsafeBitCast(sym, T.self)
}
