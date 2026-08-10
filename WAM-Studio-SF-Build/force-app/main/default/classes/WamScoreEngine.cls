public with sharing class WamScoreEngine {
  public static Decimal weightedScore(
    Map<String, Decimal> scores,
    Map<String, Decimal> weights
  ) {
    Decimal weightedTotal = 0;
    Decimal weightTotal = 0;
    if (scores == null || weights == null) {
      return 0;
    }

    for (String key : weights.keySet()) {
      Decimal weight = weights.get(key) == null ? 0 : weights.get(key);
      Decimal score = scores.containsKey(key) && scores.get(key) != null
        ? scores.get(key)
        : 0;
      weightedTotal += score * weight;
      weightTotal += weight;
    }

    if (weightTotal == 0) {
      return 0;
    }

    return (weightedTotal / weightTotal).setScale(2);
  }

  public static String toPriority(Decimal score) {
    Decimal s = score == null ? 0 : score;
    if (s >= 85) {
      return 'High';
    }
    if (s >= 65) {
      return 'Medium';
    }
    return 'Low';
  }

  public static Decimal clamp(
    Decimal value,
    Decimal minValue,
    Decimal maxValue
  ) {
    Decimal v = value == null ? 0 : value;
    Decimal minV = minValue == null ? 0 : minValue;
    Decimal maxV = maxValue == null ? 100 : maxValue;
    if (v < minV) {
      return minV;
    }
    if (v > maxV) {
      return maxV;
    }
    return v;
  }
}
