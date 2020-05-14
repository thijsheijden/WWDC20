//
//  SimulationViewController.swift
//  BookCore
//
//  Created by Thijs van der Heijden on 12/05/2020.
//

import UIKit
import AudioToolbox
import PlaygroundSupport

public class SimulationViewController: UIViewController {
    
    // MARK: UIViews
    // Simulation view
    var simulationView: SimulationView = {
        let view = SimulationView(I: 3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Graph view
    var graphView: GraphView = {
        let view = GraphView(t: 100)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var graphViewWidthConstraint: NSLayoutConstraint?
    var graphViewHeightConstraint: NSLayoutConstraint?
    
    // Bottom stack view
    var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()
    var bottomStackViewWidthAnchor: NSLayoutConstraint?
    var bottomStackViewHeightAnchor: NSLayoutConstraint?

    // Labels in the bottom stack view
    var label: UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .lightGray
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    var dayLabel: UILabel!
    var maxInfectedLabel: UILabel!
    
    var fadeView: UIView?
    var simulationDoneView: SimulationDoneView?
    var simulationDoneViewLeadingAnchor: NSLayoutConstraint?
    var simulationDoneViewCenterAnchor: NSLayoutConstraint?
    
    // MARK: Variables and constants
    // Population size
    let N: Int = 225
    
    // Maximum number of timesteps (days)
    public var t: Int = 100
    public var _t: Int!
    
    // Probability of disease jumping on contact
    public var rho: CGFloat = 0.01
    // Number of daily contacts per individual (average is 24)
    public var alpha: Int = 24
    // Average number of days until recovery (during these days the person can still spread the disease)
    var gamma: CGFloat = 1/20
    
    // Number of susceptible people at t=0
    var S: Int!
    // Susceptible over time
    var sList: [Int] = []
    // Number of infected people at t=0
    public var I: Int = 3
    public var _I: Int = 3
    // Infected over time
    var iList: [Int] = []
    // Number of recovered people at t=0
    var R: Int = 0
    // Recovered over time
    var rList: [Int] = []
    
    // Maximum number of concurrent sick people
    var maxI: Int = 0
    
    // Timer used to progress trough the simulation
    var timer: Timer?
    
    // The sound ID's
    var infectedSound: SystemSoundID!
    var recoveredSound: SystemSoundID!

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        S = N - I
        
        _t = t
        
        setupView()
//        setupSounds()
    }
    
    public override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate([
            simulationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            simulationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            simulationView.widthAnchor.constraint(equalToConstant: view.bounds.height / 2),
            simulationView.heightAnchor.constraint(equalToConstant: view.bounds.height / 2)
        ])
        
        graphViewHeightConstraint = graphView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
        graphViewWidthConstraint = graphView.widthAnchor.constraint(equalTo: simulationView.widthAnchor)
        NSLayoutConstraint.activate([
            graphView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            graphView.topAnchor.constraint(equalTo: simulationView.bottomAnchor, constant: 16),
            graphViewHeightConstraint!,
            graphViewWidthConstraint!
        ])
        
        bottomStackViewWidthAnchor = bottomStackView.widthAnchor.constraint(equalTo: simulationView.widthAnchor)
        bottomStackViewHeightAnchor = bottomStackView.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            bottomStackViewWidthAnchor!,
            bottomStackViewHeightAnchor!,
            bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // Add all the individual views to the stack views
    func setupView() {
        
        view.addSubview(simulationView)
        view.addSubview(graphView)
        graphView.addGradients()
        graphView.t = t
        
        // Add the bottom stackview housing the start button and some information labels
        view.addSubview(bottomStackView)
        
        dayLabel = label
        dayLabel.text = "Day: 0"
        bottomStackView.addArrangedSubview(dayLabel)

        maxInfectedLabel = label
        maxInfectedLabel.text = "Peak: 0"
        bottomStackView.addArrangedSubview(maxInfectedLabel)
    }
    
    // MARK: Add sounds
    func setupSounds() {
        AudioServicesCreateSystemSoundID(Bundle.main.url(forResource: "infected", withExtension: "wav")! as CFURL, &infectedSound)
        AudioServicesCreateSystemSoundID(Bundle.main.url(forResource: "recovered", withExtension: "wav")! as CFURL, &recoveredSound)
    }
    
    // MARK: Start the simulation
    public func startSimulation() {
        if self.timer == nil {
            // Initial number of susceptible people
            sList.append(S)
            graphView.N = N
            
            iList.append(I)
            graphView.infectedDataPoints = iList
            
            rList.append(R)
            graphView.recoveredDataPoints = rList
            
            let timeInterval: Double = 15 / Double(t)
            self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
                if self.t > 0 {
                    self.progress()
                } else {
                    self.timer!.invalidate()
                    self.timer = nil
                    
                    self.addSimulationDoneView()
                }
            }
        }
    }
    
    // Add simulation done view
    func addSimulationDoneView() {
        if fadeView == nil {
            fadeView = UIView(frame: view.bounds)
            fadeView?.backgroundColor = .darkGray
            fadeView?.alpha = 0.0
            view.addSubview(fadeView!)
            
            simulationDoneView = SimulationDoneView(simulationMode: .socialDistancing, peak: maxI, immunity: nil, beforeTimeUp: t > 0)
            simulationDoneView!.translatesAutoresizingMaskIntoConstraints = false
            simulationDoneView!.delegate = self
            view.addSubview(simulationDoneView!)
            simulationDoneViewLeadingAnchor = simulationDoneView!.leadingAnchor.constraint(equalTo: view.trailingAnchor)
            simulationDoneViewCenterAnchor = simulationDoneView!.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            NSLayoutConstraint.activate([
                simulationDoneViewLeadingAnchor!,
                simulationDoneView!.widthAnchor.constraint(equalToConstant: view.bounds.width / 1.5),
                simulationDoneView!.heightAnchor.constraint(equalToConstant: view.bounds.height / 2),
                simulationDoneView!.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            view.layoutIfNeeded()
            
            simulationDoneViewLeadingAnchor!.isActive = false
            simulationDoneViewCenterAnchor!.isActive = true
            
            UIView.animate(withDuration: 1.0, animations: {
                self.view.layoutIfNeeded()
                self.fadeView?.alpha = 0.9
            })
        }
    }
    
    // MARK: Step in time
    func progress() {
        DispatchQueue.global(qos: .background).async {
            for i in 0...self.N - 1 {
                
                // Check if infected person recovers
                if self.simulationView.individualStates[i] == .infectedSymptomatic || self.simulationView.individualStates[i] == .infectedAsymptomatic {
                    // Check if this individual will recover in this timestep
                    if CGFloat.random(in: 0...1) <= self.gamma {
                        // Recovered!
                        self.simulationView.individualStates[i] = .recovered
                        self.R += 1
                        self.I -= 1
                        
                        DispatchQueue.main.async {
                            self.simulationView.individualViewAtIndex(index: i + 1)?.backgroundColor = .systemBlue
                        }
                    }
                }
                
                // If the person is infected with symptoms, check if they have been sick for less than 4 days
                if self.simulationView.individualStates[i] == .infectedSymptomatic {
                    
                    // If they have been sick for less than 4 days they can still infect people
                    if self.simulationView.infectedTimePerIndividual[i] <= 4 {
                        
                        // Loop over the number of contacts and check to see if any of them got infected
                        for _ in 1...self.alpha {
                            var index = Int.random(in: 1...self.simulationView.individualStates.count)
                            
                            // Make sure we are not contacting ourselves :)
                            while index == i + 1 {
                                index = Int.random(in: 1...self.simulationView.individualStates.count)
                            }
                            
                            // Check if this person is susceptible
                            if self.simulationView.individualStates[index - 1] == .susceptible {
                                // Check if the person at this index will be infected (with chance rho)
                                if CGFloat.random(in: 0...1) <= self.rho {
                                    self.I += 1
                                    self.S -= 1
                                    // Infected!
                                    // 80% chance to be infected symptomatic
                                    if CGFloat.random(in: 0...1) <= 0.2 {
                                        self.simulationView.individualStates[index - 1] = .infectedAsymptomatic
                                    } else {
                                        self.simulationView.individualStates[index - 1] = .infectedSymptomatic
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.simulationView.individualViewAtIndex(index: index)?.backgroundColor = .red
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    self.simulationView.infectedTimePerIndividual[i] += 1
                }
                
                // If the person is infected without symptoms they can keep infecting people until they are better, with probability 0.5 rho
                if self.simulationView.individualStates[i] == .infectedAsymptomatic {
                    
                    // Loop over the number of contacts and check to see if any of them got infected
                    for _ in 1...self.alpha {
                        var index = Int.random(in: 1...self.simulationView.individualStates.count)
                        
                        // Make sure we are not contacting ourselves :)
                        while index == i + 1 {
                            index = Int.random(in: 1...self.simulationView.individualStates.count)
                        }
                        
                        // Check if this person is susceptible
                        if self.simulationView.individualStates[index - 1] == .susceptible {
                            // Check if the person at this index will be infected (with chance rho)
                            if CGFloat.random(in: 0...1) <= (0.5 * self.rho) {
                                self.I += 1
                                self.S -= 1
                                // Infected!
                                // 80% chance to be infected symptomatic
                                if CGFloat.random(in: 0...1) <= 0.2 {
                                    self.simulationView.individualStates[index - 1] = .infectedAsymptomatic
                                } else {
                                    self.simulationView.individualStates[index - 1] = .infectedSymptomatic
                                }
                                
                                DispatchQueue.main.async {
                                    self.simulationView.individualViewAtIndex(index: index)?.backgroundColor = .red
                                }
                            }
                        }
                    }
                }
                
                // If the person is susceptible to the disease
                if self.simulationView.individualStates[i] == .susceptible {
                    
                    var alreadyInfected: Bool = false
                    
                    // Loop over the number of contacts and check to see if any of them got infected
                    for _ in 1...self.alpha {
                        var index = Int.random(in: 1...self.simulationView.individualStates.count)
                        
                        // Make sure we are not contacting ourselves :)
                        while index == i + 1 {
                            index = Int.random(in: 1...self.simulationView.individualStates.count)
                        }
                        
                        if !alreadyInfected {
                            // Check if someone they meet is infected
                            if self.simulationView.individualStates[index - 1] == .infectedSymptomatic {
                                // Check if the disease transmits to this person
                                if CGFloat.random(in: 0...1) <= self.rho {
                                    self.I += 1
                                    self.S -= 1
                                    // Infected!
                                    // 80% chance to be infected symptomatic
                                    if CGFloat.random(in: 0...1) <= 0.2 {
                                        self.simulationView.individualStates[i] = .infectedAsymptomatic
                                    } else {
                                        self.simulationView.individualStates[i] = .infectedSymptomatic
                                    }
                                    
                                    alreadyInfected = true
                                    
                                    DispatchQueue.main.async {
                                        self.simulationView.individualViewAtIndex(index: i + 1)?.backgroundColor = .red
                                    }
                                }
                            } else if self.simulationView.individualStates[index - 1] == .infectedAsymptomatic {
                                // Check if the disease transmits to this person
                                if CGFloat.random(in: 0...1) <= (0.5 * self.rho) {
                                    self.I += 1
                                    self.S -= 1
                                    // Infected!
                                    // 80% chance to be infected symptomatic
                                    if CGFloat.random(in: 0...1) <= 0.2 {
                                        self.simulationView.individualStates[i] = .infectedAsymptomatic
                                    } else {
                                        self.simulationView.individualStates[i] = .infectedSymptomatic
                                    }
                                    
                                    alreadyInfected = true
                                    
                                    DispatchQueue.main.async {
                                        self.simulationView.individualViewAtIndex(index: i + 1)?.backgroundColor = .red
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if self.I > self.maxI {
                self.maxI = self.I
            }
            
            self.t -= 1
            DispatchQueue.main.async {
                self.dayLabel.text = "Day: \(self._t - self.t)"
                self.maxInfectedLabel.text = "Peak: \(self.maxI)"
            }
            
            // MARK: Update lists
            self.sList.append(self.S)
            self.iList.append(self.I)
            self.rList.append(self.R)
            
            // Check to make sure there are still infected people
            if self.I == 0 {
                self.timer?.invalidate()
                DispatchQueue.main.async {
                    self.addSimulationDoneView()
                }
            }
            
            DispatchQueue.main.async {
                // Pass data to graph view
                self.graphView.infectedDataPoints = self.iList
                self.graphView.recoveredDataPoints = self.rList
            }
        }
    }
}

extension SimulationViewController: SimulationDoneDelegate {
    public func rerunSimulationPressed() {
        simulationDoneViewCenterAnchor!.isActive = false
        simulationDoneViewLeadingAnchor!.isActive = true
        
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
            self.fadeView?.alpha = 0.0
        }, completion: { _ in
            self.simulationDoneViewCenterAnchor = nil
            self.simulationDoneViewLeadingAnchor = nil
            self.simulationDoneView!.removeFromSuperview()
            self.fadeView!.removeFromSuperview()
            self.simulationDoneView = nil
            self.fadeView = nil
            
            self.S = self.N - self._I
            self.R = 0
            self.t = self._t
            self.maxI = 0
            self.I = self._I
            
            self.rerunSimulation()
        })
    }
    
    public func closePressed() {
        simulationDoneViewCenterAnchor!.isActive = false
        simulationDoneViewLeadingAnchor!.isActive = true
        
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
            self.fadeView?.alpha = 0.0
        }, completion: { _ in
            self.simulationDoneViewCenterAnchor = nil
            self.simulationDoneViewLeadingAnchor = nil
            self.simulationDoneView!.removeFromSuperview()
            self.fadeView!.removeFromSuperview()
            self.simulationDoneView = nil
            self.fadeView = nil
        })
    }
    
    func rerunSimulation() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }

        while graphView.viewState == .drawing {
            print("drawing")
        }
        
        // Remove simulation view
        simulationView.clear()
        
        graphView.clear()
        graphView.removeFromSuperview()
        
        bottomStackView.arrangedSubviews.forEach({ subview in
            subview.removeFromSuperview()
        })
        dayLabel = nil
        maxInfectedLabel = nil

        

        // Empty all lists used to keep track
        sList.removeAll()
        iList.removeAll()
        rList.removeAll()

        graphView.infectedDataPoints = nil
        graphView.recoveredDataPoints = nil
        graphView.t = t
        
        if fadeView != nil {
            simulationDoneView!.removeFromSuperview()
            fadeView!.removeFromSuperview()
        }
    
        setupView()
        startSimulation()
    }
}

