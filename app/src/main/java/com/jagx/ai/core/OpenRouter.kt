package com.jagx.ai.core

import android.content.Context

/**
 * Back-compat name. Prefer [JagXApi].
 */
object OpenRouter {
    suspend fun chat(
        context: Context,
        messages: List<Pair<String, String>>,
        model: String = "",
        apiKey: String = "",
        systemPrompt: String = ""
    ): String {
        if (apiKey.isNotBlank()) {
            JagXApi.setApiKey(context, apiKey)
        }
        return JagXApi.chat(context, messages, systemPrompt.ifBlank { null })
    }
}
