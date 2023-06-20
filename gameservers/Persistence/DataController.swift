import CoreData

class DataController: ObservableObject {
    struct DataControllerConstants {
        static let containerName = "gameservers"
        static let devPath = "/dev/null"
    }
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: DataControllerConstants.containerName)
        
        if (inMemory) {
            container.persistentStoreDescriptions.first?.url = URL(filePath: DataControllerConstants.devPath)
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store \(error.localizedDescription)")
            }
            
            
        }
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    func deleteAll() {
        let statsRequest: NSFetchRequest<NSFetchRequestResult> = MinecraftStats.fetchRequest()
        delete(statsRequest)
        
        let serversRequest: NSFetchRequest<NSFetchRequestResult> = Server.fetchRequest()
        delete(serversRequest)
        
        save()
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
}

// MARK: Preview
extension DataController {
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        
        return dataController
    }()
}

// MARK: Testing
extension DataController {
    func createSampleData() {
        let viewContext = container.viewContext
        
        for i in 1...10 {
            let server = Server(context: viewContext)
            server.created = .now
            server.favorite = Bool.random()
            server.ip = "127.0.0.1"
            server.modified = .now
            server.serverType = Int16.random(in: 0...1)
            server.title = "My server - \(i)"
        }
        
        try? viewContext.save()
    }
}
