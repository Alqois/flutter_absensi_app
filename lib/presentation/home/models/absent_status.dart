class AbsentStatus {
  final bool IsCheckedin;
  final bool IsCheckedout;

  final String? companyTimeIn;
  final String? companyTimeOut;
  final String? attendanceTimeIn;
  final String? attendanceTimeOut;

  AbsentStatus({
    required this.IsCheckedin,
    required this.IsCheckedout,
    this.companyTimeIn,
    this.companyTimeOut,
    this.attendanceTimeIn,
    this.attendanceTimeOut,
  });
}
