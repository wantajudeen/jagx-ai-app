package com.jagx.ai.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.SmartToy
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.jagx.ai.ui.screens.AskScreen
import com.jagx.ai.ui.screens.BotScreen
import com.jagx.ai.ui.screens.BuildScreen
import com.jagx.ai.ui.screens.ImagineScreen

sealed class Screen(val route: String, val title: String, val icon: ImageVector) {
    data object Ask : Screen("ask", "Ask", Icons.Default.Chat)
    data object Imagine : Screen("imagine", "Imagine", Icons.Default.Image)
    data object Build : Screen("build", "Build", Icons.Default.Build)
    data object Bot : Screen("bot", "Bot", Icons.Default.SmartToy)
}

val bottomNavItems = listOf(Screen.Ask, Screen.Imagine, Screen.Build, Screen.Bot)

@Composable
fun JagXApp() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.onSurface
            ) {
                bottomNavItems.forEach { screen ->
                    val selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.title) },
                        label = { Text(screen.title) },
                        selected = selected,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = MaterialTheme.colorScheme.primary,
                            selectedTextColor = MaterialTheme.colorScheme.primary,
                            unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            indicatorColor = MaterialTheme.colorScheme.surfaceVariant
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Ask.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Ask.route) { AskScreen() }
            composable(Screen.Imagine.route) { ImagineScreen() }
            composable(Screen.Build.route) { BuildScreen() }
            composable(Screen.Bot.route) { BotScreen() }
        }
    }
}
