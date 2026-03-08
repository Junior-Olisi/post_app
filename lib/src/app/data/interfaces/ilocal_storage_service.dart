abstract interface class IlocalStorageService<T> {
  Future<void> saveData(int key, T data);
  Future<T?> getData(int key);
  Future<List<T>> getAllData();
  Future<T?> updateData(int key, T data);
  Future<void> deleteData(int key);
}
