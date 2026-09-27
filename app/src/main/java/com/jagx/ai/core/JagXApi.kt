package com.jagx.ai.core

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * JagX Backend client — talks to https://jagx-ai-v2.onrender.com
 * Auth header: x-api-key: <permanent JagX key>
 */
object JagXApi {
    const val DEFAULT_BASE = "https://jagx-ai-v2.onrender.com"

    private val client = OkHttpClient.Builder()
        .connectTimeout(20, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private val jsonMedia = "application/json; charset=utf-8".toMediaType()

    private const val PREFS = "jagx_prefs"
    private const val KEY_API = "jagx_api_key"
    private const val KEY_BASE = "jagx_api_base"

    fun getApiKey(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val saved = prefs.getString(KEY_API, "")?.trim().orEmpty()
        if (saved.isNotEmpty()) return saved
        return runCatching {
            Class.forName("com.jagx.ai.BuildConfig")
                .getField("JAGX_API_KEY")
                .get(null) as? String
        }.getOrNull()?.trim().orEmpty()
    }

    fun setApiKey(context: Context, key: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_API, key.trim())
            .apply()
    }

    fun getBaseUrl(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val saved = prefs.getString(KEY_BASE, "")?.trim().orEmpty()
        if (saved.isNotEmpty()) return saved.trimEnd('/')
        return runCatching {
            Class.forName("com.jagx.ai.BuildConfig")
                .getField("JAGX_API_BASE")
                .get(null) as? String
        }.getOrNull()?.trim()?.trimEnd('/') ?: DEFAULT_BASE
    }

    suspend fun chat(
        context: Context,
        messages: List<Pair<String, String>>,
        systemHint: String? = null
    ): String = withContext(Dispatchers.IO) {
        val apiKey = getApiKey(context)
        if (apiKey.isBlank()) {
            return@withContext "Add your JagX API key in Settings (or set JAGX_API_KEY secret and rebuild).\n\n" +
                "Create a permanent key on the backend with POST /create-key."
        }

        val base = getBaseUrl(context)
        val userMessage = messages.lastOrNull { it.first == "user" }?.second
            ?: messages.lastOrNull()?.second
            ?: ""

        val history = JSONArray()
        messages.dropLast(1).takeLast(8).forEach { (role, content) ->
            if (role == "user" || role == "assistant") {
                history.put(JSONObject().put("role", role).put("content", content.take(3000)))
            }
        }

        val body = JSONObject().apply {
            put("message", if (systemHint.isNullOrBlank()) userMessage else "$systemHint\n\n$userMessage")
            if (history.length() > 0) put("history", history)
        }

        val request = Request.Builder()
            .url("$base/chat")
            .addHeader("x-api-key", apiKey)
            .addHeader("Content-Type", "application/json")
            .post(body.toString().toRequestBody(jsonMedia))
            .build()

        try {
            client.newCall(request).execute().use { response ->
                val raw = response.body?.string().orEmpty()
                when (response.code) {
                    200 -> {
                        val json = JSONObject(raw)
                        json.optString("response")
                            .ifBlank { json.optString("message") }
                            .ifBlank { raw.take(500) }
                    }
                    401 -> "Invalid JagX API key. Check Settings or regenerate with /create-key."
                    429 -> "Rate limit reached. Wait a bit or upgrade your key tier."
                    else -> "JagX error ${response.code}: ${raw.take(220)}"
                }
            }
        } catch (e: Exception) {
            "Network error: ${e.message ?: "cannot reach JagX backend"}"
        }
    }

    suspend fun health(context: Context): String = withContext(Dispatchers.IO) {
        val base = getBaseUrl(context)
        try {
            val req = Request.Builder().url("$base/health").get().build()
            client.newCall(req).execute().use { r ->
                if (r.isSuccessful) "Backend online" else "Backend HTTP ${r.code}"
            }
        } catch (e: Exception) {
            "Backend offline: ${e.message}"
        }
    }
}
