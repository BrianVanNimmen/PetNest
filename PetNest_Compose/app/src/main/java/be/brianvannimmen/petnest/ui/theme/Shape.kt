package be.brianvannimmen.petnest.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes
import androidx.compose.ui.unit.dp

val PetNestShapes = Shapes(
    extraSmall = RoundedCornerShape(8.dp),   // afbeeldingsminiaturen
    small = RoundedCornerShape(10.dp),        // invoervelden
    medium = RoundedCornerShape(12.dp),       // knoppen, lijstkaarten, datumveld
    large = RoundedCornerShape(16.dp),        // hoofdkaarten
    extraLarge = RoundedCornerShape(20.dp)    // detailfoto patiënt
)
