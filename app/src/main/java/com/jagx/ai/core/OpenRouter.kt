package com.jagx.ai.core

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

object OpenRouter {
    // Free models on OpenRouter (no credit needed for light use)
    const val DEFAULT_MODEL = "meta-llama/llama-3.1-8b-instruct:free"
    const val CODER_MODEL = "qwen/qwen-2.5-coder-32b-instruct:free"
    const val STRONG_MODEL = "meta-llama/llama-3.1-70b-instruct:free"

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(90, TimeUnit.SECONDS)
        .build()

    private val jsonMedia = "application/json; charset=utf-8".toMediaType()

    /**
     * Call OpenRouter chat completions.
     * API key can come from BuildConfig / local.properties / env later.
     * For now uses a placeholder that the user can replace, or empty = demo mode.
     */
    suspend fun chat(
        messages: List<Pair<String, String>>, // role, content
        model: String = DEFAULT_MODEL,
        apiKey: String = "",
        systemPrompt: String = SYSTEM_PROMPT
    ): String = withContext(Dispatchers.IO) {
        if (apiKey.isBlank()) {
            return@withContext demoReply(messages.lastOrNull()?.second ?: "")
        }

        val body = JSONObject().apply {
            put("model", model)
            put("messages", JSONArray().apply {
                put(JSONObject().put("role", "system").put("content", systemPrompt))
                messages.forEach { (role, content) ->
                    put(JSONObject().put("role", role).put("content", content))
                }
            })
        }

        val request = Request.Builder()
            .url("https://openrouter.ai/api/v1/chat/completions")
            .addHeader("Authorization", "Bearer $apiKey")
            .addHeader("HTTP-Referer", "https://jagxai.name.ng")
            .addHeader("X-Title", "JagX AI")
            .addHeader("Content-Type", "application/json")
            .post(body.toString().toRequestBody(jsonMedia))
            .build()

        client.newCall(request).execute().use { response ->
            val raw = response.body?.string() ?: ""
            if (!response.isSuccessful) {
                return@withContext "Error ${response.code}: ${raw.take(200)}"
            }
            try {
                val json = JSONObject(raw)
                json.getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content")
            } catch (e: Exception) {
                "Parse error: ${e.message}\n$raw".take(400)
            }
        }
    }

    private fun demoReply(userText: String): String {
        val t = userText.lowercase()
        return when {
            t.contains("hello") || t.contains("hi") || t.contains("hey") ->
                "Hello! I'm JagX AI — Nigeria-first intelligence. Ask me about business, code, finance, or anything."
            t.contains("lagos") || t.contains("nigeria") || t.contains("naira") ->
                "Lagos & Nigeria are at the heart of JagX. I can help with local business plans, FX, tech, and more."
            t.contains("code") || t.contains("kotlin") || t.contains("android") ->
                "I can help with Kotlin, Compose, APIs, and architecture. Describe what you want to build."
            t.contains("company") || t.contains("business") || t.contains("startup") ->
                "Let's build it. Tell me the idea and I'll outline product, market, and first steps."
            else ->
                "JagX received: \"${userText.take(80)}\".\n\n" +
                "(Demo mode — add your OpenRouter API key in Settings for full free-model replies.)"
        }
    }

    private const val SYSTEM_PROMPT = """
You are JagX AI — a sharp, helpful Nigeria-first AI assistant.
You are built for Africans first. Be direct, practical, and culturally aware.
You can help with: coding, business plans, finance, research, writing, and product design.
Keep answers clear and useful. When relevant, use Nigerian or African context.
Never claim to be made by another company. You are JagX.
""".trimIndent()
}
