package be.brianvannimmen.petnest.ui.Screens.Klant
import be.brianvannimmen.petnest.ui.theme.*

import androidx.annotation.StringRes
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Pets
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import be.brianvannimmen.petnest.R

enum class KlantTab(
    @StringRes val labelRes: Int,
    val icon: ImageVector,
    val route: String
) {
    Home(R.string.home, Icons.Outlined.Home, "klant/home"),
    Huisdieren(R.string.mijn_huisdieren, Icons.Outlined.Pets, "klant/dieren"),
    Afspraken(R.string.afspraken, Icons.Outlined.CalendarMonth, "klant/afspraken")
}

@Composable
fun KlantBottomBar(
    selectedTab: KlantTab,
    onTabSelected: (KlantTab) -> Unit
) {
    NavigationBar(
        containerColor = MaterialTheme.colorScheme.surface,
        tonalElevation = 0.dp
    ) {
        KlantTab.entries.forEach { tab ->
            val isSelected = tab == selectedTab
            NavigationBarItem(
                selected = isSelected,
                onClick = { onTabSelected(tab) },
                icon = { Icon(tab.icon, contentDescription = stringResource(tab.labelRes)) },
                label = {
                    Text(
                        stringResource(tab.labelRes),
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
                        )
                    )
                },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = MaterialTheme.colorScheme.primary,
                    selectedTextColor = MaterialTheme.colorScheme.primary,
                    unselectedIconColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                    unselectedTextColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                    indicatorColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.12f)
                )
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun KlantBottomBarLightPreview() {
    PetNestTheme(darkTheme = false) {
        KlantBottomBar(
            selectedTab = KlantTab.Home,
            onTabSelected = {}
        )
    }
}

@Preview(showBackground = true)
@Composable
fun KlantBottomBarDarkPreview() {
    PetNestTheme(darkTheme = true) {
        KlantBottomBar(
            selectedTab = KlantTab.Afspraken,
            onTabSelected = {}
        )
    }
}