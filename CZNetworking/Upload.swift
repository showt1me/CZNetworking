//
//  Upload.swift
//  CZNetworking
//
//  Created by Cheng Zhang on 1/24/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import CZUtils
import MobileCoreServices

public class Upload {
    static let kFilePath = "file"
    
    // MARK: - Upload File
    
    public static func createRequest(_ url: URL,
                              params: HTTPRequestWorker.Params = HTTPRequestWorker.Params(),
                              filePath: String) throws -> URLRequest {
        return try createRequest(url, params: params, filePaths: [filePath])
    }
    
    // MARK: - Upload Data
    
    public static func createRequest(_ url: URL,
                              params: HTTPRequestWorker.Params = HTTPRequestWorker.Params(),
                              fileName: String,
                              data: Data) throws -> URLRequest {
        let boundary = generateBoundaryString()
        var request = createBaseRequest(url, boundary: boundary)
        let file = FileInfo(name: fileName, data: data)
        request.httpBody = try createBody(
            with: params,
            files: [file],
            boundary: boundary)
        return request
    }
}

private extension Upload {
    struct FileInfo {
        let name: String
        let data: Data
    }
    
    static func createBaseRequest(_ url: URL, boundary: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    static func createRequest(_ url: URL,
                       params: HTTPRequestWorker.Params = HTTPRequestWorker.Params(),
                       filePaths: [String]) throws -> URLRequest {
        let boundary = generateBoundaryString()
        var request = createBaseRequest(url, boundary: boundary)
        
        let files: [FileInfo] = try filePaths.map { filePath in
            let url = URL(fileURLWithPath: filePath)
            let name = url.lastPathComponent
            let data = try Data(contentsOf: url)
            return FileInfo(name: name, data: data)
        }
        
        request.httpBody = try createBody(
            with: params,
            files: files,
            boundary: boundary)
        return request
    }
    
    static func createBody(with params: HTTPRequestWorker.Params?,
                    filePathKey: String = kFilePath,
                    files: [FileInfo],
                    boundary: String) throws -> Data {
        var body = Data()
        if let params = params {
            for (key, value) in params {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for file in files {
            let mimetype = mimeType(for: file.name)
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(file.name)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(file.data)
            body.append("\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    static func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    static func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
