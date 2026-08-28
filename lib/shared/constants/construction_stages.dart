/// Construction stages for Module 04 — Construction Tracking.
class ConstructionStages {
  ConstructionStages._();

  static const stages = <String>[
    'Foundation & Plinth',
    'Structure (Columns & Beams)',
    'Brickwork & Plaster',
    'Roof Slab & Waterproofing',
    'Electrical & Plumbing',
    'Finishing & Paint',
    'Final Inspection & Handover',
  ];

  static String nameFor(int stageNo) {
    final index = stageNo - 1;
    if (index < 0 || index >= stages.length) return 'Stage $stageNo';
    return stages[index];
  }

  static int get total => stages.length;
}
