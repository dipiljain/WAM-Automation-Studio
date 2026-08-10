@isTest
private class WamScoreEngineTest {
  @isTest
  static void weightedScoreComputesExpectedValue() {
    Map<String, Decimal> scores = new Map<String, Decimal>{
      'strategic' => 90,
      'operational' => 80,
      'readiness' => 70
    };
    Map<String, Decimal> weights = new Map<String, Decimal>{
      'strategic' => 0.5,
      'operational' => 0.3,
      'readiness' => 0.2
    };

    Decimal result = WamScoreEngine.weightedScore(scores, weights);
    System.assertEquals(
      83,
      result,
      'Weighted score should align to weighted average.'
    );
  }

  @isTest
  static void priorityBandsAndClampWork() {
    System.assertEquals('High', WamScoreEngine.toPriority(90));
    System.assertEquals('Medium', WamScoreEngine.toPriority(70));
    System.assertEquals('Low', WamScoreEngine.toPriority(20));
    System.assertEquals(0, WamScoreEngine.clamp(-2, 0, 100));
    System.assertEquals(100, WamScoreEngine.clamp(120, 0, 100));
    System.assertEquals(55, WamScoreEngine.clamp(55, 0, 100));
  }
}
