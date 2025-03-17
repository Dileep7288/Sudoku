import UIKit

class SplashScreenVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    private func transitionToMainScreen() {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        mainVC?.modalTransitionStyle = .crossDissolve
        mainVC?.modalPresentationStyle = .fullScreen
        self.present((mainVC?)!, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        transitionToMainScreen()
    }
}

