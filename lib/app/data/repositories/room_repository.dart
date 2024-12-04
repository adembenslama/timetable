import 'package:get/get.dart';
import 'package:timetable/app/data/services/api_service.dart';
import 'package:timetable/app/models/models.dart';

class RoomRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Room>> getRooms() async {
    final response = await _apiService.get('/rooms');
    return (response.data as List)
        .map((json) => Room.fromJson(json))
        .toList();
  }

  Future<Room> getRoom(String id) async {
    final response = await _apiService.get('/rooms/$id');
    return Room.fromJson(response.data);
  }

  // Admin only
  Future<Room> createRoom(Room room) async {
    final response = await _apiService.post('/rooms', room.toJson());
    return Room.fromJson(response.data);
  }

  // Admin only
  Future<Room> updateRoom(Room room) async {
    final response = await _apiService.put(
      '/rooms/${room.id}',
      room.toJson(),
    );
    return Room.fromJson(response.data);
  }

  // Admin only
  Future<void> deleteRoom(String id) async {
    await _apiService.delete('/rooms/$id');
  }
} 