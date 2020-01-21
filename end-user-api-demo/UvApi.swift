//  UvApi.swift
//  end-user-api-demo

import Foundation
import OAuthSwift

// =========================== ENVIRONMENT VARIABLES ==================================
// Your UserVoice domain, e.g. "feedback.uservoice.com"
let domainUrl = ProcessInfo.processInfo.environment["domainUrl"]
// An API key created from the Admin console settings (the secret is not needed)
let apiKey = ProcessInfo.processInfo.environment["apiKey"]
// ====================================================================================

class UvApi {
    static var oauthSwift: OAuth2Swift?
    static var authToken: String = ""
    static var apiUrl: String = "https://\(domainUrl!)/api/end_users"

    //
    // POST and DELETE requests are authorized with OAuthSwift
    //

    static func postVote(forumId: Int, ideaId: Int, onSuccess: @escaping (_ data: Any) -> Void) {
        let method = OAuthSwiftHTTPRequest.Method.POST
        let route = "/forums/\(forumId)/ideas/\(ideaId)/vote"

        oauthSwift?.startAuthorizedRequest(
            "\(apiUrl)\(route)",
            method: method,
            parameters: [:]
        ) { result in
            switch result {
            case .success(let response):
                print("success: POST \(route)")
                let decoder = JSONDecoder()
                let dataResult = try! decoder.decode(Idea.self, from: response.data)
                onSuccess(dataResult)
            case .failure:
                print("failure: POST \(route)")
            }
        }
    }

    static func deleteVote(forumId: Int, ideaId: Int, onSuccess: @escaping (_ data: Any) -> Void) {
        let method = OAuthSwiftHTTPRequest.Method.DELETE
        let route = "/forums/\(forumId)/ideas/\(ideaId)/vote"

        oauthSwift?.startAuthorizedRequest(
            "\(apiUrl)\(route)",
            method: method,
            parameters: [:]
        ) { result in
            switch result {
            case .success(let response):
                print("success: DELETE \(route)")
                let decoder = JSONDecoder()
                let dataResult = try! decoder.decode(Idea.self, from: response.data)
                onSuccess(dataResult)
            case .failure:
                print("failure: DELETE \(route)")
            }
        }
    }

    static func postIdea(title: String, forumId: Int, onSuccess: @escaping (_ data: Any) -> Void) {
        let method = OAuthSwiftHTTPRequest.Method.POST
        let route = "/forums/\(forumId)/ideas"
        let params: [String: [String: Any]] = [
            "suggestion": [
                "title": title
            ]
        ]

        oauthSwift?.startAuthorizedRequest(
            "\(apiUrl)\(route)",
            method: method,
            parameters: params,
            headers: [
                "Content-Type": "application/json"
            ]
        ) { result in
            switch result {
            case .success(let response):
                print("success: POST \(route)")
                let decoder = JSONDecoder()
                let dataResult = try! decoder.decode(Idea.self, from: response.data)
                onSuccess(dataResult)
            case .failure:
                print("failure: POST \(route)")
            }
        }
    }

    //
    // GET requests are made without OAuthSwift, but include a token if signed in
    //

    static func getIdea(ideaId: Int, onSuccess: @escaping (_ data: Any) -> Void) {
        // method: GET
        let route = "/ideas/\(ideaId)"

        UvApi.getRequest(route: route) { (response, data) in
            let decoder = JSONDecoder()
            let dataResult = try! decoder.decode(Idea.self, from: data as! Data)
            onSuccess(dataResult)
        }
    }

    static func getForumIdeas(forumId: Int, onSuccess: @escaping (_ data: Any) -> Void) {
        // method: GET
        let route = "/forums/\(forumId)/ideas"

        UvApi.getRequest(route: route) { (response, data) in
            let decoder = JSONDecoder()
            let dataResult = try! decoder.decode([Idea].self, from: data as! Data)
            onSuccess(dataResult)
        }
    }

    static func getForums(onSuccess: @escaping (_ data: Any) -> Void) {
        // method: GET
        let route = "/forums"

        UvApi.getRequest(route: route) { (response, data) in
            let decoder = JSONDecoder()
            let dataResult = try! decoder.decode([Forum].self, from: data as! Data)
            onSuccess(dataResult)
        }
    }

    //
    // Authentication
    //

    static func isSignedIn() -> Bool {
        return authToken != ""
    }

    static func signIn(vc: UIViewController, onSuccess: @escaping () -> Void) {
        if (isSignedIn()) {
            print("Already signed in")
            return
        }
        print("Signing in...")

        oauthSwift = OAuth2Swift(
            consumerKey:    apiKey!,
            consumerSecret: "",
            authorizeUrl:   "https://\(domainUrl!)/api/v2/oauth/auth",
            accessTokenUrl: "https://\(domainUrl!)/api/v2/oauth/token",
            responseType:   "code"
        )

        // Open the UserVoice login page in a browser window:
        oauthSwift!.authorizeURLHandler = SafariURLHandler(viewController: vc, oauthSwift: oauthSwift!)

        // PKCE verification (optional but recommended):
        // https://tools.ietf.org/html/rfc7636
        let decodedVerifier = "uv-demo-app"
        let codeVerifier = decodedVerifier.urlBase64EncodedString()
        let codeChallenge = codeVerifier.sha256().urlBase64EncodedString()

        guard let redirectUri = URL(string: "com.uv.Demo:/oauth2Callback") else { return }

        // When requesting an access token, UserVoice returns a redirect to a login page
        // which OAuthSwift renders in a browser window. Once the user successfully
        // authenticates, UserVoice redirects back to the URL specified when creating the
        // API key ("com.uv.Demo:/oauth2Callback").
        oauthSwift!.authorize(
            withCallbackURL: redirectUri,
            scope: "scope",
            state: "state",
            codeChallenge: codeChallenge,
            codeChallengeMethod: "S256",
            codeVerifier: codeVerifier
        ) { result in
            switch result {
            case .success(let (credential, _, _)):
                print("Authorize success")
                // This token should be set in the Authorization header of every request.
                authToken = credential.oauthToken
                onSuccess()
            case .failure(let error):
                print("Authorize failure")
                print(error.localizedDescription)
            }
        }
    }

    //
    // Helpers
    //

    static func getRequest(route: String, params: Data? = nil, onSuccess: @escaping (_ response: Any, _ data: Any) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: apiUrl + route)!);
        request.httpMethod = "GET"
        request.httpBody = params
        if isSignedIn() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                print("failure: GET \(route)")
                print(error!)
                return
            }

            print("success: GET \(route)")
            onSuccess(response!, data!)
        }
        task.resume()
    }

}
