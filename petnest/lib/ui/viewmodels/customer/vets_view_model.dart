import 'package:flutter/foundation.dart';

import '../../../model/simple_item.dart';
import '../../../network/petnest_api.dart';
import '../view_model.dart';

class VetsViewModel extends ViewModel {
  VetsViewModel() {
    _fetchVets();
  }

  List<SimpleItem> _vets = const [];
  List<SimpleItem> get vets => _vets;

  Future<void> _fetchVets() async {
    try {
      final data = await PetNestApi.instance.getVets();
      _vets = [for (final v in data) SimpleItem(id: v.id, name: v.fullName)];
    } catch (e) {
      debugPrint('VETS: API error: $e');
      _vets = const [];
    }
    notify();
  }
}
