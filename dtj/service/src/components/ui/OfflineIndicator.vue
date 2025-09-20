<template>
  <div 
    v-if="!isOnline || hasOfflineData" 
    class="offline-indicator"
    :class="indicatorClass"
  >
    <div class="indicator-content">
      <div class="status-icon">
        <q-icon 
          :name="iconName" 
          :class="{ 'animate-pulse': syncInProgress }"
        />
      </div>
      
      <div class="status-text">
        <div class="status-title">{{ statusTitle }}</div>
        <div v-if="statusSubtitle" class="status-subtitle">{{ statusSubtitle }}</div>
      </div>
      
      <div v-if="canSync" class="sync-actions">
        <q-btn 
          size="sm" 
          color="primary" 
          @click="syncNow"
          :loading="syncInProgress"
        >
          Синхронизировать
        </q-btn>
      </div>
    </div>
    
    <!-- Прогресс синхронизации -->
    <div v-if="syncInProgress" class="sync-progress">
      <q-linear-progress 
        indeterminate 
        color="primary" 
        class="q-mt-xs"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useOffline } from '@/composables/useOffline.js';

const { 
  isOnline, 
  pendingCount, 
  syncInProgress, 
  hasOfflineData, 
  canSync, 
  syncNow 
} = useOffline();

const indicatorClass = computed(() => ({
  'offline': !isOnline,
  'pending': isOnline && hasOfflineData && !syncInProgress,
  'syncing': syncInProgress
}));

const iconName = computed(() => {
  if (!isOnline) return 'wifi_off';
  if (syncInProgress) return 'sync';
  if (hasOfflineData) return 'cloud_queue';
  return 'wifi';
});

const statusTitle = computed(() => {
  if (!isOnline) return 'Нет подключения к интернету';
  if (syncInProgress) return 'Синхронизация данных...';
  if (hasOfflineData) return `Ожидает синхронизации: ${pendingCount.value} операций`;
  return 'Подключено';
});

const statusSubtitle = computed(() => {
  if (!isOnline) return 'Данные сохраняются локально';
  if (hasOfflineData && !syncInProgress) return 'Нажмите "Синхронизировать" для отправки';
  return null;
});
</script>

<style scoped>
.offline-indicator {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 9999;
  padding: 8px 16px;
  transition: all 0.3s ease;
}

.offline-indicator.offline {
  background: linear-gradient(90deg, #f44336, #ff5722);
  color: white;
}

.offline-indicator.pending {
  background: linear-gradient(90deg, #ff9800, #ffc107);
  color: white;
}

.offline-indicator.syncing {
  background: linear-gradient(90deg, #2196f3, #03a9f4);
  color: white;
}

.indicator-content {
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: 1200px;
  margin: 0 auto;
}

.status-icon {
  font-size: 20px;
  min-width: 24px;
}

.status-text {
  flex: 1;
  min-width: 0;
}

.status-title {
  font-weight: 500;
  font-size: 14px;
  line-height: 1.2;
}

.status-subtitle {
  font-size: 12px;
  opacity: 0.9;
  margin-top: 2px;
}

.sync-actions {
  flex-shrink: 0;
}

.animate-pulse {
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.sync-progress {
  margin-top: 8px;
}

/* Адаптивность */
@media (max-width: 768px) {
  .offline-indicator {
    padding: 6px 12px;
  }
  
  .indicator-content {
    gap: 8px;
  }
  
  .status-title {
    font-size: 13px;
  }
  
  .status-subtitle {
    font-size: 11px;
  }
  
  .sync-actions .q-btn {
    font-size: 12px;
    padding: 4px 8px;
  }
}
</style>

