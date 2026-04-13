class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const authLogin = '/api/v1/auth/login';

  // Customers
  static const customers = '/api/v1/customers';
  static String customerById(String id) => '$customers/$id';
  static String searchCustomers(String name) =>
      '$customers/search?name=${Uri.encodeQueryComponent(name)}';

  // Materials
  static const materials = '/api/v1/materials';
  static String materialsByCategory(String category) =>
      '$materials/category/$category';
  static String materialsByComponentKey(String componentKey) =>
      '$materials/component/$componentKey';
  static String searchMaterials(String brandName) =>
      '$materials/search?brandName=${Uri.encodeQueryComponent(brandName)}';
  static const materialCategories = '$materials/categories';
  static String materialById(String id) => '$materials/$id';

  // Costings
  static const costings = '/api/v1/costings';
  static String costingById(String id) => '$costings/$id';

  // Quotations
  static const quotations = '/api/v1/quotations';
  static String quotationById(String id) => '$quotations/$id';
  static String quotationsByStatus(String status) => '$quotations/status/$status';
  static String submitQuotation(String id) => '$quotations/$id/submit';
  static String approveQuotation(String id, String? approvalNotes) {
    final query = approvalNotes == null || approvalNotes.isEmpty
        ? ''
        : '?approvalNotes=${Uri.encodeQueryComponent(approvalNotes)}';
    return '$quotations/$id/approve$query';
  }

  static String rejectQuotation(String id, String rejectionReason) =>
      '$quotations/$id/reject?rejectionReason=${Uri.encodeQueryComponent(rejectionReason)}';
  static String cancelQuotation(String id) => '$quotations/$id/cancel';
  static String quotationDocument(String id) => '$quotations/$id/document';
}
