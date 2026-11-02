import 'package:flutter/foundation.dart';

import '../../../data/models/pet.dart';
import '../../../data/petnest_repository.dart';
import '../../../data/user_session.dart';
import '../view_model.dart';

class PetsUiState {
  const PetsUiState({this.pets = const [], this.isLoading = false, this.error});

  final List<Pet> pets;
  final bool isLoading;
  final String? error;
}

class PetsViewModel extends ViewModel {
  PetsViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  PetsUiState _uiState = const PetsUiState();
  PetsUiState get uiState => _uiState;

  Pet? _selectedPet;
  Pet? get selectedPet => _selectedPet;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  Future<void> refresh() async {
    final ownerId = UserSession.uid;
    if (ownerId == null) return;

    _uiState = PetsUiState(pets: _uiState.pets, isLoading: true);
    notify();
    try {
      _uiState = PetsUiState(pets: await _repository.getPetsForOwner(ownerId));
    } catch (e) {
      _uiState = PetsUiState(pets: _uiState.pets, error: describeError(e));
    }
    notify();
  }

  Future<void> loadPetDetail(String id) async {
    _isLoadingDetail = true;
    notify();
    try {
      _selectedPet = await _repository.getPet(id);
    } catch (e) {
      debugPrint('DETAIL: ${describeError(e)}');
      _selectedPet = null;
    }
    _isLoadingDetail = false;
    notify();
  }

  Future<bool> savePet({
    required String name,
    required String species,
    required String birthDate,
    String? vetId,
    PickedUpload? photo,
  }) async {
    final ownerId = UserSession.uid;
    if (ownerId == null) return false;

    try {
      await _repository.createPet(
        ownerId: ownerId,
        name: name,
        species: species,
        birthDate: birthDate.isEmpty ? null : birthDate,
        vetId: vetId,
        photo: photo,
      );
      return true;
    } catch (e) {
      debugPrint('SAVE: ${describeError(e)}');
      return false;
    }
  }

  Future<bool> updatePet(Pet pet, {PickedUpload? photo}) async {
    try {
      await _repository.updatePet(pet, photo: photo);
      return true;
    } catch (e) {
      debugPrint('UPDATE: ${describeError(e)}');
      return false;
    }
  }
}
