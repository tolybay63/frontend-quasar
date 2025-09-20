import { ref, computed, onMounted, onUnmounted } from 'vue';
import { offlineAPI } from '@/utils/offlineApi.js';

/**
 * Composable для работы с офлайн режимом
 */
export function useOffline() {
  const isOnline = ref(navigator.onLine);
  const pendingCount = ref(0);
  const syncInProgress = ref(false);

  // Обновляем состояние при изменении сети
  const updateNetworkStatus = () => {
    isOnline.value = navigator.onLine;
    pendingCount.value = offlineAPI.getPendingCount();
    syncInProgress.value = offlineAPI.getSyncStatus().syncInProgress;
  };

  // Выполняем API запрос с поддержкой офлайн режима
  const offlineRequest = async (url, options = {}) => {
    const response = await offlineAPI.request(url, options);
    updateNetworkStatus();
    return response;
  };

  // Принудительная синхронизация
  const syncNow = async () => {
    if (isOnline.value && !syncInProgress.value) {
      syncInProgress.value = true;
      try {
        await offlineAPI.syncPending();
      } finally {
        updateNetworkStatus();
      }
    }
  };

  // Очистка отложенных запросов
  const clearPending = () => {
    offlineAPI.clearPending();
    updateNetworkStatus();
  };

  // Слушаем события сети
  onMounted(() => {
    window.addEventListener('online', updateNetworkStatus);
    window.addEventListener('offline', updateNetworkStatus);
    
    // Периодически обновляем счетчик отложенных запросов
    const interval = setInterval(updateNetworkStatus, 5000);
    
    onUnmounted(() => {
      window.removeEventListener('online', updateNetworkStatus);
      window.removeEventListener('offline', updateNetworkStatus);
      clearInterval(interval);
    });
  });

  // Вычисляемые свойства
  const hasOfflineData = computed(() => pendingCount.value > 0);
  const canSync = computed(() => isOnline.value && !syncInProgress.value && hasOfflineData.value);
  const statusText = computed(() => {
    if (!isOnline.value) return 'Офлайн';
    if (syncInProgress.value) return 'Синхронизация...';
    if (hasOfflineData.value) return `${pendingCount.value} операций в очереди`;
    return 'Онлайн';
  });

  return {
    // Состояние
    isOnline,
    pendingCount,
    syncInProgress,
    hasOfflineData,
    canSync,
    statusText,
    
    // Методы
    offlineRequest,
    syncNow,
    clearPending,
    updateNetworkStatus
  };
}

