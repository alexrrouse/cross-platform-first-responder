package com.tandem.emt.features.incidentReport

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performScrollToNode
import com.tandem.emt.MainActivity
import org.junit.Rule
import org.junit.Test

class IncidentReportUITest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    /** Demo: shows the incident list with dummy data, pauses for video capture. */
    @Test
    fun test_incidentListDemo() {
        composeTestRule.waitForIdle()

        // Verify the incident list loads with cards
        composeTestRule.onNodeWithTag("incident_card_1").assertIsDisplayed()
        Thread.sleep(3000)

        // Verify multiple cards are visible
        composeTestRule.onNodeWithTag("incident_card_2").assertIsDisplayed()
        composeTestRule.onNodeWithTag("incident_card_3").assertIsDisplayed()

        // Verify the new report FAB is present
        composeTestRule.onNodeWithTag("new_report_button").assertIsDisplayed()

        // Scroll down to show remaining cards
        composeTestRule.onNodeWithTag("incident_list")
            .performScrollToNode(hasTestTag("incident_card_5"))
        composeTestRule.waitForIdle()
        Thread.sleep(2000)
    }
}
