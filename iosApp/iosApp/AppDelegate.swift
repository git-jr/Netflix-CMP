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

        // Inicializa o Koin (KMP)
        // SyncBridge.shared.initKoin()
//         SyncBridge.shared.doInitKoin()

        // Registra tarefa
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.codandotv.streamplayerapp.KotlinProject", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        print("✅ BGTestes Task registrada!")

        scheduleAppRefresh()
        return true
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.codandotv.streamplayerapp.KotlinProject")
//         request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutos
        request.earliestBeginDate = Date() // ← EXECUTÁVEL IMEDIATAMENTE

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

    func handleAppRefresh(task: BGAppRefreshTask) {
        print("🟡 BGTestes handleAppRefresh foi chamado!")

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


