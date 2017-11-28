//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by libo on 2017/11/27.
//  Copyright © 2017年 libo. All rights reserved.
//

import UIKit

private let CellID = "CellID"

class ViewController: UIViewController {
    let data = ["物体识别"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID)
     
    }
    
  
}

extension  ViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath)
        cell.textLabel?.text = data[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let objectVC = ObjectRecongationController(nibName: "ObjectRecongationController", bundle: nil)
            present(objectVC, animated: true, completion: nil)
        }
    }
}
