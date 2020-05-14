//
//  SimulationView.swift
//  WWDC Testing
//
//  Created by Thijs van der Heijden on 13/05/2020.
//  Copyright © 2020 Thijs van der Heijden. All rights reserved.
//

import UIKit

// Individual state enum
public enum state {
    case susceptible
    case infectedSymptomatic
    case infectedAsymptomatic
    case recovered
}

public class SimulationView: UIView {
    
    // MARK: UIViews
    // Individual uiview
    var individualView: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }
    
    // Row stack view
    var rowStackView: UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }
    
    // Main vertical stack view
    var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: Variables and constants
    // Array keeping track of all the states of individuals
    public var individualStates: [state] = []
    // Array keeping track of all the individuals and how long they have been infected, IF they have been infected
    public var infectedTimePerIndividual: [Int] = []
    
    // Initial number of infected
    public var I: Int = 3
    
    public convenience init(I: Int) {
        self.init()
        self.I = I
        setupView()
    }
    
    public override func layoutSubviews() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStackView.heightAnchor.constraint(equalToConstant: bounds.height),
            mainStackView.widthAnchor.constraint(equalToConstant: bounds.width)
        ])
    }
    
    public func setupView() {
        // Add main stack view to view
        addSubview(mainStackView)
        
        for y in 0...14 {
            let stackView = rowStackView
            mainStackView.addArrangedSubview(stackView)
            for x in 0...14 {
                let v = individualView
                stackView.addArrangedSubview(v)
                
                // Insert individual into state list
                individualStates.insert(.susceptible, at: y * 14 + x)
                
                // Set individual infected time to 0 days
                infectedTimePerIndividual.insert(0, at: y * 14 + x)
            }
        }
        
        // Choose I random people to be infected at the beginning
        for _ in 0...Int(I) - 1 {
            let index = Int.random(in: 1...individualStates.count)
            individualStates[index - 1] = .infectedAsymptomatic
            
            individualViewAtIndex(index: index)?.backgroundColor = .red
        }
    }
    
    public func individualViewAtIndex(index: Int) -> UIView? {
        let row: Int = Int(ceil(Float(index) / 15) - 1)
        if let subStackView = mainStackView.arrangedSubviews[row] as? UIStackView {
            return subStackView.arrangedSubviews[(index) % 15]
        }
        return nil
    }
    
    public func clear() {
        individualStates.removeAll()
        infectedTimePerIndividual.removeAll()
        
        // Remove all subviews
        mainStackView.arrangedSubviews.forEach({ subview in
            subview.removeFromSuperview()
        })
        mainStackView.removeFromSuperview()
        
        setupView()
    }
}
