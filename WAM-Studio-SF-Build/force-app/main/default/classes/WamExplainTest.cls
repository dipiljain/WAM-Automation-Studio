@isTest
private class WamExplainTest {
  @isTest
  static void healthDriversListsPresentSignals() {
    String txt = WamExplain.healthDrivers(35, 40, 2, 1, 5);
    System.assert(txt.contains('Critical'), 'critical band expected: ' + txt);
    System.assert(
      txt.contains('critical/high portfolio alert'),
      'alert driver expected: ' + txt
    );
    System.assert(
      txt.contains('open compliance finding'),
      'finding driver expected: ' + txt
    );
    System.assert(
      txt.contains('low engagement'),
      'engagement driver expected: ' + txt
    );
    System.assert(
      txt.contains('unactioned recommendations'),
      'recs driver expected: ' + txt
    );
  }

  @isTest
  static void healthDriversSingularPhrasingAndAtRiskBand() {
    // engagement 80 (>=60 so not a driver), 1 alert, 0 findings, 0 recs
    String singular = WamExplain.healthDrivers(50, 80, 0, 1, 0);
    System.assert(
      singular.contains('1 critical/high portfolio alert'),
      'singular alert phrasing: ' + singular
    );
    System.assert(
      !singular.contains('portfolio alerts'),
      'should not pluralize a single alert: ' + singular
    );
    System.assert(
      singular.contains('At risk'),
      'at-risk band expected: ' + singular
    );
  }

  @isTest
  static void healthDriversCleanPosture() {
    String txt = WamExplain.healthDrivers(88);
    System.assert(txt.contains('Healthy'), 'healthy band expected: ' + txt);
    System.assert(
      txt.contains('No adverse signals'),
      'clean posture message expected: ' + txt
    );
  }

  @isTest
  static void healthDriversWatchBand() {
    String txt = WamExplain.healthDrivers(72, 90, 0, 0, 0);
    System.assert(txt.contains('Watch'), 'watch band expected: ' + txt);
  }

  @isTest
  static void portfolioAlertReasonVariants() {
    System.assert(
      WamExplain.portfolioAlertReason('Drift', 'Critical', 45)
        .contains('drifted'),
      'drift reason expected'
    );
    System.assert(
      WamExplain.portfolioAlertReason('Risk', 'High', null)
        .contains('risk-exposure'),
      'risk reason expected'
    );
    System.assert(
      String.isNotBlank(WamExplain.portfolioAlertReason(null, null, null)),
      'null-safe reason expected'
    );
  }

  @isTest
  static void complianceFindingReasonVariants() {
    System.assert(
      WamExplain.complianceFindingReason('KYC', 'Open').contains('verification'),
      'kyc reason expected'
    );
    System.assert(
      WamExplain.complianceFindingReason('AML', 'Open')
        .contains('anti-money-laundering'),
      'aml reason expected'
    );
    System.assert(
      WamExplain.complianceFindingReason('Surveillance', 'Escalated')
        .contains('Escalated'),
      'escalated note expected'
    );
    System.assert(
      WamExplain.complianceFindingReason('Other', 'Cleared').contains('Cleared'),
      'cleared note expected'
    );
    System.assert(
      String.isNotBlank(WamExplain.complianceFindingReason(null, null)),
      'null-safe reason expected'
    );
  }
}
