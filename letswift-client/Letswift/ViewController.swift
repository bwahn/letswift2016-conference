//
//  ViewController.swift
//  Letswift
//
//  Created by red on 2016. 7. 6..
//  Copyright © 2016년 red. All rights reserved.
//

import UIKit
import Alamofire

enum LanguageKind: Int {
    case Swift = 0
    case ObjectiveC = 1
}
let baseURL = "http://192.168.0.100:8090"
struct APIURL {
    static var VoteObjectiveC = "\(baseURL)/votes/objectivec_voted"
    static var VoteSwift = "\(baseURL)/votes/swift_voted"
    static var Vote = "\(baseURL)/vote"
}


class ViewController: UIViewController {

    let titles = ["Swift", "Objective-C"]
    var selectedIndexPath: NSIndexPath?
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = ""
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        if let selectedIndexPath = selectedIndexPath where selectedIndexPath == indexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        resultLabel.text = "Selecting.."
        let apiURL: String
        if indexPath.row == 0 {
            apiURL = APIURL.VoteSwift
        } else  {
            apiURL = APIURL.VoteObjectiveC
        }
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            let headers = [
                "Accept": "application/json"
            ]
            Alamofire.request(.PUT, apiURL, headers: headers)
                .responseJSON { response in
//                    debugPrint(response)dd
                    if let statusCode = response.response?.statusCode where statusCode == 200 {
                        Alamofire.request(.GET, APIURL.Vote, headers: headers)
                            .responseJSON { response in
//                                print("")
//                                debugPrint(response)
                                if let result = response.result.value, swift = result["swift"], objectiveC = result["objective-c"] {
                                    self.resultLabel.text = "Swift(\(swift!)) : Objective-C(\(objectiveC!))"
                                }
                                self.tableView.reloadData()
                        }
                    }
            }
        }
    }
    
}
