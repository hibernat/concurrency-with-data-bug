//
//  MainFile.swift
//  ConcurrencyData
//
//  Created by Michael Bernat on 12.03.2024.
//

import Foundation
import OSLog

@main
struct MainFile {
    
    static let logger = Logger()
    static let fileService = FileService()
    
    static func main() async {
        do {
            logger.info("Started Swift concurrency")
            try await run(maxTasksInGroup: 16)
            logger.info("Finished Swift concurrency")
        } catch {
            logger.error("Error: Swift concurrency \(error)")
        }
        
        /*
        logger.info("Started DispatchQueue")
        DispatchQueue.concurrentPerform(iterations: 1_000_000) { i in
            do {
                let url = URL(filePath: "/Users/mbernat/file.lzfse")
                let data = try! Data(contentsOf: url)
//                let _ = try (data as NSData).decompressed(using: .lzfse)
                let _ = try (data as NSData).compressed(using: .lzfse)
                logger.debug("Finished iteration # \(i)")
            } catch {
                logger.error("Error DispatchQueue: \(error)")
            }
        }
        logger.info("Finished DispatchQueue")
         */
    }
    
    static func run(maxTasksInGroup: Int) async throws {
        await withTaskGroup(of: Result<Void, Error>.self) { group in
            var tasksInGroup = 0
            for i in 0 ..< 1_000_000 {
                let operation: @Sendable () async -> Result<Void, Error> = { @Sendable in
                    async let result = Task {
                        let url = URL(filePath: "path-to/file.lzfse")
                        let data = try! await fileService.contentsOf(url: url)
                        let _ = try (data as NSData).decompressed(using: .lzfse)
//                        let _ = try (data as NSData).compressed(using: .lzfse)
                    }.result
                    _ = await result
                    logger.debug("Finished task # \(i)")
                    return .success(())
                }
                if tasksInGroup < maxTasksInGroup {
                    // there are still not enough concurrent tasks in the group
                    group.addTask(operation: operation)
                    tasksInGroup += 1
                } else {
                    // there are enough concurrent tasks in the group, must wait for finished task to add new task to the group
                    _ = await group.next()
                    group.addTask(operation: operation)
                }
            }
            // not adding new tasks to the group any more, just waiting for finishing the group tasks
            for await _ in group {
                
            }
            // all tasks are finished
        }
    }
    
}

actor FileService {
    
    init() { }
    
    func contentsOf(url: URL) throws -> Data {
        let data = try Data(contentsOf: url)
        return data
    }
}
