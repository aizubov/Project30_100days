//
//  ViewController.swift
//  Project1-3MS_100days
//
//  Created by user226947 on 12/14/22.
//

import UIKit



class ViewController: UITableViewController {

        var picturesHR = [String]()
        var picturesLR = [String]()
    
        var flagsCache = [UIImage?]()

        override func viewDidLoad() {
            super.viewDidLoad()
        
            navigationController?.navigationBar.prefersLargeTitles = true
            title = "Flags and Countries"
            
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                if item.hasSuffix(".png"){
                    if item.split(separator: "_")[1] == "hd" {
                        picturesHR.append(item)
                    } else if item.split(separator: "_")[1] == "sd" {
                        
                        picturesLR.append(item)
                        flagsCache.append(nil)
                    }
                }
            }
                
        
            picturesHR = sortByCountryName(picturesHR)
            picturesLR = sortByCountryName(picturesLR)
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return picturesLR.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Flags", for: indexPath) as! CellWithFlag
            
            cell.flagTextLabel?.text = countryName(picturesLR[indexPath.row])
             
            guard let path = Bundle.main.path(forResource: picturesLR[indexPath.row], ofType: nil) else { return cell }
            guard let image = UIImage(contentsOfFile: path) else { return cell }
             
            let newSize = CGSize(width: 50, height: 30)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
             
            cell.flagImageView?.image = scaledImage
            cell.flagImageView?.layer.borderColor = UIColor.gray.cgColor
            cell.flagImageView?.layer.borderWidth = 0.3
            cell.flagImageView?.layer.cornerRadius = 5
            
            return cell
        }
        

        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                vc.countryselected = indexPath.row
                vc.picturesHR = picturesHR
                navigationController?.pushViewController(vc, animated: true)
            }
        }
     

    func sortByCountryName(_ flags: [String]) -> [String] {
        return flags.sorted(by: {countryName($0) < countryName($1)
        })
    }
    func countryName(_ flags: String) -> String {
        return countryCodes[flags.split(separator: "_")[2].split(separator: ".")[0].uppercased(), default: "No country found"]
        
    }
    
}

class CellWithFlag: UITableViewCell {
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var flagTextLabel: UILabel!
}
