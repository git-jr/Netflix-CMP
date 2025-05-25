package com.codandotv.streamplayerapp


import com.mmk.kmpnotifier.notification.NotificationImage
import com.mmk.kmpnotifier.notification.Notifier
import com.mmk.kmpnotifier.notification.NotifierManager
import kotlin.random.Random

object NotifierHelper {
    fun showTestNotification() {
        val notifier = NotifierManager.getLocalNotifier()
        notifier.notify {
            id= Random.nextInt(0, Int.MAX_VALUE)
            title = "Tarefa Registrada"
            body = "Corpo da task Registrada"
            payloadData = mapOf(
                Notifier.KEY_URL to "https://github.com/codandotv",
                "extraKey" to "randomValue"
            )
            image = NotificationImage.Url("https://github.com/codandotv.png?size=300")
        }
    }


    fun showTestNotificationRegister() {
        val notifier = NotifierManager.getLocalNotifier()
        notifier.notify {
            id= Random.nextInt(0, Int.MAX_VALUE)
            title = "Tarefa disparada"
            body = "Corpo da task disparada"
            payloadData = mapOf(
                Notifier.KEY_URL to "https://github.com/codandotv",
                "extraKey" to "randomValue"
            )
            image = NotificationImage.Url("https://github.com/codandotv.png?size=300")
        }
    }
}