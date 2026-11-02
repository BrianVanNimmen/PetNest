import '../../../data/models/appointment.dart';
import '../../../data/petnest_repository.dart';
import '../view_model.dart';

class CustomerHomeViewModel extends ViewModel {
  CustomerHomeViewModel({PetNestRepository? repository})
    : _repository = repository ?? PetNestRepository.instance;

  final PetNestRepository _repository;

  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAppointments(String customerId) async {
    _isLoading = true;
    notify();

    try {
      _appointments = await _repository.getCustomerAppointments(
        customerId,
        limit: 5,
      );
    } catch (_) {
      _appointments = const [];
    }
    _isLoading = false;
    notify();
  }
}
