package com.jagx.ai.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// Grok-inspired dark palette
private val JagXDark = darkColorScheme(
    primary = Color(0xFFE8E8E8),
    onPrimary = Color(0xFF0A0A0A),
    primaryContainer = Color(0xFF2A2A2A),
    onPrimaryContainer = Color(0xFFE8E8E8),
    secondary = Color(0xFF8B8B8B),
    onSecondary = Color(0xFF0A0A0A),
    background = Color(0xFF0A0A0A),
    onBackground = Color(0xFFE8E8E8),
    surface = Color(0xFF121212),
    onSurface = Color(0xFFE8E8E8),
    surfaceVariant = Color(0xFF1E1E1E),
    onSurfaceVariant = Color(0xFFB0B0B0),
    outline = Color(0xFF3A3A3A),
    error = Color(0xFFFF6B6B)
)

private val JagXLight = lightColorScheme(
    primary = Color(0xFF0A0A0A),
    onPrimary = Color(0xFFFFFFFF),
    background = Color(0xFFF5F5F5),
    onBackground = Color(0xFF0A0A0A),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF0A0A0A)
)

@Composable
fun JagXTheme(
    darkTheme: Boolean = true, // force dark like Grok by default
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) JagXDark else JagXLight
    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
