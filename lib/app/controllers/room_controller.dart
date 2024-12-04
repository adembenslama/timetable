import 'package:get/get.dart';
import 'package:timetable/app/models/models.dart';
import 'package:timetable/app/data/repositories/room_repository.dart';

class RoomController extends GetxController {
  final _rooms = <Room>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = RxnString();
  
  final RoomRepository _repository = Get.find<RoomRepository>();

  // Getters
  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      print('Fetching rooms...');
      final response = await _repository.getRooms();
      print('Response: $response');
      _rooms.value = response;
      print('Rooms loaded: ${_rooms.length}');
    } catch (e) {
      print('Error fetching rooms: $e');
      _errorMessage.value = 'Failed to fetch rooms: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addRoom(Room room) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.createRoom(room);
      await fetchRooms();
    } catch (e) {
      _errorMessage.value = 'Failed to add room: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateRoom(Room room) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.updateRoom(room);
      await fetchRooms();
    } catch (e) {
      _errorMessage.value = 'Failed to update room: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      await _repository.deleteRoom(roomId);
      await fetchRooms();
    } catch (e) {
      _errorMessage.value = 'Failed to delete room: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
} 