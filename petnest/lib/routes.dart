/// Route paths (the Compose app's NavHost routes).
abstract final class Routes {
  static const login = '/login';
  static const register = '/register';
  static const registerVet = '/register/vet';
  static const registerCustomer = '/register/customer';
  static const accessibility = '/accessibility';

  // Registration for a Google account that has no PetNest profile yet
  static const completeProfile = '/complete-profile';
  static const completeProfileVet = '/complete-profile/vet';
  static const completeProfileCustomer = '/complete-profile/customer';

  static const customerHome = '/customer/home';
  static const customerPets = '/customer/pets';
  static const newPet = '/customer/pets/new';
  static String editPet(String petId) => '/customer/pets/$petId/edit';
  static String medicalRecord(String petId) => '/customer/pets/$petId/record';
  static const customerAppointments = '/customer/appointments';
  static const newAppointment = '/customer/appointments/new';

  static const vetHome = '/vet/home';
  static const vetPatients = '/vet/patients';
  static String vetPatient(String patientId) => '/vet/patients/$patientId';
  static String vetMedicalRecord(String patientId) =>
      '/vet/patients/$patientId/record';
  static const vetConsultations = '/vet/consultations';
}
