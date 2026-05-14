double calculateRunwayGoalProgress({
  required double runwayMonths,
  required int targetMonths,
}) {
  if (runwayMonths >= 9999) return 1.0;
  if (targetMonths <= 0) return 0.0;

  return (runwayMonths / targetMonths).clamp(0.0, 1.0);
}

int calculateRunwayGoalProgressPercent({
  required double runwayMonths,
  required int targetMonths,
}) {
  return (calculateRunwayGoalProgress(
            runwayMonths: runwayMonths,
            targetMonths: targetMonths,
          ) *
          100)
      .round();
}
