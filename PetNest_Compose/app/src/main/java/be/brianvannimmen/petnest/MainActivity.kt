package be.brianvannimmen.petnest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import be.brianvannimmen.petnest.ui.PetNestApp
import be.brianvannimmen.petnest.ui.sharedViewmodel.ThemeViewModel
import be.brianvannimmen.petnest.ui.theme.PetNestTheme

class MainActivity : ComponentActivity() {

    private val themeViewModel: ThemeViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            PetNestTheme(darkTheme = themeViewModel.isDarkMode) {
                Surface(modifier = Modifier.fillMaxSize()) {
                    PetNestApp(
                        isDarkMode = themeViewModel.isDarkMode,
                        onToggleDarkMode = { themeViewModel.toggleDarkMode() }
                    )
                }
            }
        }
    }
}
