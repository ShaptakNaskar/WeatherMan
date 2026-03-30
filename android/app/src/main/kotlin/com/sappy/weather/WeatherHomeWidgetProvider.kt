package com.sappy.weather

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import android.content.SharedPreferences

class WeatherHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            val prefs = widgetData

            val temperature = prefs.getString("widget_temp", "--")
            val condition = prefs.getString("widget_condition", "Updating")
            val high = prefs.getString("widget_high", "--")
            val low = prefs.getString("widget_low", "--")
            val hourly = prefs.getString("widget_hours", "Updating...")
            val bgKey = prefs.getString("widget_bg", "clear")
            val bgRes = when (bgKey) {
                "rain" -> R.drawable.widget_bg_rain_anim
                "snow" -> R.drawable.widget_bg_snow_anim
                "cloud" -> R.drawable.widget_bg_cloud_anim
                else -> R.drawable.widget_bg_clear_anim
            }

            views.setTextViewText(R.id.widget_temp, temperature)
            views.setTextViewText(R.id.widget_condition, condition)
            views.setTextViewText(R.id.widget_high_low, "H $high • L $low")
            views.setTextViewText(R.id.widget_hours, hourly)
            views.setInt(R.id.widget_root, "setBackgroundResource", bgRes)

            // Tap widget to open the app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
