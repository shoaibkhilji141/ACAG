/// Construction stages for Module 04 — Construction Tracking.
class ConstructionStages {
  ConstructionStages._();

  static const stages = <String>[
    'Site Preparation / Layout Marking',
    'Excavation Completed',
    'Foundation Completed',
    'Foundation Backfilling Completed',
    'Damp Proof Course (DPC) Completed',
    'Plinth Filling & Compaction Completed',
    'Wall Masonry up to Lintel Level Completed',
    'Lintel Completed',
    'Roof Slab (RCC) Cast Completed',
    'Plastering Completed',
    'Flooring Completed',
    'Doors & Windows Installed',
    'Electrical & Plumbing Completed',
    'Paint & Finishing Completed',
    'House Construction Completed',
  ];

  static String nameFor(int stageNo) {
    final index = stageNo - 1;
    if (index < 0 || index >= stages.length) return 'Stage $stageNo';
    return stages[index];
  }

  static int get total => stages.length;
}
