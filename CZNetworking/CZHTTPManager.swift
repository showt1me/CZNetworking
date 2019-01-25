//
//  CZHTTPManager.swift
//  CZNetworking
//
//  Created by Cheng Zhang on 1/9/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

/**
 Asynchronous HTTP requests manager based on NSOperationQueue
 */
open class CZHTTPManager: NSObject {
    public static let shared = CZHTTPManager()
    private let queue: OperationQueue
    private let httpCache: CZHTTPCache
    public enum Constant {
        public static let maxConcurrentOperationCount = 5
    }
    
    public init(maxConcurrentOperationCount: Int = Constant.maxConcurrentOperationCount) {
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        httpCache = CZHTTPCache()
        super.init()
    }
    
    public func GET(_ urlStr: String,
                    headers: HTTPRequestWorker.Headers? = nil,
                    params: HTTPRequestWorker.Params? = nil,
                    success: HTTPRequestWorker.Success? = nil,
                    failure: HTTPRequestWorker.Failure? = nil,
                    cached: HTTPRequestWorker.Cached? = nil,
                    progress: HTTPRequestWorker.Progress? = nil) {
        startOperation(
            .GET,
            urlStr: urlStr,
            headers: headers,
            params: params,
            success: success,
            failure: failure,
            cached: cached,
            progress: progress)
    }
    
    public func POST(_ urlStr: String,
                     contentType: HTTPRequestWorker.ContentType = .formUrlencoded,
                     headers: HTTPRequestWorker.Headers? = nil,
                     params: HTTPRequestWorker.Params? = nil,
                     data: Data? = nil,
                     success: HTTPRequestWorker.Success? = nil,
                     failure: HTTPRequestWorker.Failure? = nil,
                     progress: HTTPRequestWorker.Progress? = nil) {
        startOperation(
            .POST(contentType, data),
            urlStr: urlStr,
            headers: headers,
            params: params,
            success: success,
            failure: failure,
            progress: progress)
    }
    
    public func DELETE(_ urlStr: String,
                       headers: HTTPRequestWorker.Headers? = nil,
                       params: HTTPRequestWorker.Params? = nil,
                       success: HTTPRequestWorker.Success? = nil,
                       failure: HTTPRequestWorker.Failure? = nil) {
        startOperation(
            .DELETE,
            urlStr: urlStr,
            headers: headers,
            params: params,
            success: success,
            failure: failure)
    }
    
    public func UPLOAD(_ urlStr: String,
                       headers: HTTPRequestWorker.Headers? = nil,
                       params: HTTPRequestWorker.Params? = nil,
                       fileName: String? = nil,
                       data: Data,
                       success: HTTPRequestWorker.Success? = nil,
                       failure: HTTPRequestWorker.Failure? = nil,
                       progress: HTTPRequestWorker.Progress? = nil) {
        let fileName = fileName ?? UUID.generate()
        startOperation(
            .UPLOAD(fileName, data),
            urlStr: urlStr,
            headers: headers,
            params: params,
            success: success,
            failure: failure,
            progress: progress)
    }
}

private extension CZHTTPManager {
    
    func startOperation(_ requestType: HTTPRequestWorker.RequestType,
                        urlStr: String,
                        headers: HTTPRequestWorker.Headers? = nil,
                        params: HTTPRequestWorker.Params? = nil,
                        success: HTTPRequestWorker.Success? = nil,
                        failure: HTTPRequestWorker.Failure? = nil,
                        cached: HTTPRequestWorker.Cached? = nil,
                        progress: HTTPRequestWorker.Progress? = nil) {
        let op = HTTPRequestWorker(
            requestType,
            url: URL(string: urlStr)!,
            params: params,
            headers: headers,
            httpCache: self.httpCache,
            success: success,
            failure: failure,
            cached: cached,
            progress: progress)
        queue.addOperation(op)
    }
}
