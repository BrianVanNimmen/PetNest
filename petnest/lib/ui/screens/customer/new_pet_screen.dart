import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../viewmodels/customer/pets_view_model.dart';
import '../../viewmodels/customer/vets_view_model.dart';
import 'pet_form.dart';

class NewPetScreen extends StatefulWidget {
  const NewPetScreen({super.key});

  @override
  State<NewPetScreen> createState() => _NewPetScreenState();
}

class _NewPetScreenState extends State<NewPetScreen> {
  final _petsViewModel = PetsViewModel();
  final _vetsViewModel = VetsViewModel();

  @override
  void dispose() {
    _petsViewModel.dispose();
    _vetsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vetsViewModel,
      builder: (context, _) => PetForm(
        title: Strings.newPet,
        vets: _vetsViewModel.vets,
        onSave:
            ({
              required name,
              required species,
              required birthDate,
              required vet,
              required photo,
            }) => _petsViewModel.savePet(
              name: name,
              species: species,
              birthDate: birthDate,
              vetId: vet?.id ?? 0,
              photo: photo,
            ),
      ),
    );
  }
}
