class PaginatedResult<T> {
  final List<T> items;
  final int pageNo;
  final int totalCount;
  final int rawCount;

  const PaginatedResult({
    required this.items,
    required this.pageNo,
    required this.totalCount,
    required this.rawCount,
  });

  bool get isEmpty => items.isEmpty;

  static bool hasMorePages({
    required int fetchedSoFar,
    required int totalCount,
  }) =>
      fetchedSoFar < totalCount;
}
