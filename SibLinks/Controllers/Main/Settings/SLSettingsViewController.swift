//
//  SLSettingsViewController.swift
//  SibLinks
//
//  Created by Jana on 9/22/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLSettingsViewController: SLBaseViewController {
    
    static let settingsViewControllerID = "SLSettingsViewControllerID"
    
    static var controller: SLSettingsViewController! {
        let controller = UIStoryboard(name: "SettingsScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLSettingsViewController.settingsViewControllerID) as! SLSettingsViewController
        return controller
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var settingsTitleArray = ["Notifications", "New answer for your questions", "New review for your essay", "Events, news updates", "About", "Contact Us", "Terms and Privacy Policy", "Quick guide"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SLSettingsViewController {
    
    // MARK: - Configure view
    
    override func configView() {
        super.configView()
        
        self.navigationItem.title = "Settings".localized
        
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left)])
        
        self.tableView.registerNib(SLSettingTableViewCell.nib(), forCellReuseIdentifier: SLSettingTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLSettingSwitchTableViewCell.nib(), forCellReuseIdentifier: SLSettingSwitchTableViewCell.cellIdentifier())
        self.tableView.tableFooterView = UIView()
    }
}

extension SLSettingsViewController {
    
    // MARK: - Actions
    
}

extension SLSettingsViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsTitleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1, 2, 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLSettingSwitchTableViewCell.cellIdentifier())
            
            if let settingCell = cell as? SLSettingSwitchTableViewCell {
                settingCell.settingLabel.text = self.settingsTitleArray[indexPath.row]
                settingCell.selectionStyle = .None
                return settingCell
            }
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLSettingTableViewCell.cellIdentifier())
            
            if let settingCell = cell as? SLSettingTableViewCell {
                settingCell.settingLabel.text = self.settingsTitleArray[indexPath.row]
                
                switch indexPath.row {
                case 0:
                    settingCell.accessoryType = .None
                    
                default:
                    settingCell.accessoryType = .DisclosureIndicator
                }
                
                return settingCell
            }
        }
        
        return UITableViewCell()
    }
    
}

extension SLSettingsViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}
