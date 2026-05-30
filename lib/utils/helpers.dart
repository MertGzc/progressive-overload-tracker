// Hafta numarası hesaplama
String getWeekNumber(String dateString) {
  try {
    final parts = dateString.split('.');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]) - 1;
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      final startOfYear = DateTime(year, 0, 1);
      final pastDaysOfYear = date.difference(startOfYear).inDays;
      final weekNumber = ((pastDaysOfYear + startOfYear.weekday) / 7).ceil();
      return "$year'ın $weekNumber. haftası";
    }
    return '';
  } catch (e) {
    return '';
  }
}

// Hedef bilgisinden set sayısını çıkar (ör: "3x10" -> 3)
int getSetCountFromTarget(String targetReps) {
  if (targetReps.isEmpty) return 3; // Varsayılan 3 set

  final normalized = targetReps.toLowerCase().trim();
  final match = RegExp(r'^\s*(\d+)\s*[x×]\s*(\d+)\s*$').firstMatch(normalized);
  if (match != null) {
    final first = int.tryParse(match.group(1) ?? '3') ?? 3;
    final second = int.tryParse(match.group(2) ?? '3') ?? 3;

    // Eğer kullanıcı ters yazdıysa (örnek: 10x3) ve ikinci sayı mantıklıysa düzelt
    if (first > 10 && second <= 10) {
      return second;
    }
    return first;
  }

  final allNumbers =
      RegExp(r'(\d+)')
          .allMatches(normalized)
          .map((match) => int.tryParse(match.group(0) ?? '') ?? 0)
          .toList();

  if (allNumbers.length >= 2) {
    if (allNumbers[0] > 10 && allNumbers[1] <= 10) {
      return allNumbers[1];
    }
    return allNumbers[0];
  }

  return 3; // Varsayılan 3 set
}

// Ağırlık değerini sayısal olarak parse et
double parseWeight(String weightText) {
  final cleaned = weightText
      .replaceAll(RegExp(r'[^0-9.,-]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return 0.0;
  return double.tryParse(cleaned) ?? 0.0;
}

String normalizeWeight(String weightText) {
  final value = parseWeight(weightText);
  if (value == value.toInt()) {
    return value.toInt().toString();
  }
  return value.toString();
}

// İlerleme hesaplama
Map<String, dynamic>? calculateProgress(
  Map<String, dynamic> currentLog,
  Map<String, dynamic>? previousLog,
) {
  if (previousLog == null) return null;

  final currentWeight = parseWeight(currentLog['weight'] ?? '0');
  final previousWeight = parseWeight(previousLog['weight'] ?? '0');

  final weightDiff = currentWeight - previousWeight;
  final weightImproved = weightDiff > 0;

  final currentSets = List<String>.from(currentLog['sets'] ?? []);
  final previousSets = List<String>.from(previousLog['sets'] ?? []);

  final maxSets =
      currentSets.length > previousSets.length
          ? currentSets.length
          : previousSets.length;

  final setDiffs = <int>[];
  for (int i = 0; i < maxSets; i++) {
    final currentRep = double.tryParse(currentSets[i]) ?? 0;
    final previousRep = double.tryParse(previousSets[i]) ?? 0;
    setDiffs.add((currentRep - previousRep).round());
  }

  final currentTotalReps = currentSets.fold<double>(
    0,
    (sum, rep) => sum + (double.tryParse(rep) ?? 0),
  );
  final previousTotalReps = previousSets.fold<double>(
    0,
    (sum, rep) => sum + (double.tryParse(rep) ?? 0),
  );
  final repsDiff = (currentTotalReps - previousTotalReps).round();

  return {
    'weightDiff': weightDiff,
    'repsDiff': repsDiff,
    'setDiffs': setDiffs,
    'weightImproved': weightImproved,
    'repsImproved': weightImproved || repsDiff > 0,
  };
}
