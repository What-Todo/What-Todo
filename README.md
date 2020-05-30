# WhatTODO

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
A competitive and cooperative todo list app.
Shared people can track their achievement and get motivated. 

### App Evaluation

- **Category:** Productivity
- **Mobile:** This app would be primarily developed for mobile. 
- **Story:** Allows users to keep track of all the tasks they need to finish as well as their achievements. Users keep adding todo lists and share them among group. Aims to motivate by sharing todo lists and achievements.
- **Market:** General users. Open to all individuals, from students to professionals.
- **Habit:**  Users can use this app on a daily basis to track shared people's achievement. 
- **Scope:** Fist we would start with having people sign up and start sharing their achievements and daily tasks. Later it could evolve into a more integrated experience among different user accounts. Implementations such as chat or comment functions could allow the app to expand more into the Social Networking category.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can register a new account.
* User can login.
* User can have internet connection for register, login, and group feature.
* User can add list category onto todo list main menu.
* User can remove list category from todo list main menu.
* User can tap on to-do list category to view individual items.
* User can add individual item onto todo list.
* User can remove individual item from todo list.
* User can see user's and groups' progresses through in-app notifications.
* User can see and edit their profile.
* User can see list items and people involved.


**Optional Nice-to-have Stories**

* User can compete with others on an item of a todo list.
* User can cooperate with others on an item of a todo list. 
* User seeks productivity and efficiency.

### 2. Screen Archetypes

* Register
   * User can register a new account and have internet connection.
* Login
   * User can login using own account and have internet connection.
* Stream
    * User can see their notification.
* Profile
    * User can see their profile.
* Settings 
    * User can edit their profile.
* Main Menu
    * User can view their to-do list categories
    * User can tap on to-do list to view individual items.
    * User can add list category.
    * User can remove list category.
* Post
    * User can view individual post items and people involved.
    * User can add individual post items.
    * User can remove individual post items.


### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Main Menu 
* Notifications
* Profile

**Flow Navigation** (Screen to Screen)

* Registration Screen
    * Main Menu Screen
* Login Screen
    * Registration Screen
    * Main Menu Screen
* Main Menu Screen
    * Post Screen
* Profile Screen
    * Settings Screen
    

## Wireframes
### [BONUS] Digital Wireframes & Mockups

![](https://i.imgur.com/FyUxRFl.png)



### [BONUS] Interactive Prototype
![](https://i.imgur.com/Wo372TG.gif)

## Schema 

### Models
**To-do List Items (Posts)**
| Property  | Type | Description |
| --------- | ---- | ----------- |
| postId  | String | unique id for the user post |
| addedByUser | Pointer to User | name of added user  |
| details   | String    | information about the post the user wrote |
| completed | Boolean | true if completed |
| createdAt | DateTime | date when post was made |
| updatedAt | DateTime | date of latest update 

**To-do List's Categories (Categories)**
| Property  | Type | Description |
| --------- | ---- | ----------- |
| categoryId  | String | unique id for the Category |
| addedByUser | Pointer to User | name of added user  |
| name | String | name of the Category |
| Post  | Pointer to Post | information of Post name |


**User Account (Users)**
| Property  | Type | Description |
| --------- | ---- | ----------- |
| userId  | String | unique id for the user |
| name | String | name of the user |
| location | String | location of the user |



### Networking
**List of network requests by screen**
* Main Menu Screen
    * (Read/GET) Query all posts where user is author
    ```
        // 1
    ref.observe(.value, with: { snapshot in
      // 2
      var newItems: [Categories] = []

      // 3
      for child in snapshot.children {
        // 4
        if let snapshot = child as? DataSnapshot,
           let listCategory = Categories(snapshot: snapshot) {
          newItems.append(listCategory)
        }
      }

      // 5
      self.items = newItems
      self.tableView.reloadData()
    })
    ```

    * (Delete) Delete existing category
    ```
    if editingStyle == .delete {
  let deletingCategory = items[indexPath.row]
  deletingCategory.ref?.removeValue()
    }
    ```
    * (Create/POST) Create a new category
    ```
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { _ in
        guard let textField = alert.textFields?.first,
          let text = textField.text else { return }

        let category = Categories(categoryId: lastIndex+1
                               addedByUser: self.user.userId,
                                name: text)
        let categoryRef = self.ref.child(text.lowercased())

        categoryRef.setValue(category.toAnyObject())
    }
    ```
    
* Notification Screen 
    * (Read/GET) Query all posts for user's group feed
    ```
    // Listen for new posts in the Firebase database
    postsRef.observe(.childAdded, with: { (snapshot) -> Void in
      self.posts.append(snapshot)
      self.tableView.insertRows(at: [IndexPath(row: self.posts.count-1, section: self.kSectionPosts)], with: UITableView.RowAnimation.automatic)
    })
    ```
* Post Screen
    * (Create/POST) Create a new post 
    ```
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { _ in
        guard let textField = alert.textFields?.first,
          let text = textField.text else { return }

        let post = Posts(postId: lastIndex+1
                                name: text,
                               addedByUser: self.user.userId)
        let postRef = self.ref.child(text.lowercased())

        postRef.setValue(post.toAnyObject())
    }
    ```
    * (Delete) Delete existing post
    ```
    if editingStyle == .delete {
  let deletingPost = items[indexPath.row]
  deletingPost.ref?.removeValue()
    }
    ```
* Profile Screen
    * (Read/GET) Query logged in user object
    ```
    Auth.auth().signIn(withEmail: email, password: password) { user, error in
      if let error = error, user == nil {
        let alert = UIAlertController(title: "Sign In Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alert, animated: true, completion: nil)
      }
    }
    ```
    * (Update/PUT) Update user profile
    ```
    let userName = nameTextField.text
    let location = locationTextField.text
    
    self.ref.child("users/\(user.name)/userName").setValue(userName)
    self.ref.child("users/\(user.location)/location").setValue(location)
    ```


![](https://i.imgur.com/Njmyqff.gif)

## Gif of Add Member to Category (Invitation)
![](https://i.imgur.com/VFYMLAe.gifv)

## Gif of Real Time Notification
![](https://i.imgur.com/Nbmrlzh.gifv)

## Narrated Walkthrough Video

https://www.youtube.com/watch?v=V-hwLXh_SdI
