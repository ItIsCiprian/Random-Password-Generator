package com.cipherpasswordgenerator.wear

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.util.UUID

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "cipher_history")

@Serializable
data class HistoryEntry(
    val id: String = UUID.randomUUID().toString(),
    val password: String,
    val strengthLabel: String,
    val timestamp: Long = System.currentTimeMillis()
)

class HistoryManager(private val context: Context) {

    private val json = Json { ignoreUnknownKeys = true }
    private val maxHistory = 50
    private val key = stringPreferencesKey("password_history")

    val entries: Flow<List<HistoryEntry>> = context.dataStore.data.map { prefs ->
        prefs[key]?.let { json.decodeFromString(it) } ?: emptyList()
    }

    suspend fun add(password: String, strengthLabel: String) {
        context.dataStore.edit { prefs ->
            val current: List<HistoryEntry> = prefs[key]?.let {
                try { json.decodeFromString(it) } catch (_: Exception) { emptyList() }
            } ?: emptyList()

            val updated = mutableListOf(HistoryEntry(password = password, strengthLabel = strengthLabel))
            updated.addAll(current)
            val trimmed = updated.take(maxHistory)
            prefs[key] = json.encodeToString(trimmed)
        }
    }

    suspend fun clear() {
        context.dataStore.edit { prefs ->
            prefs.remove(key)
        }
    }
}
