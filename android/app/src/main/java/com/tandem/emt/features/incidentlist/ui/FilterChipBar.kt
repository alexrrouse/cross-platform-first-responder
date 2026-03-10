package com.tandem.emt.features.incidentlist.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.tandem.emt.features.incidentlist.models.FilterStatus
import com.tandem.emt.ui.theme.BrandPrimary
import com.tandem.emt.ui.theme.BrandSecondary

@Composable
fun FilterChipBar(
    selectedFilter: FilterStatus,
    onFilterSelected: (FilterStatus) -> Unit,
    modifier: Modifier = Modifier
) {
    LazyRow(
        modifier = modifier,
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(FilterStatus.entries) { filter ->
            val isSelected = filter == selectedFilter
            FilterChip(
                selected = isSelected,
                onClick = { onFilterSelected(filter) },
                label = {
                    Text(
                        text = filter.displayName,
                        color = if (isSelected) Color.White else BrandSecondary
                    )
                },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = BrandPrimary,
                    selectedLabelColor = Color.White
                ),
                border = if (!isSelected) {
                    BorderStroke(1.dp, BrandSecondary)
                } else {
                    null
                },
                modifier = Modifier.testTag("filter_chip_${filter.name}")
            )
        }
    }
}
