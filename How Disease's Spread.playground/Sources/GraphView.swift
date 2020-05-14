//
//  GraphView.swift
//  WWDC Testing
//
//  Created by Thijs van der Heijden on 12/05/2020.
//  Copyright © 2020 Thijs van der Heijden. All rights reserved.
//

import UIKit

public class GraphView: UIView {
    
    public enum state {
        case none
        case drawing
    }
    
    // MARK: Contained UIViews and layers
    private let susceptibleDataLayer: CALayer = CALayer()
    private let susceptibleGradientLayer: CAGradientLayer = CAGradientLayer()
    
    private let infectedDataLayer: CALayer = CALayer()
    private let infectedGradientLayer: CAGradientLayer = CAGradientLayer()
    
    private let recoveredDataLayer: CALayer = CALayer()
    private let recoveredGradientLayer: CAGradientLayer = CAGradientLayer()
    
    private let mainLayer: CALayer = CALayer()
    
    // MARK: Variables and constants
    private var xSpacePerDatapoint: CGFloat!
    private var ySpacePerDatapoint: CGFloat = 10
    
    public var N: Int? {
        didSet {
            ySpacePerDatapoint = bounds.height / CGFloat(N!)
        }
    }
    
    public var infectedDataPoints: [Int]? {
        didSet {
            if infectedDataPoints != nil {
                drawInfectedDatalayer(data: infectedDataPoints!)
                if infectedDataPoints!.count > 1 {
                    infectedGradientLayer.frame = bounds
                }
            }
        }
    }
    
    public var recoveredDataPoints: [Int]? {
        didSet {
            if recoveredDataPoints != nil {
                drawRecoveredDataLayer(data: recoveredDataPoints!)
                if recoveredDataPoints!.count > 1 {
                    recoveredGradientLayer.frame = bounds
                }
            }
        }
    }
    
    public var t: Int? {
        didSet {
            xSpacePerDatapoint = bounds.width / CGFloat(t!)
        }
    }
    
    private var gradientsAdded: Bool = false
    
    // Is it okay to update this view?
    public var viewState: state = .none
    
    // MARK: Initialisation
    public convenience init(t: Int) {
        self.init()
        
        self.t = t
        
        addGradients()
    }
    
    public func addGradients() {
        if !gradientsAdded {
            
            var systemColor: CGColor!
            switch traitCollection.userInterfaceStyle {
            case .dark:
                systemColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00).cgColor
            case .light:
                systemColor = UIColor.white.cgColor
            default:
                systemColor = UIColor.white.cgColor
            }
            
            infectedGradientLayer.colors = [UIColor.red.cgColor, UIColor.red.cgColor, systemColor!]
            layer.addSublayer(infectedDataLayer)
            layer.addSublayer(infectedGradientLayer)
            
            recoveredGradientLayer.colors = [systemColor!, UIColor.systemBlue.cgColor, UIColor.systemBlue.cgColor]
            layer.addSublayer(recoveredDataLayer)
            layer.addSublayer(recoveredGradientLayer)
            
            gradientsAdded = true
        }
    }
    
    public override func layoutSubviews() {
        xSpacePerDatapoint = bounds.width / CGFloat(t!)
    }
    
    // MARK: Draw infected line
    func drawInfectedDatalayer(data: [Int]) {
        
        viewState = .drawing
        
        if infectedDataLayer.sublayers?.count != 0 {
            infectedDataLayer.sublayers?.removeAll()
        }
        
        var dataPoints: [CGPoint] = []
        for i in 0...data.count - 1 {
            dataPoints.append(CGPoint(x: CGFloat(i) * xSpacePerDatapoint, y: bounds.maxY - CGFloat(data[i]) * ySpacePerDatapoint))
        }
                
        guard dataPoints.count > 1 else {
            return
        }

        if let path = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.red.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            
            // Add points to path to make it a fillable shape
            path.addLine(to: CGPoint(x: dataPoints.last!.x, y: bounds.maxY))
            path.addLine(to: CGPoint(x: 0, y: bounds.maxY))
            path.addLine(to: CGPoint(x: 0, y: dataPoints.first!.y))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
            
            infectedGradientLayer.mask = maskLayer
            
            infectedDataLayer.addSublayer(lineLayer)
            
            viewState = .none
        }
    }
    
    // MARK: Draw recovered line
    func drawRecoveredDataLayer(data: [Int]) {
        
        viewState = .drawing
        
        if recoveredDataLayer.sublayers?.count != 0 {
            recoveredDataLayer.sublayers?.removeAll()
        }
        
        var dataPoints: [CGPoint] = []
        for i in 0...data.count - 1 {
            dataPoints.append(CGPoint(x: CGFloat(i) * xSpacePerDatapoint, y: CGFloat(data[i]) * ySpacePerDatapoint))
        }
        
        guard dataPoints.count > 1 else {
            return
        }

        if let path = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.systemBlue.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            
            // Add points to path to make it a fillable shape
            path.addLine(to: CGPoint(x: dataPoints.last!.x, y: bounds.minY))
            path.addLine(to: CGPoint(x: 0, y: bounds.minY))
            path.addLine(to: CGPoint(x: 0, y: dataPoints.first!.y))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
                
            recoveredGradientLayer.mask = maskLayer
            
            recoveredDataLayer.addSublayer(lineLayer)
            
            viewState = .none
        }
    }
    
    // Clear the layers
    public func clear() {
        infectedDataLayer.sublayers?.removeAll()
        recoveredDataLayer.sublayers?.removeAll()
        
        infectedGradientLayer.removeFromSuperlayer()
        recoveredGradientLayer.removeFromSuperlayer()
        
        gradientsAdded = false
    }
    
}

// MARK: Curving algorithm
struct CurvedSegment {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
}

class CurveAlgorithm {
    static let shared = CurveAlgorithm()
    
    private func controlPointsFrom(points: [CGPoint]) -> [CurvedSegment] {
        var result: [CurvedSegment] = []
        
        let delta: CGFloat = 0.3 // The value that help to choose temporary control points.
        
        // Calculate temporary control points, these control points make Bezier segments look straight and not curving at all
        for i in 1..<points.count {
            let A = points[i-1]
            let B = points[i]
            let controlPoint1 = CGPoint(x: A.x + delta*(B.x-A.x), y: A.y + delta*(B.y - A.y))
            let controlPoint2 = CGPoint(x: B.x - delta*(B.x-A.x), y: B.y - delta*(B.y - A.y))
            let curvedSegment = CurvedSegment(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            result.append(curvedSegment)
        }
        
        // Calculate good control points
        for i in 1..<points.count-1 {
            /// A temporary control point
            let M = result[i-1].controlPoint2
            
            /// A temporary control point
            let N = result[i].controlPoint1
            
            /// central point
            let A = points[i]
            
            /// Reflection of M over the point A
            let MM = CGPoint(x: 2 * A.x - M.x, y: 2 * A.y - M.y)
            
            /// Reflection of N over the point A
            let NN = CGPoint(x: 2 * A.x - N.x, y: 2 * A.y - N.y)
            
            result[i].controlPoint1 = CGPoint(x: (MM.x + N.x)/2, y: (MM.y + N.y)/2)
            result[i-1].controlPoint2 = CGPoint(x: (NN.x + M.x)/2, y: (NN.y + M.y)/2)
        }
        
        return result
    }
    
    /**
     Create a curved bezier path that connects all points in the dataset
     */
    func createCurvedPath(_ dataPoints: [CGPoint]) -> UIBezierPath? {
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        var curveSegments: [CurvedSegment] = []
        curveSegments = controlPointsFrom(points: dataPoints)
        
        for i in 1..<dataPoints.count {
            path.addCurve(to: dataPoints[i], controlPoint1: curveSegments[i-1].controlPoint1, controlPoint2: curveSegments[i-1].controlPoint2)
        }
        return path
    }
}
