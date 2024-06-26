package com.ftel.librariesplugin

import android.util.Log
import com.ftel.ptnetlibrary.services.*
import com.ftel.ptnetlibrary.dto.*
import com.google.gson.Gson

import java.util.concurrent.CompletableFuture

class LibrariesHandler(
    act: String,
    address: String = "",
    server: String = "",
    ttl: Int = -1,
    port: Int = -1
) {
    private lateinit var result: String

    init {
        when (act) {
            "ping" -> result = pingResult(address)
            "pageLoad" -> result = pageLoadResult(address).get()
            "dnsLookup" -> result = dnsLookupResult(address, server).get()
            "portScan" -> result = portScanResult(address, port).get()
        }
    }

    private fun pingResult(address: String): String {
        val pingdto: PingDTO = PingService().execute(address = address)
        return Gson().toJson(pingdto)
    }

    private fun pageLoadResult(address: String): CompletableFuture<String> {
        return CompletableFuture.supplyAsync {
            val pageLoadService = PageLoadService()
            try {
                val time = pageLoadService.pageLoadTimer(address)
                Gson().toJson(mapOf("address" to address, "time" to time))
            } catch (e: Exception) {
                throw RuntimeException("Failed to load page: ${e.message}")
            }
        }
    }

    private fun dnsLookupResult(
        address: String,
        server: String
    ): CompletableFuture<String> {
        return CompletableFuture.supplyAsync {
            val dnsLookupService = NsLookupService()
            try {
//                Log.d("Plugins - LookupService", "${dnsLookupService.toString()}")
                var dnsResult = ArrayList<AnswerDTO>()
                var result = ArrayList<String>()
                // Cannot find source class for androidx.compose.runtime.SnapshotMutableStateImpl - dnsResponseDTO
                dnsResult = dnsLookupService.execute(address, server)
                Gson().toJson(dnsResult)
            } catch (e: Exception) {
                throw RuntimeException("Failed to load page: ${e.message}")
            }
        }
    }

    private fun portScanResult(
        address: String,
        port: Int,
        timeOut: Int = 200
    ): CompletableFuture<String> {
        return CompletableFuture.supplyAsync {
            val portScanService = PortScanService();
            portScanService.portScan(address, port, timeOut)
        }
    }

    fun getResult(): Any {
        return this.result
    }
}
