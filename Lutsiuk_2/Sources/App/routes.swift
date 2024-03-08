import Vapor

func routes(_ app: Application) throws {
    
    // MARK: - Data
    struct User: Content {
        var user_name: String
    }
    struct Interest: Content {
        var interest_name: String
    }
    struct UserInterest: Content {
        var user_name: String
        var interest_name: String
    }
    struct UserFollow: Content {
        var user_name: String
        var user_name_to_follow: String
    }
    struct UserUnFollow: Content {
        var user_name: String
        var user_name_to_unfollow: String
    }
    
    var usersSet: Set<String> = []
    var interestsSet: Set<String> = []
    var userInterestsArray: [UserInterest] = []
    var userFollowsArray: [UserFollow] = []
    var followInterests: [String: [String]] = [:]

    // MARK: - Endpoints
    app.post("user") { req -> Int in
        let user = try req.content.decode(User.self)
        
        guard !user.user_name.isEmpty else {
            return 400
        }
        if usersSet.contains(user.user_name) {
            return 400
        }
        usersSet.insert(user.user_name)
        
        return 200
    }
    
    app.post("interests") { req -> Int in
        let interest = try req.content.decode(Interest.self)
        
        guard !interest.interest_name.isEmpty else {
            return 400
        }
        if interestsSet.contains(interest.interest_name) {
            return 400
        }
        interestsSet.insert(interest.interest_name)
        
        return 200
    }
    
    app.delete("interests") { req -> Int in
        let interest_name = try req.query.get(String.self, at: "interest_name")
        
        guard !interest_name.isEmpty else {
            return 400
        }
        for (index, userInterest) in userInterestsArray.enumerated() {
            if userInterest.interest_name == interest_name {
                userInterestsArray.remove(at: index)
            }
        }
        if interestsSet.remove(interest_name) != nil {
            return 200
        } else {
            return 400
        }
    }
    
    app.post(["user", "interests"]) { req -> Int in
        let userInterest = try req.content.decode(UserInterest.self)
        
        if usersSet.contains(userInterest.user_name) && interestsSet.contains(userInterest.interest_name) {
            if !userInterestsArray.contains(where: { interest in
                return interest.user_name == userInterest.user_name && interest.interest_name == userInterest.interest_name}) {
                    userInterestsArray.append(userInterest)
                    return 200
                } else {
                    return 400
                }
            } else {
                return 400
            }
    }
    
    app.delete(["user", "interests"]) { req -> Int in
        let user_name = try req.query.get(String.self, at: "user_name")
        let interest_name = try req.query.get(String.self, at: "interest_name")
        
        guard !user_name.isEmpty && !interest_name.isEmpty else {
            return 400
        }
        
        if let index = userInterestsArray.firstIndex(where: { userInterest in
            return userInterest.user_name == user_name && userInterest.interest_name == interest_name
        }) {
            userInterestsArray.remove(at: index)
            return 200
        } else {
            return 400
        }
    }
    
    app.post(["user", "follow"]) { req -> Int in
        let userFollow = try req.content.decode(UserFollow.self)
        if usersSet.contains(userFollow.user_name) && usersSet.contains(userFollow.user_name_to_follow){
            if !userFollowsArray.contains(where: { follow in
                return follow.user_name == userFollow.user_name && follow.user_name_to_follow == userFollow.user_name_to_follow
            }) {
                userFollowsArray.append(userFollow)
                return 200
            } else {
                return 400
            }
        } else {
            return 400
        }
    }
    
    app.post(["user", "unfollow"]) { req -> Int in
        let userUnFollow = try req.content.decode(UserUnFollow.self)
        
        guard usersSet.contains(userUnFollow.user_name) && usersSet.contains(userUnFollow.user_name_to_unfollow) else {
            return 400
        }
        
        if let index = userFollowsArray.firstIndex(where: { follow in
            return follow.user_name == userUnFollow.user_name && follow.user_name_to_follow == userUnFollow.user_name_to_unfollow
        }) {
            userFollowsArray.remove(at: index)
            return 200
        } else {
            return 400
        }
    }
    
    app.get(["user", "following"]) { req -> [String] in
        let user_name = try req.query.get(String.self, at: "user_name")
        
        let followingUsers = userFollowsArray
            .filter { userFollow in
                return userFollow.user_name == user_name
            }
            .map { userFollow in
                return userFollow.user_name_to_follow
            }
        
        return followingUsers
    }
    
    app.get(["user", "common_followings"]) { req -> [String] in
        let user_name_1 = try req.query.get(String.self, at: "user_name_1")
        let user_name_2 = try req.query.get(String.self, at: "user_name_2")
        
        let user1Followings = userFollowsArray
            .filter { userFollow in
                return userFollow.user_name == user_name_1
            }
            .map { userFollow in
                return userFollow.user_name_to_follow
            }
        
        let user2Followings = userFollowsArray
            .filter { userFollow in
                return userFollow.user_name == user_name_2
            }
            .map { userFollow in
                return userFollow.user_name_to_follow
            }
        
        let commonFollowings = Array(Set(user1Followings).intersection(user2Followings))
        
        return commonFollowings
    }
    
    app.get(["user", "common_interests"]) { req -> [String] in
        let user_name_1 = try req.query.get(String.self, at: "user_name_1")
        let user_name_2 = try req.query.get(String.self, at: "user_name_2")
        
        let user1Interests = userInterestsArray
            .filter { userInterest in
                return userInterest.user_name == user_name_1
            }
            .map { userInterest in
                return userInterest.interest_name
            }
        
        let user2Interests = userInterestsArray
            .filter { userInterest in
                return userInterest.user_name == user_name_2
            }
            .map { userInterest in
                return userInterest.interest_name
            }
        
        let commonInterests = Array(Set(user1Interests).intersection(user2Interests))
        
        return commonInterests
    }
    
    app.get(["user", "possible_friends"]) { req -> [String] in
        let user_name = try req.query.get(String.self, at: "user_name")
        let userInterests = userInterestsArray
            .filter { userInterest in
                return userInterest.user_name == user_name
            }
            .map { userInterest in
                return userInterest.interest_name
            }
        let possibleFriends = userInterestsArray
            .filter { userInterest in
                return userInterest.user_name != user_name && userInterests.contains(userInterest.interest_name)
            }
            .map { userInterest in
                return userInterest.user_name
            }
        
        return possibleFriends
    }
    
    app.get(["user", "following_interests"]) { req -> [String: [String]] in
        let user_name = try req.query.get(String.self, at: "user_name")
        let followUsers = userFollowsArray
            .filter { userFollow in
                return userFollow.user_name == user_name
            }
        for userFollow in followUsers {
            let followedUserName = userFollow.user_name_to_follow
            
            let userInterests = userInterestsArray
                .filter { userInterest in
                    return userInterest.user_name == followedUserName
                }
                .map { userInterest in
                    return userInterest.interest_name
                }
            
            followInterests[followedUserName] = userInterests
        }
        
        return followInterests
    }
}
