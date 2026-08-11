/**
 * Builds grounded, human-readable "why" text for scored records
 * (client health scores, portfolio alerts, compliance findings).
 *
 * All text is derived deterministically from values known at record
 * creation/refresh time — no facts are invented. Callers that have the
 * underlying signals (engagement, open findings, alerts, unactioned
 * recommendations) should pass them so the driver text is specific; callers
 * that only have the score fall back to a band-based statement.
 */
public with sharing class WamExplain {
  /**
   * Health-score drivers built from the real component signals used by
   * WealthAIAdvisorUseCaseService.refreshScores.
   */
  public static String healthDrivers(
    Decimal score,
    Decimal engagementScore,
    Integer openFindings,
    Integer criticalAlerts,
    Integer newRecommendations
  ) {
    List<String> parts = new List<String>();
    if (criticalAlerts != null && criticalAlerts > 0) {
      parts.add(
        criticalAlerts +
          ' critical/high portfolio alert' +
          (criticalAlerts == 1 ? '' : 's')
      );
    }
    if (openFindings != null && openFindings > 0) {
      parts.add(
        openFindings +
          ' open compliance finding' +
          (openFindings == 1 ? '' : 's')
      );
    }
    if (engagementScore != null && engagementScore < 60) {
      parts.add('low engagement (score ' + fmt(engagementScore) + ')');
    }
    if (newRecommendations != null && newRecommendations > 3) {
      parts.add(newRecommendations + ' unactioned recommendations');
    }
    String band = band(score);
    if (parts.isEmpty()) {
      return band +
        ' (health score ' +
        fmt(score) +
        '). No adverse signals detected — the score reflects steady engagement and a clean compliance and portfolio posture.';
    }
    return band +
      ' (health score ' +
      fmt(score) +
      '), driven by ' +
      joinHuman(parts) +
      '.';
  }

  /** Band-only fallback for callers that only know the score (e.g. seeds). */
  public static String healthDrivers(Decimal score) {
    return healthDrivers(score, null, null, null, null);
  }

  /** Why a portfolio alert was raised. */
  public static String portfolioAlertReason(
    String alertType,
    String severity,
    Decimal healthScore
  ) {
    String type = String.isBlank(alertType) ? 'Portfolio' : alertType;
    String sev = String.isBlank(severity) ? 'Medium' : severity;
    String base =
      sev +
      '-severity ' +
      type.toLowerCase() +
      ' alert';
    if (type.equalsIgnoreCase('Drift')) {
      base += ': allocation has drifted beyond the model tolerance band';
    } else if (type.equalsIgnoreCase('Risk')) {
      base += ': a risk-exposure limit was exceeded on current holdings';
    } else {
      base += ': a monitored portfolio threshold was crossed';
    }
    if (healthScore != null) {
      base += ' (client health ' + fmt(healthScore) + ')';
    }
    return base + '.';
  }

  /** Why a compliance finding was raised. */
  public static String complianceFindingReason(
    String findingType,
    String status
  ) {
    String type = String.isBlank(findingType) ? 'Compliance' : findingType;
    String st = String.isBlank(status) ? 'Open' : status;
    String cause;
    if (type.equalsIgnoreCase('KYC') || type.equalsIgnoreCase('KYB')) {
      cause = 'identity/verification documentation is incomplete or past its review date';
    } else if (type.equalsIgnoreCase('AML')) {
      cause = 'a transaction pattern matched an anti-money-laundering screening rule';
    } else if (type.equalsIgnoreCase('Surveillance')) {
      cause = 'communications or trade activity matched a surveillance policy signal';
    } else {
      cause = 'account activity breached a monitored compliance policy';
    }
    String statusNote;
    if (st.equalsIgnoreCase('Escalated')) {
      statusNote = ' Escalated: remains open until compliance signs off on remediation.';
    } else if (st.equalsIgnoreCase('Cleared')) {
      statusNote = ' Cleared: reviewed with no further action required.';
    } else if (st.equalsIgnoreCase('Under Review')) {
      statusNote = ' Under review by a compliance analyst.';
    } else {
      statusNote = ' Auto-flagged when opened; unresolved past the policy SLA.';
    }
    return type + ' finding: ' + cause + '.' + statusNote;
  }

  private static String band(Decimal score) {
    Decimal s = score == null ? 0 : score;
    if (s < 40) {
      return 'Critical — well below the 60-point healthy threshold';
    }
    if (s < 60) {
      return 'At risk — below the 60-point healthy threshold';
    }
    if (s < 75) {
      return 'Watch — near the healthy threshold';
    }
    return 'Healthy';
  }

  private static String fmt(Decimal value) {
    return value == null ? '—' : String.valueOf(value.setScale(0));
  }

  private static String joinHuman(List<String> parts) {
    if (parts.isEmpty()) {
      return '';
    }
    if (parts.size() == 1) {
      return parts[0];
    }
    if (parts.size() == 2) {
      return parts[0] + ' and ' + parts[1];
    }
    List<String> head = new List<String>();
    for (Integer i = 0; i < parts.size() - 1; i++) {
      head.add(parts[i]);
    }
    return String.join(head, ', ') + ', and ' + parts[parts.size() - 1];
  }
}
