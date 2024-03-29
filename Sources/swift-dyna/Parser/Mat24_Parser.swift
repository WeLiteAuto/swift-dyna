//
//  File.swift
//
//
//  Created by Aaron Ge on 2024/2/4.
//

import Collections
import Foundation

public class Mat24_Parser : MaterialParser {

    public func parser(_ lines: [String], curves: OrderedDictionary<Int, Curve2D>,
                tables: OrderedDictionary<Int, CurveTable>)->DYNAMaterial? 
    {

        var pieceLinerPlasticMaterial: Mat_024? = nil
        guard !lines.isEmpty else{return pieceLinerPlasticMaterial}
        var lines = lines
        var title: String?
        if splitByWhitespace(lines[0]).count == 1 {
            title = lines.removeFirst()
        }
        let line0 = splitDataEvery10Characters(lines[0])
        guard let id = Int(line0[0].trimmingCharacters(in: .whitespaces)),
              let density = Double(line0[1].trimmingCharacters(in: .whitespaces)),
              let youngs = Double(line0[2].trimmingCharacters(in: .whitespaces)),
              let poison = Double(line0[3].trimmingCharacters(in: .whitespaces))
        else {return pieceLinerPlasticMaterial}
        
        let line1 = splitDataEvery10Characters(lines[1])
        guard let lcssId = Int(line1[2].trimmingCharacters(in: .whitespaces))
        else {return pieceLinerPlasticMaterial}
        
        
        var hardenCurves : MaterialPropertyValue = .directValue(0)
        var lowestCurve: Curve2D
        var yield : Double

        if tables.keys.contains(lcssId){
            hardenCurves = .curveTableID(lcssId, tables[lcssId]!)
            guard let lowestKey = tables[lcssId]!.keys.min() 
            else {return pieceLinerPlasticMaterial}
            lowestCurve = tables[lcssId]![lowestKey]!
        }
        
        else {
            guard let curve = curves[lcssId]
            else{return pieceLinerPlasticMaterial}
            hardenCurves = .curveTableID(lcssId, .init([0.001: curve]))
            lowestCurve = curve
        }
        
        
        
        
        yield = lowestCurve[0].y
        let dev = lowestCurve.derivative()
        guard let intersetion = lowestCurve.firstIntersection(with: dev)
        else {return pieceLinerPlasticMaterial}
        let expX = exp(intersetion.x)
        
        pieceLinerPlasticMaterial = Mat_024(id: id, density: density)
        pieceLinerPlasticMaterial?.title = title
        pieceLinerPlasticMaterial!.basic["1.Youngs"] = youngs
        pieceLinerPlasticMaterial!.basic["2.Poison"] = poison
        pieceLinerPlasticMaterial!.basic["3.Thickness"] = 0
        pieceLinerPlasticMaterial!.basic["4.Rp0.2"] = yield
        pieceLinerPlasticMaterial!.basic["5.Rm"] = intersetion.y / expX
        pieceLinerPlasticMaterial!.basic["6.At"] = 0.0
        
        pieceLinerPlasticMaterial!.hardenCurves = hardenCurves
        //
        
        return pieceLinerPlasticMaterial
        
    }
    
    static let shared = Mat24_Parser()
    
    
}
