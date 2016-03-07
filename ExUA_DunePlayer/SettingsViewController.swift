//
//  SettingsViewController.swift
//  ExUA_DunePlayer
//
//  Created by atMamont on 06.03.16.
//  Copyright © 2016 Andrey Mamchenko. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var baseURLTextField: UITextField!
    @IBOutlet weak var duneIPTextField: UITextField!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        // saving data
        Settings.sharedInstance.duneIP = duneIPTextField.text!
        Settings.sharedInstance.baseURL = baseURLTextField.text!
        Settings.sharedInstance.saveSettngs()
    }
    
    override func viewWillAppear(animated: Bool) {
        // restoring settings
        duneIPTextField.text = Settings.sharedInstance.duneIP
        baseURLTextField.text = Settings.sharedInstance.baseURL
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
