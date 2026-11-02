import 'package:flutter/foundation.dart';

import '../../../network/pet.dart';
import '../../../network/petnest_api.dart';
import '../../../network/user_session.dart';
import '../../../strings.dart';
import '../view_model.dart';

class PetsUiState {
  const PetsUiState({this.pets = const [], this.isLoading = false, this.error});

  final List<Pet> pets;
  final bool isLoading;
  final String? error;
}

class PetsViewModel extends ViewModel {
  PetsUiState _uiState = const PetsUiState();
  PetsUiState get uiState => _uiState;

  PetDetail? _selectedPet;
  PetDetail? get selectedPet => _selectedPet;

  Future<void> refresh() async {
    final customerId = UserSession.id;
    if (customerId == null) {
      _uiState = PetsUiState(pets: _uiState.pets);
      notify();
      return;
    }

    _uiState = PetsUiState(pets: _uiState.pets, isLoading: true);
    notify();

    try {
      final pets = await PetNestApi.instance.getPets(customerId);
      _uiState = PetsUiState(pets: pets);
    } on HttpStatusException {
      _uiState = PetsUiState(pets: _uiState.pets, error: Strings.serverError);
    } catch (e) {
      _uiState = PetsUiState(pets: _uiState.pets, error: '$e');
    }
    notify();
  }

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  Future<void> loadPetDetail(int id) async {
    _isLoadingDetail = true;
    notify();
    try {
      // The full pet (birth date, vet) comes with the medical record
      _selectedPet = (await PetNestApi.instance.getMedicalRecord(id))?.pet;
      // A pet without a record yet: fall back to the basics from the list
      final customerId = UserSession.id;
      if (_selectedPet == null && customerId != null) {
        final pets = await PetNestApi.instance.getPets(customerId);
        final pet = pets.where((p) => p.id == id).firstOrNull;
        if (pet != null) {
          _selectedPet = PetDetail(
            id: pet.id,
            name: pet.name,
            species: pet.species,
            photoUrl: pet.photoUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('DETAIL: error loading pet: $e');
      _selectedPet = null;
    }
    _isLoadingDetail = false;
    notify();
  }

  Future<bool> savePet({
    required String name,
    required String species,
    required String birthDate,
    required int vetId,
    PickedUpload? photo,
  }) async {
    final customerId = UserSession.id;
    if (customerId == null) {
      debugPrint('SAVE: no customer id in session');
      return false;
    }

    try {
      final response = await PetNestApi.instance.createPet(
        name: name,
        species: species,
        birthDate: birthDate,
        customerId: customerId,
        vetId: vetId,
        photo: photo,
      );
      if (response.isSuccessful) {
        await refresh();
        return true;
      }
      debugPrint('SAVE: server error: ${response.message}');
    } catch (e) {
      debugPrint('SAVE: network error: $e');
    }
    return false;
  }

  // The API's PUT endpoint takes JSON only, so a newly chosen photo is not
  // uploaded on update (same as the Compose app).
  Future<bool> updatePet({
    required int id,
    required String name,
    required String species,
    required String birthDate,
    required int vetId,
  }) async {
    final customerId = UserSession.id;
    if (customerId == null) return false;

    final request = PetUpdateRequest(
      id: id,
      name: name,
      species: species,
      birthDate: birthDate,
      customerId: customerId,
      vetId: vetId,
    );

    try {
      final response = await PetNestApi.instance.updatePet(request);
      if (response.isSuccessful && response.status == 200) {
        await refresh();
        return true;
      }
      debugPrint('UPDATE: error: ${response.message}');
    } catch (e) {
      debugPrint('UPDATE: network error: $e');
    }
    return false;
  }
}
