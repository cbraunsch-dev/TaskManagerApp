//
//  TaskDataAccessor.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol TaskDataAccessor {
    func readAll() -> Observable<[TaskEntity]>
    
    func getTaskById(with id: String) -> Observable<TaskEntity?>
    
    func save(task: TaskEntity) -> Observable<Void>
    
    func removeTask(with id: String) -> Observable<Void>
}

class RealmTaskDataAccessor: DataAccessor, TaskDataAccessor {
    private let bag = DisposeBag()
    
    func readAll() -> Observable<[TaskEntity]> {
        return Observable<[TaskEntity]>.create { observer in
            do {
                let realm = try self.obtainRealm()
                let data = realm.objects(TaskEntity.self)
                observer.onNext(Array(data))
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func getTaskById(with id: String) -> Observable<TaskEntity?> {
        return Observable<TaskEntity?>.create { observer in
            do {
                let realm = try self.obtainRealm()
                let predicate = NSPredicate(format: "taskID = %@", id)
                let tasks = realm.objects(TaskEntity.self).filter(predicate)
                observer.onNext(tasks.first)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func save(task: TaskEntity) -> Observable<Void> {
        return Observable<Void>.create { observer in
            do {
                let realm = try self.obtainRealm()
                try realm.write(transaction: {
                    realm.add(task, update: true)
                }, completion:  {
                    observer.onNext(())
                })
            } catch DataAccessorError.failedToAccessDatabase {
                observer.onError(DataAccessorError.failedToAccessDatabase)
            } catch {
                //The only recoverable errors in Realm are when we've run out of disk space
                observer.onError(DataAccessorError.outOfDiskSpace)
            }
            return Disposables.create()
        }
    }
    
    func removeTask(with id: String) -> Observable<Void> {
        return Observable<Void>.create { observer in
            do {
                let realm = try self.obtainRealm()
                self.getTaskById(with: id)
                    .subscribe(onNext: { task in
                        guard let foundTask = task else {
                            observer.onError(DataAccessorError.itemToDeleteNotFound)
                            return
                        }
                        try! realm.write(transaction: {
                            realm.delete(foundTask)
                        }, completion: {
                            observer.onNext(())
                        })
                    }, onError: { observer.onError($0) }).disposed(by: self.bag)
            } catch DataAccessorError.failedToAccessDatabase {
                observer.onError(DataAccessorError.failedToAccessDatabase)
            } catch {
                observer.onError(DataAccessorError.outOfDiskSpace)
            }
            return Disposables.create()
        }
    }
}
