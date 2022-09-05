//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Reek i on 05.09.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data Stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    //MARK: - Public Methods
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
            return []
        }
    }
    
    // Save data
    func save(_ taskName: String, completion: (Task) -> Void) {
        /*
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
         */
        let task = Task(context: viewContext)
        task.name = taskName
        
        completion(task)
        saveContext()
    }
    
    func edit(_ task: Task, newName: String) {
        task.name = newName
        saveContext()
    }
    
    func delete(_ task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    //MARK: - Core Data saving support
    func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
