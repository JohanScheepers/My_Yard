/// Represents a successful ping result.
class PingResult {
  /// The IP address that responded.
  final String ip;

  /// The latency of the ping response.
  final Duration latency;

  PingResult({required this.ip, required this.latency});
}
