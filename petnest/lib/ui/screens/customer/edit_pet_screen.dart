import 'package:material_ui/material_ui.dart';

import '../../../strings.dart';
import '../../components/petnest_app_bar.dart';
import '../../viewmodels/customer/pets_view_model.dart';
import '../../viewmodels/customer/vets_view_model.dart';
import 'pet_form.dart';

class EditPetScreen extends StatefulWidget {
  const EditPetScreen({super.key, required this.petId});

  final int petId;

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _petsViewModel = PetsViewModel();
  final _vetsViewModel = VetsViewModel();

  @override
  void initState() {
    super.initState();
    _petsViewModel.loadPetDetail(widget.petId);
  }

  @override
  void dispose() {
    _petsViewModel.dispose();
    _vetsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_petsViewModel, _vetsViewModel]),
      builder: (context, _) {
        final pet = _petsViewModel.selectedPet;
        if (pet == null) {
          return Scaffold(
            appBar: PetNestAppBar(
              title: Strings.editPet,
              onBack: () => Navigator.of(context).pop(),
            ),
            body: Center(
              child: _petsViewModel.isLoadingDetail
                  ? const CircularProgressIndicator()
                  : const Text(Strings.unknownPet),
            ),
          );
        }
        return PetForm(
          title: Strings.editPet,
          initial: pet,
          vets: _vetsViewModel.vets,
          requireVet: true,
          // A newly picked photo is not sent: the update endpoint is JSON-only
          onSave:
              ({
                required name,
                required species,
                required birthDate,
                required vet,
                required photo,
              }) => _petsViewModel.updatePet(
                id: widget.petId,
                name: name,
                species: species,
                birthDate: birthDate,
                vetId: vet!.id,
              ),
        );
      },
    );
  }
}
