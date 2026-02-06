enum UserRole {
  technician('فني', 'technician'),
  trader('تاجر', 'trader'),
  distributor('موزع', 'distributor'),
  admin('مدير', 'admin');

  final String displayName;
  final String value;

  const UserRole(this.displayName, this.value);
}