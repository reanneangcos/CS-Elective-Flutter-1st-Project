import 'package:flutter/material.dart';

import '../data/teams.dart';
import '../models/jersey.dart';
import '../widgets/jersey_art.dart';
import '../widgets/jersey_card.dart' show surname;

/// Bottom sheet used for both adding and editing a jersey.
/// Returns the filled-in [Jersey] or null if cancelled.
Future<Jersey?> showJerseyForm(BuildContext context, {Jersey? initial}) {
  return showModalBottomSheet<Jersey>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _JerseyForm(initial: initial),
  );
}

class _JerseyForm extends StatefulWidget {
  const _JerseyForm({this.initial});
  final Jersey? initial;

  @override
  State<_JerseyForm> createState() => _JerseyFormState();
}

class _JerseyFormState extends State<_JerseyForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _player;
  late final TextEditingController _number;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late String _team;
  late String _edition;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final j = widget.initial;
    _player = TextEditingController(text: j?.playerName ?? '')
      ..addListener(() => setState(() {}));
    _number = TextEditingController(text: j?.number ?? '')
      ..addListener(() => setState(() {}));
    _price = TextEditingController(text: j == null ? '' : j.price.toStringAsFixed(0));
    _stock = TextEditingController(text: j?.stock.toString() ?? '10');
    _team = j != null && nbaTeams.containsKey(j.team) ? j.team : nbaTeams.keys.first;
    _edition = j?.edition ?? 'Icon';
  }

  @override
  void dispose() {
    _player.dispose();
    _number.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  /// Association editions are white with team-colour lettering;
  /// everything else uses the team's main colour.
  (String, String) get _colors {
    final initial = widget.initial;
    if (initial != null &&
        initial.team == _team &&
        initial.edition == _edition) {
      return (initial.primaryColor, initial.secondaryColor);
    }
    final (primary, secondary) = nbaTeams[_team]!;
    return _edition == 'Association' ? ('#FFFFFF', primary) : (primary, secondary);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final (primary, secondary) = _colors;
    Navigator.pop(
      context,
      Jersey(
        id: widget.initial?.id,
        playerName: _player.text.trim(),
        team: _team,
        number: _number.text.trim(),
        edition: _edition,
        price: double.parse(_price.text.trim()),
        stock: int.parse(_stock.text.trim()),
        primaryColor: primary,
        secondaryColor: secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (primary, secondary) = _colors;
    final preview = Jersey(
      playerName: _player.text,
      team: _team,
      number: _number.text.isEmpty ? '00' : _number.text,
      edition: _edition,
      price: 0,
      stock: 0,
      primaryColor: primary,
      secondaryColor: secondary,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editing ? 'Edit jersey' : 'Add jersey',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 130,
                  child: JerseyArt(
                    primary: preview.primary,
                    secondary: preview.secondary,
                    number: preview.number,
                    label: surname(preview.playerName),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _player,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Player name'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _team,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Team'),
                items: [
                  for (final team in nbaTeams.keys)
                    DropdownMenuItem(value: team, child: Text(team)),
                ],
                onChanged: (v) => setState(() => _team = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _edition,
                decoration: const InputDecoration(labelText: 'Edition'),
                items: [
                  for (final e in Jersey.editions)
                    DropdownMenuItem(value: e, child: Text(e)),
                ],
                onChanged: (v) => setState(() => _edition = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _number,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number'),
                      validator: (v) =>
                          RegExp(r'^\d{1,2}$').hasMatch((v ?? '').trim())
                              ? null
                              : '0–99',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '₱ ',
                      ),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        return n == null || n < 0 ? 'Enter a price' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        return n == null || n < 0 ? 'Invalid' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(_editing ? Icons.save_outlined : Icons.add),
                label: Text(_editing ? 'Save changes' : 'Add to shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
