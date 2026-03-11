package com.tandem.emt.features.incidentReport.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.RemoveCircle
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import com.tandem.emt.ui.theme.DesignTokens

@Composable
fun DynamicListSection(
    items: List<String>,
    listTag: String,
    addButtonTag: String,
    removeTagPrefix: String,
    placeholder: String,
    onAdd: (String) -> Unit,
    onRemove: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    var newItem by remember { mutableStateOf("") }

    Column(modifier = modifier.testTag(listTag), verticalArrangement = Arrangement.spacedBy(DesignTokens.SpaceXs)) {
        items.forEachIndexed { index, item ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(item, style = MaterialTheme.typography.bodyMedium, modifier = Modifier.weight(1f))
                IconButton(
                    onClick = { onRemove(index) },
                    modifier = Modifier.testTag("${removeTagPrefix}_$index")
                ) {
                    Icon(
                        Icons.Default.RemoveCircle,
                        contentDescription = "Remove",
                        tint = MaterialTheme.colorScheme.error
                    )
                }
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(DesignTokens.SpaceSm)
        ) {
            OutlinedTextField(
                value = newItem,
                onValueChange = { newItem = it },
                label = { Text(placeholder) },
                modifier = Modifier.weight(1f)
            )
            IconButton(
                onClick = {
                    onAdd(newItem)
                    newItem = ""
                },
                modifier = Modifier.testTag(addButtonTag)
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add", tint = MaterialTheme.colorScheme.primary)
            }
        }
    }
}
