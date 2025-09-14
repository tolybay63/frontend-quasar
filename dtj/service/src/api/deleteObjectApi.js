import axios from 'axios';

const deleteObject = async (objectId) => {
  try {
    const response = await axios.post(import.meta.env.VITE_OBJECT_URL + '/', {
      method: 'data/deleteObjWithProperties',
      params: [objectId],
    });

    return response.data;
  } catch (error) {
    console.error('Ошибка при удалении объекта:', error);
    throw error;
  }
};

export { deleteObject };
