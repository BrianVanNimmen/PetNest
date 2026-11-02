/// All user-facing text (the Compose app's strings.xml).
abstract final class Strings {
  static const appName = 'PetNest';

  // ===== SHARED =====

  // General / buttons
  static const ok = 'OK';
  static const back = 'Back';
  static const backUppercase = 'BACK';
  static const backToLogin = 'BACK TO LOGIN';
  static const close = 'Close';
  static const closeUppercase = 'CLOSE';
  static const save = 'Save';
  static const saveUppercase = 'SAVE';
  static const cancel = 'Cancel';
  static const add = 'Add';
  static const delete = 'Delete';
  static const edit = 'Edit';
  static const choose = 'Choose';
  static const logout = 'Log out';
  static const home = 'Home';
  static const select = 'Select...';

  // Form fields
  static const name = 'Name';
  static const firstName = 'First name';
  static const lastName = 'Last name';
  static const email = 'Email';
  static const password = 'Password';
  static const repeatPassword = 'Repeat password';
  static const birthDate = 'Date of birth';
  static const municipality = 'Municipality';
  static const phone = 'Phone';
  static const practiceName = 'Practice name';
  static const speciesBreed = 'Species / Breed';
  static const vet = 'Vet';
  static const notes = 'Notes';

  // Placeholders
  static const loginEmailHint = 'hello@gmail.com';
  static const enterYourPassword = 'Enter your password';
  static const dateHint = 'YYYY-MM-DD';
  static const searchMunicipality = 'Search municipality...';
  static const firstNameHint = 'John';
  static const lastNameHint = 'Doe';
  static const emailHint = 'johndoe@email.com';
  static const passwordHint = '******';
  static const phoneHint = '0470 99 99 99';
  static const practiceNameHint = 'Animoo';
  static const noFileChosen = 'No file chosen';

  // Validation
  static const fillInAllFields = 'Please fill in all fields';
  static const enterValidEmail = 'Please enter a valid email';
  static const passwordTooShort = 'Password must be at least 6 characters';
  static const passwordsDoNotMatch = 'Passwords do not match';
  static const uploadCertificate = 'Please upload a certificate';

  // Accessibility
  static const accessibility = 'Accessibility';
  static const petnestLogo = 'PetNest logo';
  static const darkMode = 'Dark mode';
  static const pickDate = 'Pick date';

  // Login
  static const login = 'Log in';
  static const areYouVetOrOwner = 'Are you a vet or a pet owner?';
  static const noAccountYet = 'No account yet?';
  static const createAccount = 'CREATE AN ACCOUNT';

  // Register
  static const register = 'Register';
  static const registerUppercase = 'REGISTER';
  static const chooseAccountType = 'Choose your account type';
  static const registerAsVet = 'VET';
  static const registerAsCustomer = 'CUSTOMER';
  static const customerRegistration = 'Customer registration';
  static const vetRegistration = 'Vet registration';
  static const certificateLabel = 'Certificate * (pdf / png / jpg)';

  // Errors
  static const loginFailed = 'Login failed';
  static const couldNotGetUid = 'Could not retrieve UID';
  static const unknownError = 'Unknown error';
  static const firebaseRegistrationFailed = 'Firebase registration failed';
  static const unknownServerError = 'Unknown server error';
  static const couldNotReadCertificate = 'Could not read certificate';
  static const serverError = 'Server error';
  static const saveFailed = 'Save failed';
  static const invalidSession = 'Invalid session: vet ID not found.';
  static const invalidSessionLoginAgain =
      'Invalid session: vet ID not found. Please log in again.';
  static const invalidRecordId = 'Invalid record ID';
  static String networkError(Object e) => 'Network error: $e';
  static String noServerConnection(Object e) => 'No connection to server: $e';
  static String couldNotLoadMunicipalities(int code) =>
      'Could not load municipalities ($code)';

  // ===== CUSTOMER =====

  // Home
  static const welcome = 'Welcome ';
  static const guest = 'Guest';
  static const myAppointments = 'My appointments';
  static const noScheduledAppointments = 'No scheduled appointments';
  static const viewAllAppointments = 'View all appointments';
  static const myReminders = 'My reminders';
  static const newReminder = 'New reminder';
  static const noReminders = 'No reminders';

  // Navigation
  static const pets = 'Pets';
  static const myPets = 'My pets';
  static const appointments = 'Appointments';

  // Appointments
  static const newAppointment = 'New appointment';
  static const noAppointmentsYet = "You don't have any appointments yet";
  static const cancelAppointment = 'Cancel appointment';
  static const confirmCancel =
      'Are you sure you want to cancel this appointment? This cannot be undone.';
  static const yesCancel = 'Yes, cancel';
  static const saveAppointment = 'Save appointment';
  static const dateLabel = 'Date';
  static const timeLabel = 'Time';
  static const petLabel = 'Pet';
  static const appointmentType = 'Appointment type';
  static const timeSlot = 'Time slot';
  static const appointmentTypeCheckup = 'Check-up';
  static const appointmentTypeVaccination = 'Vaccination';
  static const appointmentTypeSurgery = 'Surgery';
  static const appointmentTypeOther = 'Other';
  static const unknown = 'Unknown';
  static const selectVet = 'Select vet';

  // Pets
  static const newPet = 'New pet';
  static const noPetsYet = "You haven't added any pets yet.";
  static String speciesLabel(String species) => 'Species: $species';
  static const editPet = 'Edit pet';
  static const addPhoto = '+ Photo';
  static const chosenPhoto = 'Chosen photo';
  static const currentPhoto = 'Current photo';
  static const petNameHint = 'e.g. Max';
  static const petBreedHint = 'e.g. Labrador';

  // Medical record (customer)
  static const medicalRecord = 'Medical record';
  static const noRecordFound = 'No record found';
  static const unknownPet = 'Unknown pet';
  static const unknownSpecies = 'Unknown species';
  static String birthDateLabel(String date) => 'Date of birth: $date';
  static const weightKg = 'Weight (kg)';
  static const teethStatus = 'Teeth status';
  static const bonesStatus = 'Bones status';
  static const musclesStatus = 'Muscles status';

  // ===== VET =====

  // Home
  static const welcomeDr = 'Welcome Dr. ';
  static const myConsultationsToday = 'My consultations today';
  static const noConsultationsToday = 'You have no consultations today';
  static const viewAllConsultations = 'View all consultations';

  // Navigation
  static const consultations = 'Consultations';
  static const myPatients = 'My patients';

  // Consultations
  static const noAppointmentsForDay = 'No appointments for this day';

  // Patients
  static const patients = 'Patients';
  static const noActivePatients = 'No active patients';
  static String photoOfPatient(String name) => 'Photo of $name';

  // Patient details
  static const patientDetails = 'Patient details';
  static const speciesBreedLabel = 'Species/Breed: ';
  static const medicalRecordUppercase = 'MEDICAL RECORD';

  // Medical record (vet)
  static const recordSaved = 'Record saved';
  static const weightHint = 'e.g. 5.3';
  static const teethHint = 'e.g. good / fair / poor';
  static const bonesHint = 'e.g. normal / fragile';
  static const musclesHint = 'e.g. strong / weak';
  static const notesHint = 'Additional notes...';
}
