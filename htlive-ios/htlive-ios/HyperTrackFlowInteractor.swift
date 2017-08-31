//
//  HyperTrackFlowInteractor.swift
//  htlive-ios
//
//  Created by Ravi Jain on 7/14/17.
//  Copyright © 2017 PZRT. All rights reserved.
//

import UIKit
import UserNotifications

protocol HyperTrackFlowInteractorDelegate {
    func haveStartedFlow(sender: BaseFlowController)
    
    func haveFinishedFlow(sender: BaseFlowController)
}

class HyperTrackFlowInteractor: NSObject, HyperTrackFlowInteractorDelegate {
    
    let onboardingFlowController = OnboardingFlowController()
    let permissionFlowController = PermissionsFlowController()
    let inviteFlowController = InviteFlowController()
    
    var liveLocationViewControllers  = [ShareVC]()
    
    var flows = [BaseFlowController]()
    
    var isPresentingAFlow = false
    
    override init() {
        super.init()
        initializeFlows()
    }
    
    func initializeFlows(){
        appendController(permissionFlowController)
        appendController(onboardingFlowController)
    }
    
    func appendController(_ controller: BaseFlowController) {
        controller.interactorDelegate = self
        flows.append(controller)
    }
    
    func presentFlowsIfNeeded(){
        if(!isPresentingAFlow){
            for flowController in self.flows{
                if(!flowController.isFlowCompleted()){
                    flowController.startFlow(force: false, presentingController: HyperTrackFlowInteractor.topViewController()!)
                    isPresentingAFlow = true
                    break
                }
            }
        }
        
        if (!isPresentingAFlow){
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .sound, .badge];
            center.requestAuthorization(options: options) {
                (granted, error) in
                if !granted {
                    print("Something went wrong")
                }
            }

        }
    }
    
    
    static func topViewController() -> UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
    
    func presentDeeplinkFlow(){
        
    }
    
    func acceptInvitation(_ accountId: String){
        inviteFlowController.acccountId = accountId
        inviteFlowController.autoAccept = true
        appendController(inviteFlowController)
        presentFlowsIfNeeded()
    }
    
    func addAcceptInviteFlow(_ userId: String, _ accountId: String, _ accountName: String){
        inviteFlowController.acccountId = accountId
        appendController(inviteFlowController)
        presentFlowsIfNeeded()
    }
    
    func presentLiveLocationFlow(shortCode : String){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let liveLocationController = storyboard.instantiateViewController(withIdentifier: "ShareVC") as! ShareVC
        liveLocationController.shortCode = shortCode
        HyperTrackFlowInteractor.topViewController()?.present(liveLocationController, animated:true, completion: nil)
    }
    
    func presentLiveLocationFlow(lookUpId : String,shortCode: String){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let liveLocationController = storyboard.instantiateViewController(withIdentifier: "ShareVC") as! ShareVC
        liveLocationController.lookupId = lookUpId
        liveLocationController.shortCode = shortCode
        HyperTrackFlowInteractor.topViewController()?.present(liveLocationController, animated:true, completion: nil)
    }
    
    func haveStartedFlow(sender: BaseFlowController) {
        //
    }
    
    func haveFinishedFlow(sender: BaseFlowController) {
        isPresentingAFlow = false
        let index =  flows.index(of: sender)
        flows.remove(at: index!)
        presentFlowsIfNeeded()
    }
}
