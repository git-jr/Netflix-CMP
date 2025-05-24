package com.codandotv.streamplayerapp

class SyncManager {
    suspend fun syncData() {
        println("SyncManager: Sincronizando dados de teste...")
        kotlinx.coroutines.delay(2000)
        println("SyncManager: Dados sincronizados com sucesso!")
    }
}