//
//  NSManagedObjectContext+RecursiveSave.swift
//  CoredataOperation
//
//  Created by Nagib Azad on 21/11/18.
//  Copyright © 2018 Nagib Bin Azad. All rights reserved.
//

import CoreData

extension NSManagedObjectContext{
    func saveAsyncRecusively(withCompletionBlock completionBlock: @escaping SaveCompletionHandler) -> Void {
        
        perform {
            if self.hasChanges == true {
                do{
                    try self.save()
                    if let parent = self.parent {
                        parent.saveAsyncRecusively(withCompletionBlock: {(success, error) in
                            completionBlock(success,error)
                        })
                    }else {
                        completionBlock(true, nil)
                    }
                    
                }catch let saveError as NSError{
                    completionBlock(false, saveError)
                }
            }else {
                completionBlock(true, nil)
            }
        }
    }
    
    func saveSyncRecusively(withCompletionBlock completionBlock:SaveCompletionHandler) -> Void {
        
        performAndWait {
            if self.hasChanges == true {
                do{
                    try self.save()
                    if let parent = self.parent {
                        parent.saveSyncRecusively(withCompletionBlock: {(success: Bool, error: NSError?) in
                            completionBlock(success,error)
                        })
                    }else {
                        completionBlock(true, nil)
                    }
                    
                }catch let saveError as NSError{
                    completionBlock(false, saveError)
                }
            }else {
                completionBlock(true, nil)
            }
        }
    }
}
