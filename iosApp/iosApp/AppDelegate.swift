//
//  AppDelegate.swift
//  iosApp
//
//  Created by Junior on 23/05/25.
//  Copyright © 2025 orgName. All rights reserved.
//

import UIKit
import BackgroundTasks
import streamplayerapp

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

//By default showPushNotification value is true.
        //When set showPushNotification to false foreground push  notification will not be shown.
        //You can still get notification content using #onPushNotification listener method.
        NotifierManager.shared.initialize(configuration: NotificationPlatformConfigurationIos(
            showPushNotification: true,
            askNotificationPermissionOnStart: true,
            notificationSoundName: nil
        )
        )


        // Inicializa o Koin (KMP)
        // SyncBridge.shared.initKoin()
//         SyncBridge.shared.doInitKoin()

        // Registra tarefa
        // BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.codandotv.streamplayerapp.KotlinProject", using: nil) { task in
        //     self.handleAppRefresh(task: task as! BGAppRefreshTask)
        // }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.codandotv.streamplayerapp.KotlinProject", using: nil) { task in
            self.handleAppRefresh(task: task as! BGProcessingTask)
        }

        print("✅ BGTestes Task registrada!")
        NotifierHelper().showTestNotification()


        scheduleAppRefresh()
        return true
    }

    func scheduleAppRefresh() {
        // let request = BGAppRefreshTaskRequest(identifier: "com.codandotv.streamplayerapp.KotlinProject")
//         request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutos
//         request.earliestBeginDate = Date() // ← EXECUTÁVEL IMEDIATAMENTE

        let request = BGProcessingTaskRequest(identifier: "com.codandotv.streamplayerapp.KotlinProject")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date()

//         do {
//             try BGTaskScheduler.shared.submit(request)
//             print("✅ BGTestes tarefa agendada com sucesso!")
//         } catch {
//             print("❌ BGTestes falha ao agendar tarefa:", error.localizedDescription)
//         }


        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ BGTestes tarefa agendada com sucesso para agora: \(request.earliestBeginDate!)")
        } catch {
            print("❌ BGTestes falha ao agendar tarefa: \(error.localizedDescription)")
        }


    }

    func handleAppRefresh(task: BGProcessingTask) {
        print("🟡 BGTestes handleAppRefresh foi chamado!")
        NotifierHelper().showTestNotificationRegister()

        scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = BlockOperation {
            print("🟢 BGTestes Executando operação de sync...")
            SyncBridge.shared.syncData {
                print("BGTestes Sincronizado no IOS")
                task.setTaskCompleted(success: true)
            }
        }

        task.expirationHandler = {
            print("❌ BGTestes Tarefa expirada.")
            queue.cancelAllOperations()
        }

        queue.addOperation(operation)
    }
}


