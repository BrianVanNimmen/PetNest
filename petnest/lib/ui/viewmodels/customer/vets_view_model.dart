import 'package:flutter/foundation.dart';

import '../../../data/petnest_repository.dart';
import '../../../model/simple_item.dart';
import '../view_model.dart';

/// The approved vets a customer can choose from.
class VetsViewModel extends ViewModel {
  VetsViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance {
    _fetchVets();
  }

  final PetNestRepository _repository;

  List<SimpleItem> _vets = const [];
  List<SimpleItem> get vets => _vets;

  Future<void> _fetchVets() async {
    try {
      final vets = await _repository.getApprovedVets();
      _vets = [for (final v in vets) SimpleItem(id: v.id, name: v.fullName)];
    } catch (e) {
      debugPrint('VETS: ${describeError(e)}');
      _vets = const [];
    }
    notify();
  }
}
