import axios from "axios";
import { offlineAPI } from '@/utils/offlineApi.js';

const API_BASE_URL = import.meta.env.VITE_PLAN_URL;

export async function loadWorkPlan(date = "2025-07-30", periodType = 11) {
  const objLocation = localStorage.getItem("objLocation");

  if (!objLocation) {
    throw new Error("objLocation не найден в localStorage");
  }

  console.log('Вызов метода data/loadPlan', {
    date,
    periodType,
    objLocation: parseInt(objLocation)
  });

  const requestData = {
    method: "data/loadPlan",
    params: [
      {
        date,
        periodType,
        objLocation: parseInt(objLocation),
      }
    ]
  };

  try {
    const response = await offlineAPI.request(API_BASE_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify(requestData)
    });

    const data = await response.json();
    return data.result?.records || [];
  } catch (error) {
    console.error('Ошибка загрузки плана работ:', error);
    throw error;
  }
}
