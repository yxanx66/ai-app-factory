package com.landscape.planner

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.PI
import kotlin.math.roundToInt

// MARK: - Models
enum class SunExposure(val label: String, val icon: String) {
    FullSun("Full Sun", "sun.max.fill"),
    PartialSun("Partial Sun", "cloud.sun.fill"),
    PartialShade("Partial Shade", "cloud.fill"),
    FullShade("Full Shade", "moon.fill")
}

data class Plant(
    val name: String,
    val scientificName: String,
    val sunlight: SunExposure,
    val water: String,
    val height: String,
    val spread: String,
    val description: String,
    val zones: String,
    val color: String
)

// MARK: - App Root
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LandscapePlannerApp() {
    var selectedTab by remember { mutableIntStateOf(0) }

    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    icon = { Icon(Icons.Filled.Spa, contentDescription = null) },
                    label = { Text("Plants") })
                NavigationBarItem(selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    icon = { Icon(Icons.Filled.LightMode, contentDescription = null) },
                    label = { Text("Sunlight") })
                NavigationBarItem(selected = selectedTab == 2,
                    onClick = { selectedTab = 2 },
                    icon = { Icon(Icons.Filled.Straighten, contentDescription = null) },
                    label = { Text("Area") })
            }
        }
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding)) {
            when (selectedTab) {
                0 -> PlantDatabaseScreen()
                1 -> SunlightAnalysisScreen()
                2 -> AreaCalculatorScreen()
            }
        }
    }
}

// MARK: - Tab 1: Plant Database
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PlantDatabaseScreen() {
    val plants = PlantData.all

    Scaffold(topBar = {
        TopAppBar(title = { Text("Plant Database") },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = Color(0xFF4CAF50),
                titleContentColor = Color.White))
    }) { padding ->
        List(plants, modifier = Modifier.padding(padding)) { plant ->
            NavigationCard(plant = plant)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NavigationCard(plant: Plant) {
    var expanded by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 4.dp),
        onClick = { expanded = !expanded }
    ) {
        Column(Modifier.padding(12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Spa, contentDescription = null,
                    tint = Color(0xFF4CAF50), modifier = Modifier.size(32.dp))
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text(plant.name, fontWeight = FontWeight.Bold)
                    Text(plant.scientificName, fontSize = 12.sp,
                        color = Color.Gray, fontStyle = androidx.compose.ui.text.font.FontStyle.Italic)
                    Text("${plant.sunlight.label} • ${plant.zones}",
                        fontSize = 11.sp, color = Color.Gray)
                }
                Icon(
                    if (expanded) Icons.Filled.ExpandLess else Icons.Filled.ExpandMore,
                    contentDescription = null, tint = Color.Gray
                )
            }

            if (expanded) {
                Divider(Modifier.padding(vertical = 8.dp))
                
                Row(Modifier.fillMaxWidth()) {
                    InfoChip("Sun", plant.sunlight.label, Color(0xFFFF9800))
                    Spacer(Modifier.width(8.dp))
                    InfoChip("Water", plant.water, Color(0xFF2196F3))
                    Spacer(Modifier.width(8.dp))
                    InfoChip("Height", plant.height, Color(0xFF4CAF50))
                }
                Spacer(Modifier.height(8.dp))
                Row(Modifier.fillMaxWidth()) {
                    InfoChip("Spread", plant.spread, Color(0xFF4CAF50))
                    Spacer(Modifier.width(8.dp))
                    InfoChip("Zones", plant.zones, Color(0xFF795548))
                    Spacer(Modifier.width(8.dp))
                    InfoChip("Color", plant.color, Color(0xFFE91E63))
                }
                Spacer(Modifier.height(8.dp))
                Text(plant.description, fontSize = 13.sp, color = Color.DarkGray)
            }
        }
    }
}

@Composable
fun InfoChip(label: String, value: String, color: Color) {
    Surface(
        shape = MaterialTheme.shapes.small,
        color = color.copy(alpha = 0.12f)
    ) {
        Column(Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
            Text(label, fontSize = 9.sp, color = color)
            Text(value, fontSize = 11.sp, fontWeight = FontWeight.Medium, color = color)
        }
    }
}

// MARK: - Tab 2: Sunlight Analysis
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SunlightAnalysisScreen() {
    val directions = listOf("N", "NE", "E", "SE", "S", "SW", "W", "NW")
    var selected by remember { mutableStateOf("S") }
    val focusManager = LocalFocusManager.current

    val exposure = when (selected) {
        "N" -> SunExposure.FullShade; "NE" -> SunExposure.PartialShade
        "E" -> SunExposure.PartialSun; "SE" -> SunExposure.FullSun
        "S" -> SunExposure.FullSun; "SW" -> SunExposure.FullSun
        "W" -> SunExposure.FullSun; "NW" -> SunExposure.PartialSun
        else -> SunExposure.PartialSun
    }

    val recommended = PlantData.all.filter {
        it.sunlight == exposure || it.sunlight == SunExposure.PartialSun
    }

    Scaffold(topBar = {
        TopAppBar(title = { Text("Sunlight Analysis") },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = Color(0xFFFF9800),
                titleContentColor = Color.White))
    }) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).verticalScroll(rememberScrollState())) {
            // Compass
            Box(
                modifier = Modifier.fillMaxWidth().height(220.dp).padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Canvas(modifier = Modifier.size(200.dp)) {
                    drawCircle(color = Color(0xFF4CAF50).copy(alpha = 0.15f),
                        radius = size.minDimension / 2)
                    directions.forEachIndexed { i, dir ->
                        val angle = i * 45.0 - 90.0
                        val cx = size.width / 2 + 85f * cos(angle * PI / 180).toFloat()
                        val cy = size.height / 2 + 85f * sin(angle * PI / 180).toFloat()
                        drawCircle(color = if (dir == selected) Color(0xFF4CAF50) else Color.Gray,
                            radius = 16f, center = androidx.compose.ui.geometry.Offset(cx, cy))
                    }
                }

                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Filled.Navigation, contentDescription = null,
                        tint = Color(0xFF4CAF50), modifier = Modifier.size(24.dp))
                    Text(selected, fontWeight = FontWeight.Bold,
                        fontSize = 24.sp, color = Color(0xFF4CAF50))
                }

                directions.forEachIndexed { i, dir ->
                    val angle = i * 45.0 - 90.0
                    val x = 100f + 85f * cos(angle * PI / 180).toFloat()
                    val y = 100f + 85f * sin(angle * PI / 180).toFloat()
                    Text(
                        text = dir,
                        modifier = Modifier.offset(
                            x = (x - 14).dp, y = (y - 10).dp
                        ).clickable { selected = dir },
                        fontSize = if (dir == selected) 16.sp else 13.sp,
                        fontWeight = if (dir == selected) FontWeight.Bold else FontWeight.Normal,
                        color = if (dir == selected) Color.White else Color.Gray
                    )
                }
            }

            // Exposure result
            Card(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = exposureColor(exposure).copy(alpha = 0.1f))
            ) {
                Column(Modifier.padding(16.dp).fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        when (exposure) {
                            SunExposure.FullSun -> Icons.Filled.LightMode
                            SunExposure.PartialSun -> Icons.Filled.WbCloudy
                            SunExposure.PartialShade -> Icons.Filled.Cloud
                            SunExposure.FullShade -> Icons.Filled.DarkMode
                        },
                        contentDescription = null,
                        tint = exposureColor(exposure),
                        modifier = Modifier.size(40.dp)
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(exposure.label, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Text("$selected facing", fontSize = 13.sp, color = Color.Gray)
                }
            }

            // Recommended plants
            Spacer(Modifier.height(12.dp))
            Text("Recommended Plants (${recommended.size})",
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(horizontal = 16.dp))

            recommended.forEach { plant ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 3.dp)
                ) {
                    Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.Spa, contentDescription = null,
                            tint = Color(0xFF4CAF50))
                        Spacer(Modifier.width(8.dp))
                        Column(Modifier.weight(1f)) {
                            Text(plant.name, fontWeight = FontWeight.Medium)
                            Text(plant.sunlight.label, fontSize = 12.sp, color = Color.Gray)
                        }
                        Text(plant.zones, fontSize = 12.sp, color = Color.Gray)
                    }
                }
            }
            Spacer(Modifier.height(16.dp))
        }
    }
}

private fun exposureColor(e: SunExposure) = when (e) {
    SunExposure.FullSun -> Color(0xFFFF9800)
    SunExposure.PartialSun -> Color(0xFFFDD835)
    SunExposure.PartialShade -> Color(0xFF2196F3)
    SunExposure.FullShade -> Color(0xFF9C27B0)
}

// MARK: - Tab 3: Area Calculator
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AreaCalculatorScreen() {
    var shape by remember { mutableIntStateOf(0) }
    var length by remember { mutableStateOf("") }
    var width by remember { mutableStateOf("") }
    var radius by remember { mutableStateOf("") }
    var area by remember { mutableStateOf<Double?>(null) }
    val shapes = listOf("Rectangle", "Circle", "Triangle")
    val focusManager = LocalFocusManager.current

    Scaffold(topBar = {
        TopAppBar(title = { Text("Area Calculator") },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = Color(0xFF795548),
                titleContentColor = Color.White))
    }) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).verticalScroll(rememberScrollState())) {
            Spacer(Modifier.height(12.dp))

            SingleChoiceSegmentedButtonRow(modifier = Modifier.padding(horizontal = 16.dp)) {
                shapes.forEachIndexed { i, s ->
                    SegmentedButton(selected = shape == i, onClick = { shape = i; area = null }) {
                        Text(s)
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            Card(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Column(Modifier.padding(16.dp)) {
                    when (shape) {
                        0 -> {
                            AreaInputField("Length (ft)", length, { length = it; area = null })
                            Spacer(Modifier.height(12.dp))
                            AreaInputField("Width (ft)", width, { width = it; area = null })
                        }
                        1 -> {
                            AreaInputField("Radius (ft)", radius, { radius = it; area = null })
                        }
                        2 -> {
                            AreaInputField("Base (ft)", length, { length = it; area = null })
                            Spacer(Modifier.height(12.dp))
                            AreaInputField("Height (ft)", width, { width = it; area = null })
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            Button(
                onClick = {
                    focusManager.clearFocus()
                    area = when (shape) {
                        0 -> {
                            val l = length.toDoubleOrNull(); val w = width.toDoubleOrNull()
                            if (l != null && w != null) l * w else null
                        }
                        1 -> {
                            val r = radius.toDoubleOrNull()
                            if (r != null) PI * r * r else null
                        }
                        2 -> {
                            val b = length.toDoubleOrNull(); val h = width.toDoubleOrNull()
                            if (b != null && h != null) 0.5 * b * h else null
                        }
                        else -> null
                    }
                },
                modifier = Modifier.fillMaxWidth().height(52.dp).padding(horizontal = 16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50))
            ) {
                Text("Calculate Area", fontSize = 16.sp)
            }

            area?.let { a ->
                Spacer(Modifier.height(16.dp))
                Card(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF4CAF50).copy(alpha = 0.08f))
                ) {
                    Column(Modifier.padding(20.dp).fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("Garden Area",
                            fontSize = 13.sp, color = Color.Gray)
                        Text(String.format("%.1f", a),
                            fontSize = 48.sp, fontWeight = FontWeight.Bold,
                            color = Color(0xFF4CAF50))
                        Text("sq ft", fontSize = 16.sp, color = Color.Gray)
                        Spacer(Modifier.height(4.dp))
                        Text(String.format("%.2f sq m", a * 0.092903),
                            fontWeight = FontWeight.Medium, color = Color.Gray)
                    }
                }

                Spacer(Modifier.height(12.dp))
                Card(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
                    Column(Modifier.padding(12.dp)) {
                        Text("Planting Guide", fontWeight = FontWeight.Bold)
                        val plants = (a / 4).roundToInt()
                        val shrubs = (a / 9).roundToInt()
                        val ground = a.roundToInt()
                        Text("Small shrubs (2-3ft): ~$plants plants",
                            fontSize = 12.sp, color = Color.DarkGray)
                        Text("Medium shrubs (3-5ft): ~$shrubs plants",
                            fontSize = 12.sp, color = Color.DarkGray)
                        Text("Ground cover (1ft): ~$ground plants",
                            fontSize = 12.sp, color = Color.DarkGray)
                    }
                }
            }
            Spacer(Modifier.height(24.dp))
        }
    }
}

@Composable
fun AreaInputField(label: String, value: String, onChange: (String) -> Unit) {
    Text(label, fontWeight = FontWeight.SemiBold)
    Spacer(Modifier.height(4.dp))
    OutlinedTextField(
        value = value, onValueChange = onChange,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        placeholder = { Text("Enter value") }, singleLine = true,
        modifier = Modifier.fillMaxWidth()
    )
}

// MARK: - Plant Data
object PlantData {
    val all = listOf(
        Plant("Lavender", "Lavandula angustifolia", SunExposure.FullSun,
            "Low", "1-3 ft", "2-3 ft",
            "Fragrant purple flowers on silvery-green foliage. Drought-tolerant once established. Perfect for borders and rock gardens.",
            "5-9", "Purple"),

        Plant("Japanese Maple", "Acer palmatum", SunExposure.PartialShade,
            "Moderate", "10-25 ft", "10-20 ft",
            "Elegant ornamental tree with delicate, deeply-lobed leaves. Brilliant fall color in reds and oranges.",
            "5-8", "Red / Green"),

        Plant("Hydrangea", "Hydrangea macrophylla", SunExposure.PartialSun,
            "High", "3-6 ft", "3-6 ft",
            "Classic garden shrub with large globe-shaped flower clusters. Flower color varies by soil pH. Long blooming season.",
            "4-9", "Blue / Pink / White"),

        Plant("Boxwood", "Buxus sempervirens", SunExposure.PartialSun,
            "Moderate", "2-8 ft", "2-8 ft",
            "Evergreen shrub with dense, small glossy leaves. Ideal for hedges, topiary, and formal gardens. Very adaptable.",
            "5-9", "Green"),

        Plant("Hostas", "Hosta spp.", SunExposure.FullShade,
            "Moderate", "1-3 ft", "1-4 ft",
            "Shade-loving perennials with bold foliage in green, blue, gold, and variegated patterns. Low-maintenance.",
            "3-9", "Green / Variegated"),

        Plant("Knock Out Roses", "Rosa 'Knock Out'", SunExposure.FullSun,
            "Moderate", "3-4 ft", "3-4 ft",
            "Easy-care shrub roses blooming spring to frost. Disease-resistant, self-cleaning. Available in several colors.",
            "4-9", "Red / Pink / Yellow"),

        Plant("Ornamental Grass", "Miscanthus sinensis", SunExposure.FullSun,
            "Low to Moderate", "4-7 ft", "3-5 ft",
            "Tall grass with feathery plumes in late summer. Adds movement and texture. Good for screening.",
            "4-9", "Silver / Bronze"),

        Plant("Ferns", "Matteuccia struthiopteris", SunExposure.FullShade,
            "High", "2-4 ft", "2-3 ft",
            "Classic shade plants with delicate, arching fronds. Thrives in moist, rich soil. Woodland garden essential.",
            "3-8", "Green"),

        Plant("Azalea", "Rhododendron spp.", SunExposure.PartialShade,
            "Moderate", "2-6 ft", "2-5 ft",
            "Spring-blooming shrubs covered in vibrant flowers. Prefers acidic well-drained soil. Evergreen varieties available.",
            "5-9", "Pink / Red / White"),

        Plant("Sedum", "Sedum spectabile", SunExposure.FullSun,
            "Very Low", "1-2 ft", "1-2 ft",
            "Succulent perennial with fleshy leaves and late-summer flower heads. Extremely drought-tolerant. Great for rock gardens.",
            "3-9", "Pink / Red / White")
    )
}
