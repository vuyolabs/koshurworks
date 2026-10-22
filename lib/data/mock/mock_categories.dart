import 'package:flutter/material.dart';

import '../models/work_category.dart';

/// Sample trades for the prototype.
abstract final class MockCategories {
  static const mason = WorkCategory(
    id: 'mason',
    name: 'Mason',
    icon: Icons.foundation,
    workerNoun: 'masons',
    suggestedSkills: ['Brickwork', 'Stone masonry', 'Plastering', 'RCC work', 'Tiling'],
  );
  static const carpenter = WorkCategory(
    id: 'carpenter',
    name: 'Carpenter',
    icon: Icons.carpenter,
    workerNoun: 'carpenters',
    suggestedSkills: [
      'Khatamband ceilings',
      'Cabinets',
      'Doors & windows',
      'Furniture repair',
      'Walnut wood',
    ],
  );
  static const electrician = WorkCategory(
    id: 'electrician',
    name: 'Electrician',
    icon: Icons.electrical_services,
    workerNoun: 'electricians',
    suggestedSkills: ['House wiring', 'Inverter setup', 'Fault finding', 'Panel boards', 'Lighting'],
  );
  static const plumber = WorkCategory(
    id: 'plumber',
    name: 'Plumber',
    icon: Icons.plumbing,
    workerNoun: 'plumbers',
    suggestedSkills: [
      'Pipe fitting',
      'Geyser installation',
      'Bathroom fitting',
      'Leak repair',
      'Water tanks',
    ],
  );
  static const painter = WorkCategory(
    id: 'painter',
    name: 'Painter',
    icon: Icons.format_paint,
    workerNoun: 'painters',
    suggestedSkills: [
      'Interior painting',
      'Exterior painting',
      'Putty work',
      'Wood polish',
      'Texture finish',
    ],
  );
  static const labourer = WorkCategory(
    id: 'labourer',
    name: 'Labourer',
    icon: Icons.construction,
    workerNoun: 'labourers',
    suggestedSkills: ['Material handling', 'Site cleaning', 'Excavation', 'Concrete mixing', 'Loading'],
  );
  static const contractor = WorkCategory(
    id: 'contractor',
    name: 'Contractor',
    icon: Icons.engineering,
    workerNoun: 'contractors',
    suggestedSkills: ['Full house construction', 'Renovation', 'Team management', 'Estimation', 'Roofing'],
  );

  static const all = <WorkCategory>[mason, carpenter, electrician, plumber, painter, labourer, contractor];
}

/// Districts used across the prototype, from Kashmir and Jammu divisions.
abstract final class MockDistricts {
  static const all = <String>[
    'Srinagar',
    'Budgam',
    'Ganderbal',
    'Baramulla',
    'Anantnag',
    'Pulwama',
    'Kupwara',
    'Jammu',
    'Udhampur',
    'Kathua',
  ];
}
