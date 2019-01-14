//
//  AssertionDataExtractionCapable.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxTest
import RxSwift

protocol AssertionDataExtractionCapable {
    
}

extension AssertionDataExtractionCapable {
    func extractValue<E>(from observer: TestableObserver<E>) -> E? {
        let eventsExceptStop = observer.events.filter { !$0.value.isStopEvent }
        guard let first = eventsExceptStop.first else {
            return nil
        }
        guard let element = first.value.element else {
            return nil
        }
        return element
    }
    
    func extractLastValue<E>(from observer: TestableObserver<E>) -> E? {
        let eventsExceptStop = observer.events.filter { !$0.value.isStopEvent }
        guard let last = eventsExceptStop.last else {
            return nil
        }
        guard let element = last.value.element else {
            return nil
        }
        return element
    }
    
    func extractValues<E>(from observer: TestableObserver<E>) -> [E?] {
        let eventsExceptStop = observer.events.filter { !$0.value.isStopEvent }
        let values = eventsExceptStop.map { $0.value.element }
        return values
    }
    
    func extractError<E>(from observer: TestableObserver<E>) -> Error? {
        let errorEvents = observer.events.filter { $0.value.error != nil }
        guard let firstErrorEvent = errorEvents.first else {
            return nil
        }
        guard let error = firstErrorEvent.value.error else {
            return nil
        }
        return error
    }
    
    func completedEvent<E>(from observer: TestableObserver<E>) -> Recorded<Event<E>>? {
        let completedEvent = observer.events.first { event in
            event.value.isCompleted
        }
        return completedEvent
    }
}

enum AssertionError: Error {
    case illegalState
}
