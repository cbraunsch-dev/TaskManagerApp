//
//  Lenses.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 17.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//
//  The following is based on the talk by Brandon Williams on Lenses: https://www.youtube.com/watch?v=ofjehH9f-CU
//

import Foundation

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}

func compose<A, B, C>(_ lhs: Lens<A, B>, _ rhs: Lens<B, C>) -> Lens<A, C> {
    return Lens<A, C>(
        get: { a in rhs.get(lhs.get(a)) }, //(A) -> C
        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) } //(C, A) -> A
    )
}

func * <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return compose(lhs, rhs)
}

infix operator *~ : MultiplicationPrecedence
func *~ <A, B> (lhs: Lens<A, B>, rhs: B) -> (A) -> A {
    return { a in lhs.set(rhs, a) }
}

precedencegroup PipePrecedence {
    associativity: left
    lowerThan: MultiplicationPrecedence
}
infix operator |> : PipePrecedence

func |> <A, B> (x: A, f: (A) -> B) -> B {
    return f(x)
}

func |> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

