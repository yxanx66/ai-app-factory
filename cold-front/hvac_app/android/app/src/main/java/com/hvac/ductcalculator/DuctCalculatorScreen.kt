package com.hvac.ductcalculator

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.PI
import kotlin.math.roundToInt
import kotlin.math.sqrt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DuctCalculatorScreen() {
    var isImperial by remember { mutableStateOf(true) }
    var airflow by remember { mutableStateOf("") }
    var velocity by remember { mutableStateOf("") }
    var diameter by remember { mutableStateOf<Double?>(null) }
    val focusManager = LocalFocusManager.current
    val scrollState = rememberScrollState()

    val velocityRange = if (isImperial) 300.0..1200.0 else 1.5..6.0

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Duct Size Calculator") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(scrollState)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(8.dp))

            // Icon + subtitle
            Icon(
                imageVector = androidx.compose.material.icons.Icons.Filled.Air,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            Spacer(Modifier.height(4.dp))
            Text("HVAC Round Duct Sizing", style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant)

            Spacer(Modifier.height(16.dp))

            // Unit toggle
            SegmentedButton(
                selectedValue = if (isImperial) "imperial" else "metric",
                onValueChange = { v ->
                    isImperial = v == "imperial"
                    diameter = null
                    focusManager.clearFocus()
                },
                options = listOf("imperial" to "Imperial (CFM/FPM)",
                                 "metric" to "Metric (m³/s/m/s)"),
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(20.dp))

            // Input card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Column(Modifier.padding(16.dp)) {
                    // Airflow
                    Text(
                        text = if (isImperial) "Airflow (CFM)" else "Airflow (m³/s)",
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(Modifier.height(4.dp))
                    OutlinedTextField(
                        value = airflow,
                        onValueChange = { airflow = it; diameter = null },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        placeholder = { Text(if (isImperial) "e.g. 400" else "e.g. 0.19") },
                        suffix = { Text(if (isImperial) "CFM" else "m³/s") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )

                    Spacer(Modifier.height(12.dp))

                    // Velocity
                    Text(
                        text = if (isImperial) "Velocity (FPM)" else "Velocity (m/s)",
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(Modifier.height(4.dp))
                    OutlinedTextField(
                        value = velocity,
                        onValueChange = { velocity = it; diameter = null },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        placeholder = { Text(if (isImperial) "e.g. 700" else "e.g. 3.5") },
                        suffix = { Text(if (isImperial) "FPM" else "m/s") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )

                    // Velocity warning
                    val v = velocity.toDoubleOrNull()
                    if (v != null && (v < velocityRange.start || v > velocityRange.endInclusive)) {
                        Spacer(Modifier.height(6.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = androidx.compose.material.icons.Icons.Filled.Info,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.tertiary,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(Modifier.width(4.dp))
                            Text(
                                text = if (isImperial) "Typical: 300–1200 FPM"
                                else "Typical: 1.5–6.0 m/s",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.tertiary
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // Calculate Button
            Button(
                onClick = {
                    focusManager.clearFocus()
                    val q = airflow.toDoubleOrNull()
                    val v = velocity.toDoubleOrNull()
                    if (q != null && v != null && q > 0 && v > 0) {
                        diameter = if (isImperial) {
                            24.0 * sqrt(q / (v * PI))
                        } else {
                            2000.0 * sqrt(q / (v * PI))
                        }
                    } else {
                        diameter = null
                    }
                },
                modifier = Modifier.fillMaxWidth().height(52.dp)
            ) {
                Icon(
                    imageVector = androidx.compose.material.icons.Icons.Filled.Calculate,
                    contentDescription = null
                )
                Spacer(Modifier.width(8.dp))
                Text("Calculate Diameter", fontSize = 16.sp)
            }

            Spacer(Modifier.height(20.dp))

            // Result
            diameter?.let { d ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    )
                ) {
                    Column(Modifier.padding(20.dp).fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("Recommended Round Duct Diameter",
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer)

                        Spacer(Modifier.height(8.dp))

                        Text(
                            text = String.format("%.1f", d),
                            fontSize = 56.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary,
                            textAlign = TextAlign.Center
                        )
                        Text(
                            text = if (isImperial) "in" else "mm",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )

                        if (isImperial) {
                            Spacer(Modifier.height(8.dp))
                            Surface(
                                shape = MaterialTheme.shapes.small,
                                color = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
                            ) {
                                Text(
                                    text = "Standard size: ${nearestStandardSize(d)} in",
                                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp),
                                    style = MaterialTheme.typography.titleSmall,
                                    color = MaterialTheme.colorScheme.primary
                                )
                            }

                            Spacer(Modifier.height(12.dp))
                            Text("Equivalent Rectangular:",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onPrimaryContainer)
                            rectangularEquivalents(d / 25.4).take(3).forEach { eq ->
                                Text(eq, style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onPrimaryContainer)
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // Reference
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(Modifier.padding(12.dp)) {
                    Text("Reference", fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.titleSmall)
                    Spacer(Modifier.height(4.dp))
                    ReferenceRow(color = MaterialTheme.colorScheme.primary,
                        text = "Main duct supply: 700–900 FPM")
                    ReferenceRow(color = MaterialTheme.colorScheme.secondary,
                        text = "Branch duct: 400–600 FPM")
                    ReferenceRow(color = MaterialTheme.colorScheme.tertiary,
                        text = "Return duct: 300–500 FPM")
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}

@Composable
fun SegmentedButton(selectedValue: String, onValueChange: (String) -> Unit,
                    options: List<Pair<String, String>>, modifier: Modifier = Modifier) {
    SingleChoiceSegmentedButtonRow(modifier = modifier) {
        options.forEachIndexed { index, (value, label) ->
            SegmentedButton(
                selected = selectedValue == value,
                onClick = { onValueChange(value) },
                shape = SegmentedButtonDefaults.itemShape(
                    index = index, count = options.size
                )
            ) {
                Text(label, style = MaterialTheme.typography.labelSmall)
            }
        }
    }
}

@Composable
fun ReferenceRow(color: androidx.compose.ui.graphics.Color, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 2.dp)) {
        Surface(
            modifier = Modifier.size(8.dp),
            shape = MaterialTheme.shapes.extraLarge,
            color = color
        ) {}
        Spacer(Modifier.width(8.dp))
        Text(text, style = MaterialTheme.typography.bodySmall)
    }
}

private fun nearestStandardSize(inches: Double): Int {
    val standards = listOf(4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24)
    return standards.minByOrNull { kotlin.math.abs(it - inches.roundToInt()) } ?: 6
}

private fun rectangularEquivalents(roundDia: Double): List<String> {
    val ratios = listOf(1.0 to 1.0, 1.5 to 1.0, 2.0 to 1.0)
    val area = PI * (roundDia / 2).pow(2)
    return ratios.map { (w, h) ->
        val width = sqrt(area * w / h)
        val height = area / width
        "${width.roundToInt()}×${height.roundToInt()} in"
    }
}

private fun Double.pow(exp: Double): Double = Math.pow(this, exp)
