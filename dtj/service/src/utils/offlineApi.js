/**
 * Простая обертка для работы в офлайн режиме
 * Сохраняет запросы при отсутствии интернета и синхронизирует при восстановлении
 */
class OfflineAPI {
  constructor() {
    this.pending = this.loadPending();
    this.isOnline = navigator.onLine;
    this.syncInProgress = false;
    
    // Слушаем изменения состояния сети
    window.addEventListener('online', () => {
      console.log('🌐 Интернет восстановлен, начинаем синхронизацию...');
      this.isOnline = true;
      this.syncPending();
    });
    
    window.addEventListener('offline', () => {
      console.log('📴 Интернет потерян, переходим в офлайн режим');
      this.isOnline = false;
    });
  }
  
  /**
   * Основной метод для выполнения запросов
   */
  async request(url, options = {}) {
    if (this.isOnline) {
      try {
        const response = await fetch(url, options);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response;
      } catch (error) {
        console.warn('❌ Запрос не удался, сохраняем для офлайн:', error.message);
        return this.addToPending(url, options);
      }
    } else {
      console.log('📴 Офлайн режим, сохраняем запрос:', url);
      return this.addToPending(url, options);
    }
  }
  
  /**
   * Добавляет запрос в очередь на синхронизацию
   */
  addToPending(url, options) {
    const pendingRequest = {
      id: Date.now() + Math.random(),
      url,
      options,
      timestamp: Date.now(),
      method: options.method || 'GET'
    };
    
    this.pending.push(pendingRequest);
    this.savePending();
    
    // Возвращаем "успешный" ответ для офлайн режима
    return {
      ok: true,
      status: 200,
      json: async () => ({ 
        success: true, 
        offline: true, 
        message: 'Данные сохранены для синхронизации',
        pendingId: pendingRequest.id
      })
    };
  }
  
  /**
   * Синхронизирует все отложенные запросы
   */
  async syncPending() {
    if (this.syncInProgress || this.pending.length === 0) {
      return;
    }
    
    this.syncInProgress = true;
    console.log(`🔄 Начинаем синхронизацию ${this.pending.length} запросов...`);
    
    const successIds = [];
    const errors = [];
    
    for (const request of this.pending) {
      try {
        console.log(`📤 Синхронизируем: ${request.method} ${request.url}`);
        const response = await fetch(request.url, request.options);
        
        if (response.ok) {
          successIds.push(request.id);
          console.log(`✅ Успешно: ${request.method} ${request.url}`);
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
      } catch (error) {
        console.error(`❌ Ошибка синхронизации: ${request.method} ${request.url}`, error.message);
        errors.push({ request, error: error.message });
      }
    }
    
    // Удаляем успешно синхронизированные запросы
    this.pending = this.pending.filter(req => !successIds.includes(req.id));
    this.savePending();
    
    this.syncInProgress = false;
    
    if (successIds.length > 0) {
      console.log(`✅ Синхронизировано ${successIds.length} запросов`);
      // Можно показать уведомление пользователю
      this.showNotification(`Синхронизировано ${successIds.length} операций`, 'success');
    }
    
    if (errors.length > 0) {
      console.warn(`⚠️ ${errors.length} запросов не удалось синхронизировать`);
      this.showNotification(`Не удалось синхронизировать ${errors.length} операций`, 'warning');
    }
  }
  
  /**
   * Загружает отложенные запросы из localStorage
   */
  loadPending() {
    try {
      const stored = localStorage.getItem('dtj-offline-pending');
      return stored ? JSON.parse(stored) : [];
    } catch (error) {
      console.error('Ошибка загрузки отложенных запросов:', error);
      return [];
    }
  }
  
  /**
   * Сохраняет отложенные запросы в localStorage
   */
  savePending() {
    try {
      localStorage.setItem('dtj-offline-pending', JSON.stringify(this.pending));
    } catch (error) {
      console.error('Ошибка сохранения отложенных запросов:', error);
    }
  }
  
  /**
   * Показывает уведомление пользователю
   */
  showNotification(message, type = 'info') {
    // Можно интегрировать с вашей системой уведомлений
    console.log(`🔔 ${type.toUpperCase()}: ${message}`);
    
    // Простое уведомление
    if (typeof window !== 'undefined' && window.alert) {
      // window.alert(`${type.toUpperCase()}: ${message}`);
    }
  }
  
  /**
   * Возвращает количество отложенных запросов
   */
  getPendingCount() {
    return this.pending.length;
  }
  
  /**
   * Возвращает статус синхронизации
   */
  getSyncStatus() {
    return {
      isOnline: this.isOnline,
      pendingCount: this.pending.length,
      syncInProgress: this.syncInProgress
    };
  }
  
  /**
   * Очищает все отложенные запросы (использовать осторожно!)
   */
  clearPending() {
    this.pending = [];
    this.savePending();
    console.log('🗑️ Все отложенные запросы очищены');
  }
}

// Создаем единственный экземпляр
export const offlineAPI = new OfflineAPI();

// Экспортируем также класс для тестирования
export { OfflineAPI };

