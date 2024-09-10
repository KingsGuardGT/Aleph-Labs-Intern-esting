// data/utils/pagination_helper.dart

class PaginationHelper {
  int currentPage;
  int totalPages;
  bool isLastPage;

  PaginationHelper({
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLastPage = false,
  });

  /// Update pagination details based on the API response
  void updatePagination(int totalResults, int pageSize) {
    totalPages = (totalResults / pageSize).ceil();
    isLastPage = currentPage >= totalPages;
  }

  /// Move to the next page if available
  bool loadNextPage() {
    if (!isLastPage) {
      currentPage++;
      return true;
    }
    return false;
  }

  /// Reset pagination when refreshing data
  void resetPagination() {
    currentPage = 1;
    totalPages = 1;
    isLastPage = false;
  }
}
