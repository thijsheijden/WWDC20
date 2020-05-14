/*:
 # Simulating
 Simulating disease spread is quite difficult, however with two basic parameters and a decent understanding of them, we can quite accurately simulate the spread of a disease in a population.
 */
/*:
* Callout(Task):
Play around with the parameters and see what they do!
*/
/*:
 # α (Alpha)
 The first parameter is the contact rate: α. This parameter determines how many other people an individual comes into close contact with (close enough for disease transmission) per day. On average this is 24.
 */

var α: Int = 24         // On average this is 24

/*:
 # ρ (Rho)
 The second important parameter is the probability of disease transmission: ρ. This parameter determines what the probability is a disease will transmit between those two individuals. For influenza (flu) like diseases this is often around 0.015 or 1.5% chance of jumping per contact.
 */

var ρ: CGFloat = 0.01   // For the flu this is 0.01

/*:
 Try out some different values for both parameters and see what they do. When you feel like you have a basic understanding of them, continue to the [next page](@next), to learn about social distancing!
 */

/*:
 - Note:
 Please keep in mind that due to the 3 minute length restriction this is all very simplified and missing a lot of important details.
 */

import UIKit
import PlaygroundSupport

// Present the view controller in the Live View window
let vc = DiseaseSpreadViewController()
vc.alpha = α
vc.rho = ρ
vc.preferredContentSize = CGSize(width: 750, height: 1000)
PlaygroundPage.current.liveView = vc
