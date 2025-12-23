class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final int perPage;
  final int total;
  final int lastPage;

  PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
