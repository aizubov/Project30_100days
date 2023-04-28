//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	var viewControllers = [UIViewController]() // create a cache of the detail view controllers for faster loading
	var dirty = false
    var images = [UIImage]()
    var imagesLarge = [UIImage]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
		let fm = FileManager.default
        if let resourcePath = Bundle.main.resourcePath {
            let tempItems = try? fm.contentsOfDirectory(atPath: resourcePath)
            for item in tempItems ?? [] {
                if item.range(of: "Large") != nil {
                    items.append(item)
                    let imagePath = resourcePath + "/" + item
                    print(imagePath)
                    if let image = UIImage(contentsOfFile: imagePath) {
                        let newSize = CGSize(width: 90, height: 90)
                        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                        let imageRect = CGRect(origin: .zero, size: newSize)
                        let roundedPath = UIBezierPath(roundedRect: imageRect, cornerRadius: newSize.width / 2.0)
                        roundedPath.addClip()
                        image.draw(in: imageRect)
                        if let scaledImage = UIGraphicsGetImageFromCurrentImageContext() {
                            UIGraphicsEndImageContext()
                            images.append(scaledImage)
                        } else {
                            print("Scaling failed")
                        }
                        
                    }
                }
            }
        } else {
            fatalError("Failed to get resource path from main bundle")
        }
        
        imagesLarge = Array(repeating: images, count: 10).flatMap { $0 }
         
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return imagesLarge.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        
		// find the image for this cell, and load its thumbnail
        let currentImage = items[indexPath.row % items.count]
        
        let imageToShow = imagesLarge[indexPath.row]
        
        
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))

        cell.imageView?.image = imageToShow

		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath
        

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		// add to our view controller cache and show
		viewControllers.append(vc)
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
        }
	}
}
